import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Pengaturan extends ChangeNotifier {
  bool _gelap = false;
  int _target = 20000;
  Color _warna = Colors.teal;

  bool get gelap => _gelap;
  int get target => _target;
  Color get warna => _warna;

  ThemeMode get themeMode => _gelap ? ThemeMode.dark : ThemeMode.light;

  Future<void> muat() async {
    final prefs = await SharedPreferences.getInstance();
    _gelap = prefs.getBool('gelap') ?? false;
    _target = prefs.getInt('target') ?? 20000;
    _warna = Color(prefs.getInt('warna') ?? Colors.teal.value);
    notifyListeners();
  }

  Future<void> setGelap(bool val) async {
    _gelap = val;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('gelap', val);
  }

  Future<void> setTarget(int val) async {
    _target = val;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('target', val);
  }

  Future<void> setWarna(Color val) async {
    _warna = val;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('warna', val.value);
  }
}
