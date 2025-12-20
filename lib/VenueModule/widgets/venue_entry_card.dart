import 'package:flutter/material.dart';
import 'package:gas_in/VenueModule/models/venue_model.dart';
import 'package:cached_network_image/cached_network_image.dart';

class VenueEntryCard extends StatelessWidget {
  // variables
  final VenueEntry venue;
  final VoidCallback onTap;
  final String? heroTag;

  // constructor
  const VenueEntryCard({
    super.key,
    required this.venue,
    required this.onTap,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12.0),
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
                child: AspectRatio(aspectRatio: 16 / 9, child: _buildImage()),
              ),

              Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // category
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0B3FF),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        venue.category.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 10.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // name
                    Text(
                      venue.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 6),

                    // description
                    Text(
                      venue.description.isEmpty
                          ? "Lorem ipsum dolor sit amet, consectetur adipiscing elit."
                          : (venue.description.length > 100
                                ? '${venue.description.substring(0, 100)}...'
                                : venue.description),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13.0,
                        height: 1.3,
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

  // widget untuk menampilkan gambar dengan hero animation jika heroTag tidak null
  Widget _buildImage() {
    final imageWidget = venue.thumbnail.trim().isNotEmpty
        ? CachedNetworkImage(
            imageUrl:
                'http://localhost:8000/api/proxy-image/?url=${Uri.encodeComponent(venue.thumbnail)}',
            width: double.infinity,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(color: Colors.grey[300]),
            errorWidget: (context, url, error) =>
                Image.asset('assets/venue.jpg', fit: BoxFit.cover),
          )
        : Image.asset(
            'assets/venue.jpg',
            width: double.infinity,
            fit: BoxFit.cover,
          );

    if (heroTag == null) {
      return imageWidget;
    }

    return Hero(tag: heroTag!, child: imageWidget);
  }
}
