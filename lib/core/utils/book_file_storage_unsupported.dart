import 'dart:typed_data';

abstract class BookFileStorage {
  static Future<String> saveBookFile(String bookId, String ext, Uint8List bytes, {String? originalPath}) async {
    throw UnsupportedError('Unsupported platform');
  }

  static Future<String> saveCoverImage(String bookId, Uint8List bytes) async {
    throw UnsupportedError('Unsupported platform');
  }

  static Future<Uint8List?> readBytes(String path) async {
    throw UnsupportedError('Unsupported platform');
  }

  static Future<void> deleteFile(String path) async {
    throw UnsupportedError('Unsupported platform');
  }
}
