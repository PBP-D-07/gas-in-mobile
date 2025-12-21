import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gas_in/theme/app_text.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class EditPostPage extends StatefulWidget {
  final dynamic postId;
  final String initialDescription;
  final String? initialThumbnail;

  const EditPostPage({
    super.key,
    required this.postId,
    required this.initialDescription,
    this.initialThumbnail,
  });

  @override
  State<EditPostPage> createState() => _EditPostPageState();
}

class _EditPostPageState extends State<EditPostPage> {
  late TextEditingController _descController;
  late TextEditingController _thumbController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _descController = TextEditingController(text: widget.initialDescription);
    _thumbController = TextEditingController(
      text: widget.initialThumbnail ?? "",
    );
  }

  Future<void> _updatePost() async {
    setState(() => _isLoading = true);

    final request = context.read<CookieRequest>();

    try {
      final response = await request.postJson(
        'https://nezzaluna-azzahra-gas-in.pbp.cs.ui.ac.id/forum/flutter/update/${widget.postId}/',
        jsonEncode({
          "description": _descController.text,
          "thumbnail": _thumbController.text,
        }),
      );

      setState(() => _isLoading = false);

      if (response["success"] == true && mounted) {
        Navigator.pop(context, {
          "description": _descController.text,
          "thumbnail": _thumbController.text,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text("Post updated successfully!"),
              ],
            ),
            backgroundColor: const Color(0xFF4A4E9E),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(response["error"] ?? "Failed to update post"),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text("Error: $e")),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8D5F2),
      appBar: AppBar(
        title: const Text("Edit Post"),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A1B4B),
        elevation: 0,
      ),
      body: SizedBox.expand(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFFFFF),
              Color(0xFFF3E8FF),
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                // Header
                const Text(
                  'Edit Your Post',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1B4B),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Update your post content and thumbnail',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 24),

                // description
                TextFormField(
                  controller: _descController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    labelText: "Post Description",
                    labelStyle: AppText.bodyM.copyWith(
                      color: Colors.deepPurple,
                    ),
                    hintText: "Update your post description",
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
                ),


                const SizedBox(height: 24),

                // thumbnail
                TextFormField(
                  controller: _thumbController,
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
                ),

                const SizedBox(height: 32),

                // save button
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
                    onPressed: _isLoading ? null : _updatePost,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Text(
                            "Save",
                            style: AppText.button,
                          ),
                  ),
                ),


                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
      )
      )
    );
  }

  @override
  void dispose() {
    _descController.dispose();
    _thumbController.dispose();
    super.dispose();
  }
}