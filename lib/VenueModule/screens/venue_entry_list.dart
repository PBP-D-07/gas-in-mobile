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
      appBar: AppBar(
        title: const Text(''),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A237E),
        elevation: 5,
        shadowColor: Colors.black.withOpacity(0.5),
      ),
      drawer: const LeftDrawer(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.purple[100]!, // deep purple at bottom
              Colors.purple[50]!, // medium purple
              Colors.purple[50]!, // light purple
              Colors.white, // fade to transparent at top
            ],
            stops: [0.0, 0.35, 0.7, 1.0],
          ),
        ),
        child: FutureBuilder(
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
                // Make header part of the scrollable content so it's not fixed
                return CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(25, 30, 16, 8),
                        child: ShaderMask(
                          shaderCallback: (bounds) =>
                              const LinearGradient(
                                colors: [
                                  Color(0xFF4338CA), // indigo-700
                                  Color(0xFF6B21A8), // purple-800
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ).createShader(
                                Rect.fromLTWH(
                                  0,
                                  0,
                                  bounds.width,
                                  bounds.height,
                                ),
                              ),
                          child: const Padding(
                            padding: EdgeInsets.only(right: 2),
                            child: Text(
                              'Book Your Venues!',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(25, 0, 16, 16),
                        child: Text(
                          'Found The Best Sports Venues In Your Area with gas.in!',
                          style: TextStyle(fontSize: 18, color: Colors.black),
                        ),
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final venue = snapshot.data![index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30.0,
                            vertical: 6.0,
                          ),
                          child: VenueEntryCard(
                            venue: venue,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      VenueDetailPage(venue: venue),
                                ),
                              );
                            },
                          ),
                        );
                      }, childCount: snapshot.data!.length),
                    ),
                  ],
                );
              }
            }
          },
        ),
      ),
    );
  }
}
