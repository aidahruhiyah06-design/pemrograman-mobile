import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pencatat Pengeluaran',
      theme: ThemeData(colorSchemeSeed: Colors.green, useMaterial3: true),
      home: const PengeluaranPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// Format ribuan: 15000 -> "15.000"
String formatRibuan(int angka) {
  return angka.toString().replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]}.',
      );
}

// ============ MODEL ============
class Pengeluaran {
  final int? id;
  final String nama;
  final int jumlah;
  final String kategori;
  final String tanggal;

  const Pengeluaran({
    this.id,
    required this.nama,
    required this.jumlah,
    required this.kategori,
    required this.tanggal,
  });

  Map<String, Object?> toMap() => {
        'id': id,
        'nama': nama,
        'jumlah': jumlah,
        'kategori': kategori,
        'tanggal': tanggal,
      };

  factory Pengeluaran.fromMap(Map<String, Object?> m) => Pengeluaran(
        id: m['id'] as int?,
        nama: m['nama'] as String,
        jumlah: m['jumlah'] as int,
        kategori: m['kategori'] as String,
        tanggal: m['tanggal'] as String,
      );
}

// ============ DATABASE HELPER ============
class DbHelper {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    final path = p.join(await getDatabasesPath(), 'pengeluaran.db');
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE pengeluaran('
          'id INTEGER PRIMARY KEY AUTOINCREMENT, '
          'nama TEXT NOT NULL, '
          'jumlah INTEGER NOT NULL, '
          'kategori TEXT NOT NULL, '
          'tanggal TEXT NOT NULL)',
        );
      },
    );
    return _db!;
  }

  static Future<int> tambah(Pengeluaran p) async {
    final db = await database;
    return db.insert('pengeluaran', p.toMap());
  }

  static Future<List<Pengeluaran>> semua() async {
    final db = await database;
    final rows = await db.query('pengeluaran', orderBy: 'id DESC');
    return rows.map(Pengeluaran.fromMap).toList();
  }

  static Future<int> ubah(Pengeluaran p) async {
    final db = await database;
    return db.update(
      'pengeluaran',
      p.toMap(),
      where: 'id = ?',
      whereArgs: [p.id],
    );
  }

  static Future<int> hapus(int id) async {
    final db = await database;
    return db.delete('pengeluaran', where: 'id = ?', whereArgs: [id]);
  }

  // Hitung total pengeluaran
  static Future<int> total() async {
    final db = await database;
    final result = await db.rawQuery('SELECT SUM(jumlah) as total FROM pengeluaran');
    return (result.first['total'] as int?) ?? 0;
  }
}

// ============ HALAMAN DAFTAR PENGELUARAN ============
class PengeluaranPage extends StatefulWidget {
  const PengeluaranPage({super.key});

  @override
  State<PengeluaranPage> createState() => _PengeluaranPageState();
}

class _PengeluaranPageState extends State<PengeluaranPage> {
  late Future<List<Pengeluaran>> _future;
  int _total = 0;
  bool _gelap = false;

  @override
  void initState() {
    super.initState();
    _muatPreferensi();
  }

