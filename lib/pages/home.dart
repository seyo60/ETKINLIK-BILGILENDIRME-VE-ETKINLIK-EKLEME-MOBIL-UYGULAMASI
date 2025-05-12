import 'package:flutter/material.dart';
import 'package:donem_projesi/widgets/activity_cardview.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String searchQuery = ''; // Arama sorgusu
  String selectedCategory = 'Tüm Kategoriler'; // Seçili kategori

  final List<String> categories = <String>[
    'Tüm Kategoriler',
    'Spor',
    'Sanat',
    'Eğitim',
    'Müzik'
  ]; // Kategoriler listesi

  void search(String value) {
    setState(() {
      searchQuery = value;
    });
  }

  void filterByCategory(String? value) {
    setState(() {
      selectedCategory = value!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Etkinlikler'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Arama alanı
            TextField(
              onChanged: (value) => search(value),
              decoration: InputDecoration(
                labelText: 'Etkinlik Ara',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 12),
            // Kategori seçim dropdown
            DropdownButton<String>(
              value: selectedCategory,
              icon: const Icon(Icons.arrow_downward),
              elevation: 16,
              style: const TextStyle(color: Colors.deepPurple),
              underline: Container(
                height: 2,
                color: Colors.deepPurpleAccent,
              ),
              onChanged: filterByCategory,
              items: categories.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            // ActivityCardview widgetına arama ve kategori bilgisi gönderiliyor
            Expanded(
              child: ActivityCardview(
                searchQuery: searchQuery,
                selectedCategory: selectedCategory,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
