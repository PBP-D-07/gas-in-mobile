import 'package:flutter/material.dart';
import 'package:gas_in/screens/menu.dart';
import 'package:gas_in/EventMakerModule/screens/create_event.dart';
import 'package:gas_in/VenueModule/screens/venue_form.dart';
import 'package:gas_in/ForumModule/screens/postlist_form.dart';
import 'package:gas_in/screens/login.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

class LeftDrawer extends StatelessWidget {
  // variable untuk menandai current page/active page
  final String currentPage;

  // constructor
  const LeftDrawer({super.key, this.currentPage = 'Home'});

  @override
  Widget build(BuildContext context) {
    final routeName = ModalRoute.of(context)?.settings.name;
    final activeKey = (routeName ?? currentPage)
        .toString()
        .toLowerCase()
        .trim();
    const Color activeColor = Color(0xFF101850);

    return Drawer(
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        children: [
          const SizedBox(height: 60),

          // header logo
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

          // home menu
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

          // create event menu
          _buildDrawerItem(
            title: 'Create Event',
            isActive: activeKey == 'create event',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  settings: const RouteSettings(name: 'create event'),
                  builder: (context) => CreateEventPage(),
                ),
              );
            },
          ),

          // venue form menu
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

          _buildDrawerItem(
            title: 'Create Post',
            isActive: activeKey == 'create post',
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  settings: const RouteSettings(name: 'create post'),
                  builder: (context) => PostFormPage(),
                ),
              );
            },
          ),

          const SizedBox(height: 10),

          Divider(color: Colors.purple[100], thickness: 0.5),

          const SizedBox(height: 10),

          // logout menu
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () async {
              Navigator.pop(context);
              final request = context.read<CookieRequest>();
              try {
                await request.get(
                  "https://nezzaluna-azzahra-gas-in.pbp.cs.ui.ac.id/auth/logout/",
                );
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

  // widget untuk membangun item drawer
  Widget _buildDrawerItem({
    required String title,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    const Color activeBG = Color(0xFF101850);
    const Color activeText = Colors.white;
    const Color nonactiveText = Color(0xFF101850);

    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      decoration: isActive
          ? BoxDecoration(
              color: activeBG,
              borderRadius: BorderRadius.circular(30),
            )
          : null,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        title: Text(
          title,
          style: TextStyle(
            color: isActive ? activeText : nonactiveText,
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
