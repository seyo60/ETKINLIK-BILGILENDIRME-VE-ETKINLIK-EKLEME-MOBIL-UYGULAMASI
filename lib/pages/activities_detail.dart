import 'package:flutter/material.dart';

class ActivitiesDetail extends StatelessWidget {
  final Map<String, dynamic> activity;
  const ActivitiesDetail({super.key, required this.activity});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(activity['title']?.toString() ?? 'Etkinlik Detayı'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              activity['imageUrl'] ?? 'https://example.com/default-image.jpg',
              errorBuilder: (context, error, stackTrace) {
                return Image.asset('assets/default-image.jpg');
              },
            ),
            const SizedBox(height: 10),
            Text(
              activity['statement']?.toString() ?? 'Açıklama yok',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text('Tarih: ${activity['time']?.toString() ?? 'Tarih yok'}'),
            const SizedBox(height: 10),
            Text('Tür: ${activity['type']?.toString() ?? 'Tür yok'}'),
          ],
        ),
      ),
    );
  }
}
