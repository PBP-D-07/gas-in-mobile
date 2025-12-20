import 'package:flutter/material.dart';
import 'package:gas_in/widgets/left_drawer.dart';
import 'package:gas_in/widgets/preview_menu_card.dart';
import 'package:gas_in/VenueModule/models/venue_model.dart';
import 'package:gas_in/VenueModule/screens/venue_detail.dart';
import 'package:gas_in/VenueModule/screens/venue_entry_list.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:gas_in/ForumModule/screens/forumMenu.dart';
import 'package:gas_in/screens/login.dart'; // Update this path to your LoginPage location

class MyHomePage extends StatelessWidget {
  MyHomePage({super.key});

  final List<ItemHomepage> items = [
    ItemHomepage("Events", Icons.event, Colors.deepPurple),
    ItemHomepage("Venue", Icons.place, Colors.deepPurple),
    ItemHomepage("Forum", Icons.newspaper, Colors.deepPurple),
  ];

  // fetch current user
  Future<Map<String, dynamic>?> fetchCurrentUser(CookieRequest request) async {
    try {
      final response = await request.get(
        'https://nezzaluna-azzahra-gas-in.pbp.cs.ui.ac.id/auth/current-user/',
      );
      if (response is Map && response['data'] != null) {
        return response['data'];
      }
      return null;
    } catch (e) {
      print('Error fetching current user: $e');
      return null;
    }
  }

  // fetch venue
  Future<List<VenueEntry>> fetchVenue(CookieRequest request) async {
    final response = await request.get(
      'https://nezzaluna-azzahra-gas-in.pbp.cs.ui.ac.id/venue/api/json/',
    );
    List<VenueEntry> listVenues = [];
    for (var d in response) {
      if (d != null) {
        listVenues.add(VenueEntry.fromJson(d));
      }
    }
    return listVenues;
  }

  // fetch event
  Future<List<dynamic>> fetchEvent(CookieRequest request) async {
    try {
      final response = await request.get(
        'https://nezzaluna-azzahra-gas-in.pbp.cs.ui.ac.id/event-maker/all/',
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
            FutureBuilder<Map<String, dynamic>?>(
              future: fetchCurrentUser(request),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.only(right: 16),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                } else if (snapshot.hasData && snapshot.data != null) {
                  final user = snapshot.data!;
                  final username = user['username'] ?? 'User';
                  return PopupMenuButton(
                    offset: const Offset(0, 50),
                    borderRadius: BorderRadius.circular(6),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        child: Row(
                          children: [
                            const Icon(Icons.logout, color: Colors.red),
                            const SizedBox(width: 12),
                            const Text(
                              "Logout",
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        onTap: () async {
                          await request.logout(
                            'https://nezzaluna-azzahra-gas-in.pbp.cs.ui.ac.id/auth/logout/',
                          );
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("You have been logged out"),
                              ),
                            );
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (context) => LoginPage()),
                            );
                          }
                        },
                      ),
                    ],
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.person, color: Colors.grey[800]),
                          const SizedBox(width: 8),
                          Text(
                            username,
                            style: TextStyle(
                              color: Colors.grey[800],
                              fontWeight: FontWeight.w500,
                              fontSize: 16
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                } else {
                  return Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: GestureDetector(
                      onTap: () {
                        // Navigate to login page
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Navigate to login")),
                        );
                      },
                      child: Text(
                        "Login",
                        style: TextStyle(
                          color: Colors.grey[800],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),

      drawer: const LeftDrawer(currentPage: 'home'),

      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Column(
                children: [
                  GridView.count(
                    padding: const EdgeInsets.all(20),
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: items.map((ItemHomepage item) {
                      return ItemCard(item);
                    }).toList(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // header section untuk event
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

            // preview card untuk event
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

            // header section untuk venue
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

            // preview card untuk venue
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

  // widget untuk header section dengan judul, description, dan tombol "See All"
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

  // widget untuk menampilkan state kosong
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

class ItemHomepage {
  final String name;
  final IconData icon;
  final Color color;

  ItemHomepage(this.name, this.icon, this.color);
}

class ItemCard extends StatelessWidget {
  final ItemHomepage item;

  const ItemCard(this.item, {super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Menampilkan pesan SnackBar saat kartu ditekan.
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(content: Text("Kamu telah menekan tombol ${item.name}!")),
          );
        if (item.name == "Forum") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ForumCommunity()),
          );
        }
        if (item.name == "Events") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ForumCommunity()),
          );
        }
        if (item.name == "Venue") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => VenueEntryListPage()),
          );
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Circular button dengan gradient
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [item.color, item.color.withValues(alpha: 0.7)],
              ),
              boxShadow: [
                BoxShadow(
                  color: item.color.withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Icon(item.icon, color: Colors.white, size: 40.0),
            ),
          ),
          const SizedBox(height: 12),
          // Text under the button
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              item.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF1A1A2E),
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
