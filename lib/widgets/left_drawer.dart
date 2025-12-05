import 'package:flutter/material.dart';
import 'package:gas_in/EventMakerModule/screens/edit_event.dart';
import 'package:gas_in/EventMakerModule/screens/event_detail.dart';
import 'package:gas_in/screens/menu.dart';
import 'package:gas_in/EventMakerModule/screens/create_event.dart';
import 'package:gas_in/VenueModule/screens/venue_entry_list.dart';
import 'package:gas_in/VenueModule/screens/venue_form.dart';
import 'package:gas_in/login.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

class LeftDrawer extends StatelessWidget {
  // Tambahkan parameter opsional untuk mengetahui halaman mana yang aktif
  final String currentPage;

  const LeftDrawer({super.key, this.currentPage = 'Home'});

  @override
  Widget build(BuildContext context) {
    // Try to detect current route name (if pages use named routes). If not,
    // fall back to the `currentPage` parameter passed to the drawer.
    final rawRouteName = ModalRoute.of(context)?.settings.name;
    final activeKey = (rawRouteName ?? currentPage)
        .toString()
        .toLowerCase()
        .trim();
    // Definisi Warna sesuai gambar
    const Color activeColor = Color(0xFF101850); // Biru Dongker Gelap
    const Color logoutColor = Colors.redAccent;

    return Drawer(
      backgroundColor: Colors.white, // Background Drawer Putih
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ), // Force sharp rectangular corners for the drawer panel
      child: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
        ), // Padding kiri-kanan
        children: [
          // === HEADER ===
          const SizedBox(height: 60), // Spasi dari atas (pengganti SafeArea)
          Row(
            children: [
              // Logo asset to match the top AppBar branding
              Image.asset('assets/logo_biru.png', width: 50),
              const SizedBox(width: 6),
              // Gradient-styled brand text (same look as in `menu.dart`)
              const Padding(
                padding: EdgeInsets.only(right: 2),
                child: Text(
                  'GAS.in',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: activeColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20), // Jarak Header ke Menu
          // === MENU ITEMS ===

          // 1. Home
          _buildDrawerItem(
            title: 'Home',
            isActive: activeKey == 'home', // Logic aktif (case-insensitive)
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  settings: const RouteSettings(name: 'home'),
                  builder: (context) => MyHomePage(),
                ),
              );
            },
          ),

          // 2. Create Event (Masuk kategori Event)
          _buildDrawerItem(
            title: 'Create Event',
            isActive: activeKey == 'create event',
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  settings: const RouteSettings(name: 'create event'),
                  builder: (context) => CreateEventPage(),
                ),
              );
            },
          ),

          // 3. Edit Event
          _buildDrawerItem(
            title: 'Edit Event',
            isActive: activeKey == 'edit event',
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  settings: const RouteSettings(name: 'edit event'),
                  builder: (context) => EditEventPage(initialData: {}),
                ),
              );
            },
          ),

          // 4. Event Detail
          _buildDrawerItem(
            title: 'Event Detail',
            isActive: activeKey == 'event detail',
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  settings: const RouteSettings(name: 'event detail'),
                  builder: (context) => EventDetailPage(
                    name: 'Pacilrun',
                    description: 'lari bos',
                    location: 'depok',
                    category: 'running',
                    thumbnailFile: null,
                    selectedDate: DateTime.now(),
                  ),
                ),
              );
            },
          ),

          // 5. Book Venue (Masuk kategori Venue)
          _buildDrawerItem(
            title: 'Book Venue',
            isActive: activeKey == 'book venue',
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  settings: const RouteSettings(name: 'book venue'),
                  builder: (context) => VenueEntryListPage(),
                ),
              );
            },
          ),

          // 6. Create Venue
          _buildDrawerItem(
            title: 'Create Venue',
            isActive: activeKey == 'create venue',
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  settings: const RouteSettings(name: 'create venue'),
                  builder: (context) => VenueFormPage(),
                ),
              );
            },
          ),

          const SizedBox(height: 10),
          const Divider(color: Colors.grey, thickness: 0.5), // Garis tipis
          const SizedBox(height: 10),

          // === LOGOUT ===
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () async {
              // close drawer first
              Navigator.pop(context);
              final request = context.read<CookieRequest>();
              try {
                // try application logout endpoint
                await request.get("http://localhost:8000/auth/logout/");
              } catch (e) {
                // ignore network errors, still navigate to login
              }

              // navigate to login and remove previous routes
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }

  // Helper Widget untuk membuat Item Menu (Pill Shape)
  Widget _buildDrawerItem({
    required String title,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    const Color activeBg = Color(0xFF101850);
    const Color activeText = Colors.white;
    const Color inactiveText = Color(0xFF101850);

    return Container(
      margin: const EdgeInsets.only(bottom: 2), // Jarak antar item (dikurangi)
      decoration: isActive
          ? BoxDecoration(
              color: activeBg, // Background Biru Dongker kalau aktif
              borderRadius: BorderRadius.circular(30), // Pill Shape
            )
          : null, // Tidak ada background kalau tidak aktif
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
        title: Text(
          title,
          style: TextStyle(
            color: isActive ? activeText : inactiveText,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            fontSize: 16,
          ),
        ),
        onTap: onTap,
        dense: true,
        visualDensity: const VisualDensity(
          vertical: -3,
        ), // Kompres sedikit tinggi baris
      ),
    );
  }
}
