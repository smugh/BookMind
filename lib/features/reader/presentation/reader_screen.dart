import 'dart:typed_data';
import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/book_file_storage.dart';
import '../../../data/database/app_database.dart';
import '../../../data/database/database_provider.dart';
import '../../notes/presentation/add_reflection_sheet.dart';
import 'epub_viewer.dart';
import 'reader_settings_sheet.dart';

class ReaderScreen extends ConsumerStatefulWidget {
  final BookEntry book;
  final int initialPage;

  const ReaderScreen({
    super.key,
    required this.book,
    this.initialPage = 1,
  });

  @override
  ConsumerState<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends ConsumerState<ReaderScreen> {
  late final PdfViewerController _pdfViewerController;
  late int _currentPage;
  int _totalPages = 0;
  bool _isSearching = false;
  final TextEditingController _searchQueryController = TextEditingController();
  PdfTextSearchResult? _searchResult;
  Uint8List? _bookBytes;
  bool _isLoadingBytes = true;

  // Controls whether notes / sticky notes are shown inline on the ebook page
  // By default: false (HIDDEN) so the original ebook text is clean and undisturbed
  bool _showNotesOnPage = false;

  // Set of note IDs that the user has explicitly chosen to expand inline on the page
  final Set<String> _expandedInlineNoteIds = {};

  // Set of note IDs that are currently minimized as a sticky note
  final Set<String> _minimizedStickyNoteIds = {};

  ReaderSettings _settings = const ReaderSettings();

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage;
    _totalPages = widget.book.totalPages > 0 ? widget.book.totalPages : 320;
    _pdfViewerController = PdfViewerController();
    _loadBookBytes();
  }

  Future<void> _loadBookBytes() async {
    final bytes = await BookFileStorage.readBytes(widget.book.filePath);
    if (mounted) {
      setState(() {
        _bookBytes = bytes;
        _isLoadingBytes = false;
      });
    }
  }

  @override
  void dispose() {
    _searchQueryController.dispose();
    _pdfViewerController.dispose();
    super.dispose();
  }

  void _updateReadingPosition(int page, [int? total]) {
    _currentPage = page;
    if (total != null && total > 0) {
      _totalPages = total;
    }
    ref.read(appDatabaseProvider).updateLastReadPosition(
          bookId: widget.book.id,
          page: _currentPage,
          totalPages: _totalPages > 0 ? _totalPages : null,
        );
  }

