import 'package:flutter/material.dart';
import 'package:gas_in/login.dart';
import 'package:gas_in/widgets/left_drawer.dart';

class MyHomePage extends StatelessWidget {
  MyHomePage({super.key});

  final List<ItemHomepage> items = [
    ItemHomepage("Event", Icons.list),
    ItemHomepage("Forum", Icons.chat_bubble_outline_outlined ),
    ItemHomepage("Venue", Icons.stadium_outlined ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 5,
        shadowColor: Colors.black.withValues(alpha: 0.5),
        titleSpacing: 0,
        title: Row(
          children: [
            Expanded(
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset("assets/logo.png", width: 20),
                    const SizedBox(width: 6),
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFF4338CA), Color(0xFF6B21A8)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ).createShader(
                        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.only(right: 2),
                        child: Text(
                          'GAS.in',
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
                child: const Text(
                  "Login",
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ),
      drawer: const LeftDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: GridView.count(
                primary: true,
                padding: const EdgeInsets.all(20),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                crossAxisCount: 3,
                shrinkWrap: true,
                // Tambahkan childAspectRatio jika teks terlalu panjang atau terpotong
                // childAspectRatio: 0.8, 
                children: items.map((ItemHomepage item) {
                  return ItemCard(item);
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ItemHomepage {
  final String name;
  final IconData icon;

  ItemHomepage(this.name, this.icon );
}

class ItemCard extends StatelessWidget {
  final ItemHomepage item;

  const ItemCard(this.item, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center, // Vertikal center
      children: [
        // 1. Bagian Tombol Lingkaran
        Container(
          width: 60, // Tentukan ukuran lingkaran
          height: 60,
          decoration: BoxDecoration(
            // Membuat bentuk lingkaran
            shape: BoxShape.circle, 
            gradient: const LinearGradient(
              colors: [
                Color(0xFF4338CA), // Indigo
                Color(0xFF6B21A8), // Purple
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(2, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              // Membuat efek ripple (klik) juga berbentuk lingkaran
              customBorder: const CircleBorder(), 
              onTap: () {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(SnackBar(
                      content: Text("Kamu menekan tombol ${item.name}!")));
              },
              child: Center(
                child: Icon(
                  item.icon,
                  color: Colors.white,
                  size: 30.0,
                ),
              ),
            ),
          ),
        ),
        
        // 2. Jarak antara tombol dan teks
        const SizedBox(height: 8), 

        // 3. Bagian Teks (Sekarang di luar tombol)
        Text(
          item.name,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.black, // Ubah ke hitam agar terbaca di background putih
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}