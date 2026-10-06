import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ============ STATE GLOBAL ============
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

// ============ PREFERENSI ============
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

// ============ APP ============
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
          onUnknownRoute: (settings) {
            return MaterialPageRoute(
              builder: (_) => Scaffold(
                appBar: AppBar(title: const Text('404')),
                body: const Center(
                  child: Text('404 - Halaman tidak ditemukan'),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// ============ SHELL (TAB CONTAINER) ============
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
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(
                    Icons.travel_explore,
                    size: 44,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Galeri Wisata Indonesia',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
            for (int i = 0; i < _judul.length; i++)
              ListTile(
                leading: Icon(
                  [Icons.place, Icons.favorite, Icons.settings][i],
                ),
                title: Text(_judul[i]),
                selected: _index == i,
                onTap: () {
                  setState(() => _index = i);
                  Navigator.pop(context);
                },
              ),
          ],
        ),
      ),
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

// ============ MODEL ============
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
    deskripsi: 'Pulau dewata dengan pantai eksotis, pura megah, '
        'dan budaya yang memukau. Cocok untuk liburan romantis '
        'maupun petualangan.',
    ikon: Icons.beach_access,
    warna: Colors.orange,
  ),
  Wisata(
    nama: 'Yogyakarta',
    lokasi: 'DI Yogyakarta',
    deskripsi: 'Kota budaya dengan Candi Borobudur, Prambanan, '
        'Malioboro, dan kuliner legendaris. Surga bagi pecinta '
        'sejarah dan seni.',
    ikon: Icons.temple_buddhist,
    warna: Colors.brown,
  ),
  Wisata(
    nama: 'Lombok',
    lokasi: 'Nusa Tenggara Barat',
    deskripsi: 'Pulau dengan Gunung Rinjani, Gili Trawangan, '
        'dan pantai pink. Alamnya masih asri dan jauh dari '
        'keramaian.',
    ikon: Icons.terrain,
    warna: Colors.green,
  ),
  Wisata(
    nama: 'Raja Ampat',
    lokasi: 'Papua Barat',
    deskripsi: 'Surga bawah laut dengan keanekaragaman hayati '
        'terkaya di dunia. Tempat terbaik untuk diving dan '
        'snorkeling.',
    ikon: Icons.scuba_diving,
    warna: Colors.blue,
  ),
];

// ============ TAB DESTINASI ============
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
                radius: 24,
                backgroundColor: wisata.warna,
                child: Icon(wisata.ikon, color: Colors.white),
              ),
            ),
            title: Text(
              wisata.nama,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(wisata.lokasi),
            trailing: ListenableBuilder(
              listenable: daftarFavorit,
              builder: (context, _) {
                final isFav = daftarFavorit.value.contains(wisata.nama);
                return IconButton(
                  icon: Icon(
                    isFav ? Icons.favorite : Icons.favorite_border,
                    color: isFav
                        ? Theme.of(context).colorScheme.error
                        : null,
                  ),
                  onPressed: () async {
                    final set = Set<String>.from(daftarFavorit.value);
                    if (isFav) {
                      set.remove(wisata.nama);
                    } else {
                      set.add(wisata.nama);
                    }
                    daftarFavorit.value = set;
                    await simpanFavorit();
                  },
                );
              },
            ),
            onTap: () {
              Navigator.pushNamed(context, '/detail', arguments: wisata);
            },
          ),
        );
      },
    );
  }
}

