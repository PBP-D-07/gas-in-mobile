import 'package:flutter/material.dart';
import 'package:gas_in/ForumModule/models/post_entry.dart';
import 'package:gas_in/ForumModule/screens/edit_post.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

class PostDetailPage extends StatefulWidget {
  final PostEntry post;

  const PostDetailPage({super.key, required this.post});

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  final _commentController = TextEditingController();
  late List<Comment> _comments;
  bool _isLiked = false;
  int _likeCount = 0;
  int _views = 0;
  bool _thumbnailValid = true;

  @override
  void initState() {
    super.initState();
    _comments = widget.post.comments ?? [];
    _likeCount = widget.post.likeCount;
    _views = widget.post.postViews;
    _incrementViews();
    _checkLikeStatus();
  }

  void _showSnackBar({
    required String message,
    required IconData icon,
    Color backgroundColor = const Color(0xFF4A4E9E),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Future<void> _checkLikeStatus() async {
    final request = context.read<CookieRequest>();
    if (!request.loggedIn) return;

    try {
      final response = await request.get(
        'https://nezzaluna-azzahra-gas-in.pbp.cs.ui.ac.id/forum/flutter/check-like/${widget.post.id}/',
      );
      setState(() {
        _isLiked = response['liked'] ?? false;
        _likeCount = response['like_count'] ?? widget.post.likeCount;
      });
    } catch (e) {
      print('Error checking like status: $e');
    }
  }

  Future<void> _toggleLike() async {
    final request = context.read<CookieRequest>();
    if (!request.loggedIn) {
      _showSnackBar(message: 'Please login to like posts', icon: Icons.login);
      return;
    }

    try {
      final response = await request.post(
        'https://nezzaluna-azzahra-gas-in.pbp.cs.ui.ac.id/forum/flutter/like/${widget.post.id}/',
        {},
      );
      setState(() {
        _isLiked = response['liked'];
        _likeCount = response['like_count'];
      });
    } catch (e) {
      print('Error toggling like: $e');
    }
  }

  Future<void> _incrementViews() async {
    final request = context.read<CookieRequest>();
    try {
      final response = await request.post(
        'https://nezzaluna-azzahra-gas-in.pbp.cs.ui.ac.id/forum/view/${widget.post.id}/',
        {},
      );

      setState(() {
        _views = response['views'];
      });
    } catch (e) {
      print('Error incrementing views: $e');
    }
  }

  Future<void> _addComment() async {
    final request = context.read<CookieRequest>();
    if (!request.loggedIn) {
      _showSnackBar(message: 'Please login to comment', icon: Icons.login);
      return;
    }

    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    try {
      final response = await request.post(
        'https://nezzaluna-azzahra-gas-in.pbp.cs.ui.ac.id/forum/comment/${widget.post.id}/add/',
        {'content': content},
      );

      if (response['status'] == 'success') {
        setState(() {
          _comments.insert(0, Comment.fromJson(response['comment']));
        });
        _commentController.clear();
      } else {
        _showSnackBar(
          message: response['message'] ?? 'Cannot add comment',
          icon: Icons.error_outline,
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      _showSnackBar(
        message: 'This is a dummy post. Comments are disabled.',
        icon: Icons.info_outline,
      );
    }
  }

  Future<void> _deletePost() async {
    final request = context.read<CookieRequest>();

    try {
      final response = await request.post(
        'https://nezzaluna-azzahra-gas-in.pbp.cs.ui.ac.id/forum/flutter/delete/${widget.post.id}/',
        {},
      );

      if (response['status'] == 'success') {
        _showSnackBar(
          message: 'Post deleted successfully',
          icon: Icons.check_circle,
        );
        Navigator.pop(context);
      }
    } catch (e) {
      print('Delete error: $e');
      _showSnackBar(
        message: 'Failed to delete post',
        icon: Icons.error_outline,
        backgroundColor: Colors.red,
      );
    }
  }

  Future<void> _confirmDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete Post',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text('Are you sure you want to delete this post?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      _deletePost();
    }
  }

  void _openEditPage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditPostPage(
          postId: widget.post.id,
          initialDescription: widget.post.description,
          initialThumbnail: widget.post.thumbnail,
        ),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        widget.post.description = result["description"];
        widget.post.thumbnail = result["thumbnail"]?.trim().isEmpty == true
            ? null
            : result["thumbnail"];
      });
    }
  }

  String _formatDate(DateTime date) {
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
    return '${date.day} ${months[date.month - 1]} ${date.year}, '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatCommentDate(DateTime date) {
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
    final hasThumbnail =
        _thumbnailValid &&
        widget.post.thumbnail != null &&
        widget.post.thumbnail!.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFE8D5F2),
      appBar: AppBar(
        title: const Text('Post Detail'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A1B4B),
        elevation: 0,
        actions: [
          if (widget.post.isOwner == true) ...[
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: _openEditPage,
              tooltip: 'Edit Post',
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _confirmDelete,
              tooltip: 'Delete Post',
            ),
          ],
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Post Card Container
            Container(
              margin: const EdgeInsets.all(16),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Thumbnail Image
                  if (hasThumbnail)
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      child: Image.network(
                        'https://nezzaluna-azzahra-gas-in.pbp.cs.ui.ac.id/forum/proxy-image/?url=${Uri.encodeComponent(widget.post.thumbnail!)}',
                        width: double.infinity,
                        height: 250,
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

                  Padding(
                    padding: const EdgeInsets.all(20.0),
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
                                colors: [Colors.orange, Colors.deepOrange],
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
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1B4B),
                            height: 1.3,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Author Info Row
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: const Color(0xFFD4B5E8),
                              child: Text(
                                (widget.post.ownerUsername ?? 'U')[0]
                                    .toUpperCase(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF4A4E9E),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
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
                            _buildStatItem(Icons.visibility, '$_views'),
                            const SizedBox(width: 20),
                            _buildStatItem(Icons.favorite, '$_likeCount'),
                            const SizedBox(width: 20),
                            _buildStatItem(
                              Icons.comment,
                              '${_comments.length}',
                            ),
                          ],
                        ),

                        const Divider(height: 32, thickness: 1),

                        // Action Buttons Row
                        Row(
                          children: [
                            Expanded(
                              child: _buildActionButton(
                                icon: _isLiked
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                label: 'Like',
                                color: _isLiked ? Colors.red : Colors.grey,
                                onTap: _toggleLike,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Comments Section
            Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
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
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Comments Header
                    Row(
                      children: [
                        const Text(
                          'Comments',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1B4B),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8D5F2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${_comments.length}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4A4E9E),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Add Comment Box
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE0E0E0)),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: const Color(0xFFD4B5E8),
                            child: const Icon(
                              Icons.person,
                              color: Color(0xFF4A4E9E),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _commentController,
                              decoration: const InputDecoration(
                                hintText: 'Write a comment...',
                                border: InputBorder.none,
                                hintStyle: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                              maxLines: null,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF4A4E9E),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.send, size: 20),
                              color: Colors.white,
                              onPressed: _addComment,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Comments List
                    _comments.isEmpty
                        ? Container(
                            padding: const EdgeInsets.all(32),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.comment_outlined,
                                    size: 56,
                                    color: Colors.grey[300],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'No comments yet',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Be the first to comment!',
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _comments.length,
                            itemBuilder: (context, index) {
                              final comment = _comments[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8F9FA),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFFE8D5F2),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 18,
                                          backgroundColor: const Color(
                                            0xFFD4B5E8,
                                          ),
                                          child: Text(
                                            comment.user[0].toUpperCase(),
                                            style: const TextStyle(
                                              color: Color(0xFF4A4E9E),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                comment.user,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                  color: Color(0xFF1A1B4B),
                                                ),
                                              ),
                                              Text(
                                                _formatCommentDate(
                                                  comment.createdAt,
                                                ),
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      comment.content,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF1A1B4B),
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
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

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}
