import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class BookFileStorage {
  static Future<String> saveBookFile(String bookId, String ext, Uint8List bytes, {String? originalPath}) async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final booksDir = Directory(p.join(appDocDir.path, 'books'));
    if (!await booksDir.exists()) await booksDir.create(recursive: true);

    final savedFilePath = p.join(booksDir.path, '$bookId.$ext');

    if (originalPath != null && await File(originalPath).exists()) {
      await File(originalPath).copy(savedFilePath);
    } else {
      await File(savedFilePath).writeAsBytes(bytes);
    }

    return savedFilePath;
  }

  static Future<String> saveCoverImage(String bookId, Uint8List bytes) async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final coversDir = Directory(p.join(appDocDir.path, 'covers'));
    if (!await coversDir.exists()) await coversDir.create(recursive: true);

    final coverPath = p.join(coversDir.path, '$bookId.jpg');
    await File(coverPath).writeAsBytes(bytes);
    return coverPath;
  }

  static Future<Uint8List?> readBytes(String path) async {
    final file = File(path);
    if (await file.exists()) {
      return file.readAsBytes();
    }
    return null;
  }

  static Future<void> deleteFile(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {}
  }
}
