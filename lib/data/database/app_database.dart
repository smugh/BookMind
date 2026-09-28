import 'package:drift/drift.dart';
import 'connection/connection.dart' as impl;


part 'app_database.g.dart';

@DataClassName('BookEntry')
class Books extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get author => text().withDefault(const Constant('Unknown Author'))();
  TextColumn get coverPath => text().nullable()();
  TextColumn get filePath => text()();
  TextColumn get fileType => text().withDefault(const Constant('pdf'))(); // 'pdf' or 'epub'
  IntColumn get totalPages => integer().withDefault(const Constant(0))();
  IntColumn get lastReadPage => integer().withDefault(const Constant(1))();
  DateTimeColumn get lastReadAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('HighlightEntry')
class Highlights extends Table {
  TextColumn get id => text()();
  TextColumn get bookId => text().references(Books, #id, onDelete: KeyAction.cascade)();
  IntColumn get pageNumber => integer()();
  TextColumn get selectedText => text()();
  TextColumn get color => text().withDefault(const Constant('yellow'))(); // yellow, green, blue
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('NoteEntry')
class Notes extends Table {
  TextColumn get id => text()();
  TextColumn get highlightId => text().references(Highlights, #id, onDelete: KeyAction.cascade)();
  TextColumn get reflectionText => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('TagEntry')
class Tags extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().unique()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('NoteTagEntry')
class NoteTags extends Table {
  TextColumn get noteId => text().references(Notes, #id, onDelete: KeyAction.cascade)();
  TextColumn get tagId => text().references(Tags, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column> get primaryKey => {noteId, tagId};
}

@DataClassName('BookmarkEntry')
class Bookmarks extends Table {
  TextColumn get id => text()();
  TextColumn get bookId => text().references(Books, #id, onDelete: KeyAction.cascade)();
  IntColumn get pageNumber => integer()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

// Composite model for Knowledge Hub
class NoteWithDetails {
  final NoteEntry note;
  final HighlightEntry highlight;
  final BookEntry book;
  final List<TagEntry> tags;

  NoteWithDetails({
    required this.note,
    required this.highlight,
    required this.book,
    required this.tags,
  });
}

@DriftDatabase(tables: [Books, Highlights, Notes, Tags, NoteTags, Bookmarks])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(impl.openConnection());

  AppDatabase.forTesting(super.connection);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      beforeOpen: (details) async {
        await customStatement('PRAGMA foreign_keys = ON');
      },
    );
  }

  // --- Books Operations ---
  Stream<List<BookEntry>> watchAllBooks() {
    return (select(books)
          ..orderBy([
            (b) => OrderingTerm(expression: b.lastReadAt, mode: OrderingMode.desc),
            (b) => OrderingTerm(expression: b.createdAt, mode: OrderingMode.desc),
          ]))
        .watch();
  }

  Future<List<BookEntry>> getAllBooks() {
    return (select(books)
          ..orderBy([
            (b) => OrderingTerm(expression: b.lastReadAt, mode: OrderingMode.desc),
            (b) => OrderingTerm(expression: b.createdAt, mode: OrderingMode.desc),
          ]))
        .get();
  }

  Future<BookEntry?> getBookById(String id) {
    return (select(books)..where((b) => b.id.equals(id))).getSingleOrNull();
  }

  Future<int> insertBook(BooksCompanion book) => into(books).insert(book);

  Future<bool> updateBook(BookEntry book) => update(books).replace(book);

  Future<void> updateLastReadPosition({
    required String bookId,
    required int page,
    int? totalPages,
  }) async {
    final companion = BooksCompanion(
      lastReadPage: Value(page),
      lastReadAt: Value(DateTime.now()),
      totalPages: totalPages != null ? Value(totalPages) : const Value.absent(),
    );
    await (update(books)..where((b) => b.id.equals(bookId))).write(companion);
  }

  Future<int> deleteBook(String id) {
    return (delete(books)..where((b) => b.id.equals(id))).go();
  }

  // --- Highlights Operations ---
  Stream<List<HighlightEntry>> watchHighlightsForBook(String bookId) {
    return (select(highlights)
          ..where((h) => h.bookId.equals(bookId))
          ..orderBy([(h) => OrderingTerm(expression: h.pageNumber)]))
        .watch();
  }

  Future<int> insertHighlight(HighlightsCompanion highlight) =>
      into(highlights).insert(highlight);

  Future<int> deleteHighlight(String id) =>
      (delete(highlights)..where((h) => h.id.equals(id))).go();

  // --- Notes Operations ---
  Future<int> insertNote(NotesCompanion note) => into(notes).insert(note);

  Future<bool> updateNoteReflection(String noteId, String newReflection) async {
    final count = await (update(notes)..where((n) => n.id.equals(noteId))).write(
      NotesCompanion(reflectionText: Value(newReflection)),
    );
    return count > 0;
  }

  Future<int> deleteNote(String id) =>
      (delete(notes)..where((n) => n.id.equals(id))).go();

  // --- Tags Operations ---
  Future<TagEntry> getOrCreateTag(String name) async {
    final cleanName = name.trim().toLowerCase();
    final existing = await (select(tags)..where((t) => t.name.equals(cleanName)))
        .getSingleOrNull();
    if (existing != null) return existing;

    final id = DateTime.now().microsecondsSinceEpoch.toString();
    await into(tags).insert(TagsCompanion.insert(id: id, name: cleanName));
    return TagEntry(id: id, name: cleanName);
  }

  Future<List<TagEntry>> getAllTags() => select(tags).get();

  Stream<List<TagEntry>> watchAllTags() => select(tags).watch();

  Future<void> setTagsForNote(String noteId, List<String> tagNames) async {
    await (delete(noteTags)..where((nt) => nt.noteId.equals(noteId))).go();
    for (final name in tagNames) {
      if (name.trim().isEmpty) continue;
      final tag = await getOrCreateTag(name.trim());
      await into(noteTags).insertOnConflictUpdate(
        NoteTagsCompanion.insert(noteId: noteId, tagId: tag.id),
      );
    }
  }

  // --- Bookmarks Operations ---
  Stream<List<BookmarkEntry>> watchBookmarksForBook(String bookId) {
    return (select(bookmarks)
          ..where((bm) => bm.bookId.equals(bookId))
          ..orderBy([(bm) => OrderingTerm(expression: bm.pageNumber)]))
        .watch();
  }

  Future<int> insertBookmark(BookmarksCompanion bookmark) =>
      into(bookmarks).insert(bookmark);

  Future<int> deleteBookmark(String id) =>
      (delete(bookmarks)..where((bm) => bm.id.equals(id))).go();

  // --- Knowledge Hub Queries ---
  Stream<List<NoteWithDetails>> watchAllNotesWithDetails({
    String? searchQuery,
    String? filterBookId,
    String? filterTagId,
  }) {
    final query = select(notes).join([
      innerJoin(highlights, highlights.id.equalsExp(notes.highlightId)),
      innerJoin(books, books.id.equalsExp(highlights.bookId)),
    ]);

    if (filterBookId != null && filterBookId.isNotEmpty) {
      query.where(books.id.equals(filterBookId));
    }

    query.orderBy([OrderingTerm(expression: notes.createdAt, mode: OrderingMode.desc)]);

    return query.watch().asyncMap((rows) async {
      final results = <NoteWithDetails>[];
      for (final row in rows) {
        final noteEntry = row.readTable(notes);
        final highlightEntry = row.readTable(highlights);
        final bookEntry = row.readTable(books);

        // Fetch tags for this note
        final tagRows = await (select(noteTags).join([
          innerJoin(tags, tags.id.equalsExp(noteTags.tagId)),
        ])..where(noteTags.noteId.equals(noteEntry.id))).get();

        final noteTagsList = tagRows.map((tr) => tr.readTable(tags)).toList();

        // Tag filter check
        if (filterTagId != null && filterTagId.isNotEmpty) {
          final hasTag = noteTagsList.any((t) => t.id == filterTagId);
          if (!hasTag) continue;
        }

        // Search query check (Search quote, reflection, tags, or book title)
        if (searchQuery != null && searchQuery.trim().isNotEmpty) {
          final q = searchQuery.toLowerCase().trim();
          final matchesQuote = highlightEntry.selectedText.toLowerCase().contains(q);
          final matchesReflection = noteEntry.reflectionText.toLowerCase().contains(q);
          final matchesBook = bookEntry.title.toLowerCase().contains(q);
          final matchesTag = noteTagsList.any((t) => t.name.toLowerCase().contains(q));

          if (!matchesQuote && !matchesReflection && !matchesBook && !matchesTag) {
            continue;
          }
        }

        results.add(
          NoteWithDetails(
            note: noteEntry,
            highlight: highlightEntry,
            book: bookEntry,
            tags: noteTagsList,
          ),
        );
      }
      return results;
    });
  }

  // Count helper
  Future<int> countNotesForBook(String bookId) async {
    final query = select(notes).join([
      innerJoin(highlights, highlights.id.equalsExp(notes.highlightId)),
    ])..where(highlights.bookId.equals(bookId));
    final rows = await query.get();
    return rows.length;
  }
}

