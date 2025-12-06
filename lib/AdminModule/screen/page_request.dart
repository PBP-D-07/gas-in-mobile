import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class PageRequest extends StatefulWidget {
  const PageRequest({super.key});

  @override
  State<PageRequest> createState() => _PageRequestState();
}

class _PageRequestState extends State<PageRequest> {
  List<Event> pendingEvents = [];
  List<Event> approvedEvents = [];
  List<Event> rejectedEvents = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadEvents();
    });
  }

  Future<void> _loadEvents() async {
    final request = context.read<CookieRequest>();
    
    setState(() => isLoading = true);
    
    try {
      final response = await request.get('http://localhost:8000/admin/json/');
      
      if (response != null) {
        setState(() {
          pendingEvents = (response['pending_events'] as List)
              .map((e) => Event.fromJson(e))
              .toList();
          approvedEvents = (response['approved_events'] as List)
              .map((e) => Event.fromJson(e))
              .toList();
          rejectedEvents = (response['rejected_events'] as List)
              .map((e) => Event.fromJson(e))
              .toList();
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading events: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> _updateEventStatus(String eventId, String status) async {
    final request = context.read<CookieRequest>();
    
    try {
      final response = await request.post(
        'http://localhost:8000/admin/events/update-status/$eventId/',
        {'status': status},
      );
      
      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Event ${status}d successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        await _loadEvents();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update event: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteEvent(String eventId) async {
    final request = context.read<CookieRequest>();
    
    try {
      final response = await request.post(
        'http://localhost:8000/admin/events/delete/$eventId/',
        {},
      );
      
      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Event deleted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        await _loadEvents();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete event: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.deepPurpleAccent,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8E5FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.admin_panel_settings,
                    color: Color(0xFF6C5CE7),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                const Text(
                  'Events Request Management',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3436),
                  ),
                ),
                const Spacer(),
                // OutlinedButton.icon(
                //   onPressed: () {
                //     // TODO: Show create request dialog
                //   },
                //   icon: const Icon(Icons.add),
                //   label: const Text('New Request'),
                //   style: OutlinedButton.styleFrom(
                //     foregroundColor: const Color(0xFF6C5CE7),
                //     side: const BorderSide(color: Color(0xFF6C5CE7)),
                //     padding: const EdgeInsets.symmetric(
                //       horizontal: 20,
                //       vertical: 12,
                //     ),
                //   ),
                // ),
              ],
            ),
          ),

          // Kanban Board
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Request Screening (Pending)
                        Expanded(
                          child: _buildColumn(
                            title: 'Request Screening',
                            count: pendingEvents.length,
                            color: const Color(0xFFFFFDE7), 
                            borderColor: Colors.yellowAccent,
                            events: pendingEvents,
                            status: 'pending',
                          ),
                        ),
                        const SizedBox(width: 16),
                        
                        // Request In Progress (Approved)
                        Expanded(
                          child: _buildColumn(
                            title: 'Request Approve',
                            count: approvedEvents.length,
                            color: const Color(0xFFE8F5E9),
                            borderColor: Colors.greenAccent,
                            events: approvedEvents,
                            status: 'approved',
                          ),
                        ),
                        const SizedBox(width: 16),
                        
                        // Request Closed (Rejected)
                        Expanded(
                          child: _buildColumn(
                            title: 'Request Rejected',
                            count: rejectedEvents.length,
                            color: const Color(0xFFFFEBEE),
                            borderColor: Colors.redAccent,
                            events: rejectedEvents,
                            status: 'rejected',
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildColumn({
    required String title,
    required int count,
    required Color color,
    required Color borderColor,
    required List<Event> events,
    required String status,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Column Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: borderColor,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    count.toString(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: borderColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Event Cards
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              itemCount: events.length,
              itemBuilder: (context, index) {
                return _buildEventCard(events[index], status);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(Event event, String status) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Event Name
          Text(
            event.name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Color(0xFF2D3436),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),

          // Category Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              event.category,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF2196F3),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Date & Location
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  event.date,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.location_on, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  event.location,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // User Avatar & Name
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: const Color(0xFF6C5CE7),
                child: Text(
                  event.username[0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                event.username,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),

          // Action Buttons
          if (status == 'pending') ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _updateEventStatus(event.id, 'approve'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('✓ Approve', style: TextStyle(fontSize: 12)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _updateEventStatus(event.id, 'reject'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF5350),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('✗ Reject', style: TextStyle(fontSize: 12)),
                  ),
                ),
              ],
            ),
          ],
          if (status == 'approved') ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _updateEventStatus(event.id, 'pending'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF9800),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Revoke', style: TextStyle(fontSize: 12)),
              ),
            ),
          ],
          if (status == 'rejected') ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _deleteEvent(event.id),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF5350),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('🗑 Delete', style: TextStyle(fontSize: 12)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Event Model
class Event {
  final String id;
  final String name;
  final String category;
  final String date;
  final String location;
  final String username;

  Event({
    required this.id,
    required this.name,
    required this.category,
    required this.date,
    required this.location,
    required this.username,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? 'Unnamed Event',
      category: json['category'] ?? 'Other',
      date: json['date'] ?? '',
      location: json['location'] ?? 'N/A',
      username: json['user']?['username'] ?? json['username'] ?? 'Unknown',
    );
  }
}