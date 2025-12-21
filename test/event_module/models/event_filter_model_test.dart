import 'package:flutter_test/flutter_test.dart';
import 'package:gas_in/EventModule/models/event_filter_model.dart';

void main() {
  group('SavedSearch Model Tests', () {
    test('should create SavedSearch from JSON', () {
      final json = {
        'id': '123',
        'name': 'Test Search',
        'location': 'Jakarta',
        'category': 'running',
        'created_at': '2025-01-01T10:00:00.000Z',
      };

      final savedSearch = SavedSearch.fromJson(json);

      expect(savedSearch.id, '123');
      expect(savedSearch.name, 'Test Search');
      expect(savedSearch.location, 'Jakarta');
      expect(savedSearch.category, 'running');
      expect(savedSearch.createdAt, DateTime.parse('2025-01-01T10:00:00.000Z'));
    });

    test('should convert SavedSearch to JSON', () {
      final savedSearch = SavedSearch(
        id: '123',
        name: 'Test Search',
        location: 'Jakarta',
        category: 'running',
        createdAt: DateTime.parse('2025-01-01T10:00:00.000Z'),
      );

      final json = savedSearch.toJson();

      expect(json['id'], '123');
      expect(json['name'], 'Test Search');
      expect(json['location'], 'Jakarta');
      expect(json['category'], 'running');
      expect(json['created_at'], '2025-01-01T10:00:00.000Z');
    });

    test('should handle empty strings in SavedSearch', () {
      final json = {
        'id': '123',
        'name': 'Test',
        'location': '',
        'category': '',
        'created_at': '2025-01-01T10:00:00.000Z',
      };

      final savedSearch = SavedSearch.fromJson(json);

      expect(savedSearch.location, '');
      expect(savedSearch.category, '');
    });
  });

  group('SavedSearchResponse Model Tests', () {
    test('should create SavedSearchResponse from JSON', () {
      final json = {
        'message': 'Success',
        'data': [
          {
            'id': '1',
            'name': 'Search 1',
            'location': 'Jakarta',
            'category': 'running',
            'created_at': '2025-01-01T10:00:00.000Z',
          },
          {
            'id': '2',
            'name': 'Search 2',
            'location': 'Bogor',
            'category': 'futsal',
            'created_at': '2025-01-02T10:00:00.000Z',
          },
        ],
      };

      final response = SavedSearchResponse.fromJson(json);

      expect(response.message, 'Success');
      expect(response.data.length, 2);
      expect(response.data[0].name, 'Search 1');
      expect(response.data[1].name, 'Search 2');
    });

    test('should convert SavedSearchResponse to JSON', () {
      final response = SavedSearchResponse(
        message: 'Success',
        data: [
          SavedSearch(
            id: '1',
            name: 'Search 1',
            location: 'Jakarta',
            category: 'running',
            createdAt: DateTime.parse('2025-01-01T10:00:00.000Z'),
          ),
        ],
      );

      final json = response.toJson();

      expect(json['message'], 'Success');
      expect(json['data'].length, 1);
      expect(json['data'][0]['name'], 'Search 1');
    });

    test('should handle empty data list', () {
      final json = {
        'message': 'No results',
        'data': [],
      };

      final response = SavedSearchResponse.fromJson(json);

      expect(response.message, 'No results');
      expect(response.data, isEmpty);
    });

    test('savedSearchResponseFromJson should parse string', () {
      final jsonString = '''
      {
        "message": "Success",
        "data": [{
          "id": "1",
          "name": "Test",
          "location": "Jakarta",
          "category": "running",
          "created_at": "2025-01-01T10:00:00.000Z"
        }]
      }
      ''';

      final response = savedSearchResponseFromJson(jsonString);

      expect(response.message, 'Success');
      expect(response.data.length, 1);
    });

    test('savedSearchResponseToJson should convert to string', () {
      final response = SavedSearchResponse(
        message: 'Success',
        data: [
          SavedSearch(
            id: '1',
            name: 'Test',
            location: 'Jakarta',
            category: 'running',
            createdAt: DateTime.parse('2025-01-01T10:00:00.000Z'),
          ),
        ],
      );

      final jsonString = savedSearchResponseToJson(response);

      expect(jsonString, contains('Success'));
      expect(jsonString, contains('Test'));
      expect(jsonString, contains('Jakarta'));
    });
  });
}