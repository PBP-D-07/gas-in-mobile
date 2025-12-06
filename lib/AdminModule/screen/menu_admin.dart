import 'package:flutter/material.dart';
import 'package:gas_in/AdminModule/widgets/left_drawer.dart';
import 'package:gas_in/AdminModule/widgets/users_card.dart';

class adminPage extends StatelessWidget {
  adminPage({super.key});
  
  final List<ItemAdminpage> items = [
    ItemAdminpage("Users Management", Icons.person, Colors.blueAccent),
    ItemAdminpage("Event Requests Management", Icons.event_available, Colors.yellowAccent),
    ItemAdminpage("Logout", Icons.logout, Colors.redAccent)
  ];

  @override
  Widget build(BuildContext context) {
    // Scaffold menyediakan struktur dasar halaman dengan AppBar dan body.
    return Scaffold(
      // AppBar adalah bagian atas halaman yang menampilkan judul.
      appBar: AppBar(
        // Judul aplikasi "gas.in" dengan teks putih dan tebal.
        title: const Text(
          'Admin',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontStyle: FontStyle.italic,
          ),
        ),
        // Warna latar belakang AppBar diambil dari skema warna tema aplikasi.
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      drawer : LeftDrawer(),
      // Body halaman dengan padding di sekelilingnya.
      body: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 16.0),
                    child: Text(
                      'Selamat datang Admin!',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  GridView.count(
                    padding: const EdgeInsets.all(20),
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: items.map((ItemAdminpage item) {
                      return ItemCard(item);
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }
}
