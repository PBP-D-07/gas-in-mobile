import 'package:flutter/material.dart';
import 'package:gas_in/VenueModule/models/venue_model.dart';
import 'package:gas_in/widgets/left_drawer.dart';
import 'package:gas_in/VenueModule/screens/venue_detail.dart';
import 'package:gas_in/VenueModule/widgets/venue_entry_card.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:shimmer/shimmer.dart';

class VenueEntryListPage extends StatefulWidget {
  // variable untuk menandai current page/active page
  final String drawerPage;

  // constructor
  const VenueEntryListPage({super.key, this.drawerPage = 'book venue'});

  @override
  State<VenueEntryListPage> createState() => _VenueEntryListPageState();
}

class _VenueEntryListPageState extends State<VenueEntryListPage> {
  // fetch venue
  Future<List<VenueEntry>> fetchVenue(CookieRequest request) async {
    final response = await request.get('http://localhost:8000/venue/api/json/');

    var data = response;

    List<VenueEntry> listVenues = [];
    for (var d in data) {
      if (d != null) {
        listVenues.add(VenueEntry.fromJson(d));
      }
    }
    return listVenues;
  }

  // widget untuk menampilkan shimmer loading card
  Widget _buildShimmerCard() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 6.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 160,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(6.0),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(height: 12, width: 60, color: Colors.white),
                    const SizedBox(height: 10),
                    Container(height: 16, width: 180, color: Colors.white),
                    const SizedBox(height: 8),
                    Container(height: 14, width: 140, color: Colors.white),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
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
        shadowColor: Colors.black.withValues(alpha: 0.5),
      ),

      // left drawer
      drawer: LeftDrawer(currentPage: widget.drawerPage),

      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.purple[100]!,
              Colors.purple[50]!,
              Colors.purple[50]!,
              Colors.white,
            ],
            stops: [0.0, 0.35, 0.7, 1.0],
          ),
        ),

        // refresh indicator untuk pull to refresh
        child: RefreshIndicator(
          onRefresh: () => fetchVenue(request),
          child: FutureBuilder(
            future: fetchVenue(request),
            builder: (context, AsyncSnapshot snapshot) {
              if (snapshot.data == null) {
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  itemCount: 3,
                  itemBuilder: (_, __) => _buildShimmerCard(),
                );
              } else {
                if (!snapshot.hasData) {
                  return const Column(
                    children: [
                      Text(
                        'There are no news in football news yet.',
                        style: TextStyle(
                          fontSize: 20,
                          color: Color(0xff59A5D8),
                        ),
                      ),
                      SizedBox(height: 8),
                    ],
                  );
                } else {
                  return CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(25, 30, 16, 8),
                          child: ShaderMask(
                            shaderCallback: (bounds) =>
                                const LinearGradient(
                                  colors: [
                                    Color(0xFF4338CA),
                                    Color(0xFF6B21A8),
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

                            // judul halaman
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

                      // description halaman
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(25, 0, 16, 16),
                          child: Text(
                            'Found The Best Sports Venues In Your Area with gas.in!',
                            style: TextStyle(fontSize: 18, color: Colors.black),
                          ),
                        ),
                      ),

                      // list venue entry
                      SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final venue = snapshot.data![index];
                          final heroTag = 'venue-${venue.id}';
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 30.0,
                              vertical: 6.0,
                            ),
                            child: VenueEntryCard(
                              venue: venue,
                              heroTag: heroTag,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => VenueDetailPage(
                                      venue: venue,
                                      heroTag: heroTag,
                                    ),
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
      ),
    );
  }
}
