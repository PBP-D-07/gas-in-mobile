import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gas_in/EventModule/screens/saved_search.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

@GenerateMocks([CookieRequest])
import 'saved_searches_test.mocks.dart';

void main() {
  group('SavedSearchesPage Widget Tests', () {
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
          child: const SavedSearchesPage(),
        ),
      );
    }

    testWidgets('should display page title', (WidgetTester tester) async {
      when(
        mockRequest.get(any),
      ).thenAnswer((_) async => {'message': 'Success', 'data': []});

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('My Saved Searches'), findsOneWidget);
    });

    testWidgets('should show loading indicator initially', (
      WidgetTester tester,
    ) async {
      when(mockRequest.get(any)).thenAnswer(
        (_) => Future.delayed(
          const Duration(milliseconds: 100),
          () => {'message': 'Success', 'data': []},
        ),
      );

      await tester.pumpWidget(createTestWidget());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('should display empty state when no saved searches', (
      WidgetTester tester,
    ) async {
      when(
        mockRequest.get(any),
      ).thenAnswer((_) async => {'message': 'Success', 'data': []});

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Belum ada saved search'), findsOneWidget);
      expect(
        find.text('Simpan filter favorit Anda untuk akses cepat'),
        findsOneWidget,
      );
    });

    testWidgets('should display saved searches when data is loaded', (
      WidgetTester tester,
    ) async {
      when(mockRequest.get(any)).thenAnswer(
        (_) async => {
          'message': 'Success',
          'data': [
            {
              'id': '1',
              'name': 'My Search',
              'location': 'Jakarta',
              'category': 'running',
              'created_at': '2025-01-01T10:00:00',
            },
          ],
        },
      );

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('My Search'), findsOneWidget);
      // Gunakan textContaining agar lebih fleksibel terhadap spasi/emoji
      expect(find.textContaining('Jakarta'), findsOneWidget);
    });

    testWidgets('should show delete confirmation dialog', (
      WidgetTester tester,
    ) async {
      when(mockRequest.get(any)).thenAnswer(
        (_) async => {
          'message': 'Success',
          'data': [
            {
              'id': '1',
              'name': 'My Search',
              'location': 'Jakarta',
              'category': 'running',
              'created_at': '2025-01-01T10:00:00',
            },
          ],
        },
      );

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap delete button
      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      expect(find.text('Hapus Saved Search'), findsOneWidget);
      expect(
        find.text('Apakah Anda yakin ingin menghapus saved search ini?'),
        findsOneWidget,
      );
    });

    testWidgets('should delete saved search when confirmed', (
      WidgetTester tester,
    ) async {
      when(mockRequest.get(any)).thenAnswer(
        (_) async => {
          'message': 'Success',
          'data': [
            {
              'id': '1',
              'name': 'My Search',
              'location': 'Jakarta',
              'category': 'running',
              'created_at': '2025-01-01T10:00:00',
            },
          ],
        },
      );

      when(
        mockRequest.post(any, any),
      ).thenAnswer((_) async => {'status': 'success'});

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap delete
      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      // Confirm delete
      await tester.tap(find.text('Hapus'));
      await tester.pumpAndSettle();

      verify(mockRequest.post(
        argThat(contains('delete')), 
        any, // Ini merujuk ke parameter body (Map)
      )).called(1);
    });

    testWidgets('should return selected filter when Apply is tapped', (
      WidgetTester tester,
    ) async {
      when(mockRequest.get(any)).thenAnswer(
        (_) async => {
          'message': 'Success',
          'data': [
            {
              'id': '1',
              'name': 'My Search',
              'location': 'Jakarta',
              'category': 'running',
              'created_at': '2025-01-01T10:00:00',
            },
          ],
        },
      );

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap Apply Filter
      await tester.tap(find.text('Apply Filter'));
      await tester.pumpAndSettle();

      // Page should be popped with filter data
      expect(find.byType(SavedSearchesPage), findsNothing);
    });

    // testWidgets('getCategoryLabel should return correct labels', (
    //   WidgetTester tester,
    // ) async {
    //   when(
    //     mockRequest.get(any),
    //   ).thenAnswer((_) async => {'message': 'Success', 'data': []});

    //   await tester.pumpWidget(createTestWidget());
    //   await tester.pumpAndSettle();

    //   final dynamic state = tester.state(find.byType(SavedSearchesPageState));

    //   expect(state.getCategoryLabel('running'), 'Lari');
    //   expect(state.getCategoryLabel('basketball'), 'Basket');
    //   expect(state.getCategoryLabel(null), '');
    // });
  });
}
