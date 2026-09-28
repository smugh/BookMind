import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/database/app_database.dart';
import '../../../data/database/database_provider.dart';
import '../../../shared/widgets/book_cover_widget.dart';
import '../../library/presentation/widgets/book_detail_sheet.dart';
import '../../reader/presentation/reader_screen.dart';

class GlobalSearchScreen extends ConsumerStatefulWidget {
  const GlobalSearchScreen({super.key});

  @override
  ConsumerState<GlobalSearchScreen> createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends ConsumerState<GlobalSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  // Curated recommended books matching Screen 7 in mockup
  final List<BookEntry> _recommendedBooks = [
    BookEntry(
      id: 'rec_thinking_fast_slow',
      title: 'Thinking, Fast and Slow',
      author: 'Daniel Kahneman',
      filePath: 'sample_thinking',
      fileType: 'pdf',
      totalPages: 499,
      lastReadPage: 1,
      createdAt: DateTime(2024, 1, 1),
    ),
    BookEntry(
      id: 'rec_dopamine_nation',
      title: 'Dopamine Nation',
      author: 'Anna Lembke',
      filePath: 'sample_dopamine',
      fileType: 'pdf',
      totalPages: 304,
      lastReadPage: 1,
      createdAt: DateTime(2024, 1, 1),
    ),
    BookEntry(
      id: 'rec_psychology_money',
      title: 'The Psychology of Money',
      author: 'Morgan Housel',
      filePath: 'sample_psychology_money',
      fileType: 'epub',
      totalPages: 256,
      lastReadPage: 1,
      createdAt: DateTime(2024, 1, 1),
    ),
  ];

