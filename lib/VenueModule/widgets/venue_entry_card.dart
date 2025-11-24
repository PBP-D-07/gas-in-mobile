import 'package:flutter/material.dart';
import 'package:gas_in/VenueModule/models/venue_model.dart';

class VenueEntryCard extends StatelessWidget {
  final VenueEntry venue;
  final VoidCallback onTap;

  const VenueEntryCard({super.key, required this.venue, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        onTap: onTap,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
            side: BorderSide(color: Colors.grey.shade300),
          ),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thumbnail using aspect ratio so height scales with width
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.network(
                      'http://localhost:8000/proxy-image/?url=${Uri.encodeComponent(venue.thumbnail)}',
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[300],
                        child: const Center(child: Icon(Icons.broken_image)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Title
                Text(
                  venue.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),

                // Category
                Text(
                  'Category: ${venue.category}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12.0, color: Colors.black54),
                ),
                const SizedBox(height: 6),

                // Content preview limited to 2 lines
                Text(
                  venue.description.length > 100
                      ? '${venue.description.substring(0, 100)}...'
                      : venue.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.black54, fontSize: 13.0),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