// ============ TAB FAVORIT ============
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
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.favorite_border,
                  size: 64,
                  color: Theme.of(context).colorScheme.outline,
                ),
                const SizedBox(height: 12),
                const Text('Belum ada destinasi favorit'),
                const SizedBox(height: 8),
                const Text(
                  'Tap ikon ♡ di tab Destinasi',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: fav.length,
          itemBuilder: (context, i) {
            final wisata = fav[i];
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
                trailing: const Icon(Icons.chevron_right),
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

// ============ TAB PENGATURAN ============
class PengaturanTab extends StatelessWidget {
  const PengaturanTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([themeMode, seedColor]),
      builder: (context, _) {
        final tema = Theme.of(context);
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: SwitchListTile(
                title: const Text('Mode gelap'),
                subtitle: const Text('Terapkan tema gelap'),
                secondary: Icon(
                  themeMode.value == ThemeMode.dark
                      ? Icons.dark_mode
                      : Icons.light_mode,
                ),
                value: themeMode.value == ThemeMode.dark,
                onChanged: (v) async {
                  themeMode.value = v ? ThemeMode.dark : ThemeMode.light;
                  await simpanTema();
                },
              ),
            ),
            const SizedBox(height: 16),
            Text('Warna Tema', style: tema.textTheme.titleMedium),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Wrap(
                  spacing: 16,
                  runSpacing: 12,
                  children: [
                    for (final c in pilihanWarna)
                      GestureDetector(
                        onTap: () async {
                          seedColor.value = c;
                          await simpanTema();
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: seedColor.value == c ? 56 : 44,
                          height: seedColor.value == c ? 56 : 44,
                          decoration: BoxDecoration(
                            color: c,
                            shape: BoxShape.circle,
                            border: seedColor.value == c
                                ? Border.all(
                                    color: tema.colorScheme.onSurface,
                                    width: 3,
                                  )
                                : null,
                          ),
                          child: seedColor.value == c
                              ? const Icon(Icons.check,
                                  color: Colors.white, size: 24)
                              : null,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: Text(
                'Galeri Wisata Indonesia v1.0',
                style: tema.textTheme.bodySmall,
              ),
            ),
          ],
        );
      },
    );
  }
}

// ============ HALAMAN DETAIL ============
class DetailPage extends StatefulWidget {
  final Wisata wisata;
  const DetailPage({super.key, required this.wisata});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _badge;
  bool _deskripsiBuka = false;

  @override
  void initState() {
    super.initState();
    _badge = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _badge.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final w = widget.wisata;

    return Scaffold(
      appBar: AppBar(title: Text(w.nama)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Hero: ikon terbang dari daftar
            Hero(
              tag: 'ikon-${w.nama}',
              child: CircleAvatar(
                radius: 64,
                backgroundColor: w.warna,
                child: Icon(w.ikon, size: 64, color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),

            // Nama wisata
            Text(w.nama, style: tema.textTheme.headlineMedium),
            const SizedBox(height: 4),

            // Lokasi dengan ikon
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.place,
                    size: 18, color: tema.colorScheme.primary),
                const SizedBox(width: 4),
                Text(w.lokasi, style: tema.textTheme.bodyMedium),
              ],
            ),
            const SizedBox(height: 24),

            // Badge animasi (AnimationController - eksplisit)
            ScaleTransition(
              scale: Tween(begin: 0.95, end: 1.05).animate(
                CurvedAnimation(parent: _badge, curve: Curves.easeInOut),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: w.warna.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, color: w.warna, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Destinasi Populer',
                      style: TextStyle(
                        color: w.warna,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Deskripsi
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Deskripsi',
                      style: tema.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: Text(
                        w.deskripsi,
                        style: tema.textTheme.bodyMedium,
                        maxLines: _deskripsiBuka ? null : 3,
                        overflow: _deskripsiBuka
                            ? TextOverflow.visible
                            : TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: TextButton(
                        onPressed: () =>
                            setState(() => _deskripsiBuka = !_deskripsiBuka),
                        child: Text(
                          _deskripsiBuka ? 'Tampilkan lebih sedikit' : 'Baca selengkapnya',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Tombol favorit
            ListenableBuilder(
              listenable: daftarFavorit,
              builder: (context, _) {
                final isFav = daftarFavorit.value.contains(w.nama);
                return FilledButton.icon(
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
