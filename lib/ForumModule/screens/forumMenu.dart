import 'package:flutter/material.dart';
import 'package:gas_in/widgets/left_drawer.dart';
import 'package:gas_in/ForumModule/models/post_entry.dart';
import 'package:gas_in/ForumModule/screens/post_detail.dart';
import 'package:gas_in/ForumModule/screens/postlist_form.dart';
import 'package:gas_in/ForumModule/widgets/post_card_entry.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

class ForumCommunity extends StatefulWidget {
  const ForumCommunity({super.key});

  @override
  State<ForumCommunity> createState() => _ForumCommunityState();
}

class _ForumCommunityState extends State<ForumCommunity> {
  String _currentFilter = 'all';

  Future<List<PostEntry>> fetchPost(
    CookieRequest request,
    String filter,
  ) async {
    final url =
        'https://nezzaluna-azzahra-gas-in.pbp.cs.ui.ac.id/forum/json/?filter=$filter';

    try {
      final data = await request.get(url);

      if (data is Map && data.containsKey('error')) {
        throw Exception(data['message'] ?? 'Failed to load posts');
      }

      List<PostEntry> listPost = [];
      for (var d in data) {
        if (d != null) {
          listPost.add(PostEntry.fromJson(d));
        }
      }

      return listPost;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: const Color(0xFFE8D5F2),
      drawer: LeftDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Community Forum',
          style: TextStyle(
            color: Color(0xFF1A1B4B),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ElevatedButton.icon(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PostFormPage()),
                );
                setState(() {});
              },
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Post'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A4E9E),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Buttons
          Container(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildFilterButton(
                      'For You',
                      'all',
                      _currentFilter == 'all',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildFilterButton(
                      'My Post',
                      'my',
                      _currentFilter == 'my',
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Post List
          Expanded(child: _buildPostList(request, _currentFilter)),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String label, String filter, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentFilter = filter;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFD4B5E8) : const Color(0xFFE8D5F2),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: const Color(0xFF1A1B4B),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildPostList(CookieRequest request, String filter) {
    if (filter == "my" && !request.loggedIn) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.login, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Please login to see your posts',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/login');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A4E9E),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
              ),
              child: const Text('Login'),
            ),
          ],
        ),
      );
    }

    return FutureBuilder(
      future: fetchPost(request, filter),
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 60, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Error: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.inbox, size: 60, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  filter == "my"
                      ? 'You haven\'t created any posts yet.'
                      : 'There are no posts in Forum Community yet.',
                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        } else {
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.length,
            itemBuilder: (_, index) => Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: PostEntryCard(
                post: snapshot.data![index],
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          PostDetailPage(post: snapshot.data![index]),
                    ),
                  );
                  setState(() {});
                },
              ),
            ),
          );
        }
      },
    );
  }
}

class ItemHomepage {
  final String name;
  final IconData icon;

  ItemHomepage(this.name, this.icon);
}
