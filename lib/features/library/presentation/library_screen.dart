import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/database/app_database.dart';
import '../../../data/database/database_provider.dart';
import '../../../shared/widgets/book_cover_widget.dart';
import '../../reader/presentation/reader_screen.dart';
import '../data/library_service.dart';
import 'widgets/book_detail_sheet.dart';

final libraryFilterProvider = StateProvider<String>((ref) => 'Semua');

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booksAsync = ref.watch(allBooksStreamProvider);
    final activeFilter = ref.watch(libraryFilterProvider);

    return Scaffold(
      backgroundColor: AppColors.n100,
      appBar: AppBar(
        title: Text('Perpustakaan', style: AppTypography.headlineLarge),
        actions: [
          IconButton(
            tooltip: 'Cari Buku',
            icon: const Icon(Icons.search, color: AppColors.n900),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Gunakan tab Pencarian untuk mencari buku dan catatan.')),
              );
            },
          ),
          IconButton(
            tooltip: 'Import Buku',
            icon: const Icon(Icons.add_circle_outline, color: AppColors.primaryCoffee, size: 26),
            onPressed: () => _importBook(context, ref),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: booksAsync.when(
        data: (books) {
          if (books.isEmpty) {
            return _buildEmptyState(context, ref);
          }

          // Filter books
          final filteredBooks = books.where((b) {
            if (activeFilter == 'Sedang Dibaca') {
              return b.lastReadAt != null && (b.totalPages == 0 || b.lastReadPage < b.totalPages);
            } else if (activeFilter == 'Selesai') {
              return b.totalPages > 0 && b.lastReadPage >= b.totalPages;
            } else if (activeFilter == 'Favorit') {
              return b.title.contains('Atomic') || b.title.contains('Stoic');
            }
            return true;
          }).toList();

          final filterOptions = ['Semua', 'Sedang Dibaca', 'Selesai', 'Favorit'];

          return RefreshIndicator(
            color: AppColors.primaryCoffee,
            onRefresh: () async {
              ref.invalidate(allBooksStreamProvider);
            },
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              children: [
                // Filter chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: filterOptions.map((filter) {
                      final isSelected = activeFilter == filter;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: InkWell(
                          onTap: () {
                            ref.read(libraryFilterProvider.notifier).state = filter;
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primaryCoffee : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected ? AppColors.primaryCoffee : AppColors.n300,
                              ),
                            ),
                            child: Text(
                              filter,
                              style: TextStyle(
                                color: isSelected ? Colors.white : AppColors.n700,
                                fontSize: 12,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 18),

                // 3-Column Grid of Books
                _buildBooksGrid(context, filteredBooks),
                const SizedBox(height: 90), // Bottom padding for FAB & nav
              ],
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primaryCoffee),
        ),
        error: (err, stack) => Center(
          child: Text('Terjadi kesalahan memuat buku: $err'),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _importBook(context, ref),
        backgroundColor: AppColors.primaryCoffee,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.library_add),
        label: const Text('Import Buku'),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: AppColors.primaryCream,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.auto_stories,
                size: 64,
                color: AppColors.primaryCoffee,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Belum Ada Buku',
              style: AppTypography.headlineLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Mulai bangun perpustakaan pribadi Anda dengan mengimpor file PDF atau EPUB.',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium,
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: () => _importBook(context, ref),
              icon: const Icon(Icons.add),
              label: const Text('Import Buku Sekarang'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryCoffee,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBooksGrid(BuildContext context, List<BookEntry> books) {
    if (books.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 40),
        alignment: Alignment.center,
        child: Text(
          'Tidak ada buku yang sesuai dengan filter.',
          style: AppTypography.bodyMedium,
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.52,
        crossAxisSpacing: 12,
        mainAxisSpacing: 16,
      ),
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _showBookDetail(context, book),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: BookCoverWidget(
                  book: book,
                  width: double.infinity,
                  height: double.infinity,
                  borderRadius: 8,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                book.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.titleMedium.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                book.author,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.bodyMedium.copyWith(
                  fontSize: 10,
                  color: AppColors.n500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showBookDetail(BuildContext context, BookEntry book) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BookDetailSheet(
        book: book,
        onOpenBook: () => _openReader(context, book, book.lastReadPage),
      ),
    );
  }

  void _openReader(BuildContext context, BookEntry book, int page) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => ReaderScreen(
          book: book,
          initialPage: page,
        ),
      ),
    );
  }

  Future<void> _importBook(BuildContext context, WidgetRef ref) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      final imported = await ref.read(libraryServiceProvider).pickAndImportBook();
      if (imported != null) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Berhasil mengimpor "${imported.title}"'),
            backgroundColor: AppColors.primaryCoffee,
          ),
        );
      }
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Gagal mengimpor buku: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}
