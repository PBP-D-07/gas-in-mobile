import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gas_in/EventModule/widgets/save_filter_dialog.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

@GenerateMocks([CookieRequest])
import 'save_filter_dialog_test.mocks.dart';

void main() {
  group('SaveFilterDialog Widget Tests', () {
    late MockCookieRequest mockRequest;

    setUp(() {
      mockRequest = MockCookieRequest();
    });

    Widget createTestWidget({
      String? location,
      String? category,
      VoidCallback? onSaved,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: Provider<CookieRequest>.value(
            value: mockRequest,
            child: SaveFilterDialog(
              location: location,
              category: category,
              onSaved: onSaved ?? () {},
            ),
          ),
        ),
      );
    }

    testWidgets('should display dialog with all elements',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(location: 'Jakarta', category: 'running'),
      );

      expect(find.text('Save Current Filter'), findsOneWidget);
      expect(find.text('Nama Filter'), findsOneWidget);
      expect(find.text('Batal'), findsOneWidget);
      expect(find.text('Simpan'), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets('should show location and category info when provided',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(location: 'Jakarta', category: 'running'),
      );

      expect(find.text('Filter yang akan disimpan:'), findsOneWidget);
      expect(find.text('Lokasi: Jakarta'), findsOneWidget);
      expect(find.text('Kategori: Lari'), findsOneWidget);
    });

    testWidgets('should show warning when no filters provided',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Tidak ada filter aktif'), findsOneWidget);
    });

    testWidgets('should validate empty name field',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.tap(find.text('Simpan'));
      await tester.pump();

      expect(find.text('Nama filter tidak boleh kosong'), findsOneWidget);
    });

    testWidgets('should validate name length', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.enterText(find.byType(TextFormField), 'ab');
      await tester.tap(find.text('Simpan'));
      await tester.pump();

      expect(find.text('Nama filter minimal 3 karakter'), findsOneWidget);
    });

    testWidgets('should close dialog when Batal is tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.tap(find.text('Batal'));
      await tester.pumpAndSettle();

      expect(find.byType(SaveFilterDialog), findsNothing);
    });

    testWidgets('should call API on successful save',
        (WidgetTester tester) async {
      when(mockRequest.post(any, any)).thenAnswer(
        (_) async => {'status': 'success', 'message': 'Saved search created successfully'},
      );

      bool onSavedCalled = false;

      await tester.pumpWidget(
        createTestWidget(
          location: 'Jakarta',
          category: 'running',
          onSaved: () => onSavedCalled = true,
        ),
      );

      await tester.enterText(find.byType(TextFormField), 'Test Search');
      await tester.tap(find.text('Simpan'));
      await tester.pump();

      verify(mockRequest.post(any, any)).called(1);
    });

    testWidgets('should display loading indicator while saving',
        (WidgetTester tester) async {
      when(mockRequest.post(any, any)).thenAnswer(
        (_) => Future.delayed(
          const Duration(seconds: 1),
          () => {'status': 'success'},
        ),
      );

      await tester.pumpWidget(createTestWidget());

      await tester.enterText(find.byType(TextFormField), 'Test');
      await tester.tap(find.text('Simpan'));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('should show category label correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(category: 'football'),
      );

      expect(find.text('Kategori: Sepak Bola'), findsOneWidget);
    });
  });
}