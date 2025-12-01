import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:intl/intl.dart';

class EventDetailPage extends StatelessWidget {
  final String name;
  final String description;
  final String location;
  final String category;
  final File? thumbnailFile;
  final DateTime? selectedDate;

  const EventDetailPage({
    super.key,
    required this.name,
    required this.description,
    required this.location,
    required this.category,
    required this.thumbnailFile,
    required this.selectedDate,
  });

  String formatDate(DateTime date) {
    return DateFormat("EEEE, dd MMMM yyyy", "id_ID").format(date);
  }

  String formatTime(DateTime date) {
    return DateFormat("HH:mm", "id_ID").format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Event Detail", style: TextStyle(fontWeight: FontWeight.bold),),
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

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: thumbnailFile != null
                  ? Image.file(
                      thumbnailFile!,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      height: 200,
                      width: double.infinity,
                      color: Colors.grey.shade300,
                      child: Center(
                        child: Icon(
                          Icons.image,
                          size: 60,
                          color: Colors.deepPurple.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 10),

            if (thumbnailFile != null)
              Text(
                basename(thumbnailFile!.path),
                style: const TextStyle(color: Colors.black54),
              ),

            const SizedBox(height: 24),

            /// Event Name
            Row(
              children: [
                Text(
                  name,
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  description,
                  style: TextStyle(fontSize: 20, color: Colors.grey),
                ),
              ],
            ),

            const SizedBox(height: 16),

            /// Location
            SizedBox(
              width: double.infinity,
              child: Card(
                elevation: 8,
                shadowColor: Colors.black.withValues(alpha: .5),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Location

                      /// Date
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 20),
                          const SizedBox(width: 8),

                          /// Text
                          Text(
                            selectedDate == null
                                ? "Not set"
                                : formatDate(selectedDate!),
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      Row(
                        children: [
                          const Icon(Icons.schedule, size: 20),
                          const SizedBox(width: 8),

                          /// Text
                          Text(
                            selectedDate == null
                                ? "Not set"
                                : formatTime(selectedDate!),
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.bolt, size: 20),
                          const SizedBox(width: 8),

                          /// Text
                          Text(category, style: const TextStyle(fontSize: 16)),
                        ],
                      ),

                      const SizedBox(height: 8),

                      Row(
                        children: [
                          const Icon(Icons.location_pin, size: 20),
                          const SizedBox(width: 8),

                          /// Text
                          Text(
                            selectedDate == null ? "Not set" : location,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),

                      /// Category
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
