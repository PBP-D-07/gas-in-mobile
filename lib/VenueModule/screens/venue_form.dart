import 'package:flutter/material.dart';
import 'package:gas_in/widgets/left_drawer.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

class VenueFormPage extends StatefulWidget {
  const VenueFormPage({super.key});

  @override
  State<VenueFormPage> createState() => _VenueFormPageState();
}

class _VenueFormPageState extends State<VenueFormPage> {
  final _formKey = GlobalKey<FormState>();

  // variabel untuk menyimpan state input form
  String _name = "";
  String _description = "";
  String _location = "";
  String _category = "";
  String _thumbnail = "";
  String _images = "";
  String _contact = "";

  // list kategori venue
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

  // custom input decoration untuk form fields
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

  // widget untuk label form fields
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

  // widget untuk membangun form input
  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      extendBodyBehindAppBar: true,
      // appBar dengan drawer
      appBar: AppBar(
        title: const Text(''),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A237E),
        elevation: 5,
        shadowColor: Colors.black.withValues(alpha: 0.5),
      ),
      // left drawer
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
                  color: Colors.white.withValues(alpha: 0.7),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
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
                      // field nama venue
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

                      // field deskripsi venue
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

                      // field lokasi venue
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

                      // field kontak venue
                      _buildLabel("Contact Number"),
                      TextFormField(
                        keyboardType: TextInputType.phone,
                        decoration: _customInputDecoration(hint: ""),
                        onChanged: (val) => setState(() => _contact = val),
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

                      // field kategori venue
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

                      // field images venue
                      _buildLabel("Images"),
                      TextFormField(
                        decoration: _customInputDecoration(
                          hint:
                              "https://example.com/img1.jpg, https://example.com/img2.jpg",
                        ),
                        maxLines: 3,
                        onChanged: (val) => setState(() => _images = val),
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return "Masukkan URL gambar!";
                          }
                          final urls = val
                              .split(',')
                              .map((e) => e.trim())
                              .where((e) => e.isNotEmpty);
                          for (var url in urls) {
                            final uri = Uri.tryParse(url);
                            if (uri == null || !uri.isAbsolute) {
                              return "Pastikan semua URL valid!";
                            }
                          }
                          return null;
                        },
                      ),

                      // field thumbnail venue
                      _buildLabel("Thumbnail"),
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

                      // submit form button
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
                              // validasi
                              if (_formKey.currentState!.validate()) {
                                List<String> images = _images
                                    .split(',')
                                    .map((e) => e.trim())
                                    .where((e) => e.isNotEmpty)
                                    .toList();

                                // json encode data form
                                final payload = jsonEncode({
                                  "name": _name,
                                  "description": _description,
                                  "location": _location,
                                  "thumbnail": _thumbnail,
                                  "images": images,
                                  "contact_number": _contact,
                                  "category": _category,
                                });

                                // kirim data ke backend
                                try {
                                  final response = await request.postJson(
                                    "https://nezzaluna-azzahra-gas-in.pbp.cs.ui.ac.id/venue/create-venue-flutter/",
                                    payload,
                                  );

                                  // tampilkan snackbar sesuai response
                                  if (context.mounted) {
                                    if (response != null &&
                                        response['status'] == 'success') {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: const Text(
                                            "Venue berhasil dibuat!",
                                          ),
                                          backgroundColor: Colors.purple[800],
                                        ),
                                      );
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => VenueFormPage(),
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
