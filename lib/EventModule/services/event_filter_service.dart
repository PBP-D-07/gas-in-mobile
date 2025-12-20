import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:gas_in/EventModule/models/event_filter_model.dart';

class EventFilterService {
  static const String baseUrl = 'http://localhost:8000/event/api';

  // Get filtered events - return raw response
  static Future<dynamic> getFilteredEvents(
    CookieRequest request, {
    String? location,
    String? category,
  }) async {
    String url = '$baseUrl/events/?';
    if (location != null && location.isNotEmpty) {
      url += 'location=$location&';
    }
    if (category != null && category.isNotEmpty) {
      url += 'category=$category&';
    }

    final response = await request.get(url);
    return response;
  }

  // Get all saved searches
  static Future<SavedSearchResponse> getSavedSearches(
    CookieRequest request,
  ) async {
    final response = await request.get('$baseUrl/saved-search/');
    return SavedSearchResponse.fromJson(response);
  }

  // Create saved search
  static Future<Map<String, dynamic>> createSavedSearch(
    CookieRequest request, {
    required String name,
    String? location,
    String? category,
  }) async {
    final response = await request.post(
      '$baseUrl/saved-search/create/',
      {
        'name': name,
        'location': location ?? '',
        'category': category ?? '',
      },
    );
    return response;
  }

  // Delete saved search
  static Future<Map<String, dynamic>> deleteSavedSearch(
    CookieRequest request,
    String id,
  ) async {
    final response = await request.post(
      '$baseUrl/saved-search/$id/delete/',
      {},
    );
    return response;
  }

  // Update saved search
  static Future<Map<String, dynamic>> updateSavedSearch(
    CookieRequest request,
    String id, {
    required String name,
    String? location,
    String? category,
  }) async {
    final response = await request.post(
      '$baseUrl/saved-search/$id/update/',
      {
        'name': name,
        'location': location ?? '',
        'category': category ?? '',
      },
    );
    return response;
  }

  // Get category label in Indonesian
  static String getCategoryLabel(String? category) {
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
}