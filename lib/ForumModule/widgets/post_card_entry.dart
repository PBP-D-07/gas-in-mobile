import 'package:flutter/material.dart';
import 'package:gas_in/ForumModule/models/post_entry.dart';

class PostEntryCard extends StatefulWidget {
  final PostEntry post;
  final VoidCallback onTap;

  const PostEntryCard({
    super.key,
    required this.post,
    required this.onTap,
  });

  @override
  State<PostEntryCard> createState() => _PostEntryCardState();
}

class _PostEntryCardState extends State<PostEntryCard> {
  bool _thumbnailValid = true;

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return "${difference.inDays}d ago";
    } else if (difference.inHours > 0) {
      return "${difference.inHours}h ago";
    } else if (difference.inMinutes > 0) {
      return "${difference.inMinutes}m ago";
    } else {
      return "Just now";
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasThumbnail = _thumbnailValid &&
        widget.post.thumbnail != null &&
        widget.post.thumbnail!.trim().isNotEmpty;

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
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
            // thumbnail image if exist
            if (hasThumbnail)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: Image.network(
                  'http://localhost:8000/forum/proxy-image/?url=${Uri.encodeComponent(widget.post.thumbnail!)}',
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) {
                        setState(() {
                          _thumbnailValid = false;
                        });
                      }
                    });
                    return const SizedBox.shrink();
                  },
                ),
              ),

            // Content Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hot Badge 
                  if (widget.post.isHot == true)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.deepOrange],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(
                            Icons.local_fire_department,
                            size: 16,
                            color: Colors.white,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'HOT POST',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Post Description
                  Text(
                    widget.post.description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1B4B),
                      height: 1.3,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Author Info Row 
                  Row(
                    children: [
                      // Profile Picture Circle Avatar
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: const Color(0xFFD4B5E8),
                        child: Text(
                          (widget.post.ownerUsername ?? 'U')[0].toUpperCase(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4A4E9E),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Username and Time
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.post.ownerUsername ?? 'Unknown User',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Color(0xFF1A1B4B),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              _formatDate(widget.post.createdAt),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Category Badge 
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFE4D6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          widget.post.category.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFF6B35),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Stats Row 
                  Row(
                    children: [
                      _buildStatItem(
                        Icons.visibility,
                        '${widget.post.postViews}',
                      ),
                      const SizedBox(width: 20),
                      _buildStatItem(
                        Icons.favorite,
                        '${widget.post.likeCount}',
                      ),
                      const SizedBox(width: 20),
                      _buildStatItem(
                        Icons.comment,
                        '${widget.post.comments?.length ?? 0}',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}