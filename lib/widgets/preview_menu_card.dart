import 'package:flutter/material.dart';
import 'package:gas_in/VenueModule/models/venue_model.dart';

class PreviewCard extends StatelessWidget {
  // variables
  final String title;
  final String description;
  final String category;
  final String? thumbnail;
  final VoidCallback onTap;

  // constructor
  const PreviewCard({
    super.key,
    required this.title,
    required this.description,
    required this.category,
    this.thumbnail,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(4, 8, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6.0),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4338CA).withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(6.0),
          onTap: onTap,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // image
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(6.0),
                ),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: thumbnail != null && thumbnail!.trim().isNotEmpty
                      ? Image.network(
                          'https://nezzaluna-azzahra-gas-in.pbp.cs.ui.ac.id/api/proxy-image/?url=${Uri.encodeComponent(thumbnail!)}',
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
              ),

              // card content
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // category
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0B3FF),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        category.isNotEmpty
                            ? category.toUpperCase()
                            : "General",
                        style: const TextStyle(
                          fontSize: 11.0,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // title
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                        letterSpacing: -0.5,
                      ),
                    ),

                    const SizedBox(height: 6),

                    // description
                    Text(
                      description.isEmpty
                          ? "Lorem ipsum dolor sit amet, consectetur adipiscing elit."
                          : description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12.0,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// venue entry card
class VenueEntryCard extends StatelessWidget {
  final VenueEntry venue;
  final VoidCallback onTap;

  const VenueEntryCard({super.key, required this.venue, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return PreviewCard(
      title: venue.name,
      description: venue.description,
      category: venue.category,
      thumbnail: venue.thumbnail,
      onTap: onTap,
    );
  }
}

// event entry card
class EventEntryCard extends StatelessWidget {
  final Map<String, dynamic> event;
  final VoidCallback onTap;

  const EventEntryCard({super.key, required this.event, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return PreviewCard(
      title: event['name'] ?? 'Event',
      description: event['description'] ?? '',
      category: event['category_display'] ?? event['category'] ?? 'Event',
      thumbnail: event['thumbnail'],
      onTap: onTap,
    );
  }
}
