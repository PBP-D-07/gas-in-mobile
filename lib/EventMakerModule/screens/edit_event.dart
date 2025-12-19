import 'package:flutter/material.dart';
import 'package:gas_in/screens/menu.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data';

class EditEventPage extends StatefulWidget {
  final String eventId;

  const EditEventPage({super.key, required this.eventId});

  @override
  State<EditEventPage> createState() => _EditEventPageState();
}

class _EditEventPageState extends State<EditEventPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;
  String _category = "other";
  Uint8List? _webThumbnailBytes; // untuk web
  File? _thumbnailFile;
  final ImagePicker _picker = ImagePicker();
  DateTime _selectedDate = DateTime.now();
  bool isLoading = true;

  final List<String> _categories = [
    "running",
    "badminton",
    "futsal",
    "football",
    "basketball",
    "cycling",
    "volleyball",
    "yoga",
    "padel",
    "other",
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _locationController = TextEditingController();
    fetchEventData();
  }

  Future<void> fetchEventData() async {
    final response = await http.get(
      Uri.parse("http://localhost:8000/event-maker/${widget.eventId}/"),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)["data"];

      setState(() {
        _nameController.text = data["name"] ?? "";
        _descriptionController.text = data["description"] ?? "";
        _locationController.text = data["location"] ?? "";

        _category = data["category"] ?? "other";

        _selectedDate = data["date"] != null
            ? DateTime.parse(data["date"])
            : DateTime.now();

        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  String formatDate(DateTime date) {
    return DateFormat("EEEE, dd MMMM yyyy HH:mm", "id_ID").format(date);
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      appBar: AppBar(
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
              const Text(
                "Edit Event",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Update your event details",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              // NAME
              TextFormField(
                controller: _nameController,
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
                validator: (value) => (value == null || value.isEmpty)
                    ? "Nama can't be empty!"
                    : null,
              ),
              const SizedBox(height: 16),

              // DESCRIPTION
              TextFormField(
                controller: _descriptionController,
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
                validator: (value) => (value == null || value.isEmpty)
                    ? "Description can't be empty"
                    : null,
              ),
              const SizedBox(height: 16),

              // LOCATION
              TextFormField(
                controller: _locationController,
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
                    formatDate(_selectedDate),
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
                items: _categories
                    .map(
                      (cat) => DropdownMenuItem(
                        value: cat,
                        child: Text(cat[0].toUpperCase() + cat.substring(1)),
                      ),
                    )
                    .toList(),
                onChanged: (value) => _category = value!,
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
                    setState(() {
                      _thumbnailFile = File(picked.path);
                    });
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
                  child: _thumbnailFile == null
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
                          child: Image.file(
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
                            "Anda harus login terlebih dahulu untuk mengedit event.",
                          ),
                        ),
                      );
                      return;
                    }

                    if (!_formKey.currentState!.validate()) return;

                    if (_thumbnailFile == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please choose a thumbnail first"),
                        ),
                      );
                      return;
                    }

                    final url = Uri.parse(
                      "http://localhost:8000/event-maker/api/edit/${widget.eventId}/",
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

                    multipartRequest.fields['name'] = _nameController.text;
                    multipartRequest.fields['description'] =
                        _descriptionController.text;
                    multipartRequest.fields['location'] =
                        _locationController.text;

                    multipartRequest.fields['date'] = DateFormat(
                      "yyyy-MM-ddTHH:mm",
                    ).format(_selectedDate);

                    multipartRequest.fields['category'] = _category;

                    // === Thumbnail ===
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

                    // === Send request ===
                    final response = await multipartRequest.send();
                    final respStr = await response.stream.bytesToString();
                    final respJson = jsonDecode(respStr);

                    if (!context.mounted) return;

                    if (response.statusCode == 200) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Event updated successfully"),
                        ),
                      );

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => MyHomePage()),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            respJson['message'] ?? "Failed to edit event",
                          ),
                        ),
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
