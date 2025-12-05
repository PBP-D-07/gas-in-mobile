import 'package:flutter/material.dart';
import 'package:gas_in/widgets/left_drawer.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:gas_in/screens/menu.dart';

class VenueFormPage extends StatefulWidget {
  const VenueFormPage({super.key});

  @override
  State<VenueFormPage> createState() => _VenueFormPageState();
}

class _VenueFormPageState extends State<VenueFormPage> {
  final _formKey = GlobalKey<FormState>();
  String _name = "";
  String _description = "";
  String _location = "";
  String _category = "running";
  String _thumbnail = "";
  String _imagesCsv = "";
  String _contactNumber = "";

  final List<String> _categories = [
    'running',
    'badminton',
    'futsal',
    'football',
    'basketball',
    'cycling',
    'volleyball',
    'yoga',
    'padel',
    'other',
  ];

  // Helper untuk Style Input Decoration
  InputDecoration _customInputDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[400]),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      filled: true,
      fillColor: Colors.white, // Input field tetap putih solid
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.0),
        borderSide: const BorderSide(color: Color(0xFF1A237E), width: 2.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.0),
        borderSide: const BorderSide(color: Color(0xFF1A237E), width: 2.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.0),
        borderSide: const BorderSide(color: Colors.red, width: 2.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.0),
        borderSide: const BorderSide(color: Colors.red, width: 2.5),
      ),
    );
  }

  // Helper untuk Label
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0, top: 12.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      extendBodyBehindAppBar: true, // Agar gradient sampai ke atas
      appBar: AppBar(
        title: const Text(''),
        backgroundColor: Colors.white, // Transparan
        foregroundColor: const Color(0xFF1A237E),
        elevation: 5,
        shadowColor: Colors.black.withOpacity(0.5),
      ),
      drawer: const LeftDrawer(),
      body: Container(
        // === Background Gradient ===
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Colors.purple[50]!, Colors.purple[100]!],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24.0, 60.0, 24.0, 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // === Header Text (Di luar kotak putih) ===
              const SizedBox(height: 20),
              const Text(
                'Create New Venue',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Create Venue for people around you!',
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              const SizedBox(height: 30),

              // === KOTAK PUTIH OPACITY (Form Container) ===
              Container(
                padding: const EdgeInsets.all(20.0), // Padding dalam kotak
                decoration: BoxDecoration(
                  // Warna putih dengan Opacity 70%
                  color: Colors.white.withOpacity(0.7),
                  // Sudut kotak agak tegas (8.0), ganti 0.0 jika ingin lancip total
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // === Name ===
                      _buildLabel("Venue Name"),
                      TextFormField(
                        decoration: _customInputDecoration(hint: ""),
                        onChanged: (val) => setState(() => _name = val),
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return "Nama tidak boleh kosong!";
                          }
                          return null;
                        },
                      ),

                      // === Description ===
                      _buildLabel("Description"),
                      TextFormField(
                        maxLines: 4,
                        decoration: _customInputDecoration(hint: ""),
                        onChanged: (val) => setState(() => _description = val),
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return "Deskripsi tidak boleh kosong!";
                          }
                          return null;
                        },
                      ),

                      // === Location ===
                      _buildLabel("Location"),
                      TextFormField(
                        decoration: _customInputDecoration(hint: ""),
                        onChanged: (val) => setState(() => _location = val),
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return "Lokasi tidak boleh kosong!";
                          }
                          return null;
                        },
                      ),

                      // === Contact ===
                      _buildLabel("Contact Number"),
                      TextFormField(
                        keyboardType: TextInputType.phone,
                        decoration: _customInputDecoration(hint: ""),
                        onChanged: (val) =>
                            setState(() => _contactNumber = val),
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return "Kontak tidak boleh kosong!";
                          }
                          final parsed = int.tryParse(
                            value.replaceAll(',', '.'),
                          );
                          if (parsed == null) {
                            return "Masukkan angka yang valid untuk harga!";
                          }
                          return null;
                        },
                      ),

                      // === Category ===
                      _buildLabel("Category"),
                      DropdownButtonFormField<String>(
                        decoration: _customInputDecoration(),
                        initialValue: _category.isEmpty ? null : _category,
                        items: _categories
                            .map(
                              (cat) => DropdownMenuItem(
                                value: cat,
                                child: Text(
                                  cat[0].toUpperCase() + cat.substring(1),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _category = newValue ?? "";
                          });
                        },
                        onSaved: (String? value) {
                          _category = value ?? '';
                        },
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return "Kategori tidak boleh kosong!";
                          }
                          return null;
                        },
                      ),

                      // === Images (CSV) ===
                      _buildLabel("Images (comma-separated URLs)"),
                      TextFormField(
                        decoration: _customInputDecoration(hint: "https://..."),
                        maxLines: 2,
                        onChanged: (val) => setState(() => _imagesCsv = val),
                        // optional: allow empty
                        validator: (val) => null,
                      ),

                      // === Thumbnail ===
                      _buildLabel("Thumbnail (Image URL)"),
                      TextFormField(
                        decoration: _customInputDecoration(hint: ""),
                        maxLines: 4, // Kotak besar seperti di gambar
                        onChanged: (val) => setState(() => _thumbnail = val),
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return "Thumbnail produk tidak boleh kosong!";
                          } else if (!Uri.tryParse(value)!.isAbsolute) {
                            return "Masukkan URL yang valid!";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 30),

                      // === Tombol Add Event (smaller, centered) ===
                      Center(
                        child: SizedBox(
                          width: 150,
                          height: 40,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE0B3FF),
                              foregroundColor: Colors.black,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(22),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                // Logic simpan data
                                List<String> images = _imagesCsv
                                    .split(',')
                                    .map((e) => e.trim())
                                    .toList();

                                final payload = jsonEncode({
                                  "name": _name,
                                  "description": _description,
                                  "location": _location,
                                  "thumbnail": _thumbnail,
                                  "images": images,
                                  "contact_number": _contactNumber,
                                  "category": _category,
                                });

                                final response = await request.postJson(
                                  "http://localhost:8000/venue/create-venue-flutter/",
                                  payload,
                                );

                                if (context.mounted) {
                                  if (response != null &&
                                      response['status'] == 'success') {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text("Success!")),
                                    );
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => MyHomePage(),
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text("Failed.")),
                                    );
                                  }
                                }
                              }
                            },
                            child: const Text("Add Venue"),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
