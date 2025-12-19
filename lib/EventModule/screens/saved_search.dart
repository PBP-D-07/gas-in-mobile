import 'package:flutter/material.dart';
import 'package:gas_in/EventModule/models/event_filter_model.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class SavedSearchesPage extends StatefulWidget {
  const SavedSearchesPage({super.key});

  @override
  State<SavedSearchesPage> createState() => _SavedSearchesPageState();
}

class _SavedSearchesPageState extends State<SavedSearchesPage> {
  bool isLoading = true;
  List<SavedSearch> savedSearches = [];

  @override
  void initState() {
    super.initState();
    loadSavedSearches();
  }

  Future<void> loadSavedSearches() async {
    setState(() => isLoading = true);
    final request = context.read<CookieRequest>();

    try {
      final response = await request.get('http://localhost:8000/event/api/saved-search/');
      final savedSearchResponse = SavedSearchResponse.fromJson(response);
      setState(() {
        savedSearches = savedSearchResponse.data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> deleteSavedSearch(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Saved Search'),
        content: const Text('Apakah Anda yakin ingin menghapus saved search ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final request = context.read<CookieRequest>();
    try {
      await request.post(
        'http://localhost:8000/event/api/saved-search/$id/delete/',
        {},
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Saved search berhasil dihapus')),
        );
        loadSavedSearches();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  void applySavedSearch(SavedSearch search) {
    Navigator.pop(context, {
      'location': search.location,
      'category': search.category,
    });
  }

  String getCategoryLabel(String? category) {
    if (category == null || category.isEmpty) return '';
    
    const categories = {
      'running': 'Lari',
      'badminton': 'Badminton',
      'futsal': 'Futsal',
      'football': 'Sepak Bola',
      'basketball': 'Basket',
      'cycling': 'Sepeda',
      'volleyball': 'Voli',
      'yoga': 'Yoga',
      'padel': 'Padel',
      'other': 'Lainnya',
    };
    return categories[category] ?? category;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Saved Searches'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : savedSearches.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.bookmark_border,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Belum ada saved search',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Simpan filter favorit Anda untuk akses cepat',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: savedSearches.length,
                  itemBuilder: (context, index) {
                    final search = savedSearches[index];
                    final filters = <String>[];
                    
                    if (search.location.isNotEmpty) {
                      filters.add('📍 ${search.location}');
                    }
                    if (search.category.isNotEmpty) {
                      filters.add('🏃 ${getCategoryLabel(search.category)}');
                    }

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              search.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              filters.isEmpty
                                  ? 'All events'
                                  : filters.join(' • '),
                              style: const TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () => applySavedSearch(search),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Theme.of(context).colorScheme.primary,
                                    ),
                                    child: const Text('Apply'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  onPressed: () => deleteSavedSearch(search.id),
                                  icon: const Icon(Icons.delete),
                                  color: Colors.red,
                                  style: IconButton.styleFrom(
                                    backgroundColor: Colors.red[50],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}