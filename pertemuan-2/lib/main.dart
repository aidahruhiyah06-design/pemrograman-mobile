import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daftar Kontak',
      theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
      home: const KontakPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// Model data Kontak
class Kontak {
  final String nama;
  final String telepon;
  final String email;
  const Kontak(this.nama, this.telepon, this.email);
}

// Daftar kontak (6 kontak)
const daftarKontak = [
  Kontak('Aidah Ruhiyah', '081234567890', 'aidah@example.com'),
  Kontak('Budi Santoso', '082345678901', 'budi@example.com'),
  Kontak('Citra Dewi', '083456789012', 'citra@example.com'),
  Kontak('Dedi Kurniawan', '084567890123', 'dedi@example.com'),
  Kontak('Eka Putri', '085678901234', 'eka@example.com'),
  Kontak('Fajar Rahman', '086789012345', 'fajar@example.com'),
];

// ============ HALAMAN DAFTAR KONTAK ============
class KontakPage extends StatelessWidget {
  const KontakPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Kontak'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        itemCount: daftarKontak.length,
        itemBuilder: (context, index) {
          final kontak = daftarKontak[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              // Avatar berisi huruf pertama nama
              leading: CircleAvatar(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                child: Text(
                  kontak.nama[0].toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
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

// ============ HALAMAN DETAIL KONTAK ============
class DetailKontakPage extends StatelessWidget {
  final Kontak kontak;
  const DetailKontakPage({super.key, required this.kontak});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Kontak'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar besar
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              child: Text(
                kontak.nama[0].toUpperCase(),
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Nama
            Text(
              kontak.nama,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),

            // Telepon
            Row(
              children: [
                const Icon(Icons.phone, color: Colors.teal),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Telepon',
                        style: TextStyle(color: Colors.grey, fontSize: 12)),
                    Text(kontak.telepon, style: const TextStyle(fontSize: 16)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Email
            Row(
              children: [
                const Icon(Icons.email, color: Colors.teal),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Email',
                        style: TextStyle(color: Colors.grey, fontSize: 12)),
                    Text(kontak.email, style: const TextStyle(fontSize: 16)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 40),

            // Tombol kembali
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Kembali'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 32, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
