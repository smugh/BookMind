export 'book_file_storage_unsupported.dart'
    if (dart.library.js_interop) 'book_file_storage_web.dart'
    if (dart.library.io) 'book_file_storage_io.dart';
