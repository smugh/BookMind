import 'package:bookmind/core/theme/app_colors.dart';
import 'package:bookmind/data/database/app_database.dart';
import 'package:bookmind/shared/widgets/book_cover_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('BookCoverWidget displays title and fallback gradient', (WidgetTester tester) async {
    final testBook = BookEntry(
      id: 'test-1',
      title: 'Atomic Habits',
      author: 'James Clear',
      filePath: '/dummy/path.pdf',
      fileType: 'pdf',
      totalPages: 320,
      lastReadPage: 1,
      createdAt: DateTime.now(),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BookCoverWidget(book: testBook),
        ),
      ),
    );

    expect(find.text('Atomic Habits'), findsOneWidget);
    expect(find.text('James Clear'), findsOneWidget);
    expect(find.text('PDF'), findsOneWidget);
  });

  test('AppColors tokens are properly configured', () {
    expect(AppColors.primaryCoffee, const Color(0xFF6B4E3D));
    expect(AppColors.primaryTerracotta, const Color(0xFFD97757));
    expect(AppColors.primaryCream, const Color(0xFFF8EEDD));
  });
}
