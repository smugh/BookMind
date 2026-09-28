import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/responsive.dart';
import '../../../data/database/app_database.dart';
import '../../../data/database/database_provider.dart';
import '../../../shared/widgets/book_cover_widget.dart';
import '../../library/presentation/widgets/book_detail_sheet.dart';
import '../../profile/presentation/profile_screen.dart';
import '../../profile/presentation/reading_stats_screen.dart';
import '../../reader/presentation/reader_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final VoidCallback onSeeAllLibrary;
  final VoidCallback? onGoToStats;

  const HomeScreen({
    super.key,
    required this.onSeeAllLibrary,
    this.onGoToStats,
  });

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _activeFilter = 'Semua';

  final List<String> _filters = ['Semua', 'Sedang Dibaca', 'Selesai', 'Favorit'];

  @override
  Widget build(BuildContext context) {
    final booksAsync = ref.watch(allBooksStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.n100,
      appBar: AppBar(
        titleSpacing: 20,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Halo,',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.n500),
            ),
            Row(
              children: [
                Text(
                  'Selamat membaca! ',
                  style: AppTypography.headlineLarge.copyWith(fontSize: 20),
                ),
                const Text('👋', style: TextStyle(fontSize: 18)),
              ],
            ),
          ],
        ),
        actions: [
          // Analytics / Statistik button
          IconButton(
            icon: const Icon(
              Icons.bar_chart_rounded,
              color: AppColors.primaryCoffee,
              size: 26,
            ),
            tooltip: 'Statistik Membaca',
            onPressed: () {
              if (widget.onGoToStats != null) {
                widget.onGoToStats!();
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ReadingStatsScreen()),
                );
              }
            },
          ),
          const SizedBox(width: 4),
          // Profile Avatar matching Screen 3 top right
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(right: 20),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFDE2D9),
                border: Border.all(color: AppColors.primaryTerracotta, width: 1.5),
              ),
              alignment: Alignment.center,
              child: const Text(
                'NP',
                style: TextStyle(
                  color: AppColors.primaryCoffee,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
      body: booksAsync.when(
        data: (books) {
          if (books.isEmpty) {
            return _buildEmptyState(context);
          }

          // Active reading book for "Lanjut Membaca" card
          final recentBook = books.where((b) => b.lastReadAt != null).isNotEmpty
              ? books.firstWhere((b) => b.lastReadAt != null)
              : books.first;

          // Filter books for "Perpustakaan Saya" grid
          final filteredBooks = books.where((b) {
            if (_activeFilter == 'Sedang Dibaca') {
              return b.lastReadAt != null &&
                  (b.totalPages == 0 || b.lastReadPage < b.totalPages);
            } else if (_activeFilter == 'Selesai') {
              return b.totalPages > 0 && b.lastReadPage >= b.totalPages;
            } else if (_activeFilter == 'Favorit') {
              return b.title.contains('Atomic') || b.title.contains('Stoic');
            }
            return true;
          }).toList();

          final isTablet = Responsive.isTabletOrDesktop(context);

          return RefreshIndicator(
            color: AppColors.primaryCoffee,
            onRefresh: () async {
              ref.invalidate(allBooksStreamProvider);
            },
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1040),
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  children: [
                    if (isTablet) ...[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildRecentReadingCard(context, recentBook),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Statistik Membaca', style: AppTypography.headlineMedium),
                                const SizedBox(height: 12),
                                _buildQuickStatsCard(context),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ] else ...[
                      // Section "Lanjut Membaca"
                      _buildRecentReadingCard(context, recentBook),
                      const SizedBox(height: 16),

                      // Quick Analytics / Statistik Banner
                      _buildQuickStatsCard(context),
                      const SizedBox(height: 24),
                    ],

                // Section "Perpustakaan Saya"
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Perpustakaan Saya', style: AppTypography.headlineMedium),
                    InkWell(
                      onTap: widget.onSeeAllLibrary,
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
                const SizedBox(height: 12),

                // Filter Pills
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _filters.map((filter) {
                      final isSelected = _activeFilter == filter;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: InkWell(
                          onTap: () => setState(() => _activeFilter = filter),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primaryCoffee
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primaryCoffee
                                    : AppColors.n300,
                              ),
                            ),
                            child: Text(
                              filter,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                color: isSelected ? Colors.white : AppColors.n700,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),

                // 3-Column Book Grid
                _buildBooksGrid(context, filteredBooks),
                const SizedBox(height: 40),
                  ],
                ),
              ),
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
    );
  }

  Widget _buildRecentReadingCard(BuildContext context, BookEntry book) {
    final total = book.totalPages > 0 ? book.totalPages : 320;
    final progressRatio = (book.lastReadPage / total).clamp(0.05, 1.0);
    final progressPercent = (progressRatio * 100).toInt();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Lanjut Membaca', style: AppTypography.headlineMedium),
        const SizedBox(height: 12),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _openReader(context, book, book.lastReadPage),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.n200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                BookCoverWidget(
                  book: book,
                  width: 65,
                  height: 95,
                  borderRadius: 8,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.title,
                        style: AppTypography.titleLarge.copyWith(fontSize: 15),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        book.author,
                        style: AppTypography.bodyMedium.copyWith(
                          fontSize: 12,
                          color: AppColors.n500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Bab 4 dari 20',
                            style: AppTypography.labelSmall.copyWith(
                              fontSize: 11,
                              color: AppColors.n500,
                            ),
                          ),
                          Text(
                            '$progressPercent%',
                            style: AppTypography.labelSmall.copyWith(
                              fontSize: 11,
                              color: AppColors.primaryTerracotta,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: progressRatio,
                          backgroundColor: AppColors.n200,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.primaryCoffee,
                          ),
                          minHeight: 5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryCoffee,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStatsCard(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (widget.onGoToStats != null) {
          widget.onGoToStats!();
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ReadingStatsScreen()),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.n200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.bar_chart_rounded,
                color: Color(0xFFD97706),
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Statistik Membaca',
                        style: AppTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryTerracotta.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          '2026',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryTerracotta,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '12 Buku · 2.340 Halaman · 48 Jam Membaca',
                    style: AppTypography.bodyMedium.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.n700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(Icons.access_time_rounded, size: 12, color: AppColors.primaryTerracotta),
                      const SizedBox(width: 4),
                      Text(
                        'Sesi Terakhir: Hari ini, 20:45 WIB',
                        style: AppTypography.labelSmall.copyWith(
                          fontSize: 11,
                          color: AppColors.n500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              size: 20,
              color: AppColors.n500,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBooksGrid(BuildContext context, List<BookEntry> books) {
    final isTablet = Responsive.isTabletOrDesktop(context);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isTablet ? 5 : 3,
        childAspectRatio: isTablet ? 0.60 : 0.52,
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

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.auto_stories, size: 64, color: AppColors.primaryCoffee),
          const SizedBox(height: 16),
          Text('Belum Ada Buku', style: AppTypography.headlineMedium),
        ],
      ),
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
}
