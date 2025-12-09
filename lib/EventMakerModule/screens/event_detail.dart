import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gas_in/EventMakerModule/models/event_model.dart';
import 'package:gas_in/EventMakerModule/screens/edit_event.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class EventDetailPage extends StatefulWidget {
  final String eventId;

  const EventDetailPage({super.key, required this.eventId});

  @override
  State<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  late Future<EventMaker> futureEvent;
  late Future<Map<String, dynamic>?> futureUser;

  @override
  void initState() {
    super.initState();
    futureEvent = fetchEventMaker(widget.eventId);
    futureUser = fetchCurrentUser();
  }

  String getFullImageUrl(String? thumbnail) {
    if (thumbnail == null) return "";
    if (thumbnail.startsWith("http")) return thumbnail;
    return "http://localhost:8000$thumbnail";
  }

  Future<Map<String, dynamic>?> fetchCurrentUser() async {
    final request = context.read<CookieRequest>();
    final response = await request.get(
      "http://localhost:8000/auth/current-user/",
    );

    if (response['data'] != null) {
      return response['data'];
    }
    return null;
  }

  Future<EventMaker> fetchEventMaker(String id) async {
    final url = Uri.parse("http://localhost:8000/event-maker/$id/");

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception("Failed to load event");
    }

    return EventMaker.fromJson(jsonDecode(response.body));
  }

  Future<void> deleteEvent(String id) async {
    final url = Uri.parse("http://localhost:8000/event-maker/api/delete/$id/");

    final response = await http.post(url);

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(
        // ignore: use_build_context_synchronously
        context,
      ).showSnackBar(const SnackBar(content: Text("Event deleted")));
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
    } else {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to delete event (${response.statusCode})"),
        ),
      );
    }
  }

  Future<void> joinEvent(String id) async {
    final request = context.read<CookieRequest>();

    final response = await request.post(
      "http://localhost:8000/event-maker/api/join/$id/",
      jsonEncode({}),
    );

    if (response != null && response['data'] != null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Successfully joined the event!")),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Failed to join: ${response?['message'] ?? 'Unknown error'}",
          ),
        ),
      );
    }
  }

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
        title: const Text(
          "Event Detail",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        foregroundColor: Colors.white,

        backgroundColor: Colors.transparent,
        elevation: 0,

        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4338CA), Color(0xFF6B21A8)],
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

      body: FutureBuilder(
        future: Future.wait([futureEvent, futureUser]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final event = (snapshot.data![0] as EventMaker).data;
          final user = snapshot.data![1] as Map<String, dynamic>?;

          final bool isOwner = user != null && user["id"] == event.owner.id;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: event.thumbnail != null
                      ? Image.network(
                          getFullImageUrl(event.thumbnail),
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          height: 200,
                          color: Colors.grey.shade300,
                          child: const Center(
                            child: Icon(Icons.image, size: 60),
                          ),
                        ),
                ),

                const SizedBox(height: 20),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    event.name,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 6),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    event.description,
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                  ),
                ),

                const SizedBox(height: 24),

                Card(
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.calendar_today),
                            const SizedBox(width: 8),
                            Text(formatDate(event.date)),
                          ],
                        ),
                        const SizedBox(height: 8),

                        Row(
                          children: [
                            const Icon(Icons.schedule),
                            const SizedBox(width: 8),
                            Text(formatTime(event.date)),
                          ],
                        ),
                        const SizedBox(height: 8),

                        Row(
                          children: [
                            const Icon(Icons.bolt),
                            const SizedBox(width: 8),
                            Text(event.categoryDisplay),
                          ],
                        ),
                        const SizedBox(height: 8),

                        Row(
                          children: [
                            const Icon(Icons.location_on),
                            const SizedBox(width: 8),
                            Text(event.location),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                if (isOwner) ...[
                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  EditEventPage(eventId: widget.eventId),
                            ),
                          );
                        },
                        icon: const Icon(Icons.edit),
                        label: const Text("Edit"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.white,
                        ),
                      ),

                      ElevatedButton.icon(
                        onPressed: () => deleteEvent(event.id),
                        icon: const Icon(Icons.delete),
                        label: const Text("Delete"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  // ======= NON-OWNER: JOIN BUTTON =======
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => joinEvent(event.id),
                      icon: const Icon(Icons.group_add),
                      label: const Text("Join Event"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
