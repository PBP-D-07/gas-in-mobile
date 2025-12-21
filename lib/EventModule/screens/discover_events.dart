import 'package:flutter/material.dart';
import 'package:gas_in/EventMakerModule/screens/event_detail.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:gas_in/EventModule/screens/saved_search.dart';
import 'package:gas_in/EventModule/widgets/save_filter_dialog.dart';
import 'package:gas_in/EventMakerModule/screens/create_event.dart';
import 'package:gas_in/widgets/left_drawer.dart';
import 'package:intl/intl.dart';

class DiscoverEventsPage extends StatefulWidget {
  const DiscoverEventsPage({super.key});

  @override
  State<DiscoverEventsPage> createState() => _DiscoverEventsPageState();
}

class _DiscoverEventsPageState extends State<DiscoverEventsPage> {
  String? selectedLocation;
  String? selectedCategory;

  List<dynamic> filteredEvents = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchFilteredEvents();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> fetchFilteredEvents() async {
    setState(() => isLoading = true);
    final request = context.read<CookieRequest>();

    try {
      String url =
          'https://nezzaluna-azzahra-gas-in.pbp.cs.ui.ac.id/event/api/events/?';
      if (selectedLocation != null && selectedLocation!.isNotEmpty) {
        url += 'location=$selectedLocation&';
      }
      if (selectedCategory != null && selectedCategory!.isNotEmpty) {
        url += 'category=$selectedCategory&';
      }

      print('Fetching events from: $url');
      final response = await request.get(url);
      print('Response: $response');

      setState(() {
        if (response is Map && response['data'] != null) {
          filteredEvents = response['data'] is List ? response['data'] : [];
        } else if (response is List) {
          filteredEvents = response;
        } else {
          filteredEvents = [];
        }
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching events: $e');
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }

  void resetFilters() {
    setState(() {
      selectedLocation = null;
      selectedCategory = null;
    });
    fetchFilteredEvents();
  }

  void _showSaveFilterModal(CookieRequest request) {
    if ((selectedLocation == null || selectedLocation!.isEmpty) &&
        (selectedCategory == null || selectedCategory!.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih minimal satu filter sebelum menyimpan!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SaveFilterDialog(
          location: selectedLocation,
          category: selectedCategory,
          onSaved: () {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Filter berhasil disimpan!'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          },
        );
      },
    );
  }

  String getCategoryLabel(String? category) {
    if (category == null || category.isEmpty) return '';

    const categories = {
      'running': 'Lari',
      'badminton': 'Badminton',
      'futsal': 'Futsal',
      'football': 'Sepak Bola',
      'basketball': 'Basket',
      'cycling': 'Bersepeda',
      'volleyball': 'Voli',
      'yoga': 'Yoga',
      'padel': 'Padel',
      'other': 'Lainnya',
    };
    return categories[category] ?? category;
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF1A1B4B),
        elevation: 0,
        title: const Text(
          'Discover Events',
          style: TextStyle(
            color: Color(0xFF1A1B4B),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      drawer: const LeftDrawer(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start, 
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) =>
                        LinearGradient(
                          colors: [
                            Colors.deepPurple,
                            Colors.deepPurple.withValues(alpha: 0.7),
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ).createShader(
                          Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                        ),
                    child: const Text(
                      'Discover Exciting Events Near You',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  Text(
                    'Explore sports events near you.',
                    style: TextStyle(fontSize: 18, color: Colors.black),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CreateEventPage(),
                          ),
                        ).then((_) => fetchFilteredEvents());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Add Event',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SavedSearchesPage(),
                          ),
                        );

                        if (result != null && result is Map) {
                          setState(() {
                            selectedLocation = result['location'];
                            selectedCategory = result['category'];
                          });
                          fetchFilteredEvents();
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: Colors.deepPurple,
                          width: 2,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'See Filter Saved',
                        style: TextStyle(
                          color: Colors.deepPurple,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.1),
                      spreadRadius: 2,
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Filter Events',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),

                    const Text(
                      'Lokasi',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),

                    _buildFilterDropdown('location', (value) {
                      setState(() {
                        selectedLocation = value;
                      });
                      fetchFilteredEvents();
                    }),
                    const SizedBox(height: 15),

                    const Text(
                      'Kategori Olahraga',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),

                    _buildFilterDropdown('category', (value) {
                      setState(() {
                        selectedCategory = value;
                      });
                      fetchFilteredEvents();
                    }),
                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: resetFilters,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple.shade50,
                              foregroundColor: Colors.deepPurple,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Reset Filter',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _showSaveFilterModal(request),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Save',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Text(
                      'Menampilkan ${filteredEvents.length} event',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              isLoading
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(50.0),
                        child: CircularProgressIndicator(
                          color: Colors.deepPurple,
                        ),
                      ),
                    )
                  : filteredEvents.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(50.0),
                        child: Column(
                          children: [
                            Icon(
                              Icons.event_busy,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Tidak ada event ditemukan',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Coba ubah filter atau buat event baru',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredEvents.length,
                      itemBuilder: (context, index) {
                        return _buildEventCard(filteredEvents[index]);
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterDropdown(String type, Function(String?) onChanged) {
    final List<String> locationOptions = [
      'Jakarta',
      'Bogor',
      'Depok',
      'Tangerang',
      'Bekasi',
    ];
    final List<Map<String, String>> categoryOptions = [
      {'value': 'running', 'label': 'Lari'},
      {'value': 'badminton', 'label': 'Badminton'},
      {'value': 'futsal', 'label': 'Futsal'},
      {'value': 'football', 'label': 'Sepak Bola'},
      {'value': 'basketball', 'label': 'Basket'},
      {'value': 'cycling', 'label': 'Bersepeda'},
      {'value': 'volleyball', 'label': 'Voli'},
      {'value': 'yoga', 'label': 'Yoga'},
      {'value': 'padel', 'label': 'Padel'},
      {'value': 'other', 'label': 'Lainnya'},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.deepPurple),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: type == 'location' ? selectedLocation : selectedCategory,
          hint: Text(type == 'location' ? 'Semua Lokasi' : 'Semua Kategori'),
          items: [
            DropdownMenuItem(
              value: null,
              child: Text(
                type == 'location' ? 'Semua Lokasi' : 'Semua Kategori',
              ),
            ),
            if (type == 'location')
              ...locationOptions.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              })
            else
              ...categoryOptions.map((cat) {
                return DropdownMenuItem<String>(
                  value: cat['value'],
                  child: Text(cat['label']!),
                );
              }),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildEventCard(dynamic event) {
    final String eventId = event['id'] ?? '';
    final String name = event['name'] ?? 'No Name';
    final String description = event['description'] ?? '';
    final String location = event['location'] ?? '';
    final String category = event['category'] ?? '';
    final String? thumbnail = event['thumbnail'];

    DateTime? eventDate;
    try {
      if (event['date'] != null) {
        eventDate = DateTime.parse(event['date']);
      }
    } catch (e) {
      eventDate = null;
    }

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          if (eventId.isNotEmpty) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EventDetailPage(eventId: eventId),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Event ID tidak valid'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: thumbnail != null && thumbnail.isNotEmpty
                  ? Image.network(
                      thumbnail.startsWith('http')
                          ? thumbnail
                          : 'https://nezzaluna-azzahra-gas-in.pbp.cs.ui.ac.id$thumbnail',
                      height: 180,
                      width: double.infinity, 
                      fit: BoxFit.cover, 
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: 180,
                          width: double.infinity,
                          color: Colors.grey[300],
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                  : null,
                              color: Colors.deepPurple,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 180,
                          width: double.infinity, 
                          color: Colors.grey[300],
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.image_not_supported,
                                size: 50,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Image not available',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    )
                  : Container(
                      height: 180,
                      width: double.infinity,
                      color: Colors.grey[300],
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.image, size: 50, color: Colors.grey),
                          SizedBox(height: 8),
                          Text(
                            'No image',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
            ),

            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      getCategoryLabel(category),
                      style: const TextStyle(
                        color: Colors.deepPurple,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          location,
                          style: const TextStyle(color: Colors.grey),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  if (eventDate != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            DateFormat(
                              'EEEE, dd MMM yyyy HH:mm',
                              'id_ID',
                            ).format(eventDate),
                            style: const TextStyle(color: Colors.grey),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 8),

                  Text(
                    description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 12),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () {
                        if (eventId.isNotEmpty) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  EventDetailPage(eventId: eventId),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.arrow_forward, size: 16),
                      label: const Text('View Details'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.deepPurple,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
