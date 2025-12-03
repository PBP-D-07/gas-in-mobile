import 'package:flutter/material.dart';
import 'package:gas_in/widgets/left_drawer.dart';
import 'package:gas_in/screens/menu.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class EditEventPage extends StatefulWidget {
  final Map<String, dynamic> initialData;

  const EditEventPage({super.key, required this.initialData});

  @override
  State<EditEventPage> createState() => _EditEventPageState();
}

class _EditEventPageState extends State<EditEventPage> {
  final _formKey = GlobalKey<FormState>();

  late String _name;
  late String _description;
  late String _location;
  late String _category;
  File? _thumbnailFile;
  final ImagePicker _picker = ImagePicker();
  DateTime? _selectedDate;

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

    _name = widget.initialData["name"] ?? "";
    _description = widget.initialData["description"] ?? "";
    _location = widget.initialData["location"] ?? "";
    _category = widget.initialData["category"] ?? "other";
    _selectedDate = widget.initialData["date"] != null
        ? DateTime.parse(widget.initialData["date"])
        : DateTime.now();
  }

  String formatDate(DateTime date) {
    return DateFormat("EEEE, dd MMMM yyyy HH:mm", "id_ID").format(date);
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Edit Event",
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
                initialValue: _name,
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
                initialValue: _description,
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
                initialValue: _location,
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
                                      MaterialStateTextStyle.resolveWith((
                                        states,
                                      ) {
                                        if (states.contains(
                                          MaterialState.selected,
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
                value: _category,
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
                    if (!_formKey.currentState!.validate()) return;
                    if (_selectedDate == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Please choose a date first")),
                      );
                      return;
                    }
                    if (_thumbnailFile == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Please choose a thumbnail first"),
                        ),
                      );
                      return;
                    }

                    final requestProvider = context.read<CookieRequest>();

                    final url = Uri.parse(
                      "https://nezzaluna-azzahra-gas-in.pbp.cs.ui.ac.id/event-maker/api/edit",
                    );

                    var request = http.MultipartRequest("POST", url);

                    final cookies = requestProvider.cookies;
                    if (cookies.isNotEmpty) {
                      request.headers["Cookie"] = cookies.entries
                          .map((e) => '${e.key}=${e.value}')
                          .join('; ');

                      if (cookies.containsKey('csrftoken')) {
                        request.headers['X-CSRFToken'] = cookies['csrftoken']!
                            .toString();
                      }
                    }

                    request.fields['name'] = _name;
                    request.fields['description'] = _description;
                    request.fields['location'] = _location;
                    request.fields['date'] = _selectedDate!.toIso8601String();
                    request.fields['category'] = _category;

                    request.files.add(
                      await http.MultipartFile.fromPath(
                        'thumbnail',
                        _thumbnailFile!.path,
                      ),
                    );

                    final response = await request.send();
                    final respStr = await response.stream.bytesToString();
                    final respJson = jsonDecode(respStr);

                    if (!context.mounted) return;

                    if (respJson['status'] == 'success') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Event created successfully")),
                      );
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => MyHomePage()),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Failed to create event")),
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
