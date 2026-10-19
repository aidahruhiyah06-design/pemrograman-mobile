import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Praktikum 1',
      home: const KartuPerkenalanPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class KartuPerkenalanPage extends StatelessWidget {
  const KartuPerkenalanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kartu Perkenalan'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ikon / Foto
            const Icon(
              Icons.person,
              size: 100,
              color: Colors.blue,
            ),
            const SizedBox(height: 16),
            
            // Nama
            const Text(
              'Aidah',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            
            // NIM
            const Text(
              'NIM: 20240801142',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            
            // Jurusan
            const Text(
              'Jurusan: Teknik Informatika',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            
            // Hobi
            const Text(
              'Hobi: Membaca',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
