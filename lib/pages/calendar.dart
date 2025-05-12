import 'package:flutter/material.dart';
import 'package:device_calendar/device_calendar.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  final DeviceCalendarPlugin _deviceCalendarPlugin = DeviceCalendarPlugin();
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  List<Calendar> _calendars = [];
  bool _permissionsGranted = false;

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones(); // Zaman dilimlerini yükleme
    _initializeNotifications();
    _retrieveCalendars();
  }

  // Bildirimler için başlatma
  Future<void> _initializeNotifications() async {
    final androidInitialization = AndroidInitializationSettings('app_icon');
    final initializationSettings =
        InitializationSettings(android: androidInitialization);
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // Takvimleri alma
  Future<void> _retrieveCalendars() async {
    var permissionsGranted = await _deviceCalendarPlugin.requestPermissions();
    if (permissionsGranted.isSuccess && permissionsGranted.data!) {
      var calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();
      setState(() {
        _permissionsGranted = true;
        _calendars = calendarsResult?.data ?? [];
      });
    }
  }

  // Etkinlik ekleme ve bildirim gönderme
  Future<void> _addEventToCalendar() async {
    if (!_permissionsGranted) return;

    final calendarId = _calendars.first.id; // İlk takvim seçiliyor.
    final location = tz.getLocation('Europe/Istanbul'); // Bölgeyi belirtin
    final now = DateTime.now();

    final event = Event(
      calendarId,
      title: 'Yeni Etkinlik',
      description: 'Bu bir hatırlatma etkinliğidir.',
      start: tz.TZDateTime.from(now.add(const Duration(minutes: 5)), location),
      end: tz.TZDateTime.from(now.add(const Duration(minutes: 30)), location),
    );

    await _deviceCalendarPlugin.createOrUpdateEvent(event);
    _scheduleNotification(event);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Etkinlik başarıyla eklendi!')),
    );
  }

  // Etkinlik için bildirim zamanlama
  void _scheduleNotification(Event event) async {
    final notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'event_channel_id',
        'Etkinlik Bildirimleri',
        importance: Importance.high,
        priority: Priority.high,
      ),
    );

    final notificationTime = event.start!.subtract(const Duration(minutes: 5));

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Yaklaşan Etkinlik: ${event.title}',
      event.description,
      tz.TZDateTime.from(notificationTime, tz.local),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Takvim')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _permissionsGranted ? _addEventToCalendar : null,
              child: const Text('Etkinlik Ekle ve Hatırlatıcı Ayarla'),
            ),
          ],
        ),
      ),
    );
  }
}
