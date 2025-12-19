import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:gas_in/EventModule/screens/saved_search.dart'; // Untuk navigasi ke Saved Searches

// Ganti dengan path model yang benar
// import '../models/event/event_model.dart'; 
// import '../models/event/saved_search_model.dart'; 

// Ganti dengan path warna yang benar
const Color primaryColor = Color(0xFF5533FF); 
const Color secondaryColor = Color(0xFF0D1B36);
const Color lightPurple = Color(0xFFE0B0FF); 
const Color darkButton = Color(0xFF0D1B36); 
const Color accentColor = Color(0xFFF06292); 

class DiscoverEventsPage extends StatefulWidget {
  const DiscoverEventsPage({super.key});

  @override
  State<DiscoverEventsPage> createState() => _DiscoverEventsPageState();
}

class _DiscoverEventsPageState extends State<DiscoverEventsPage> {
  // TODO: Tambahkan variabel state untuk filter (lokasi, kategori)
  String? selectedLocation;
  String? selectedCategory;
  TextEditingController savedSearchNameController = TextEditingController();

  // TODO: Tambahkan fungsi fetchFilteredEvents
  // ...

  // Fungsi untuk menampilkan modal "Saved Current Filter"
  void _showSaveFilterModal(CookieRequest request) {
    if ((selectedLocation == null || selectedLocation!.isEmpty) && 
        (selectedCategory == null || selectedCategory!.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih minimal satu filter sebelum menyimpan!'))
      );
      return;
    }
    
    savedSearchNameController.clear();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          contentPadding: const EdgeInsets.all(24),
          title: const Text(
            "Saved Current Filter",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Lorem Ipsum Dolor Sit Amet"),
              const SizedBox(height: 16),
              TextField(
                controller: savedSearchNameController,
                decoration: InputDecoration(
                  hintText: "Nama Filter",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15)
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Tombol CANCEL (Merah)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Cancel', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Tombol SAVE (Biru Tua)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _saveFilter(request, context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: darkButton,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Save', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // Fungsi untuk memanggil API save filter
  void _saveFilter(CookieRequest request, BuildContext dialogContext) async {
    final name = savedSearchNameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama filter tidak boleh kosong!'))
      );
      return;
    }
    
    // TODO: Kirim POST request ke /event/api/saved-search/create/
    final response = await request.post(
      "http://localhost:8000/event/api/saved-search/create/",
      {
        'name': name,
        'location': selectedLocation,
        'category': selectedCategory,
      }
    );

    Navigator.pop(dialogContext); // Tutup modal
    
    if (response['message'] == 'Saved search created successfully') {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Filter berhasil disimpan!'))
      );
    } else {
       ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan filter: ${response['message'] ?? 'Unknown Error'}'))
      );
    }
  }

  // TODO: Tambahkan fungsi resetFilters
  // ...

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      // Background yang sesuai desain
      backgroundColor: Colors.white, 
      appBar: AppBar(
        // Kosongkan AppBar atau atur minimalis jika desain tidak menampilkan
        toolbarHeight: 0,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                'Discover Events',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const Text(
                'Lorem Ipsum Dolor Sit Amet',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
              const SizedBox(height: 20),

              // Tombol Aksi (Add Event & See Filter Saved)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Navigasi ke halaman Add Event
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: darkButton,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Add Event', style: TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SavedSearchesPage()),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: darkButton, width: 2),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('See Filter Saved', style: TextStyle(color: darkButton, fontSize: 16)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // Filter Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 2,
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Filter Events', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 15),
                    
                    // Filter Lokasi
                    const Text('Lokasi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                    _buildFilterDropdown('location', (value) {
                      setState(() {
                        selectedLocation = value;
                        // TODO: Panggil fetchFilteredEvents
                      });
                    }),
                    const SizedBox(height: 15),

                    // Filter Kategori
                    const Text('Kategori Olahraga', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                    _buildFilterDropdown('category', (value) {
                      setState(() {
                        selectedCategory = value;
                        // TODO: Panggil fetchFilteredEvents
                      });
                    }),
                    const SizedBox(height: 20),

                    // Tombol Reset dan Save
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              // TODO: Panggil resetFilters
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: lightPurple, // Warna Ungu Muda
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Reset Filter', style: TextStyle(color: secondaryColor, fontSize: 16)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _showSaveFilterModal(request),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: darkButton, // Warna Biru Tua
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Save', style: TextStyle(color: Colors.white, fontSize: 16)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    const Text('Menampilkan P event', style: TextStyle(color: Colors.grey)), // Ganti dengan angka event sebenarnya
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Event Cards (Contoh)
              // TODO: Ganti dengan FutureBuilder untuk menampilkan Event Card sebenarnya
              _buildEventCardExample(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterDropdown(String type, Function(String?) onChanged) {
    // List opsi yang sesuai dengan desain Django Anda
    final List<String> locationOptions = ['Jakarta', 'Bogor', 'Depok', 'Tangerang', 'Bekasi'];
    final List<String> categoryOptions = ['running', 'badminton', 'futsal', 'football', 'basketball'];
    
    List<String> options = type == 'location' ? locationOptions : categoryOptions;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: type == 'location' ? selectedLocation : selectedCategory,
          hint: Text(type == 'location' ? 'Semua Lokasi' : 'Semua Kategori'),
          items: [
            DropdownMenuItem(value: null, child: Text(type == 'location' ? 'Semua Lokasi' : 'Semua Kategori')),
            ...options.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }

  // Widget Event Card contoh (Hanya untuk desain)
  Widget _buildEventCardExample(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.asset(
              'assets/badminton_court.jpg', // Ganti dengan asset atau network image
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Badminton', 
                    style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Lorem ipsum dolor sit amet',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Text(
                  'Lorem ipsum dolor sit amet',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}