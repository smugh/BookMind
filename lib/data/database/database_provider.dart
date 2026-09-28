import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_database.dart';
import 'sample_data_seeder.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  // Ensure sample books/notes are seeded if database is brand new
  SampleDataSeeder.seedIfEmpty(db);
  ref.onDispose(() {
    db.close();
  });
  return db;
});

// Stream of all books
final allBooksStreamProvider = StreamProvider<List<BookEntry>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.watchAllBooks();
});

// Stream of all tags
final allTagsStreamProvider = StreamProvider<List<TagEntry>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.watchAllTags();
});
