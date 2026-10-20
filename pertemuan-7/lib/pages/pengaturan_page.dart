import 'package:flutter/material.dart';
import '../state/pengaturan.dart';

class PengaturanPage extends StatelessWidget {
  final Pengaturan state;
  const PengaturanPage({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: const Text('Mode Gelap'),
            value: state.gelap,
            onChanged: (v) => state.setGelap(v),
          ),
          const SizedBox(height: 16),
          Text('Target Tabungan Harian: ${state.target}'),
          Slider(
            value: state.target.toDouble(),
            min: 5000,
            max: 100000,
            divisions: 19,
            label: state.target.toString(),
            onChanged: (v) => state.setTarget(v.toInt()),
          ),
          const SizedBox(height: 16),
          const Text('Warna Tema:'),
          Wrap(
            spacing: 8,
            children: [
              Colors.teal, Colors.blue, Colors.purple, Colors.orange, Colors.green
            ].map((c) => GestureDetector(
              onTap: () => state.setWarna(c),
              child: CircleAvatar(backgroundColor: c, child: state.warna == c ? const Icon(Icons.check, color: Colors.white) : null),
            )).toList(),
          ),
        ],
      ),
    );
  }
}
