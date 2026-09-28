import 'package:drift/drift.dart';
import 'app_database.dart';

class SampleDataSeeder {
  static Future<void> seedIfEmpty(AppDatabase db) async {
    final existingBooks = await db.getAllBooks();
    if (existingBooks.isNotEmpty) return;

    // Seed Books from Design Mockup
    final now = DateTime.now();

    final booksToSeed = [
      BooksCompanion.insert(
        id: 'book_atomic_habits',
        title: 'Atomic Habits',
        author: const Value('James Clear'),
        filePath: 'sample_atomic_habits',
        fileType: const Value('pdf'),
        totalPages: const Value(320),
        lastReadPage: const Value(84),
        lastReadAt: Value(now.subtract(const Duration(hours: 3))),
      ),
      BooksCompanion.insert(
        id: 'book_daily_stoic',
        title: 'The Daily Stoic',
        author: const Value('Ryan Holiday'),
        filePath: 'sample_daily_stoic',
        fileType: const Value('pdf'),
        totalPages: const Value(416),
        lastReadPage: const Value(45),
        lastReadAt: Value(now.subtract(const Duration(days: 2))),
      ),
      BooksCompanion.insert(
        id: 'book_deep_work',
        title: 'Deep Work',
        author: const Value('Cal Newport'),
        filePath: 'sample_deep_work',
        fileType: const Value('pdf'),
        totalPages: const Value(304),
        lastReadPage: const Value(12),
        lastReadAt: Value(now.subtract(const Duration(days: 5))),
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

    // Seed Highlights & Notes
    final highlightsToSeed = [
      (
        highlight: HighlightsCompanion.insert(
          id: 'hl_atomic_1',
          bookId: 'book_atomic_habits',
          pageNumber: 84,
          selectedText:
              'Every action you take is a vote for the type of person you wish to become.',
          color: const Value('yellow'),
          createdAt: Value(now.subtract(const Duration(days: 1))),
        ),
        note: NotesCompanion.insert(
          id: 'note_atomic_1',
          highlightId: 'hl_atomic_1',
          reflectionText:
              'Ini mengingatkan aku bahwa konsistensi kecil jauh lebih penting daripada motivasi besar yang sementara.',
          createdAt: Value(now.subtract(const Duration(days: 1))),
        ),
        tags: ['habit', 'mindset', 'identitas'],
      ),
      (
        highlight: HighlightsCompanion.insert(
          id: 'hl_atomic_2',
          bookId: 'book_atomic_habits',
          pageNumber: 102,
          selectedText:
              'You do not rise to the level of your goals. You fall to the level of your systems.',
          color: const Value('green'),
          createdAt: Value(now.subtract(const Duration(days: 3))),
        ),
        note: NotesCompanion.insert(
          id: 'note_atomic_2',
          highlightId: 'hl_atomic_2',
          reflectionText: 'Sistem > motivasi.',
          createdAt: Value(now.subtract(const Duration(days: 3))),
        ),
        tags: ['sistem', 'produktivitas'],
      ),
      (
        highlight: HighlightsCompanion.insert(
          id: 'hl_daily_stoic_1',
          bookId: 'book_daily_stoic',
          pageNumber: 45,
          selectedText:
              'Discipline is choosing between what you want now and what you want most.',
          color: const Value('blue'),
          createdAt: Value(now.subtract(const Duration(days: 7))),
        ),
        note: NotesCompanion.insert(
          id: 'note_daily_stoic_1',
          highlightId: 'hl_daily_stoic_1',
          reflectionText: 'Perlu diingat saat malas.',
          createdAt: Value(now.subtract(const Duration(days: 7))),
        ),
        tags: ['disiplin', 'stoikisme'],
      ),
      (
        highlight: HighlightsCompanion.insert(
          id: 'hl_deep_work_1',
          bookId: 'book_deep_work',
          pageNumber: 24,
          selectedText:
              'Clarity about what matters provides clarity about what does not.',
          color: const Value('yellow'),
          createdAt: Value(now.subtract(const Duration(days: 10))),
        ),
        note: NotesCompanion.insert(
          id: 'note_deep_work_1',
          highlightId: 'hl_deep_work_1',
          reflectionText: 'Fokus pada hal yang memberikan dampak terbesar.',
          createdAt: Value(now.subtract(const Duration(days: 10))),
        ),
        tags: ['fokus', 'produktivitas'],
      ),
    ];

    for (final item in highlightsToSeed) {
      await db.insertHighlight(item.highlight);
      await db.insertNote(item.note);
      await db.setTagsForNote(item.note.id.value, item.tags);
    }
  }
}
