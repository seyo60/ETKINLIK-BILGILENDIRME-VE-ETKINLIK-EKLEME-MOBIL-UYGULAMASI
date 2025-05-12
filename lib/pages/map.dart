import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController mapController = MapController();
  LatLng? _currentPosition;
  late Future<List<Map<String, dynamic>>> activities;

  @override
  void initState() {
    super.initState();
    activities = getDataFunction();
    getUserCurrentLocation(); // Kullanıcı konumunu al
  }

  // Kullanıcı konumunu almak için Geolocator kullanma
  Future<void> getUserCurrentLocation() async {
    // Konum izni isteme
    await Geolocator.requestPermission()
        .then((value) {})
        .onError((error, stackTrace) async {
      await Geolocator.requestPermission();
      print("ERROR: $error");
    });

    // Konumu alma
    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
    });

    print("Kullanıcı Konumu: ${position.latitude}, ${position.longitude}");
  }

  // Firebaseden verileri çekme ve mesafeyi hesaplama
  Future<List<Map<String, dynamic>>> getDataFunction() async {
    var querySnapshot =
        await FirebaseFirestore.instance.collection('activities').get();

    if (querySnapshot.docs.isEmpty) {
      print("Firebase Verisi Boş!");
      return [];
    }

    var activities = querySnapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
    print("Firebase Verisi: $activities");

    if (_currentPosition != null) {
      for (var activity in activities) {
        var coordinate = activity['coordinate'];
        if (coordinate != null && coordinate is GeoPoint) {
          double latitude = coordinate.latitude;
          double longitude = coordinate.longitude;

          activity['distance'] = Geolocator.distanceBetween(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
            latitude,
            longitude,
          );
        } else {
          activity['distance'] = double.infinity; // Geçersiz konum
        }
      }

      // Mesafeye göre sıralama
      activities.sort((a, b) =>
          (a['distance'] as double).compareTo(b['distance'] as double));
    }

    return activities;
  }

  // Google Maps üzerinden yol tarifi almak için URL başlatma
  Future<void> _launchGoogleMaps(double latitude, double longitude) async {
    final String googleMapsUrl =
        'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude&travelmode=driving';

    // URLyi başlatma
    if (await canLaunch(googleMapsUrl)) {
      await launch(googleMapsUrl);
    } else {
      throw 'Google Maps açılmadı!';
    }
  }

  // Etkinliğin detaylarını gösteren fonksiyon
  void _showActivityDetails(BuildContext context, String title,
      String description, double latitude, double longitude) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(description),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Kapat'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _launchGoogleMaps(latitude,
                    longitude); // Google Maps üzerinden yol tarifi alma
              },
              child: const Text('Yol Tarifi'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Harita Sayfası'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: activities,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Veri yok'));
          } else {
            // Firebaseden alınan verileri filtreleme
            var activitiesList = snapshot.data!;
            var markers = <Marker>[];

            // Veriler döngüyle işleniyor ve işaretçi oluşturuluyor.
            for (var activity in activitiesList) {
              var coordinate = activity['coordinate'];
              if (coordinate != null && coordinate is GeoPoint) {
                double latitude = coordinate.latitude;
                double longitude = coordinate.longitude;

                // Her marker için bir GestureDetector ekleme
                markers.add(
                  Marker(
                    point: LatLng(latitude, longitude),
                    width: 40.0,
                    height: 40.0,
                    child: GestureDetector(
                      onTap: () {
                        // Etkinlik bilgilerini pop-up olarak gösterme
                        _showActivityDetails(
                          context,
                          activity['title'] ?? 'Başlık Yok',
                          activity['statement'] ?? 'Açıklama Yok',
                          latitude,
                          longitude,
                        );
                      },
                      child: Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                  ),
                );
              }
            }

            // Kullanıcı konumunu mavi işaretçi ile ekleme
            if (_currentPosition != null) {
              markers.add(
                Marker(
                  point: _currentPosition!,
                  width: 40.0,
                  height: 40.0,
                  child: Icon(
                    Icons.location_on,
                    color: Colors.blue, // Kullanıcıyı gösteren mavi işaretçi
                    size: 40,
                  ),
                ),
              );
            }

            return FlutterMap(
              mapController: mapController,
              options: MapOptions(
                initialCenter:
                    _currentPosition ?? LatLng(0, 0), // Haritanın konumu
                initialZoom: 15,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.app',
                ),
                MarkerLayer(
                  markers: markers,
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
