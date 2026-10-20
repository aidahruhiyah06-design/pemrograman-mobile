import 'package:flutter/material.dart';
import 'pages/shell_page.dart';
import 'state/pengaturan.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final Pengaturan _state = Pengaturan();

  @override
  void initState() {
    super.initState();
    _state.addListener(() => setState(() {}));
    _state.muat();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TabungKu',
      debugShowCheckedModeBanner: false,
      themeMode: _state.themeMode,
      theme: ThemeData(colorSchemeSeed: _state.warna, useMaterial3: true, brightness: Brightness.light),
      darkTheme: ThemeData(colorSchemeSeed: _state.warna, useMaterial3: true, brightness: Brightness.dark),
      home: ShellPage(state: _state),
    );
  }
}
