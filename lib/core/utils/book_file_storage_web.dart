import 'dart:typed_data';

class BookFileStorage {
  static final Map<String, Uint8List> _webMemoryStorage = {};

  static Future<String> saveBookFile(String bookId, String ext, Uint8List bytes, {String? originalPath}) async {
    final virtualPath = 'web_storage://books/$bookId.$ext';
    _webMemoryStorage[virtualPath] = bytes;
    return virtualPath;
  }

  static Future<String> saveCoverImage(String bookId, Uint8List bytes) async {
    final virtualPath = 'web_storage://covers/$bookId.jpg';
    _webMemoryStorage[virtualPath] = bytes;
    return virtualPath;
  }

  static Future<Uint8List?> readBytes(String path) async {
    return _webMemoryStorage[path];
  }

  static Future<void> deleteFile(String path) async {
    _webMemoryStorage.remove(path);
  }
}
