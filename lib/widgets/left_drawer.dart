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
  final String currentPage;

  const LeftDrawer({super.key, this.currentPage = 'Home'});

  @override
  Widget build(BuildContext context) {
    final rawRouteName = ModalRoute.of(context)?.settings.name;
    final activeKey = (rawRouteName ?? currentPage)
        .toString()
        .toLowerCase()
        .trim();
    const Color activeColor = Color(0xFF101850);
    const Color logoutColor = Colors.redAccent;

    return Drawer(
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        children: [
          const SizedBox(height: 60),
          Row(
            children: [
              Image.asset('assets/logo_biru.png', width: 50),
              const SizedBox(width: 6),
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
          const SizedBox(height: 20),

          _buildDrawerItem(
            title: 'Home',
            isActive: activeKey == 'home',
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
          const Divider(color: Colors.grey, thickness: 0.5),
          const SizedBox(height: 10),

          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () async {
              Navigator.pop(context);
              final request = context.read<CookieRequest>();
              try {
                await request.get("http://localhost:8000/auth/logout/");
              } catch (e) {}

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

  Widget _buildDrawerItem({
    required String title,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    const Color activeBg = Color(0xFF101850);
    const Color activeText = Colors.white;
    const Color inactiveText = Color(0xFF101850);

    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      decoration: isActive
          ? BoxDecoration(
              color: activeBg,
              borderRadius: BorderRadius.circular(30),
            )
          : null,
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
        visualDensity: const VisualDensity(vertical: -3),
      ),
    );
  }
}
