import 'package:drift/drift.dart';
import 'package:epubx/epubx.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';
import '../../../core/utils/book_file_storage.dart';
import '../../../data/database/app_database.dart';
import '../../../data/database/database_provider.dart';

class LibraryService {
  final AppDatabase _db;
  final _uuid = const Uuid();

  LibraryService(this._db);

  /// Pick a PDF or EPUB file and import it into the local database and app storage.
  Future<BookEntry?> pickAndImportBook() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'epub'],
      withData: true,
    );

    if (result == null || result.files.isEmpty) return null;
    final file = result.files.first;

    final ext = (file.extension ?? (file.name.contains('.') ? file.name.split('.').last : 'pdf'))
        .toLowerCase();
    final isEpub = ext == 'epub';

    Uint8List? fileBytes = file.bytes;
    if (fileBytes == null && file.path != null) {
      fileBytes = await BookFileStorage.readBytes(file.path!);
    }

    if (fileBytes == null) return null;

    final bookId = _uuid.v4();
    final savedFilePath = await BookFileStorage.saveBookFile(
      bookId,
      ext,
      fileBytes,
      originalPath: file.path,
    );

    String title = p.basenameWithoutExtension(file.name);
    String author = 'Penulis Tidak Diketahui';
    String? coverPath;

    if (isEpub) {
      try {
        final epubBook = await EpubReader.readBook(fileBytes);

        if (epubBook.Title != null && epubBook.Title!.trim().isNotEmpty) {
          title = epubBook.Title!.trim();
        }
        if (epubBook.Author != null && epubBook.Author!.trim().isNotEmpty) {
          author = epubBook.Author!.trim();
        }

        // Try extracting cover
        if (epubBook.CoverImage != null) {
          final encoded = Uint8List.fromList(img.encodeJpg(epubBook.CoverImage!));
          coverPath = await BookFileStorage.saveCoverImage(bookId, encoded);
        }
      } catch (_) {
        // Fallback to filename
      }
    }

    final companion = BooksCompanion(
      id: Value(bookId),
      title: Value(title),
      author: Value(author),
      filePath: Value(savedFilePath),
      fileType: Value(isEpub ? 'epub' : 'pdf'),
      coverPath: Value(coverPath),
      totalPages: const Value(0),
      lastReadPage: const Value(1),
      createdAt: Value(DateTime.now()),
    );

    await _db.insertBook(companion);
    return _db.getBookById(bookId);
  }

  /// Delete a book and its physical stored files
  Future<void> deleteBook(BookEntry book) async {
    await _db.deleteBook(book.id);

    try {
      await BookFileStorage.deleteFile(book.filePath);
      if (book.coverPath != null) {
        await BookFileStorage.deleteFile(book.coverPath!);
      }
    } catch (_) {}
  }
}

final libraryServiceProvider = Provider<LibraryService>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return LibraryService(db);
});
