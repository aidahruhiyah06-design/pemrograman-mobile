import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeMode = ValueNotifier<ThemeMode>(ThemeMode.light);
final seedColor = ValueNotifier<Color>(Colors.teal);
final daftarFavorit = ValueNotifier<Set<String>>({});

const pilihanWarna = [
  Colors.teal,
  Colors.indigo,
  Colors.deepOrange,
  Colors.pink,
  Colors.green,
];

ThemeData buatTema(Color seed, Brightness brightness) {
  return ThemeData(
    useMaterial3: true,
    colorSchemeSeed: seed,
    brightness: brightness,
    appBarTheme: const AppBarTheme(centerTitle: true),
  );
}

Future<void> muatPreferensi() async {
  final prefs = await SharedPreferences.getInstance();
  final gelap = prefs.getBool('gelap') ?? false;
  themeMode.value = gelap ? ThemeMode.dark : ThemeMode.light;

  final warnaInt = prefs.getInt('warna') ?? Colors.teal.value;
  seedColor.value = Color(warnaInt);

  final favoritList = prefs.getStringList('favorit') ?? [];
  daftarFavorit.value = favoritList.toSet();
}

Future<void> simpanTema() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('gelap', themeMode.value == ThemeMode.dark);
  await prefs.setInt('warna', seedColor.value.value);
}

Future<void> simpanFavorit() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setStringList('favorit', daftarFavorit.value.toList());
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await muatPreferensi();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([themeMode, seedColor]),
      builder: (context, _) {
        return MaterialApp(
          title: 'Galeri Wisata',
          debugShowCheckedModeBanner: false,
          theme: buatTema(seedColor.value, Brightness.light),
          darkTheme: buatTema(seedColor.value, Brightness.dark),
          themeMode: themeMode.value,
          initialRoute: '/',
          routes: {
            '/': (_) => const ShellPage(),
          },
          onGenerateRoute: (settings) {
            if (settings.name == '/detail') {
              final wisata = settings.arguments as Wisata;
              return MaterialPageRoute(
                builder: (_) => DetailPage(wisata: wisata),
                settings: settings,
              );
            }
            return null;
          },
        );
      },
    );
  }
}

class ShellPage extends StatefulWidget {
  const ShellPage({super.key});

  @override
  State<ShellPage> createState() => _ShellPageState();
}

class _ShellPageState extends State<ShellPage> {
  int _index = 0;

  static const _halaman = [
    DestinasiTab(),
    FavoritTab(),
    PengaturanTab(),
  ];
  static const _judul = ['Destinasi', 'Favorit', 'Pengaturan'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_judul[_index])),
      body: IndexedStack(index: _index, children: _halaman),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.place_outlined),
            selectedIcon: Icon(Icons.place),
            label: 'Destinasi',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite),
            label: 'Favorit',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Pengaturan',
          ),
        ],
      ),
    );
  }
}

class Wisata {
  final String nama;
  final String lokasi;
  final String deskripsi;
  final IconData ikon;
  final Color warna;
  const Wisata({
    required this.nama,
    required this.lokasi,
    required this.deskripsi,
    required this.ikon,
    required this.warna,
  });
}

const daftarWisata = [
  Wisata(
    nama: 'Bali',
    lokasi: 'Provinsi Bali',
    deskripsi: 'Pulau dewata dengan pantai eksotis dan budaya yang memukau.',
    ikon: Icons.beach_access,
    warna: Colors.orange,
  ),
  Wisata(
    nama: 'Yogyakarta',
    lokasi: 'DI Yogyakarta',
    deskripsi: 'Kota budaya dengan Candi Borobudur dan Malioboro.',
    ikon: Icons.temple_buddhist,
    warna: Colors.brown,
  ),
  Wisata(
    nama: 'Lombok',
    lokasi: 'Nusa Tenggara Barat',
    deskripsi: 'Pulau dengan Gunung Rinjani dan Gili Trawangan.',
    ikon: Icons.terrain,
    warna: Colors.green,
  ),
  Wisata(
    nama: 'Raja Ampat',
    lokasi: 'Papua Barat',
    deskripsi: 'Surga bawah laut dengan keanekaragaman hayati terkaya.',
    ikon: Icons.scuba_diving,
    warna: Colors.blue,
  ),
];

