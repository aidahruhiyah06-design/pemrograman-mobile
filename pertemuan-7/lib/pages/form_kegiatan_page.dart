import 'package:flutter/material.dart';
import '../data/db_helper.dart';
import '../models/kegiatan.dart';

class FormKegiatanPage extends StatefulWidget {
  final Kegiatan? kegiatan;
  const FormKegiatanPage({super.key, this.kegiatan});

  @override
  State<FormKegiatanPage> createState() => _FormKegiatanPageState();
}

class _FormKegiatanPageState extends State<FormKegiatanPage> {
  final _formKey = GlobalKey<FormState>();
  final _judulCtrl = TextEditingController();
  final _nominalCtrl = TextEditingController();
  DateTime _tanggal = DateTime.now();
  Tipe _tipe = Tipe.tanpa;
  String _kategori = 'Makan';

  final _listKategori = ['Makan', 'Transport', 'Belajar', 'Hiburan', 'Lainnya'];

  @override
  void initState() {
    super.initState();
    if (widget.kegiatan != null) {
      _judulCtrl.text = widget.kegiatan!.judul;
      _nominalCtrl.text = widget.kegiatan!.nominal > 0 ? widget.kegiatan!.nominal.toString() : '';
      _tanggal = DateTime.parse(widget.kegiatan!.tanggal);
      _tipe = widget.kegiatan!.tipe;
      _kategori = widget.kegiatan!.kategori;
    }
  }

  @override
  void dispose() {
    _judulCtrl.dispose();
    _nominalCtrl.dispose();
    super.dispose();
  }

  Future<void> _pilihTanggal() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _tanggal,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) setState(() => _tanggal = picked);
  }

  void _simpan() async {
    if (!_formKey.currentState!.validate()) return;
    
    final tglStr = '${_tanggal.year}-${_tanggal.month.toString().padLeft(2, '0')}-${_tanggal.day.toString().padLeft(2, '0')}';
    
    final data = Kegiatan(
      id: widget.kegiatan?.id,
      judul: _judulCtrl.text.trim(),
      tanggal: tglStr,
      tipe: _tipe,
      nominal: _tipe == Tipe.tanpa ? 0 : int.parse(_nominalCtrl.text),
      kategori: _tipe == Tipe.pengeluaran ? _kategori : '-',
    );

    if (widget.kegiatan == null) {
      await DbHelper.tambah(data);
    } else {
      await DbHelper.ubah(data);
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.kegiatan == null ? 'Tambah Kegiatan' : 'Ubah Kegiatan')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _judulCtrl,
              decoration: const InputDecoration(labelText: 'Nama Kegiatan', border: OutlineInputBorder()),
              validator: (v) => v == null || v.trim().isEmpty ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: 12),
            ListTile(
              title: const Text('Tanggal'),
              subtitle: Text('${_tanggal.day}/${_tanggal.month}/${_tanggal.year}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: _pilihTanggal,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<Tipe>(
              value: _tipe,
              decoration: const InputDecoration(labelText: 'Jenis Keuangan', border: OutlineInputBorder()),
              items: Tipe.values.map((t) => DropdownMenuItem(value: t, child: Text(t.name))).toList(),
              onChanged: (v) => setState(() => _tipe = v!),
            ),
            if (_tipe != Tipe.tanpa) ...[
              const SizedBox(height: 12),
              TextFormField(
                controller: _nominalCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Nominal (Rp)', border: OutlineInputBorder()),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Wajib diisi';
                  if (int.tryParse(v) == null || int.parse(v) <= 0) return 'Harus angka > 0';
                  return null;
                },
              ),
            ],
            if (_tipe == Tipe.pengeluaran) ...[
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _kategori,
                decoration: const InputDecoration(labelText: 'Kategori', border: OutlineInputBorder()),
                items: _listKategori.map((k) => DropdownMenuItem(value: k, child: Text(k))).toList(),
                onChanged: (v) => setState(() => _kategori = v!),
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton(onPressed: _simpan, child: const Text('Simpan')),
          ],
        ),
      ),
    );
  }
}
