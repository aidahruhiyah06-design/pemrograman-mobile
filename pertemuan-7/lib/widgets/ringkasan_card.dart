import 'package:flutter/material.dart';
import '../models/kegiatan.dart';
import '../utils/format.dart';

class RingkasanCard extends StatelessWidget {
  final Ringkasan ringkasan;
  final int target;

  const RingkasanCard({super.key, required this.ringkasan, required this.target});

  @override
  Widget build(BuildContext context) {
    final tabungan = ringkasan.tabungan;
    final progress = (tabungan / target).clamp(0.0, 1.0);
    final isNegatif = tabungan < 0;

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ringkasan Hari Ini', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('Kegiatan: ${ringkasan.selesai}/${ringkasan.jumlahKegiatan} selesai'),
            const SizedBox(height: 4),
            Text('Pemasukan: ${formatRupiah(ringkasan.pemasukan)}'),
            Text('Pengeluaran: ${formatRupiah(ringkasan.pengeluaran)}'),
            const Divider(),
            Text(
              'Tabungan: ${formatRupiah(tabungan)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isNegatif ? Colors.red : Colors.green,
              ),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: progress, minHeight: 10),
            const SizedBox(height: 4),
            Text(isNegatif ? 'Peringatan: Tabungan minus!' : (progress >= 1.0 ? 'Target tercapai! Mantap!' : 'Target: ${formatRupiah(target)}')),
          ],
        ),
      ),
    );
  }
}
