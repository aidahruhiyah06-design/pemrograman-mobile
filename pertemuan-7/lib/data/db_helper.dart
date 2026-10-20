import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import '../models/kegiatan.dart';

// Variabel global untuk sinkronisasi antar tab (petunjuk 5.3)
final ValueNotifier<int> versiData = ValueNotifier(0);

class DbHelper {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    final path = p.join(await getDatabasesPath(), 'tabungku.db');
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE kegiatan(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            judul TEXT NOT NULL,
            tanggal TEXT NOT NULL,
            selesai INTEGER NOT NULL,
            tipe TEXT NOT NULL,
            nominal INTEGER NOT NULL,
            kategori TEXT NOT NULL
          )
        ''');
      },
    );
    return _db!;
  }

  static Future<List<Kegiatan>> pada(String tanggal) async {
    final db = await database;
    final rows = await db.query('kegiatan', where: 'tanggal = ?', whereArgs: [tanggal], orderBy: 'id DESC');
    return rows.map(Kegiatan.fromMap).toList();
  }

  static Future<Ringkasan> ringkasan(String tanggal) async {
    final db = await database;
    final hasil = await db.rawQuery('''
      SELECT COUNT(*) AS jumlah,
      COALESCE(SUM(selesai), 0) AS selesai,
      COALESCE(SUM(CASE WHEN tipe = 'pemasukan' THEN nominal END), 0) AS masuk,
      COALESCE(SUM(CASE WHEN tipe = 'pengeluaran' THEN nominal END), 0) AS keluar
      FROM kegiatan
      WHERE tanggal = ?
    ''', [tanggal]);
    final baris = hasil.first;
    return Ringkasan(
      jumlahKegiatan: baris['jumlah'] as int,
      selesai: baris['selesai'] as int,
      pemasukan: baris['masuk'] as int,
      pengeluaran: baris['keluar'] as int,
    );
  }

  static Future<Map<String, int>> pengeluaranPerKategori(String tanggal) async {
    final db = await database;
    final rows = await db.rawQuery('''
      SELECT kategori, SUM(nominal) AS total
      FROM kegiatan
      WHERE tanggal = ? AND tipe = 'pengeluaran'
      GROUP BY kategori
    ''', [tanggal]);
    Map<String, int> hasil = {};
    for (var row in rows) {
      hasil[row['kategori'] as String] = row['total'] as int;
    }
    return hasil;
  }

  static Future<int> tambah(Kegiatan k) async {
    final db = await database;
    final id = await db.insert('kegiatan', k.toMap());
    versiData.value++; // Trigger refresh
    return id;
  }

  static Future<int> ubah(Kegiatan k) async {
    final db = await database;
    final res = await db.update('kegiatan', k.toMap(), where: 'id = ?', whereArgs: [k.id]);
    versiData.value++;
    return res;
  }

  static Future<int> hapus(int id) async {
    final db = await database;
    final res = await db.delete('kegiatan', where: 'id = ?', whereArgs: [id]);
    versiData.value++;
    return res;
  }
}
