import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // FirebaseAuth paketini ekledik
import 'package:geolocator/geolocator.dart';

class ActivityCardview extends StatefulWidget {
  final String searchQuery; // Arama sorgusu
  final String selectedCategory; // Seçilen kategori

  const ActivityCardview({
    super.key,
    required this.searchQuery,
    required this.selectedCategory,
  });

  @override
  _ActivityCardviewState createState() => _ActivityCardviewState();
}

class _ActivityCardviewState extends State<ActivityCardview> {
  Position? _userCurrentPosition;
  late Future<List<Map<String, dynamic>>> activities;

  @override
  void initState() {
    super.initState();
    activities = getDataFunction();
    getUserCurrentLocation();
  }

  // Kullanıcı konumunu alma fonksiyonu
  Future<void> getUserCurrentLocation() async {
    await Geolocator.requestPermission()
        .then((value) {})
        .onError((error, stackTrace) async {
      await Geolocator.requestPermission();
      print("ERROR: $error");
    });

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _userCurrentPosition = position;
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

    if (_userCurrentPosition != null) {
      for (var activity in activities) {
        var coordinate = activity['coordinate'];
        if (coordinate != null && coordinate is GeoPoint) {
          double latitude = coordinate.latitude;
          double longitude = coordinate.longitude;

          activity['distance'] = Geolocator.distanceBetween(
            _userCurrentPosition!.latitude,
            _userCurrentPosition!.longitude,
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

  // Etkinliği favorilere ekleyen fonksiyon
  Future<void> addToFavorites(Map<String, dynamic> activity) async {
    var user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        // Kullanıcı IDsine göre favori etkinlikleri Firestorea ekle
        await FirebaseFirestore.instance
            .collection('favorites')
            .doc(user.uid) // Kullanıcı IDsi ile belge oluştur
            .collection('userFavorites')
            .add({
          'title': activity['title'],
          'type': activity['type'],
          'image': activity['image'],
          'time': activity['time'],
          'coordinate': activity['coordinate'],
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Etkinlik favorilerinize eklendi!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Favori ekleyebilmek için giriş yapmalısınız')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: activities,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Hata: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Veri yok'));
        } else {
          var activitiesList = snapshot.data!;
          var filteredActivities = activitiesList.where((activity) {
            final matchesSearchQuery = widget.searchQuery.isEmpty ||
                activity['title']
                    .toString()
                    .toLowerCase()
                    .contains(widget.searchQuery.toLowerCase());
            final matchesCategory =
                widget.selectedCategory == 'Tüm Kategoriler' ||
                    activity['type'] == widget.selectedCategory;

            return matchesSearchQuery && matchesCategory;
          }).toList();

          return ListView.builder(
            itemCount: filteredActivities.length,
            itemBuilder: (context, index) {
              var activity = filteredActivities[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ActivitiesDetail(activity: activity),
                      ),
                    );
                  },
                  child: Card(
                    elevation: 5,
                    color: const Color.fromARGB(223, 219, 52, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.network(
                            activity['image'] ??
                                'https://example.com/default-image.jpg',
                            height: 150,
                            width: MediaQuery.of(context).size.width * 0.4,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  activity['title']?.toString() ?? 'Başlık yok',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  activity['statement']?.toString() ??
                                      'Açıklama yok',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Tarih: ${activity['time']?.toString() ?? 'Tarih yok'}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Etkinlik Türü: ${activity['type']?.toString() ?? 'Tür yok'}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Mesafe: ${(activity['distance']! / 1000).toStringAsFixed(2)} km',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }
}

class ActivitiesDetail extends StatefulWidget {
  final Map<String, dynamic> activity;

  const ActivitiesDetail({Key? key, required this.activity}) : super(key: key);

  @override
  _ActivitiesDetailState createState() => _ActivitiesDetailState();
}

class _ActivitiesDetailState extends State<ActivitiesDetail> {
  final TextEditingController _commentController = TextEditingController();
  late Future<List<Map<String, dynamic>>> comments;

  @override
  void initState() {
    super.initState();
    comments = fetchComments();
  }

  // Yorumları Firestoredan çekme
  Future<List<Map<String, dynamic>>> fetchComments() async {
    try {
      // Etkinlik IDsine göre yorumları filtrele
      var querySnapshot = await FirebaseFirestore.instance
          .collection('comments')
          .where('activityId', isEqualTo: widget.activity['id'] ?? '')
          .get();

      if (querySnapshot.docs.isEmpty) {
        return [];
      }

      return querySnapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        return {
          'name': data['name'] ?? 'Bilinmeyen Kullanıcı',
          'comment': data['comment'] ?? 'Yorum mevcut değil',
          'time': data['time'] ?? FieldValue.serverTimestamp(),
        };
      }).toList();
    } catch (e) {
      print("Yorumları çekerken hata oluştu: $e");
      return [];
    }
  }

  // Yorum ekleme fonksiyonu
  Future<void> addComment() async {
    var user = FirebaseAuth.instance.currentUser;
    String commentText = _commentController.text.trim();
    if (user != null && commentText.isNotEmpty) {
      try {
        // Yorum verilerini Firestorea ekle
        await FirebaseFirestore.instance.collection('comments').add({
          'activityId': widget.activity['id'] ?? '',
          'name': user.displayName ?? 'Bilinmeyen Kullanıcı',
          'comment': commentText,
          'time': FieldValue.serverTimestamp(),
        });

        // Yorum ekledikten sonra tekrar yorumları getir
        setState(() {
          comments = fetchComments();
        });

        _commentController.clear();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Yorum eklerken hata oluştu: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Yorum alanı boş olamaz')),
      );
    }
  }

// Katılımcı ekleme fonksiyonu
  Future<void> addParticipant(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        //Katılımcının zaten etkinliğe katılıp katılmadığını kontrol et
        final querySnapshot = await FirebaseFirestore.instance
            .collection('participants')
            .where('userId', isEqualTo: user.uid)
            .where('activityId', isEqualTo: widget.activity['id'])
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          // Eğer kullanıcı zaten katılmışsa
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Bu etkinliğe zaten katıldınız!')),
          );
          return;
        }

        // Katılımcıyı participants koleksiyonuna ekle
        await FirebaseFirestore.instance.collection('participants').add({
          'userId': user.uid,
          'activityId': widget.activity['id'],
          'name': user.displayName ?? 'Bilinmeyen Kullanıcı',
          'email': user.email ?? 'Bilinmeyen Email',
          'title': widget.activity['title'] ?? 'Başlık yok',
          'type': widget.activity['type'] ?? 'Tür yok',
          'joinedAt': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Etkinliğe başarıyla katıldınız!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Katılma sırasında bir hata oluştu: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Etkinliğe katılabilmek için giriş yapmalısınız!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text(widget.activity['title'] ?? 'Etkinlik Detayı')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(widget.activity['image'] ??
                'https://example.com/default-image.jpg'),
            SizedBox(height: 20),
            Text(
              widget.activity['title'] ?? 'Başlık yok',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              widget.activity['statement_detail'] ?? 'Detay yok',
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Tarih: ${widget.activity['time'] ?? 'Tarih yok'}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'Etkinlik Türü: ${widget.activity['type'] ?? 'Tür yok'}',
              style: TextStyle(fontSize: 18),
            ),

            SizedBox(height: 20),

            ElevatedButton(
              onPressed: () => addParticipant(context),
              child: Text('Etkinliğe Katıl'),
            ),
            SizedBox(height: 20),
            // Yorum ekleme alanı
            TextField(
              controller: _commentController,
              decoration: InputDecoration(
                labelText: 'Yorumunuzu yazın',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: addComment,
              child: Text('Yorum Ekle'),
            ),
            const SizedBox(height: 16),

            SizedBox(height: 20),
            // Yorumlar listesi
            Text('Yorumlar', style: TextStyle(fontSize: 20)),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: comments,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Hata: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('Henüz yorum yok'));
                } else {
                  var commentsList = snapshot.data!;
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: commentsList.length,
                    itemBuilder: (context, index) {
                      var comment = commentsList[index];
                      return ListTile(
                        title: Text(comment['name']),
                        subtitle: Text(comment['comment']),
                      );
                    },
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
