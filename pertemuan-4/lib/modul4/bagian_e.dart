import 'package:flutter/material.dart';
import 'bagian_c.dart'; 

class DetailPenggunaPage extends StatelessWidget {
  final Pengguna pengguna;
  const DetailPenggunaPage({super.key, required this.pengguna});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(pengguna.name)),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.email),
            title: Text(pengguna.email),
          ),
          ListTile(
            leading: const Icon(Icons.phone),
            title: Text(pengguna.phone),
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(pengguna.website),
          ),
        ],
      ),
    );
  }
}
