import 'package:flutter/material.dart';
import '../data/db_helper.dart';
import '../models/kegiatan.dart';
import '../utils/format.dart';

class LaporanPage extends StatefulWidget {
  const LaporanPage({super.key});

  @override
  State<LaporanPage> createState() => _LaporanPageState();
}

class _LaporanPageState extends State<LaporanPage> {
  DateTime _tanggal = DateTime.now();
  late Future<Ringkasan> _futureRingkasan;
  late Future<Map<String, int>> _futureKategori;

  String get _tglStr => '${_tanggal.year}-${_tanggal.month.toString().padLeft(2, '0')}-${_tanggal.day.toString().padLeft(2, '0')}';

  @override
  void initState() {
    super.initState();
    _muat();
  }

  void _muat() {
    setState(() {
      _futureRingkasan = DbHelper.ringkasan(_tglStr);
      _futureKategori = DbHelper.pengeluaranPerKategori(_tglStr);
    });
  }

  Future<void> _pilihTanggal() async {
    final picked = await showDatePicker(context: context, initialDate: _tanggal, firstDate: DateTime(2020), lastDate: DateTime(2030));
    if (picked != null) {
      setState(() => _tanggal = picked);
      _muat();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            title: const Text('Pilih Tanggal'),
            subtitle: Text(formatTanggalIndo(_tglStr)),
            trailing: const Icon(Icons.calendar_month),
            onTap: _pilihTanggal,
          ),
          const Divider(),
          FutureBuilder<Ringkasan>(
            future: _futureRingkasan,
            builder: (context, snap) {
              if (!snap.hasData) return const CircularProgressIndicator();
              final r = snap.data!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Kegiatan: ${r.selesai}/${r.jumlahKegiatan}'),
                  Text('Pemasukan: ${formatRupiah(r.pemasukan)}'),
                  Text('Pengeluaran: ${formatRupiah(r.pengeluaran)}'),
                  Text('Tabungan: ${formatRupiah(r.tabungan)}', style: TextStyle(fontWeight: FontWeight.bold, color: r.tabungan < 0 ? Colors.red : Colors.green)),
                ],
              );
            },
          ),
          const Divider(),
          const Text('Pengeluaran per Kategori:'),
          FutureBuilder<Map<String, int>>(
            future: _futureKategori,
            builder: (context, snap) {
              if (!snap.hasData) return const SizedBox();
              final map = snap.data!;
              if (map.isEmpty) return const Text('Tidak ada pengeluaran.');
              return Column(
                children: map.entries.map((e) => ListTile(title: Text(e.key), trailing: Text(formatRupiah(e.value)))).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
