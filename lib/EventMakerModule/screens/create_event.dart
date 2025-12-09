import 'package:flutter/material.dart';
import 'package:gas_in/widgets/left_drawer.dart';
import 'package:gas_in/screens/menu.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data';

String formatDate(DateTime date) {
  return DateFormat("EEEE, dd MMMM yyyy HH:mm", "id_ID").format(date);
}

class CreateEventPage extends StatefulWidget {
  const CreateEventPage({super.key});

  @override
  State<CreateEventPage> createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  final _formKey = GlobalKey<FormState>();

  String _name = "";
  String _description = "";
  String _location = "";
  String _category = "other";
  Uint8List? _webThumbnailBytes; // untuk web
  File? _thumbnailFile; // untuk mobile

  final ImagePicker _picker = ImagePicker();
  DateTime? _selectedDate;

  final List<Map<String, String>> _categories = [
    {"value": "running", "label": "Lari"},
    {"value": "badminton", "label": "Badminton"},
    {"value": "futsal", "label": "Futsal"},
    {"value": "football", "label": "Sepak Bola"},
    {"value": "basketball", "label": "Basket"},
    {"value": "cycling", "label": "Bersepeda"},
    {"value": "volleyball", "label": "Voli"},
    {"value": "yoga", "label": "Yoga"},
    {"value": "padel", "label": "Padel"},
    {"value": "other", "label": "Lainnya"},
  ];

