import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const  MaterialApp(
      title: 'Tugas Modul 2',
      home: KontakPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// Model Data
class Kontak {
  final String nama;
  final String telepon;
  final String email;
  const Kontak(this.nama, this.telepon, this.email);
}

// Daftar Kontak (6 data)
const daftarKontak = [
  Kontak('Aidah', '08123456789', 'aidah@email.com'),
  Kontak('Budi', '08234567890', 'budi@email.com'),
  Kontak('Citra', '08345678901', 'citra@email.com'),
  Kontak('Dewi', '08456789012', 'dewi@email.com'),
  Kontak('Eko', '08567890123', 'eko@email.com'),
  Kontak('Fajar', '08678901234', 'fajar@email.com'),
];

// Halaman Utama (Daftar Kontak)
class KontakPage extends StatelessWidget {
  const KontakPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Kontak')),
      body: ListView.builder(
        itemCount: daftarKontak.length,
        itemBuilder: (context, index) {
          final kontak = daftarKontak[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              leading: CircleAvatar(
                child: Text(kontak.nama[0]),
              ),
              title: Text(kontak.nama),
              subtitle: Text(kontak.telepon),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailKontakPage(kontak: kontak),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// Halaman Detail
class DetailKontakPage extends StatelessWidget {
  final Kontak kontak;
  const DetailKontakPage({super.key, required this.kontak});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Kontak')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 40,
                child: Text(
                  kontak.nama[0],
                  style: const TextStyle(fontSize: 30),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Nama: ${kontak.nama}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('Telepon: ${kontak.telepon}',
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('Email: ${kontak.email}',
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Kembali'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