class DestinasiTab extends StatelessWidget {
  const DestinasiTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: daftarWisata.length,
      itemBuilder: (context, i) {
        final wisata = daftarWisata[i];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: ListTile(
            leading: Hero(
              tag: 'ikon-${wisata.nama}',
              child: CircleAvatar(
                backgroundColor: wisata.warna,
                child: Icon(wisata.ikon, color: Colors.white),
              ),
            ),
            title: Text(wisata.nama),
            subtitle: Text(wisata.lokasi),
            onTap: () {
              Navigator.pushNamed(context, '/detail', arguments: wisata);
            },
          ),
        );
      },
    );
  }
}

class FavoritTab extends StatelessWidget {
  const FavoritTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: daftarFavorit,
      builder: (context, _) {
        final fav = daftarWisata
            .where((w) => daftarFavorit.value.contains(w.nama))
            .toList();

        if (fav.isEmpty) {
          return const Center(child: Text('Belum ada destinasi favorit'));
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: fav.length,
          itemBuilder: (context, i) {
            final wisata = fav[i];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: wisata.warna,
                  child: Icon(wisata.ikon, color: Colors.white),
                ),
                title: Text(wisata.nama),
                subtitle: Text(wisata.lokasi),
                onTap: () {
                  Navigator.pushNamed(context, '/detail', arguments: wisata);
                },
              ),
            );
          },
        );
      },
    );
  }
}

class PengaturanTab extends StatelessWidget {
  const PengaturanTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([themeMode, seedColor]),
      builder: (context, _) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SwitchListTile(
              title: const Text('Mode gelap'),
              value: themeMode.value == ThemeMode.dark,
              onChanged: (v) async {
                themeMode.value = v ? ThemeMode.dark : ThemeMode.light;
                await simpanTema();
              },
            ),
            const SizedBox(height: 16),
            const Text('Warna Tema'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 16,
              runSpacing: 12,
              children: [
                for (final c in pilihanWarna)
                  GestureDetector(
                    onTap: () async {
                      seedColor.value = c;
                      await simpanTema();
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: c,
                        shape: BoxShape.circle,
                        border: seedColor.value == c
                            ? Border.all(color: Colors.black, width: 2)
                            : null,
                      ),
                      child: seedColor.value == c
                          ? const Icon(Icons.check, color: Colors.white)
                          : null,
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class DetailPage extends StatefulWidget {
  final Wisata wisata;
  const DetailPage({super.key, required this.wisata});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _badge;

  @override
  void initState() {
    super.initState();
    _badge = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _badge.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = widget.wisata;
    final isFav = daftarFavorit.value.contains(w.nama);

    return Scaffold(
      appBar: AppBar(title: Text(w.nama)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Hero(
              tag: 'ikon-${w.nama}',
              child: CircleAvatar(
                radius: 64,
                backgroundColor: w.warna,
                child: Icon(w.ikon, size: 64, color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            Text(w.nama, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(w.lokasi),
            const SizedBox(height: 24),
            ScaleTransition(
              scale: Tween(begin: 0.95, end: 1.05).animate(
                CurvedAnimation(parent: _badge, curve: Curves.easeInOut),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: w.warna.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text('Destinasi Populer', style: TextStyle(color: w.warna)),
              ),
            ),
            const SizedBox(height: 24),
            Text(w.deskripsi, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ListenableBuilder(
              listenable: daftarFavorit,
              builder: (context, _) {
                return ElevatedButton.icon(
                  onPressed: () async {
                    final set = Set<String>.from(daftarFavorit.value);
                    if (isFav) {
                      set.remove(w.nama);
                    } else {
                      set.add(w.nama);
                    }
                    daftarFavorit.value = set;
                    await simpanFavorit();
                  },
                  icon: Icon(isFav ? Icons.favorite : Icons.favorite_border),
                  label: Text(isFav ? 'Hapus dari Favorit' : 'Tambah ke Favorit'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