  void resetForm() {
    setState(() {
      _name = "";
      _description = "";
      _location = "";
      _category = "other";
      _selectedDate = null;
      _thumbnailFile = null;
      _webThumbnailBytes = null;
    });

    _formKey.currentState?.reset(); // reset validator
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Create New Event",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        foregroundColor: Colors.white,

        // Hapus backgroundColor, ganti pakai gradient
        backgroundColor: Colors.transparent,
        elevation: 0,

        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF4338CA), // Indigo 700
                Color(0xFF6B21A8), // Purple 800
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // NAME
              TextFormField(
                decoration: InputDecoration(
                  labelText: "Event Name",
                  labelStyle: TextStyle(color: Colors.deepPurple),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.deepPurpleAccent,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.deepPurple,
                      width: 1.2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => _name = value,
                validator: (value) => (value == null || value.isEmpty)
                    ? "Nama can't be empty!"
                    : null,
              ),

              const SizedBox(height: 16),

              // DESCRIPTION
              TextFormField(
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: "Description",
                  labelStyle: TextStyle(color: Colors.deepPurple),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.deepPurpleAccent,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.deepPurple,
                      width: 1.2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => _description = value,
                validator: (value) => (value == null || value.isEmpty)
                    ? "Description can't be empty"
                    : null,
              ),

              const SizedBox(height: 16),

              // LOCATION
              TextFormField(
                decoration: InputDecoration(
                  labelText: "Location",
                  labelStyle: TextStyle(color: Colors.deepPurple),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.deepPurpleAccent,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.deepPurple,
                      width: 1.2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => _location = value,
                validator: (value) => (value == null || value.isEmpty)
                    ? "Location is required!"
                    : null,
              ),

              const SizedBox(height: 16),

              // DATE PICKER
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.deepPurple, width: 1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  iconColor: Colors.deepPurple,
                  textColor: Colors.deepPurple,
                  title: Text(
                    _selectedDate == null
                        ? "Choose Event Date"
                        : formatDate(_selectedDate!),
                    style: TextStyle(color: Colors.black),
                  ),
                  trailing: const Icon(
                    Icons.calendar_month,
                    color: Colors.deepPurple,
                  ),
                  onTap: () async {
                    // DATE PICKER
                    DateTime? picked = await showDatePicker(
                      context: context,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(
                        DateTime.now().year + 20,
                        DateTime.now().month,
                        DateTime.now().day,
                      ),
                      initialDate: DateTime.now(),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.light(
                              primary: Colors.deepPurple,
                              onPrimary: Colors.white,
                            ),
                            datePickerTheme: const DatePickerThemeData(
                              dayStyle: TextStyle(color: Colors.deepPurple),
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );

                    if (picked != null) {
                      // TIME PICKER
                      TimeOfDay? time = await showTimePicker(
                        // ignore: use_build_context_synchronously
                        context: context,
                        initialTime: TimeOfDay.now(),
                        initialEntryMode:
                            TimePickerEntryMode.input, // scroll mode
                        builder: (context, child) {
                          return MediaQuery(
                            data: MediaQuery.of(
                              context,
                            ).copyWith(alwaysUse24HourFormat: true),
                            child: Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: const ColorScheme.light(
                                  primary: Colors.deepPurple,
                                  onPrimary: Colors.white,
                                ),
                                timePickerTheme: TimePickerThemeData(
                                  dialHandColor: Colors.deepPurple,
                                  dialBackgroundColor:
                                      Colors.deepPurple.shade50,
                                  hourMinuteTextStyle:
                                      WidgetStateTextStyle.resolveWith((
                                        states,
                                      ) {
                                        if (states.contains(
                                          WidgetState.selected,
                                        )) {
                                          return const TextStyle(
                                            color: Colors.white,
                                            fontSize: 32,
                                          );
                                        }
                                        return const TextStyle(
                                          color: Colors.deepPurple,
                                          fontSize: 32,
                                        );
                                      }),
                                ),
                              ),
                              child: child!,
                            ),
                          );
                        },
                      );

                      if (time != null) {
                        setState(() {
                          _selectedDate = DateTime(
                            picked.year,
                            picked.month,
                            picked.day,
                            time.hour,
                            time.minute,
                          );
                        });
                      }
                    }
                  },
                ),
              ),

              const SizedBox(height: 16),

              // CATEGORY
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: InputDecoration(
                  labelText: "Category",
                  labelStyle: TextStyle(color: Colors.deepPurple),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.deepPurpleAccent,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.deepPurple,
                      width: 1.2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  border: OutlineInputBorder(),
                ),
                dropdownColor: Colors.white,

                items: _categories.map((cat) {
                  return DropdownMenuItem(
                    value: cat["value"], // ✅ String
                    child: Text(cat["label"]!), // ✅ label tampil
                  );
                }).toList(),

                onChanged: (value) {
                  setState(() {
                    _category = value!; // simpan value string
                  });
                },
              ),

              const SizedBox(height: 16),

              // THUMBNAIL PICKER
              Text("Thumbnail", style: TextStyle(color: Colors.deepPurple)),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () async {
                  final picked = await _picker.pickImage(
                    source: ImageSource.gallery,
                    imageQuality: 70,
                  );

                  if (picked != null) {
                    if (kIsWeb) {
                      // WEB → simpan sebagai bytes
                      final bytes = await picked.readAsBytes();
                      setState(() {
                        _webThumbnailBytes = bytes;
                        _thumbnailFile = null;
                      });
                    } else {
                      // MOBILE → simpan sebagai File
                      setState(() {
                        _thumbnailFile = File(picked.path);
                        _webThumbnailBytes = null;
                      });
                    }
                  }
                },
                child: Container(
                  width: double.infinity,
                  height: 180,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.deepPurple, width: 1),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white,
                  ),
                  child: (_thumbnailFile == null && _webThumbnailBytes == null)
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.image,
                              size: 50,
                              color: Colors.deepPurple,
                            ),
                            SizedBox(height: 8),
                            Text(
                              "Tap to upload image",
                              style: TextStyle(
                                color: Colors.deepPurple,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: kIsWeb
                              ? Image.memory(
                                  _webThumbnailBytes!,
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                )
                              : Image.file(
                                  _thumbnailFile!,
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                        ),
                ),
              ),

              const SizedBox(height: 24),

              // SUBMIT BUTTON
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 14,
                    ),
                  ),
                  onPressed: () async {
                    final requestProvider = context.read<CookieRequest>();

                    if (!requestProvider.loggedIn) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Anda harus login terlebih dahulu untuk membuat event.",
                          ),
                        ),
                      );
                      return;
                    }

                    if (!_formKey.currentState!.validate()) return;

                    if (_selectedDate == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please choose a date first"),
                        ),
                      );
                      return;
                    }

                    if (_thumbnailFile == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please choose a thumbnail first"),
                        ),
                      );
                      return;
                    }

                    final url = Uri.parse(
                      "http://localhost:8000/event-maker/api/create/",
                    );

                    var multipartRequest = http.MultipartRequest("POST", url);

                    final cookieHeader = request.headers['cookie'];
                    if (cookieHeader != null) {
                      multipartRequest.headers['cookie'] = cookieHeader;
                    }

                    final csrfToken = request.headers['X-CSRFToken'];
                    if (csrfToken != null) {
                      multipartRequest.headers['X-CSRFToken'] = csrfToken;
                    }

                    multipartRequest.fields['name'] = _name;
                    multipartRequest.fields['description'] = _description;
                    multipartRequest.fields['location'] = _location;
                    multipartRequest.fields['date'] = DateFormat(
                      "yyyy-MM-ddTHH:mm",
                    ).format(_selectedDate!);
                    multipartRequest.fields['category'] = _category;

                    if (kIsWeb) {
                      multipartRequest.files.add(
                        http.MultipartFile.fromBytes(
                          'thumbnail',
                          _webThumbnailBytes!,
                          filename: "thumbnail.jpg",
                        ),
                      );
                    } else {
                      multipartRequest.files.add(
                        await http.MultipartFile.fromPath(
                          'thumbnail',
                          _thumbnailFile!.path,
                        ),
                      );
                    }

                    final response = await multipartRequest.send();
                    final respStr = await response.stream.bytesToString();
                    final respJson = jsonDecode(respStr);

                    if (!context.mounted) return;

                    if (response.statusCode == 201) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Event created successfully"),
                        ),
                      );

                      resetForm();

                      // TODO: nanti push ke event page
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => MyHomePage()),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(respJson['message'])),
                      );
                    }
                  },
                  child: const Text("Save", style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
