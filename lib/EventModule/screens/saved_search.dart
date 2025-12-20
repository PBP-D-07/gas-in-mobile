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
      final response = await request.get(
        'https://nezzaluna-azzahra-gas-in.pbp.cs.ui.ac.id/event/api/saved-search/',
      );

      print('Response from saved searches: $response');

      final savedSearchResponse = SavedSearchResponse.fromJson(response);
      setState(() {
        savedSearches = savedSearchResponse.data;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading saved searches: $e');
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }

  Future<void> deleteSavedSearch(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Saved Search'),
        content: const Text(
          'Apakah Anda yakin ingin menghapus saved search ini?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final request = context.read<CookieRequest>();
    try {
      final response = await request.post(
        'https://nezzaluna-azzahra-gas-in.pbp.cs.ui.ac.id/event/api/saved-search/$id/delete/',
        {"delete": "true"},
      );

      print('Delete response: $response');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Saved search berhasil dihapus'),
            backgroundColor: Colors.green,
          ),
        );
        loadSavedSearches();
      }
    } catch (e) {
      print('Error deleting saved search: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }

  void applySavedSearch(SavedSearch search) {
    Navigator.pop(context, {
      'location': search.location.isEmpty ? null : search.location,
      'category': search.category.isEmpty ? null : search.category,
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
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF4338CA), // Indigo 700
                Color(0xFF6B21A8), // Purple 800
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text('My Saved Searches'),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.deepPurple),
            )
          : savedSearches.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.bookmark_border,
                        size: 64,
                        color: Colors.deepPurple.shade200,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Belum ada saved search',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Simpan filter favorit Anda untuk akses cepat',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
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
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                search.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () => deleteSavedSearch(search.id),
                              icon: const Icon(Icons.delete_outline),
                              color: Colors.red,
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.red[50],
                              ),
                              tooltip: 'Hapus',
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            filters.isEmpty
                                ? 'Semua event'
                                : filters.join(' • '),
                            style: TextStyle(
                              color: Colors.deepPurple.shade700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => applySavedSearch(search),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Apply Filter',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
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
