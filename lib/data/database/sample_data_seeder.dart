import 'package:drift/drift.dart';
import 'app_database.dart';

class SampleDataSeeder {
  static Future<void> seedIfEmpty(AppDatabase db) async {
    final existingBooks = await db.getAllBooks();
    if (existingBooks.isNotEmpty) return;

    // Seed Books from Design Mockup
    final booksToSeed = [
      BooksCompanion.insert(
        id: 'book_atomic_habits',
        title: 'Atomic Habits',
        author: const Value('James Clear'),
        filePath: 'sample_atomic_habits',
        fileType: const Value('pdf'),
        totalPages: const Value(320),
        lastReadPage: const Value(1),
        lastReadAt: const Value.absent(),
      ),
      BooksCompanion.insert(
        id: 'book_daily_stoic',
        title: 'The Daily Stoic',
        author: const Value('Ryan Holiday'),
        filePath: 'sample_daily_stoic',
        fileType: const Value('pdf'),
        totalPages: const Value(416),
        lastReadPage: const Value(1),
        lastReadAt: const Value.absent(),
      ),
      BooksCompanion.insert(
        id: 'book_deep_work',
        title: 'Deep Work',
        author: const Value('Cal Newport'),
        filePath: 'sample_deep_work',
        fileType: const Value('pdf'),
        totalPages: const Value(304),
        lastReadPage: const Value(1),
        lastReadAt: const Value.absent(),
      ),
      BooksCompanion.insert(
        id: 'book_sapiens',
        title: 'Sapiens',
        author: const Value('Yuval Noah Harari'),
        filePath: 'sample_sapiens',
        fileType: const Value('epub'),
        totalPages: const Value(464),
        lastReadPage: const Value(1),
        lastReadAt: const Value.absent(),
      ),
      BooksCompanion.insert(
        id: 'book_ikigai',
        title: 'Ikigai',
        author: const Value('Hector Garcia'),
        filePath: 'sample_ikigai',
        fileType: const Value('epub'),
        totalPages: const Value(208),
        lastReadPage: const Value(1),
        lastReadAt: const Value.absent(),
      ),
      BooksCompanion.insert(
        id: 'book_mindset',
        title: 'Mindset',
        author: const Value('Carol Dweck'),
        filePath: 'sample_mindset',
        fileType: const Value('pdf'),
        totalPages: const Value(320),
        lastReadPage: const Value(1),
        lastReadAt: const Value.absent(),
      ),
    ];

    for (final b in booksToSeed) {
      await db.insertBook(b);
    }
  }
}
