import 'package:flutter/material.dart';
import 'package:gas_in/widgets/left_drawer.dart';
import 'package:gas_in/widgets/preview_menu_card.dart';
import 'package:gas_in/VenueModule/models/venue_model.dart';
import 'package:gas_in/VenueModule/screens/venue_detail.dart';
import 'package:gas_in/VenueModule/screens/venue_entry_list.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  Future<List<VenueEntry>> fetchVenue(CookieRequest request) async {
    final response = await request.get('http://localhost:8000/venue/api/json/');
    List<VenueEntry> listVenues = [];
    for (var d in response) {
      if (d != null) {
        listVenues.add(VenueEntry.fromJson(d));
      }
    }
    return listVenues;
  }

  Future<List<dynamic>> fetchEvent(CookieRequest request) async {
    try {
      final response = await request.get(
        'http://localhost:8000/event-maker/all/',
      );

      if (response is Map && response['data'] is List) {
        return (response['data'] as List).toList();
      } else if (response is List) {
        return response.toList();
      }
      return [];
    } catch (e) {
      print('Error fetching events: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: const Color(0xFFFDF7FF),

      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Row(
          children: [
            Expanded(
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset("assets/logo.png", width: 24),
                    const SizedBox(width: 8),
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFF4338CA), Color(0xFF6B21A8)],
                      ).createShader(bounds),
                      child: const Text(
                        'GAS.in',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                "Login",
                style: TextStyle(
                  color: Colors.grey[800],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
      drawer: const LeftDrawer(currentPage: 'home'),

      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),

            _buildSectionHeader(
              context: context,
              title: "Events",
              subtitle: "Check out upcoming events",
              onSeeAllTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    settings: const RouteSettings(name: 'event detail'),
                    builder: (context) =>
                        const VenueEntryListPage(drawerPage: 'event detail'),
                  ),
                );
              },
            ),

            SizedBox(
              height: 360,
              child: FutureBuilder(
                future: fetchEvent(request),
                builder: (context, AsyncSnapshot snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return _buildEmptyState('No events available.');
                  } else {
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: snapshot.data!.length > 5
                          ? 5
                          : snapshot.data!.length,
                      itemBuilder: (context, index) {
                        var event = snapshot.data![index];
                        return SizedBox(
                          width: 350,
                          child: EventEntryCard(
                            event: event,
                            onTap: () {
                              print("Event tapped");
                            },
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),

            const SizedBox(height: 10),

            _buildSectionHeader(
              context: context,
              title: "Venue",
              subtitle: "Explore popular venues near you",
              onSeeAllTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    settings: const RouteSettings(name: 'book venue'),
                    builder: (context) =>
                        const VenueEntryListPage(drawerPage: 'book venue'),
                  ),
                );
              },
            ),

            SizedBox(
              height: 360,
              child: FutureBuilder(
                future: fetchVenue(request),
                builder: (context, AsyncSnapshot snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return _buildEmptyState('No venues found.');
                  } else {
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: snapshot.data!.length > 5
                          ? 5
                          : snapshot.data!.length,
                      itemBuilder: (context, index) {
                        VenueEntry venue = snapshot.data![index];
                        return SizedBox(
                          width: 350,
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
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required BuildContext context,
    required String title,
    required String subtitle,
    required VoidCallback onSeeAllTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1A1A2E),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: onSeeAllTap,
            child: Text(
              'See All',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(20),
        child: Text(
          message,
          style: TextStyle(
            color: Colors.grey[500],
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }
}
