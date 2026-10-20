import 'package:flutter/material.dart';
import '../data/db_helper.dart';
import '../models/kegiatan.dart';
import '../widgets/ringkasan_card.dart';
import '../widgets/kegiatan_tile.dart';
import 'form_kegiatan_page.dart';

class BerandaPage extends StatefulWidget {
  final int target;
  const BerandaPage({super.key, required this.target});

  @override
  State<BerandaPage> createState() => _BerandaPageState();
}

class _BerandaPageState extends State<BerandaPage> {
  late Future<List<Kegiatan>> _futureKegiatan;
  late Future<Ringkasan> _futureRingkasan;
  final DateTime _hariIni = DateTime.now();

  String get _tglStr => '${_hariIni.year}-${_hariIni.month.toString().padLeft(2, '0')}-${_hariIni.day.toString().padLeft(2, '0')}';

  @override
  void initState() {
    super.initState();
    _muat();
    versiData.addListener(_muat);
  }

  @override
  void dispose() {
    versiData.removeListener(_muat);
    super.dispose();
  }

  void _muat() {
    setState(() {
      _futureKegiatan = DbHelper.pada(_tglStr);
      _futureRingkasan = DbHelper.ringkasan(_tglStr);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          FutureBuilder<Ringkasan>(
            future: _futureRingkasan,
            builder: (context, snap) {
              if (!snap.hasData) return const SizedBox();
              return RingkasanCard(ringkasan: snap.data!, target: widget.target);
            },
          ),
          Expanded(
            child: FutureBuilder<List<Kegiatan>>(
              future: _futureKegiatan,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                final list = snap.data ?? [];
                if (list.isEmpty) return const Center(child: Text('Belum ada kegiatan hari ini.'));
                return ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (context, i) {
                    final k = list[i];
                    return KegiatanTile(
                      kegiatan: k,
                      onToggle: () async {
                        await DbHelper.ubah(Kegiatan(id: k.id, judul: k.judul, tanggal: k.tanggal, selesai: !k.selesai, tipe: k.tipe, nominal: k.nominal, kategori: k.kategori));
                      },
                      onHapus: () async {
                        final ya = await showDialog<bool>(context: context, builder: (_) => AlertDialog(
                          title: const Text('Hapus?'),
                          content: const Text('Yakin hapus kegiatan ini?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
                            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus')),
                          ],
                        ));
                        if (ya == true) await DbHelper.hapus(k.id!);
                      },
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => FormKegiatanPage(kegiatan: k))),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FormKegiatanPage())),
        child: const Icon(Icons.add),
      ),
    );
  }
}