  Future<void> _muatPreferensi() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _gelap = prefs.getBool('gelap') ?? false);
    _muat();
  }

  Future<void> _ubahTema(bool nilai) async {
    setState(() => _gelap = nilai);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('gelap', nilai);
  }

  void _muat() {
    setState(() {
      _future = DbHelper.semua();
      DbHelper.total().then((t) {
        if (mounted) setState(() => _total = t);
      });
    });
  }

  Future<void> _buka([Pengeluaran? item]) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FormPengeluaranPage(item: item),
      ),
    );
    if (!mounted) return;
    _muat();
  }

  Future<void> _konfirmasiHapus(Pengeluaran item) async {
    final ya = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Pengeluaran'),
        content: Text('Hapus "${item.nama}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (ya == true) {
      await DbHelper.hapus(item.id!);
      _muat();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        brightness: _gelap ? Brightness.dark : Brightness.light,
        colorSchemeSeed: Colors.green,
        useMaterial3: true,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Pencatat Pengeluaran'),
          actions: [
            IconButton(
              icon: Icon(_gelap ? Icons.light_mode : Icons.dark_mode),
              onPressed: () => _ubahTema(!_gelap),
            ),
          ],
        ),
        body: Column(
          children: [
            // Kartu total
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade400, Colors.green.shade700],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text(
                    'Total Pengeluaran',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Rp ${formatRibuan(_total)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Daftar pengeluaran
            Expanded(
              child: FutureBuilder<List<Pengeluaran>>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Galat: ${snapshot.error}'));
                  }
                  final data = snapshot.data!;
                  if (data.isEmpty) {
                    return const Center(
                      child: Text(
                        'Belum ada pengeluaran',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (context, i) {
                      final item = data[i];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.green.shade100,
                            child: const Icon(Icons.shopping_bag,
                                color: Colors.green),
                          ),
                          title: Text(item.nama),
                          subtitle: Text(
                            '${item.kategori} • ${item.tanggal.split('T').first}',
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Rp ${formatRibuan(item.jumlah)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                              const SizedBox(height: 4),
                              InkWell(
                                onTap: () => _konfirmasiHapus(item),
                                child: const Icon(Icons.delete,
                                    size: 18, color: Colors.red),
                              ),
                            ],
                          ),
                          onTap: () => _buka(item),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _buka(),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

// ============ HALAMAN FORM ============
class FormPengeluaranPage extends StatefulWidget {
  final Pengeluaran? item;
  const FormPengeluaranPage({super.key, this.item});

  @override
  State<FormPengeluaranPage> createState() => _FormPengeluaranPageState();
}

class _FormPengeluaranPageState extends State<FormPengeluaranPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nama;
  late final TextEditingController _jumlah;
  String? _kategori;

  final _kategoriList = const [
    'Makanan',
    'Minuman',
    'Transportasi',
    'Belanja',
    'Hiburan',
    'Kesehatan',
    'Pendidikan',
    'Lainnya',
  ];

  @override
  void initState() {
    super.initState();
    _nama = TextEditingController(text: widget.item?.nama ?? '');
    _jumlah = TextEditingController(
      text: widget.item?.jumlah.toString() ?? '',
    );
    _kategori = widget.item?.kategori;
  }

  @override
  void dispose() {
    _nama.dispose();
    _jumlah.dispose();
    super.dispose();
  }

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) return;

    final p = Pengeluaran(
      id: widget.item?.id,
      nama: _nama.text.trim(),
      jumlah: int.parse(_jumlah.text.trim()),
      kategori: _kategori!,
      tanggal: widget.item?.tanggal ?? DateTime.now().toIso8601String(),
    );

    if (widget.item == null) {
      await DbHelper.tambah(p);
    } else {
      await DbHelper.ubah(p);
    }
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final baru = widget.item == null;
    return Scaffold(
      appBar: AppBar(
        title: Text(baru ? 'Tambah Pengeluaran' : 'Ubah Pengeluaran'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nama,
              decoration: const InputDecoration(
                labelText: 'Nama pengeluaran',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.shopping_bag),
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Nama wajib diisi'
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _jumlah,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Jumlah (Rp)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Jumlah wajib diisi';
                }
                final angka = int.tryParse(v.trim());
                if (angka == null) return 'Jumlah harus angka';
                if (angka <= 0) return 'Jumlah harus lebih dari 0';
                return null;
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _kategori,
              decoration: const InputDecoration(
                labelText: 'Kategori',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              items: _kategoriList
                  .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                  .toList(),
              onChanged: (v) => setState(() => _kategori = v),
              validator: (v) => v == null ? 'Pilih kategori' : null,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _simpan,
              icon: const Icon(Icons.save),
              label: const Text('Simpan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
