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
  });
}
