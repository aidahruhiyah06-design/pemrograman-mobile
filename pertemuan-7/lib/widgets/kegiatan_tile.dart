import 'package:flutter/material.dart';
import '../models/kegiatan.dart';
import '../utils/format.dart';

class KegiatanTile extends StatelessWidget {
  final Kegiatan kegiatan;
  final VoidCallback onToggle;
  final VoidCallback onHapus;
  final VoidCallback onTap;

  const KegiatanTile({
    super.key,
    required this.kegiatan,
    required this.onToggle,
    required this.onHapus,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color? warnaNominal;
    String prefix = '';
    if (kegiatan.tipe == Tipe.pemasukan) {
      warnaNominal = Colors.green;
      prefix = '+';
    } else if (kegiatan.tipe == Tipe.pengeluaran) {
      warnaNominal = Colors.red;
      prefix = '-';
    }

    return ListTile(
      leading: Checkbox(value: kegiatan.selesai, onChanged: (_) => onToggle()),
      title: Text(kegiatan.judul, style: TextStyle(decoration: kegiatan.selesai ? TextDecoration.lineThrough : null)),
      subtitle: kegiatan.tipe == Tipe.pengeluaran ? Text(kegiatan.kategori) : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (kegiatan.tipe != Tipe.tanpa)
            Text('$prefix${formatRupiah(kegiatan.nominal)}', style: TextStyle(color: warnaNominal, fontWeight: FontWeight.bold)),
          IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: onHapus),
        ],
      ),
      onTap: onTap,
    );
  }
}