  Future<void> _toggleBookmark() async {
    final db = ref.read(appDatabaseProvider);
    final bookmarks = await db.watchBookmarksForBook(widget.book.id).first;
    final existing = bookmarks.where((bm) => bm.pageNumber == _currentPage).firstOrNull;

    if (existing != null) {
      await db.deleteBookmark(existing.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bookmark halaman $_currentPage dihapus'),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } else {
      await db.insertBookmark(
        BookmarksCompanion(
          id: drift.Value(const Uuid().v4()),
          bookId: drift.Value(widget.book.id),
          pageNumber: drift.Value(_currentPage),
          createdAt: drift.Value(DateTime.now()),
        ),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Halaman $_currentPage ditambahkan ke Bookmark'),
            backgroundColor: AppColors.primaryCoffee,
            duration: const Duration(seconds: 1),
          ),
        );
      }
    }
  }

  void _openAddReflection(
    String quote,
    int page, {
    String defaultColor = 'yellow',
    String? existingHighlightId,
    String? existingNoteId,
    String? initialReflection,
    List<String>? initialTags,
    bool initialIsSticky = true,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AddReflectionSheet(
        bookId: widget.book.id,
        bookTitle: widget.book.title,
        pageNumber: page,
        quoteText: quote,
        initialColor: defaultColor,
        existingHighlightId: existingHighlightId,
        existingNoteId: existingNoteId,
        initialReflection: initialReflection,
        initialTags: initialTags,
        initialIsSticky: initialIsSticky,
      ),
    );
  }

  void _openReaderSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => ReaderSettingsSheet(
        settings: _settings.copyWith(showNotesOnPage: _showNotesOnPage),
        onSettingsChanged: (newSettings) {
          setState(() {
            _settings = newSettings;
            _showNotesOnPage = newSettings.showNotesOnPage;
          });
        },
      ),
    );
  }

  void _showNoteDetailModal({
    required String quote,
    required NoteWithDetails? noteDetails,
    required String highlightColorKey,
    required Color highlightColor,
    required String reflectionText,
    required String noteId,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFFAF7F2),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.n300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title and close
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF9C3),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFFDE047)),
                        ),
                        child: const Text('📌', style: TextStyle(fontSize: 14)),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Catatan pada Halaman $_currentPage',
                        style: AppTypography.headlineMedium.copyWith(fontSize: 16),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Highlighted Quote preview
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: highlightColor.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(10),
                  border: Border(left: BorderSide(color: highlightColor, width: 3.5)),
                ),
                child: Text(
                  '“$quote”',
                  style: GoogleFonts.lora(
                    fontSize: 13.5,
                    fontStyle: FontStyle.italic,
                    color: AppColors.n700,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Reflection note body
              Text(
                'Refleksi & Catatan:',
                style: AppTypography.labelSmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.n700,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFCD34D)),
                ),
                child: Text(
                  reflectionText,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    height: 1.5,
                    color: const Color(0xFF451A03),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Tags
              if (noteDetails != null && noteDetails.tags.isNotEmpty)
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: noteDetails.tags
                      .where((t) => t.name.toLowerCase() != 'stickynote')
                      .map(
                        (t) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.n300),
                          ),
                          child: Text(
                            '#${t.name}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.primaryTerracotta,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              const SizedBox(height: 20),

              // Action buttons: Buka di Halaman & Edit Catatan
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        setState(() {
                          _expandedInlineNoteIds.add(noteId);
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Catatan ditampilkan di halaman'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                      icon: const Icon(Icons.unfold_more, size: 16),
                      label: const Text('Buka di Halaman', style: TextStyle(fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryCoffee,
                        side: const BorderSide(color: AppColors.primaryCoffee),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _openAddReflection(
                          quote,
                          _currentPage,
                          defaultColor: highlightColorKey,
                          existingHighlightId: noteDetails?.highlight.id,
                          existingNoteId: noteDetails?.note.id,
                          initialReflection: reflectionText,
                          initialTags: noteDetails?.tags.map((t) => t.name).toList(),
                          initialIsSticky: true,
                        );
                      },
                      icon: const Icon(Icons.edit_outlined, size: 16),
                      label: const Text('Edit Catatan', style: TextStyle(fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryCoffee,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _toggleStickyMinimize(String noteId) {
    setState(() {
      if (_minimizedStickyNoteIds.contains(noteId)) {
        _minimizedStickyNoteIds.remove(noteId);
      } else {
        _minimizedStickyNoteIds.add(noteId);
      }
    });
  }

  void _showBookNotesDrawer() {
    final db = ref.read(appDatabaseProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: const BoxDecoration(
            color: Color(0xFFFAF7F2),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.n300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Catatan & Bookmark di Buku Ini',
                style: AppTypography.headlineMedium,
              ),
              const SizedBox(height: 12),
              Expanded(
                child: DefaultTabController(
                  length: 2,
                  child: Column(
                    children: [
                      const TabBar(
                        labelColor: AppColors.primaryCoffee,
                        unselectedLabelColor: AppColors.n500,
                        indicatorColor: AppColors.primaryCoffee,
                        tabs: [
                          Tab(text: 'Highlight & Catatan'),
                          Tab(text: 'Bookmark'),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            // Tab 1: Highlights & Notes
                            StreamBuilder<List<NoteWithDetails>>(
                              stream: db.watchAllNotesWithDetails(filterBookId: widget.book.id),
                              builder: (context, snapshot) {
                                final notes = snapshot.data ?? [];
                                if (notes.isEmpty) {
                                  return const Center(child: Text('Belum ada catatan untuk buku ini'));
                                }
                                return ListView.separated(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  itemCount: notes.length,
                                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                                  itemBuilder: (context, idx) {
                                    final item = notes[idx];
                                    final isSticky = item.tags.any((t) =>
                                        t.name.toLowerCase() == 'stickynote' ||
                                        t.name.toLowerCase() == 'sticky-note');
                                    return ListTile(
                                      tileColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        side: const BorderSide(color: AppColors.n200),
                                      ),
                                      title: Text(
                                        item.highlight.selectedText,
                                        style: AppTypography.quoteText.copyWith(fontSize: 13),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          if (item.note.reflectionText.isNotEmpty)
                                            Padding(
                                              padding: const EdgeInsets.only(top: 4.0),
                                              child: Text(
                                                item.note.reflectionText,
                                                style: AppTypography.bodyMedium.copyWith(fontSize: 12),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          if (isSticky)
                                            Padding(
                                              padding: const EdgeInsets.only(top: 4.0),
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFFEF9C3),
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: const Text(
                                                  '📌 Sticky Note',
                                                  style: TextStyle(fontSize: 10, color: Color(0xFF713F12), fontWeight: FontWeight.bold),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      trailing: Text(
                                        'Hal. ${item.highlight.pageNumber}',
                                        style: AppTypography.labelSmall.copyWith(
                                          color: AppColors.primaryTerracotta,
                                        ),
                                      ),
                                      onTap: () {
                                        Navigator.pop(ctx);
                                        _jumpToPage(item.highlight.pageNumber);
                                      },
                                    );
                                  },
                                );
                              },
                            ),

                            // Tab 2: Bookmarks
                            StreamBuilder<List<BookmarkEntry>>(
                              stream: db.watchBookmarksForBook(widget.book.id),
                              builder: (context, snapshot) {
                                final bookmarks = snapshot.data ?? [];
                                if (bookmarks.isEmpty) {
                                  return const Center(child: Text('Belum ada bookmark'));
                                }
                                return ListView.separated(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  itemCount: bookmarks.length,
                                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                                  itemBuilder: (context, idx) {
                                    final bm = bookmarks[idx];
                                    return ListTile(
                                      tileColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        side: const BorderSide(color: AppColors.n200),
                                      ),
                                      leading: const Icon(Icons.bookmark, color: AppColors.primaryTerracotta),
                                      title: Text('Halaman ${bm.pageNumber}', style: AppTypography.titleMedium),
                                      trailing: IconButton(
                                        icon: const Icon(Icons.delete_outline, size: 18),
                                        onPressed: () => db.deleteBookmark(bm.id),
                                      ),
                                      onTap: () {
                                        Navigator.pop(ctx);
                                        _jumpToPage(bm.pageNumber);
                                      },
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _jumpToPage(int page) {
    if (widget.book.fileType == 'pdf' && _bookBytes != null) {
      _pdfViewerController.jumpToPage(page);
    }
    setState(() => _currentPage = page);
    _updateReadingPosition(page);
  }

  @override
  Widget build(BuildContext context) {
    final isPdf = widget.book.fileType.toLowerCase() == 'pdf';

    // Theme styles based on reader settings (Terang, Sepia, Gelap)
    Color readerBg = const Color(0xFFFAF7F2);
    Color readerText = AppColors.n900;
    if (_settings.colorMode == 'sepia') {
      readerBg = const Color(0xFFF8EEDD);
      readerText = const Color(0xFF5A4333);
    } else if (_settings.colorMode == 'gelap') {
      readerBg = const Color(0xFF1E1E1E);
      readerText = const Color(0xFFE0E0E0);
    }

    TextStyle readerTextStyle;
    if (_settings.fontFamily == 'Lora') {
      readerTextStyle = GoogleFonts.lora(
        fontSize: _settings.fontSize,
        color: readerText,
        height: _settings.lineSpacing,
      );
    } else if (_settings.fontFamily == 'Inter') {
      readerTextStyle = GoogleFonts.inter(
        fontSize: _settings.fontSize,
        color: readerText,
        height: _settings.lineSpacing,
      );
    } else if (_settings.fontFamily == 'Sans Serif') {
      readerTextStyle = GoogleFonts.plusJakartaSans(
        fontSize: _settings.fontSize,
        color: readerText,
        height: _settings.lineSpacing,
      );
    } else {
      readerTextStyle = TextStyle(
        fontFamily: 'serif',
        fontSize: _settings.fontSize,
        color: readerText,
        height: _settings.lineSpacing,
      );
    }

    return Scaffold(
      backgroundColor: readerBg,
      appBar: AppBar(
        backgroundColor: readerBg,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: readerText),
          onPressed: () {
            _updateReadingPosition(_currentPage);
            Navigator.pop(context);
          },
        ),
        title: _isSearching && isPdf && _bookBytes != null
            ? TextField(
                controller: _searchQueryController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Cari dalam buku...',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchQueryController.clear();
                      _searchResult?.clear();
                      setState(() => _isSearching = false);
                    },
                  ),
                ),
                onSubmitted: (query) {
                  if (query.trim().isNotEmpty) {
                    _searchResult = _pdfViewerController.searchText(query.trim());
                    setState(() {});
                  }
                },
              )
            : Text(
                widget.book.title,
                style: AppTypography.headlineMedium.copyWith(fontSize: 16, color: readerText),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
        actions: [
          // Toggle note visibility on page (default: hidden so original text is undisturbed)
          IconButton(
            icon: Icon(
              _showNotesOnPage ? Icons.sticky_note_2 : Icons.sticky_note_2_outlined,
              color: _showNotesOnPage ? AppColors.primaryTerracotta : readerText,
            ),
            tooltip: _showNotesOnPage
                ? 'Sembunyikan Catatan di Halaman'
                : 'Tampilkan Catatan di Halaman',
            onPressed: () {
              setState(() {
                _showNotesOnPage = !_showNotesOnPage;
                _settings = _settings.copyWith(showNotesOnPage: _showNotesOnPage);
              });
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _showNotesOnPage
                        ? 'Catatan ditampilkan langsung di halaman buku'
                        : 'Catatan disembunyikan agar teks buku lebih nyaman dibaca',
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
          // Table of contents / notes
          IconButton(
            icon: Icon(Icons.menu_book, color: readerText),
            tooltip: 'Catatan Buku',
            onPressed: _showBookNotesDrawer,
          ),
          // Bookmark toggle
          StreamBuilder<List<BookmarkEntry>>(
            stream: ref.watch(appDatabaseProvider).watchBookmarksForBook(widget.book.id),
            builder: (context, snapshot) {
              final isBookmarked = (snapshot.data ?? [])
                  .any((bm) => bm.pageNumber == _currentPage);
              return IconButton(
                icon: Icon(
                  isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  color: isBookmarked ? AppColors.primaryTerracotta : readerText,
                ),
                tooltip: 'Bookmark Halaman',
                onPressed: _toggleBookmark,
              );
            },
          ),
          // Add notes button in top navbar alongside Bookmark
          IconButton(
            icon: Icon(Icons.note_add_outlined, color: readerText),
            tooltip: 'Add notes',
            onPressed: () => _openAddReflection('', _currentPage),
          ),
          // Font Settings (Aa)
          IconButton(
            icon: Text(
              'Aa',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: readerText,
                fontFamily: 'serif',
              ),
            ),
            tooltip: 'Pengaturan Tampilan',
            onPressed: _openReaderSettings,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: _isLoadingBytes
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryCoffee),
            )
          : Stack(
              children: [
                _bookBytes != null && _bookBytes!.isNotEmpty
                    ? (isPdf
                        ? SfPdfViewer.memory(
                            _bookBytes!,
                            controller: _pdfViewerController,
                            canShowScrollHead: true,
                            canShowScrollStatus: true,
                            onDocumentLoaded: (details) {
                              _updateReadingPosition(_currentPage, details.document.pages.count);
                              if (widget.initialPage > 1) {
                                _pdfViewerController.jumpToPage(widget.initialPage);
                              }
                            },
                            onPageChanged: (details) {
                              _updateReadingPosition(details.newPageNumber);
                            },
                          )
                        : EpubViewer(
                            bytes: _bookBytes!,
                            initialPage: widget.initialPage,
                            onPageChanged: (page, total) {
                              _updateReadingPosition(page, total);
                            },
                            onTextSelected: (text, page) {
                              _openAddReflection(text, page);
                            },
                          ))
                    : _buildInteractiveReader(readerTextStyle, readerBg, readerText),

                // Bottom Progress Bar & Reading Status
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: readerBg,
                      border: Border(top: BorderSide(color: AppColors.n300.withOpacity(0.5))),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 3,
                            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                            activeTrackColor: AppColors.primaryTerracotta,
                            inactiveTrackColor: AppColors.n300,
                            thumbColor: AppColors.primaryTerracotta,
                          ),
                          child: Slider(
                            value: _currentPage.toDouble().clamp(1.0, (_totalPages > 0 ? _totalPages : 320).toDouble()),
                            min: 1,
                            max: (_totalPages > 0 ? _totalPages : 320).toDouble(),
                            onChanged: (val) {
                              _jumpToPage(val.toInt());
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '$_currentPage dari $_totalPages',
                                style: AppTypography.labelSmall.copyWith(fontSize: 11),
                              ),
                              Text(
                                '${((_currentPage / (_totalPages > 0 ? _totalPages : 320)) * 100).toInt()}%',
                                style: AppTypography.labelSmall.copyWith(
                                  fontSize: 11,
                                  color: AppColors.primaryTerracotta,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  /// INTERACTIVE READER WITH REAL-TIME HIGHLIGHTS & MINIMIZABLE STICKY NOTES
  Widget _buildInteractiveReader(TextStyle textStyle, Color bg, Color textColor) {
    final db = ref.watch(appDatabaseProvider);

    return StreamBuilder<List<NoteWithDetails>>(
      stream: db.watchAllNotesWithDetails(filterBookId: widget.book.id),
      builder: (context, snapshot) {
        final notesWithDetails = snapshot.data ?? [];

        // Sample chapter paragraphs
        const List<String> chapterParagraphs = [
          'Progress is often invisible in the moment. We do not see the results of our habits immediately, but the effects compound over time.',
          'Every action you take is a vote for the type of person you wish to become.',
          'The goal is not to read a book, but to become the kind of person who reads. The goal is not to run a marathon, but to become a runner. When your identity shifts, your habits naturally align with who you are.',
          'Small habits, repeated consistently, shape your identity and create remarkable results over the span of months and years.',
        ];

        NoteWithDetails? findNoteForParagraph(String paragraph) {
          for (final n in notesWithDetails) {
            final sel = n.highlight.selectedText.trim().toLowerCase();
            final pLower = paragraph.trim().toLowerCase();
            if (sel.isNotEmpty && (pLower.contains(sel) || sel.contains(pLower))) {
              return n;
            }
          }
          return null;
        }

        // Find any other highlights made by user not matching chapter paragraphs
        final matchedNotes = <NoteWithDetails>{};
        for (final p in chapterParagraphs) {
          final match = findNoteForParagraph(p);
          if (match != null) matchedNotes.add(match);
        }
        final otherNotes = notesWithDetails.where((n) => !matchedNotes.contains(n)).toList();

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 780),
            child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 90),
          children: [
            // Chapter Subtitle
            Text(
              'BAB 4',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                letterSpacing: 2,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryTerracotta,
              ),
            ),
            const SizedBox(height: 6),

            // Chapter Title
            Text(
              'The Man in the Arena',
              style: GoogleFonts.lora(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 20),

            // Paragraphs rendered with unified layout (identical coordinates, margins, and line-wrapping)
            for (int i = 0; i < chapterParagraphs.length; i++) ...[
              _buildBookParagraph(
                text: chapterParagraphs[i],
                textStyle: textStyle,
                noteDetails: findNoteForParagraph(chapterParagraphs[i]),
              ),
              if (i < chapterParagraphs.length - 1)
                const SizedBox(height: 18),
            ],

            // Dynamic User Created Notes (Only shown inline if _showNotesOnPage is explicitly enabled)
            if (_showNotesOnPage && otherNotes.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Divider(height: 24),
              Text(
                'Catatan Lain pada Halaman Ini:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryCoffee.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 12),
              ...otherNotes.map((noteItem) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: _buildBookParagraph(
                    text: noteItem.highlight.selectedText,
                    textStyle: textStyle,
                    noteDetails: noteItem,
                  ),
                );
              }),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  },
    );
  }

  Color _getHighlightColor(String colorKey) {
    switch (colorKey.toLowerCase()) {
      case 'green':
        return AppColors.highlightGreen;
      case 'blue':
        return AppColors.highlightBlue;
      case 'peach':
        return AppColors.highlightPeach;
      case 'yellow':
      default:
        return AppColors.highlightYellow;
    }
  }

  /// Unified book paragraph renderer:
  /// Preserves 100% identical layout, coordinates, word-wrapping, and margins
  /// whether text has notes or not. Notes are indicated solely by text highlight color.
  Widget _buildBookParagraph({
    required String text,
    required TextStyle textStyle,
    required NoteWithDetails? noteDetails,
  }) {
    final hasNote = noteDetails != null;
    final isDark = _settings.colorMode == 'gelap';

    Color? highlightColor;
    String highlightColorKey = 'yellow';
    String reflectionText = '';
    String noteId = '';

    if (hasNote) {
      highlightColorKey = noteDetails.highlight.color;
      highlightColor = _getHighlightColor(highlightColorKey);
      reflectionText = noteDetails.note.reflectionText;
      noteId = noteDetails.note.id;
    }

    final bool isInlineStickyVisible =
        hasNote && (_showNotesOnPage || _expandedInlineNoteIds.contains(noteId));

    final opacity = isDark ? 0.38 : 0.65;
    final activeHighlightColor = highlightColor ?? AppColors.highlightYellow;

    Widget textWidget;
    if (hasNote) {
      final selected = noteDetails.highlight.selectedText.trim();
      if (selected.isNotEmpty && text.contains(selected) && selected != text) {
        // Highlight only the selected substring within the paragraph
        final startIndex = text.indexOf(selected);
        final endIndex = startIndex + selected.length;
        final before = text.substring(0, startIndex);
        final match = text.substring(startIndex, endIndex);
        final after = text.substring(endIndex);

        textWidget = Text.rich(
          TextSpan(
            style: textStyle,
            children: [
              if (before.isNotEmpty) TextSpan(text: before),
              TextSpan(
                text: match,
                style: textStyle.copyWith(
                  backgroundColor: activeHighlightColor.withOpacity(opacity),
                ),
              ),
              if (after.isNotEmpty) TextSpan(text: after),
            ],
          ),
          textAlign: _settings.alignLeft ? TextAlign.left : TextAlign.justify,
        );
      } else {
        // Highlight whole paragraph
        textWidget = Text(
          text,
          style: textStyle.copyWith(
            backgroundColor: activeHighlightColor.withOpacity(opacity),
          ),
          textAlign: _settings.alignLeft ? TextAlign.left : TextAlign.justify,
        );
      }
    } else {
      // Normal unhighlighted paragraph
      textWidget = Text(
        text,
        style: textStyle,
        textAlign: _settings.alignLeft ? TextAlign.left : TextAlign.justify,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: () {
            if (hasNote) {
              _showNoteDetailModal(
                quote: noteDetails.highlight.selectedText.isNotEmpty
                    ? noteDetails.highlight.selectedText
                    : text,
                noteDetails: noteDetails,
                highlightColorKey: highlightColorKey,
                highlightColor: activeHighlightColor,
                reflectionText: reflectionText,
                noteId: noteId,
              );
            } else {
              _openAddReflection(text, _currentPage);
            }
          },
          borderRadius: BorderRadius.circular(4),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: textWidget,
          ),
        ),
        if (isInlineStickyVisible) ...[
          const SizedBox(height: 10),
          _buildStickyNoteWidget(
            noteId: noteId,
            reflectionText: reflectionText.isNotEmpty
                ? reflectionText
                : 'Ini mengingatkan aku bahwa konsistensi kecil jauh lebih penting daripada motivasi besar yang sementara.',
            isMinimized: _minimizedStickyNoteIds.contains(noteId),
            pageNumber: _currentPage,
            tags: noteDetails.tags.map((t) => t.name).toList(),
            onToggleMinimize: () => _toggleStickyMinimize(noteId),
            onCloseNote: () {
              setState(() {
                _expandedInlineNoteIds.remove(noteId);
                if (_showNotesOnPage) {
                  _minimizedStickyNoteIds.add(noteId);
                }
              });
            },
            onEditNote: () {
              _openAddReflection(
                text,
                _currentPage,
                defaultColor: highlightColorKey,
                existingHighlightId: noteDetails.highlight.id,
                existingNoteId: noteDetails.note.id,
                initialReflection: reflectionText,
                initialTags: noteDetails.tags.map((t) => t.name).toList(),
                initialIsSticky: true,
              );
            },
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }

  /// STICKY NOTE COMPONENT (Point 6: Can be minimized/expanded & stays attached to text)
  Widget _buildStickyNoteWidget({
    required String noteId,
    required String reflectionText,
    required bool isMinimized,
    required int pageNumber,
    required List<String> tags,
    required VoidCallback onToggleMinimize,
    required VoidCallback onEditNote,
    VoidCallback? onCloseNote,
  }) {
    // When Minimized: Compact Post-It Tag Badge attached right next to quote
    if (isMinimized) {
      return GestureDetector(
        onTap: onToggleMinimize,
        child: Container(
          margin: const EdgeInsets.only(left: 12),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF9C3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFDE047), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFEAB308).withOpacity(0.18),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFACC15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text('📌', style: TextStyle(fontSize: 12)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Sticky Note: "${reflectionText.length > 30 ? '${reflectionText.substring(0, 30)}...' : reflectionText}"',
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF713F12),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFDE047)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Buka',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF854D0E),
                      ),
                    ),
                    SizedBox(width: 2),
                    Icon(Icons.unfold_more_rounded, size: 14, color: Color(0xFF854D0E)),
                  ],
                ),
              ),
              if (onCloseNote != null) ...[
                const SizedBox(width: 6),
                InkWell(
                  onTap: onCloseNote,
                  borderRadius: BorderRadius.circular(8),
                  child: const Padding(
                    padding: EdgeInsets.all(2.0),
                    child: Icon(Icons.close, size: 14, color: Color(0xFF854D0E)),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    // When Expanded: Post-It Style Note attached directly on page
    return Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(4), // folded tape corner aesthetic
        ),
        border: Border.all(color: const Color(0xFFFCD34D), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFEAB308).withOpacity(0.14),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sticky Note Header with Pin, Title, Edit & Minimize Buttons
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDE047),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text('📌', style: TextStyle(fontSize: 13)),
              ),
              const SizedBox(width: 8),
              Text(
                'Catatan Tempel (Sticky Note)',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF713F12),
                ),
              ),
              const Spacer(),
              // Edit button
              InkWell(
                onTap: onEditNote,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFFDE047)),
                  ),
                  child: const Icon(Icons.edit_outlined, size: 14, color: Color(0xFF713F12)),
                ),
              ),
              const SizedBox(width: 6),
              // Minimize button (Point 6)
              InkWell(
                onTap: onToggleMinimize,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF08A),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFFACC15)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.unfold_less_rounded, size: 14, color: Color(0xFF713F12)),
                      SizedBox(width: 2),
                      Text(
                        'Minimize',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF713F12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (onCloseNote != null) ...[
                const SizedBox(width: 6),
                InkWell(
                  onTap: onCloseNote,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFFDE047)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.visibility_off_outlined, size: 13, color: Color(0xFF713F12)),
                        SizedBox(width: 2),
                        Text(
                          'Sembunyikan',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF713F12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),

          // Note Reflection Text Body
          Text(
            reflectionText,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              height: 1.45,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF451A03),
            ),
          ),
          const SizedBox(height: 10),

          // Tags & Timestamp
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Wrap(
                spacing: 4,
                children: tags.where((t) => t.toLowerCase() != 'stickynote').map((t) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFFDE047)),
                    ),
                    child: Text(
                      '#$t',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF78350F),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const Text(
                'Menempel di teks 📌',
                style: TextStyle(
                  fontSize: 10,
                  fontStyle: FontStyle.italic,
                  color: Color(0xFF92400E),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
