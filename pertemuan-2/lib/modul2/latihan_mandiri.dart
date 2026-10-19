import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Praktikum 2',
      theme: ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true),
      home: const MenuPage(),
    );
  }
}

// Soal 4: Fungsi buat format ribuan
String formatRibuan(int angka) {
  return angka.toString().replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
        (match) => '${match[1]}.',
      );
}

// Soal 2: Tambah properti deskripsi
class Makanan {
  final String nama;
  final int harga;
  final String deskripsi; // <-- Tambahan soal 2
  const Makanan(this.nama, this.harga, this.deskripsi);
}

// Soal 1: Tambah 3 menu baru
const daftarMenu = [
  Makanan('Nasi Goreng', 15000, 'Nasi goreng spesial'),
  Makanan('Mie Ayam', 12000, 'Mie ayam pangsit'),
  Makanan('Es Teh', 4000, 'Es teh manis'),
  Makanan('Ayam Bakar', 20000, 'Ayam bakar madu'),
  Makanan('Sate Ayam', 18000, 'Sate ayam madura'),      // baru
  Makanan('Bakso Sapi', 13000, 'Bakso urat sapi'),      // baru
  Makanan('Es Jeruk', 5000, 'Es jeruk peras'),          // baru
];

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Menu')),
      body: ListView.builder(
        itemCount: daftarMenu.length,
        itemBuilder: (context, index) {
          final item = daftarMenu[index];
          // Soal 3: Ganti Card dengan Container
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: const Icon(Icons.restaurant),
              title: Text(item.nama),
              // Soal 4: Pakai formatRibuan
              subtitle: Text('Rp ${formatRibuan(item.harga)}'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => DetailPage(makanan: item)),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class DetailPage extends StatelessWidget {
  final Makanan makanan;
  const DetailPage({super.key, required this.makanan});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(makanan.nama)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.restaurant_menu, size: 80),
            const SizedBox(height: 16),
            Text(makanan.nama, style: const TextStyle(fontSize: 24)),
            Text('Rp ${formatRibuan(makanan.harga)}'),
            const SizedBox(height: 8),
            // Soal 2: Tampilkan deskripsi
            Text(makanan.deskripsi),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Kembali'),
            ),
          ],
        ),
      ),
    );
  }
}
