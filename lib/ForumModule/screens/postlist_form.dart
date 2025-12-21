import 'package:flutter/material.dart';
import 'package:gas_in/ForumModule/screens/forum_menu.dart';
import 'package:gas_in/theme/app_theme.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:gas_in/theme/app_text.dart';

class PostFormPage extends StatefulWidget {
  const PostFormPage({super.key});

  @override
  State<PostFormPage> createState() => _PostFormPageState();
}

class _PostFormPageState extends State<PostFormPage> {
  final _formKey = GlobalKey<FormState>();

  String _description = "";
  String _category = "running";
  String _thumbnail = "";

  final List<Map<String, String>> _categories = [
    {'value': 'running', 'label': 'Lari'},
    {'value': 'workout', 'label': 'Workout'},
    {'value': 'nutrition', 'label': 'Nutrisi'},
    {'value': 'event', 'label': 'Event'},
    {'value': 'recovery', 'label': 'Pemulihan'},
    {'value': 'motivation', 'label': 'Motivasi'},
  ];

  void resetForm() {
    setState(() {
      _description = "";
      _category = "running";
      _thumbnail = "";
    });
    _formKey.currentState?.reset();
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(''),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A237E),
        elevation: 5,
        shadowColor: Colors.black.withValues(alpha: 0.5),
      ),
      backgroundColor: Colors.white,

      body: SizedBox.expand(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFFFFFF), Color(0xFFF3E8FF)],
            ),
          ),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ===== Header dengan AppText =====
                  Text(
                    'Create New Post',
                    style: AppTheme.heading1.copyWith(
                      color: const Color(0xFF0F1B5C),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Let others around you know what’s happening",
                    style: AppTheme.bodyMedium,
                  ),
                  const SizedBox(height: 28),

                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ===== DESCRIPTION =====
                        TextFormField(
                          maxLines: 5,
                          decoration: InputDecoration(
                            labelText: "Post Description",
                            labelStyle: AppText.bodyM.copyWith(
                              color: Colors.deepPurple,
                            ),
                            hintText: "What's on your mind?",
                            hintStyle: AppText.bodyS,
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.deepPurpleAccent,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.deepPurple,
                                width: 1.2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            border: const OutlineInputBorder(),
                          ),
                          style: AppText.bodyM,
                          onChanged: (value) {
                            setState(() {
                              _description = value;
                            });
                          },
                          validator: (value) => value == null || value.isEmpty
                              ? "Description can't be empty!"
                              : null,
                        ),

                        const SizedBox(height: 16),

                        // ===== CATEGORY =====
                        DropdownButtonFormField<String>(
                          initialValue: _category,
                          decoration: InputDecoration(
                            labelText: "Category",
                            labelStyle: AppText.bodyM.copyWith(
                              color: Colors.deepPurple,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.deepPurpleAccent,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.deepPurple,
                                width: 1.2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            border: const OutlineInputBorder(),
                          ),
                          style: AppText.bodyM,
                          dropdownColor: Colors.white,
                          items: _categories.map((cat) {
                            return DropdownMenuItem(
                              value: cat['value'],
                              child: Text(cat['label']!, style: AppText.bodyM),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _category = value!;
                            });
                          },
                        ),

                        const SizedBox(height: 16),

                        // ===== THUMBNAIL =====
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: "Thumbnail URL (Optional)",
                            labelStyle: AppText.bodyM.copyWith(
                              color: Colors.deepPurple,
                            ),
                            hintText: "Enter image URL",
                            hintStyle: AppText.bodyS,
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.deepPurpleAccent,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.deepPurple,
                                width: 1.2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            border: const OutlineInputBorder(),
                          ),
                          style: AppText.bodyM,
                          onChanged: (value) {
                            setState(() {
                              _thumbnail = value;
                            });
                          },
                        ),

                        const SizedBox(height: 24),

                        // ===== SUBMIT BUTTON =====
                        Center(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 40,
                                vertical: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () async {
                              if (!request.loggedIn) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "You must login first to create a post.",
                                      style: AppText.bodyM.copyWith(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                );
                                return;
                              }

                              if (!_formKey.currentState!.validate()) return;

                              final response = await request.postJson(
                                "https://nezzaluna-azzahra-gas-in.pbp.cs.ui.ac.id/forum/create-flutter/",
                                jsonEncode({
                                  "description": _description,
                                  "thumbnail": _thumbnail,
                                  "category": _category,
                                }),
                              );

                              if (!context.mounted) return;

                              if (response['status'] == 'success') {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "Post created successfully!",
                                      style: AppText.bodyM.copyWith(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                );

                                resetForm();

                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const ForumCommunity(),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      response['message'] ??
                                          "Failed to create post",
                                      style: AppText.bodyM.copyWith(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                );
                              }
                            },
                            child: Text("Post", style: AppText.button),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
