import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gas_in/VenueModule/models/venue_model.dart';
import 'package:url_launcher/url_launcher.dart';

class VenueDetailPage extends StatelessWidget {
  final VenueEntry venue;

  const VenueDetailPage({super.key, required this.venue});

  String _formatDate(DateTime date) {
    // Simple date formatter without intl package
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _openWhatsApp(BuildContext context, String number) async {
    try {
      final cleaned = number.replaceAll(RegExp(r'[^0-9+]'), '');
      final phone = cleaned.startsWith('+') ? cleaned.substring(1) : cleaned;
      final uri = Uri.parse('https://wa.me/$phone');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(content: Text('Could not open WhatsApp')),
          );
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text('Error opening WhatsApp: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 2,
      ),
      body: Container(
        // Ensure the gradient fills the whole screen
        constraints: const BoxConstraints.expand(),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.purple[100]!,
              Colors.purple[50]!,
              Colors.purple[50]!,
              Colors.white,
            ],
            stops: const [0.0, 0.35, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Thumbnail (with fallback) ---
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: venue.thumbnail.trim().isNotEmpty
                      ? Image.network(
                          'http://localhost:8000/api/proxy-image/?url=${Uri.encodeComponent(venue.thumbnail)}',
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Image.asset(
                                'assets/venue.jpg',
                                fit: BoxFit.cover,
                              ),
                        )
                      : Image.asset(
                          'assets/venue.jpg',
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                ),

                // --- Content ---
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        venue.name,
                        style: const TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Owner / creator
                      Row(
                        children: [
                          const Icon(
                            Icons.person_outline,
                            size: 16,
                            color: Colors.black54,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            venue.ownerUsername != null &&
                                    venue.ownerUsername.toString().isNotEmpty
                                ? 'Owner: ${venue.ownerUsername}'
                                : 'Owner: BonDummy',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Category badge + date
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10.0,
                              vertical: 6.0,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE0B3FF),
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            child: Text(
                              venue.category.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _formatDate(venue.createdAt),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Location & Contact
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 18,
                            color: Colors.black54,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              venue.location.isNotEmpty ? venue.location : '-',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.phone_outlined,
                            size: 18,
                            color: Colors.black54,
                          ),
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: () =>
                                _openWhatsApp(context, venue.contactNumber),
                            child: SelectableText(
                              venue.contactNumber,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () {
                              final text = venue.contactNumber;
                              if (text.isNotEmpty) {
                                Clipboard.setData(ClipboardData(text: text));
                                ScaffoldMessenger.of(context)
                                  ..hideCurrentSnackBar()
                                  ..showSnackBar(
                                    const SnackBar(
                                      content: Text('Contact copied'),
                                    ),
                                  );
                              }
                            },
                            icon: const Icon(Icons.copy, size: 18),
                            tooltip: 'Copy contact',
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Images carousel (if any)
                      if (venue.images.isNotEmpty) ...[
                        const Text(
                          'Gallery',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 100,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: venue.images.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 8),
                            itemBuilder: (context, i) {
                              final img = venue.images[i];
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: img.trim().isNotEmpty
                                    ? Image.network(
                                        'http://localhost:8000/api/proxy-image/?url=${Uri.encodeComponent(img)}',
                                        width: 140,
                                        height: 100,
                                        fit: BoxFit.cover,
                                        errorBuilder: (c, e, s) => Image.asset(
                                          'assets/venue.jpg',
                                          width: 140,
                                          height: 100,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : Image.asset(
                                        'assets/venue.jpg',
                                        width: 140,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],

                      const Divider(),

                      // Full description
                      Text(
                        venue.description.isNotEmpty ? venue.description : '-',
                        style: const TextStyle(fontSize: 16.0, height: 1.6),
                        textAlign: TextAlign.justify,
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
