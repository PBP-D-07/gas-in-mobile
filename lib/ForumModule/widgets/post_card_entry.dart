import 'package:flutter/material.dart';
import 'package:gas_in/ForumModule/models/post_entry.dart';

class PostEntryCard extends StatelessWidget {
  final PostEntry post;
  final VoidCallback onTap;

  const PostEntryCard({
    super.key,
    required this.post,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: InkWell(
        onTap: onTap,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
            side: BorderSide(color: Colors.grey.shade300),
          ),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // THUMBNAIL
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: post.thumbnail != null && post.thumbnail!.isNotEmpty
                      ? Image.network(
                          'http://localhost:8000/forum/proxy-image/?url=${Uri.encodeComponent(post.thumbnail!)}',
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _thumbnailPlaceholder(),
                        )
                      : _thumbnailPlaceholder(),
                ),

                const SizedBox(height: 12),

                // DESCRIPTION (as title)
                Text(
                  post.description.length > 60
                      ? '${post.description.substring(0, 60)}...'
                      : post.description,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                // CATEGORY
                Text(
                  "Category: ${post.category}",
                  style: const TextStyle(color: Colors.black54),
                ),

                const SizedBox(height: 8),

                // OWNER
                if (post.ownerUsername != null)
                  Text(
                    "By: ${post.ownerUsername}",
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),

                const SizedBox(height: 8),

                Row(
                  children: [
                    Icon(Icons.remove_red_eye, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text("${post.postViews}"),

                    const SizedBox(width: 16),

                    Icon(Icons.favorite, size: 16, color: Colors.redAccent),
                    const SizedBox(width: 4),
                    Text("${post.likeCount}"),

                    const SizedBox(width: 16),

                    if (post.isHot == true)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          "HOT",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _thumbnailPlaceholder() {
    return Container(
      height: 150,
      width: double.infinity,
      color: Colors.grey[300],
      child: const Center(
        child: Icon(Icons.image_not_supported, size: 40),
      ),
    );
  }
}
