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
  String _category = "";
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

  InputDecoration _customInputDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[400]),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      filled: true,
      fillColor: Colors.white,
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(''),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A237E),
        elevation: 5,
        shadowColor: Colors.black.withOpacity(0.5),
      ),
      drawer: const LeftDrawer(),
      body: Container(
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
              const SizedBox(height: 20),
              ShaderMask(
                shaderCallback: (bounds) =>
                    const LinearGradient(
                      colors: [Color(0xFF4338CA), Color(0xFF6B21A8)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ).createShader(
                      Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                    ),
                child: const Padding(
                  padding: EdgeInsets.only(right: 2),
                  child: Text(
                    'Create New Venue',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Create Venue for people around you!',
                style: TextStyle(fontSize: 18, color: Colors.black),
              ),
              const SizedBox(height: 30),

              Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
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

                      _buildLabel("Images (comma-separated URLs)"),
                      TextFormField(
                        decoration: _customInputDecoration(
                          hint:
                              "https://example.com/img1.jpg, https://example.com/img2.jpg",
                        ),
                        maxLines: 3,
                        onChanged: (val) => setState(() => _imagesCsv = val),
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return "Masukkan URL gambar!";
                          }
                          if (val != null && val.isNotEmpty) {
                            final urls = val
                                .split(',')
                                .map((e) => e.trim())
                                .where((e) => e.isNotEmpty);
                            for (var url in urls) {
                              if (!Uri.tryParse(url)!.isAbsolute) {
                                return "Pastikan semua URL valid!";
                              }
                            }
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 6),
                      Padding(
                        padding: const EdgeInsets.only(left: 4.0),
                        child: Text(
                          "Pisahkan dengan koma (,) untuk multiple images",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),

                      _buildLabel("Thumbnail (Image URL)"),
                      TextFormField(
                        decoration: _customInputDecoration(hint: ""),
                        maxLines: 4,
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
                                List<String> images = _imagesCsv
                                    .split(',')
                                    .map((e) => e.trim())
                                    .where((e) => e.isNotEmpty)
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

                                try {
                                  final response = await request.postJson(
                                    "http://localhost:8000/venue/create-venue-flutter/",
                                    payload,
                                  );

                                  if (context.mounted) {
                                    if (response != null &&
                                        response['status'] == 'success') {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            "Venue berhasil dibuat!",
                                          ),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => MyHomePage(),
                                        ),
                                      );
                                    } else {
                                      final errorMsg =
                                          response?['message'] ??
                                          'Gagal membuat venue.';
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(errorMsg),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("Error: $e"),
                                        backgroundColor: Colors.red,
                                      ),
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
