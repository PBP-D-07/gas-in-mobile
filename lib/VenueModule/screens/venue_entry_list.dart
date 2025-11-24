import 'package:flutter/material.dart';
import 'package:gas_in/VenueModule/models/venue_model.dart';
import 'package:gas_in/widgets/left_drawer.dart';
import 'package:gas_in/VenueModule/screens/venue_detail.dart';
import 'package:gas_in/VenueModule/widgets/venue_entry_card.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

class VenueEntryListPage extends StatefulWidget {
  const VenueEntryListPage({super.key});

  @override
  State<VenueEntryListPage> createState() => _VenueEntryListPageState();
}

class _VenueEntryListPageState extends State<VenueEntryListPage> {
  Future<List<VenueEntry>> fetchNews(CookieRequest request) async {
    // To connect Android emulator with Django on localhost, use URL http://10.0.2.2/
    // If you using chrome,  use URL http://localhost:8000

    final response = await request.get('http://localhost:8000/venue/api/json/');

    // Decode response to json format
    var data = response;

    // Convert json data to VenueEntry objects
    List<VenueEntry> listVenues = [];
    for (var d in data) {
      if (d != null) {
        listVenues.add(VenueEntry.fromJson(d));
      }
    }
    return listVenues;
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    return Scaffold(
      appBar: AppBar(title: const Text('Book Venues')),
      drawer: const LeftDrawer(),
      body: FutureBuilder(
        future: fetchNews(request),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.data == null) {
            return const Center(child: CircularProgressIndicator());
          } else {
            if (!snapshot.hasData) {
              return const Column(
                children: [
                  Text(
                    'There are no news in football news yet.',
                    style: TextStyle(fontSize: 20, color: Color(0xff59A5D8)),
                  ),
                  SizedBox(height: 8),
                ],
              );
            } else {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (_, index) => VenueEntryCard(
                  venue: snapshot.data![index],
                  onTap: () {
                    // Navigate to news detail page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            VenueDetailPage(venue: snapshot.data![index]),
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
