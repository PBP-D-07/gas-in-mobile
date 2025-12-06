import 'package:flutter/material.dart';
import 'package:gas_in/AdminModule/screen/menu_admin.dart';
import 'package:gas_in/AdminModule/screen/page_request.dart';
import 'package:gas_in/AdminModule/screen/page_users.dart';

class LeftDrawer extends StatelessWidget {
  const LeftDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
            // TODO: Bagian drawer header
              decoration: BoxDecoration(
                color: Colors.deepPurple,
              ),
              child: Column(
                children: [
                  Text(
                    'Admin gas.in',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Padding(padding: EdgeInsets.all(10)),
                  Text("Pusat info users dan events ada disini!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      ),
                  ),
                ],
              ),
            ),
          // TODO: Bagian routing
          ListTile(
            leading: const Icon(Icons.admin_panel_settings),
            title: const Text('Admin Homepage'),
            onTap: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => adminPage(),
                  ));
            },
          ),
          ListTile(
            leading: const Icon(Icons.verified_user),
            title: const Text('Users Management'),
            onTap: () {
              /*
              TODO: Buatlah routing ke NewsFormPage di sini,
              setelah halaman NewsFormPage sudah dibuat.
              */
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PageUsers(),
                  ));
            },
          ),
          ListTile(
            leading: const Icon(Icons.event_available_rounded),
            title: const Text('Events Management'),
            onTap: () {
              /*
              TODO: Buatlah routing ke NewsFormPage di sini,
              setelah halaman NewsFormPage sudah dibuat.
              */
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PageRequest(),
                  ));
            },
          ),
        ],
      ),
    );
  }
}