  final List<({String icon, String name, Color bg, Color border})> _categories = const [
    (icon: '🌱', name: 'Self-Development', bg: Color(0xFFFDF6ED), border: Color(0xFFF6E8D6)),
    (icon: '🎯', name: 'Productivity', bg: Color(0xFFF5F2EB), border: Color(0xFFEAE3D6)),
    (icon: '🧠', name: 'Psychology', bg: Color(0xFFEDE9FE), border: Color(0xFFDDD6FE)),
    (icon: '💼', name: 'Business', bg: Color(0xFFE2E8F0), border: Color(0xFFCBD5E1)),
    (icon: '❤️', name: 'Health', bg: Color(0xFFFDE2D9), border: Color(0xFFFBD0C0)),
    (icon: '📖', name: 'Philosophy', bg: Color(0xFFF8EEDD), border: Color(0xFFECDDBD)),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(appDatabaseProvider);
    final allBooksAsync = ref.watch(allBooksStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.n100,
      appBar: AppBar(
        title: Text('Pencarian', style: AppTypography.headlineLarge),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        children: [
          // Search Input Field matching Screen 7
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() => _query = val.trim()),
                  decoration: InputDecoration(
                    hintText: 'Cari buku, penulis, atau topik...',
                    prefixIcon: const Icon(Icons.search, color: AppColors.n500),
                    suffixIcon: _query.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _query = '');
                            },
                          )
                        : null,
                    fillColor: Colors.white,
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.n200),
                ),
                child: IconButton(
                  icon: const Icon(Icons.tune, color: AppColors.n700),
                  tooltip: 'Filter Pencarian',
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Filter pencarian berdasarkan topik & format')),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // IF SEARCHING: Show search results
          if (_query.isNotEmpty) ...[
            Text('Buku Ditemukan', style: AppTypography.headlineMedium.copyWith(fontSize: 16)),
            const SizedBox(height: 12),
            allBooksAsync.when(
              data: (books) {
                final matched = books
                    .where((b) =>
                        b.title.toLowerCase().contains(_query.toLowerCase()) ||
                        b.author.toLowerCase().contains(_query.toLowerCase()))
                    .toList();
                if (matched.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text('Tidak ada buku yang cocok dengan kata kunci ini.'),
                  );
                }
                return SizedBox(
                  height: 190,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: matched.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 14),
                    itemBuilder: (context, idx) {
                      final b = matched[idx];
                      return GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (ctx) => BookDetailSheet(
                              book: b,
                              onOpenBook: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ReaderScreen(book: b, initialPage: b.lastReadPage),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                        child: SizedBox(
                          width: 95,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              BookCoverWidget(book: b, width: 95, height: 135),
                              const SizedBox(height: 6),
                              Text(
                                b.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                b.author,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 10, color: AppColors.n500),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Error: $e'),
            ),
            const SizedBox(height: 24),

            Text('Catatan & Highlight Terkait', style: AppTypography.headlineMedium.copyWith(fontSize: 16)),
            const SizedBox(height: 12),
            StreamBuilder<List<NoteWithDetails>>(
              stream: db.watchAllNotesWithDetails(searchQuery: _query),
              builder: (context, snapshot) {
                final notes = snapshot.data ?? [];
                if (notes.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text('Tidak ada catatan yang cocok.'),
                  );
                }
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: notes.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, idx) {
                    final item = notes[idx];
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.n200),
                      ),
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.highlight.selectedText,
                            style: AppTypography.quoteText.copyWith(fontSize: 13),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (item.note.reflectionText.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              item.note.reflectionText,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.bodyMedium.copyWith(fontSize: 12),
                            ),
                          ],
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${item.book.title} · Hal. ${item.highlight.pageNumber}',
                                style: AppTypography.labelSmall,
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ReaderScreen(
                                        book: item.book,
                                        initialPage: item.highlight.pageNumber,
                                      ),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Buka di Buku >',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryTerracotta,
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
              },
            ),
          ] else ...[
            // DEFAULT VIEW MATCHING SCREEN 7:

            // 1. Section "Rekomendasi untuk Kamu"
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Rekomendasi untuk Kamu', style: AppTypography.headlineMedium),
                InkWell(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Menampilkan semua buku kurasi pilihan')),
                    );
                  },
                  child: const Text(
                    'Lihat Semua',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryTerracotta,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Horizontal Carousel of Recommended Books
            SizedBox(
              height: 205,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _recommendedBooks.length,
                separatorBuilder: (_, __) => const SizedBox(width: 14),
                itemBuilder: (context, idx) {
                  final b = _recommendedBooks[idx];
                  return GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (ctx) => BookDetailSheet(
                          book: b,
                          onOpenBook: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ReaderScreen(book: b, initialPage: 1),
                              ),
                            );
                          },
                        ),
                      );
                    },
                    child: SizedBox(
                      width: 105,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          BookCoverWidget(
                            book: b,
                            width: 105,
                            height: 150,
                            borderRadius: 10,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            b.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.titleMedium.copyWith(fontSize: 12),
                          ),
                          Text(
                            b.author,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.bodyMedium.copyWith(
                              fontSize: 10,
                              color: AppColors.n500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 28),

            // 2. Section "Kategori"
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Kategori', style: AppTypography.headlineMedium),
                InkWell(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Menampilkan seluruh topik bacaan')),
                    );
                  },
                  child: const Text(
                    'Lihat Semua',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryTerracotta,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // 2-column Aesthetic Category Cards (Screen 7)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 2.7,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _categories.length,
              itemBuilder: (context, idx) {
                final cat = _categories[idx];
                return InkWell(
                  onTap: () {
                    setState(() {
                      _query = cat.name;
                      _searchController.text = cat.name;
                    });
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: cat.bg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: cat.border),
                    ),
                    child: Row(
                      children: [
                        Text(cat.icon, style: const TextStyle(fontSize: 16)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            cat.name,
                            style: AppTypography.titleMedium.copyWith(
                              fontSize: 12,
                              color: AppColors.primaryCoffee,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 40),
          ],
        ],
      ),
    );
  }
}
