import 'package:bookmind/data/database/app_database.dart';
import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  test('Database CRUD Operations for Book, Highlight, Note, and Tag', () async {
    // 1. Insert Book
    await db.insertBook(
      const BooksCompanion(
        id: Value('book-1'),
        title: Value('Atomic Habits'),
        author: Value('James Clear'),
        filePath: Value('/mock/atomic_habits.pdf'),
        fileType: Value('pdf'),
        totalPages: Value(320),
        lastReadPage: Value(1),
      ),
    );

    final books = await db.getAllBooks();
    expect(books.length, 1);
    expect(books.first.title, 'Atomic Habits');

    // 2. Insert Highlight
    await db.insertHighlight(
      const HighlightsCompanion(
        id: Value('hl-1'),
        bookId: Value('book-1'),
        pageNumber: Value(84),
        selectedText: Value('Every action you take is a vote for the person you wish to become.'),
        color: Value('yellow'),
      ),
    );

    final highlights = await db.watchHighlightsForBook('book-1').first;
    expect(highlights.length, 1);
    expect(highlights.first.pageNumber, 84);

    // 3. Insert Note & Tag
    await db.insertNote(
      const NotesCompanion(
        id: Value('note-1'),
        highlightId: Value('hl-1'),
        reflectionText: Value('Konsistensi kecil jauh lebih bernilai jangka panjang.'),
      ),
    );

    await db.setTagsForNote('note-1', ['habits', 'identity']);

    // 4. Query Knowledge Hub
    final notesWithDetails = await db.watchAllNotesWithDetails().first;
    expect(notesWithDetails.length, 1);
    final detail = notesWithDetails.first;
    expect(detail.book.title, 'Atomic Habits');
    expect(detail.highlight.selectedText, contains('Every action'));
    expect(detail.note.reflectionText, contains('Konsistensi'));
    expect(detail.tags.map((t) => t.name), containsAll(['habits', 'identity']));

    // 5. Update Reading Position
    await db.updateLastReadPosition(bookId: 'book-1', page: 85);
    final updatedBook = await db.getBookById('book-1');
    expect(updatedBook?.lastReadPage, 85);
    expect(updatedBook?.lastReadAt, isNotNull);

    // 6. Reading Session CRUD Operations (Bug fixing Requirement 1 & 2)
    final startTime = DateTime(2026, 9, 29, 14, 0);
    final endTime = DateTime(2026, 9, 29, 14, 30);
    await db.insertReadingSession(
      ReadingSessionsCompanion(
        id: const Value('session-1'),
        bookId: const Value('book-1'),
        startTime: Value(startTime),
        endTime: Value(endTime),
        durationSeconds: const Value(1800),
        startPage: const Value(85),
        endPage: const Value(105),
        pagesRead: const Value(21),
      ),
    );

    final sessions = await db.getAllReadingSessionsWithBook();
    expect(sessions.length, 1);
    expect(sessions.first.book.title, 'Atomic Habits');
    expect(sessions.first.session.durationSeconds, 1800);
    expect(sessions.first.session.pagesRead, 21);
    expect(sessions.first.session.startPage, 85);
    expect(sessions.first.session.endPage, 105);

    // Delete Session
    await db.deleteReadingSession('session-1');
    final afterDelete = await db.getAllReadingSessionsWithBook();
    expect(afterDelete.isEmpty, true);

    // 7. Update Book General Information (Title & Genre)
    await db.updateBookInfo(
      id: 'book-1',
      title: 'Atomic Habits 2nd Edition',
      author: 'James Clear',
      genre: 'Self-Development',
    );
    final editedBook = await db.getBookById('book-1');
    expect(editedBook?.title, 'Atomic Habits 2nd Edition');
    expect(editedBook?.genre, 'Self-Development');
  });
}
