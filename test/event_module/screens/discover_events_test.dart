import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gas_in/EventModule/screens/discover_events.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';

@GenerateMocks([CookieRequest])
import 'discover_events_test.mocks.dart';

void main() {
  group('DiscoverEventsPage Widget Tests', () {
    late MockCookieRequest mockRequest;

    setUpAll(() async {
      await initializeDateFormatting('en_ISO', null);
    });

    setUp(() {
      mockRequest = MockCookieRequest();
    });
    

    Widget createTestWidget() {
      return MaterialApp(
        home: Provider<CookieRequest>.value(
          value: mockRequest,
          child: const DiscoverEventsPage(),
        ),
      );
    }

    testWidgets('should display page title and elements',
        (WidgetTester tester) async {
      when(mockRequest.get(any)).thenAnswer((_) async => {'data': []});

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Discover Events'), findsWidgets);
      expect(find.text('Add Event'), findsOneWidget);
      expect(find.text('See Filter Saved'), findsOneWidget);
      expect(find.text('Filter Events'), findsOneWidget);
    });

    testWidgets('should show loading indicator initially',
        (WidgetTester tester) async {
      when(mockRequest.get(any)).thenAnswer(
        (_) => Future.delayed(
          const Duration(milliseconds: 100),
          () => {'data': []},
        ),
      );

      await tester.pumpWidget(createTestWidget());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('should display empty state when no events',
        (WidgetTester tester) async {
      when(mockRequest.get(any)).thenAnswer((_) async => {'data': []});

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Tidak ada event ditemukan'), findsOneWidget);
      expect(find.text('Coba ubah filter atau buat event baru'), findsOneWidget);
    });

    testWidgets('should display events when data is loaded',
        (WidgetTester tester) async {
      when(mockRequest.get(any)).thenAnswer((_) async => {
            'data': [
              {
                'id': '1',
                'name': 'Test Event',
                'description': 'Test Description',
                'location': 'Jakarta',
                'category': 'running',
                'date': '2025-12-25T10:00:00',
                'thumbnail': null,
              }
            ]
          });

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Gunakan find.textContaining agar lebih aman
  expect(find.textContaining('Test Event'), findsOneWidget);
  expect(find.textContaining('Jakarta'), findsOneWidget);
    });

    testWidgets('should call API when filter is changed',
        (WidgetTester tester) async {
      when(mockRequest.get(any)).thenAnswer((_) async => {'data': []});

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Open location dropdown
      await tester.tap(find.text('Semua Lokasi').first);
      await tester.pumpAndSettle();

      // Select Jakarta
      await tester.tap(find.text('Jakarta').last);
      await tester.pumpAndSettle();

      // Verify API called with location filter
      verify(mockRequest.get(argThat(contains('location=Jakarta')))).called(1);
    });

    testWidgets('should reset filters when Reset button tapped',
        (WidgetTester tester) async {
      when(mockRequest.get(any)).thenAnswer((_) async => {'data': []});

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap reset button
      await tester.tap(find.text('Reset Filter'));
      await tester.pumpAndSettle();

      // Should call API without filters
      verify(mockRequest.get(argThat(endsWith('/event/api/events/?')))).called(greaterThan(0));
    });

    testWidgets('getCategoryLabel should return correct labels',
        (WidgetTester tester) async {
      when(mockRequest.get(any)).thenAnswer((_) async => {'data': []});

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final state = tester.state(find.byType(DiscoverEventsPage)) as dynamic;

      expect(state.getCategoryLabel('running'), 'Lari');
      expect(state.getCategoryLabel('futsal'), 'Futsal');
      expect(state.getCategoryLabel('football'), 'Sepak Bola');
      expect(state.getCategoryLabel(null), '');
      expect(state.getCategoryLabel(''), '');
    });
  });
}