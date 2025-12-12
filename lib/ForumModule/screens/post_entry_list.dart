import 'package:flutter/material.dart';
import 'package:gas_in/ForumModule/models/post_entry.dart';
import 'package:gas_in/ForumModule/screens/post_detail.dart';
import 'package:gas_in/ForumModule/widgets/post_card_entry.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

class PostEntryListPage extends StatefulWidget {
  final String filter;
  const PostEntryListPage({super.key, required this.filter});

  @override
  State<PostEntryListPage> createState() => _PostEntryListPageState();
}

class _PostEntryListPageState extends State<PostEntryListPage> {
  Future<List<PostEntry>> fetchPost(CookieRequest request) async {
    // TODO: Replace the URL with your app's URL and don't forget to add a trailing slash (/)!
    // To connect Android emulator with Django on localhost, use URL http://10.0.2.2/
    // If you using chrome,  use URL http://localhost:8000
    
    final url = 'http://localhost:8000/forum/json/?filter=${widget.filter}';

    // Decode response to json format
    final data = await request.get(url);
    
    // Convert json data to PostEntry objects
    List<PostEntry> listPost = [];
    for (var d in data) {
      if (d != null) {
        listPost.add(PostEntry.fromJson(d));
      }
    }
    return listPost;
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Entry List'),
      ),
      body: FutureBuilder(
        future: fetchPost(request),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.data == null) {
            return const Center(child: CircularProgressIndicator());
          } else {
            if (!snapshot.hasData) {
              return const Column(
                children: [
                  Text(
                    'There are no post in Forum Community yet.',
                    style: TextStyle(fontSize: 20, color: Color(0xff59A5D8)),
                  ),
                  SizedBox(height: 8),
                ],
              );
            } else {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (_, index) => PostEntryCard(
                  post: snapshot.data![index],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PostDetailPage(
                          post: snapshot.data![index],
                        ),
                      ),
                    );
                  },
                ),
              );
            }
          }
        },
      ),
    );
  }
}