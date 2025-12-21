import 'package:flutter_test/flutter_test.dart';
import 'package:gas_in/EventModule/services/event_filter_service.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

import '../screens/discover_events_test.mocks.dart';
@GenerateMocks([CookieRequest])
import 'event_filter_services_test.mocks.dart' hide MockCookieRequest;

void main() {
  group('EventFilterService Tests', () {
    late MockCookieRequest mockRequest;

    setUp(() {
      mockRequest = MockCookieRequest();
    });

    group('getFilteredEvents', () {
      test('should fetch events without filters', () async {
        final mockResponse = {
          'data': [
            {'id': '1', 'name': 'Event 1'}
          ]
        };

        when(mockRequest.get(any)).thenAnswer((_) async => mockResponse);

        final result = await EventFilterService.getFilteredEvents(mockRequest);

        expect(result, mockResponse);
        verify(mockRequest.get(argThat(contains('/event/api/events/?')))).called(1);
      });

      test('should fetch events with location filter', () async {
        final mockResponse = {'data': []};

        when(mockRequest.get(any)).thenAnswer((_) async => mockResponse);

        await EventFilterService.getFilteredEvents(
          mockRequest,
          location: 'Jakarta',
        );

        verify(mockRequest.get(argThat(contains('location=Jakarta')))).called(1);
      });

      test('should fetch events with category filter', () async {
        final mockResponse = {'data': []};

        when(mockRequest.get(any)).thenAnswer((_) async => mockResponse);

        await EventFilterService.getFilteredEvents(
          mockRequest,
          category: 'running',
        );

        verify(mockRequest.get(argThat(contains('category=running')))).called(1);
      });

      test('should fetch events with both filters', () async {
        final mockResponse = {'data': []};

        when(mockRequest.get(any)).thenAnswer((_) async => mockResponse);

        await EventFilterService.getFilteredEvents(
          mockRequest,
          location: 'Jakarta',
          category: 'running',
        );

        final captured = verify(mockRequest.get(captureAny)).captured;
        expect(captured[0], contains('location=Jakarta'));
        expect(captured[0], contains('category=running'));
      });
    });

    group('getSavedSearches', () {
      test('should fetch saved searches successfully', () async {
        final mockResponse = {
          'message': 'Success',
          'data': [
            {
              'id': '1',
              'name': 'My Search',
              'location': 'Jakarta',
              'category': 'running',
              'created_at': '2025-01-01T10:00:00.000Z',
            }
          ]
        };

        when(mockRequest.get(any)).thenAnswer((_) async => mockResponse);

        final result = await EventFilterService.getSavedSearches(mockRequest);

        expect(result.message, 'Success');
        expect(result.data.length, 1);
        expect(result.data[0].name, 'My Search');
      });
    });

    group('createSavedSearch', () {
      test('should create saved search with all fields', () async {
        final mockResponse = {
          'status': 'success',
          'message': 'Created',
        };

        when(mockRequest.post(any, any)).thenAnswer((_) async => mockResponse);

        final result = await EventFilterService.createSavedSearch(
          mockRequest,
          name: 'Test Search',
          location: 'Jakarta',
          category: 'running',
        );

        expect(result['status'], 'success');
        final captured = verify(mockRequest.post(any, captureAny)).captured;
        expect(captured[0]['name'], 'Test Search');
        expect(captured[0]['location'], 'Jakarta');
        expect(captured[0]['category'], 'running');
      });

      test('should create saved search with empty location and category',
          () async {
        final mockResponse = {'status': 'success'};

        when(mockRequest.post(any, any)).thenAnswer((_) async => mockResponse);

        await EventFilterService.createSavedSearch(
          mockRequest,
          name: 'Test',
        );

        final captured = verify(mockRequest.post(any, captureAny)).captured;
        expect(captured[0]['location'], '');
        expect(captured[0]['category'], '');
      });
    });

    group('deleteSavedSearch', () {
      test('should delete saved search', () async {
        final mockResponse = {'status': 'success'};

        when(mockRequest.post(any, any)).thenAnswer((_) async => mockResponse);

        final result =
            await EventFilterService.deleteSavedSearch(mockRequest, '123');

        expect(result['status'], 'success');
        // Gunakan argThat untuk URL dan any() untuk body-nya
        verify(mockRequest.post(
          argThat(contains('123/delete/')), 
          any, // Ini merujuk ke parameter body (Map)
        )).called(1);
      });
    });

    group('updateSavedSearch', () {
      test('should update saved search', () async {
        final mockResponse = {'status': 'success'};

        when(mockRequest.post(any, any)).thenAnswer((_) async => mockResponse);

        final result = await EventFilterService.updateSavedSearch(
          mockRequest,
          '123',
          name: 'Updated',
          location: 'Bogor',
          category: 'futsal',
        );

        expect(result['status'], 'success');
        final captured = verify(mockRequest.post(any, captureAny)).captured;
        expect(captured[0]['name'], 'Updated');
        expect(captured[0]['location'], 'Bogor');
      });
    });

    group('getCategoryLabel', () {
      test('should return correct Indonesian label for running', () {
        expect(EventFilterService.getCategoryLabel('running'), 'Lari');
      });

      test('should return correct Indonesian label for futsal', () {
        expect(EventFilterService.getCategoryLabel('futsal'), 'Futsal');
      });

      test('should return correct Indonesian label for football', () {
        expect(EventFilterService.getCategoryLabel('football'), 'Sepak Bola');
      });

      test('should return correct Indonesian label for basketball', () {
        expect(EventFilterService.getCategoryLabel('basketball'), 'Basket');
      });

      test('should return correct Indonesian label for cycling', () {
        expect(EventFilterService.getCategoryLabel('cycling'), 'Bersepeda');
      });

      test('should return correct Indonesian label for volleyball', () {
        expect(EventFilterService.getCategoryLabel('volleyball'), 'Voli');
      });

      test('should return correct Indonesian label for yoga', () {
        expect(EventFilterService.getCategoryLabel('yoga'), 'Yoga');
      });

      test('should return correct Indonesian label for padel', () {
        expect(EventFilterService.getCategoryLabel('padel'), 'Padel');
      });

      test('should return correct Indonesian label for other', () {
        expect(EventFilterService.getCategoryLabel('other'), 'Lainnya');
      });

      test('should return empty string for null', () {
        expect(EventFilterService.getCategoryLabel(null), '');
      });

      test('should return empty string for empty string', () {
        expect(EventFilterService.getCategoryLabel(''), '');
      });

      test('should return original value for unknown category', () {
        expect(EventFilterService.getCategoryLabel('unknown'), 'unknown');
      });
    });
  });
}