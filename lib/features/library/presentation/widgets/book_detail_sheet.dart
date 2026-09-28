import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../data/database/app_database.dart';
import '../../../../data/database/database_provider.dart';
import '../../../../shared/widgets/book_cover_widget.dart';
import '../../data/library_service.dart';

class BookDetailSheet extends ConsumerStatefulWidget {
  final BookEntry book;
  final VoidCallback onOpenBook;

  const BookDetailSheet({
    super.key,
    required this.book,
    required this.onOpenBook,
  });

  @override
  ConsumerState<BookDetailSheet> createState() => _BookDetailSheetState();
}

class _BookDetailSheetState extends ConsumerState<BookDetailSheet> {
  bool _isDescriptionExpanded = false;

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(appDatabaseProvider);
    final book = widget.book;

    // Derived category tags based on title/category
    final tags = _getTagsForBook(book.title);
    final synopsis = _getSynopsisForBook(book.title);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.n100,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Drag handle
            Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.n300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),

            // Top action buttons row (Back / Dismiss & More)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.keyboard_arrow_down, size: 28),
                  onPressed: () => Navigator.pop(context),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_horiz),
                  onSelected: (val) {
                    if (val == 'delete') {
                      _confirmDelete(context, ref);
                    }
                  },
                  itemBuilder: (ctx) => [
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                          SizedBox(width: 8),
                          Text('Hapus Buku', style: TextStyle(color: AppColors.error)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Large Centered Book Cover
            BookCoverWidget(
              book: book,
              width: 125,
              height: 180,
              borderRadius: 12,
            ),
            const SizedBox(height: 16),

            // Book Title
            Text(
              book.title,
              textAlign: TextAlign.center,
              style: AppTypography.headlineLarge.copyWith(fontSize: 20),
            ),
            const SizedBox(height: 4),

            // Book Author
            Text(
              book.author,
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(color: AppColors.n700),
            ),
            const SizedBox(height: 12),

            // Category Tags
            Wrap(
              spacing: 8,
              runSpacing: 6,
              alignment: WrapAlignment.center,
              children: tags.map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.n300),
                  ),
                  child: Text(
                    tag,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.n700,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // 3 Stat Boxes Row
            FutureBuilder<int>(
              future: db.countNotesForBook(book.id),
              builder: (context, snapshot) {
                final pageCount = book.totalPages > 0 ? book.totalPages : 320;
                final lastReadStr = book.lastReadAt != null
                    ? DateFormatter.formatShortDate(book.lastReadAt!)
                    : '2026';

                return Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.auto_stories_outlined,
                        value: '$pageCount',
                        label: 'halaman',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.star_border,
                        value: '4.7',
                        label: '(125k)',
                        iconColor: const Color(0xFFD97706),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.history,
                        value: lastReadStr,
                        label: 'Terakhir dibaca',
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),

            // Primary Action: "Lanjut Membaca"
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  widget.onOpenBook();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryCoffee,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Text(
                  book.lastReadAt == null ? 'Mulai Membaca' : 'Lanjut Membaca',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Secondary Action
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Buku "${book.title}" sudah ada di perpustakaan Anda.'),
                      backgroundColor: AppColors.primaryCoffee,
                    ),
                  );
                },
                icon: const Icon(Icons.bookmark_added_outlined, size: 18, color: AppColors.primaryCoffee),
                label: const Text(
                  'Tersimpan di Perpustakaan',
                  style: TextStyle(
                    color: AppColors.primaryCoffee,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  backgroundColor: AppColors.primaryCream,
                  side: const BorderSide(color: Color(0xFFE9DCBF)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Section "Tentang Buku Ini"
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Tentang Buku Ini',
                style: AppTypography.headlineMedium.copyWith(fontSize: 16),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              synopsis,
              maxLines: _isDescriptionExpanded ? 100 : 3,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.n700,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerLeft,
              child: InkWell(
                onTap: () {
                  setState(() => _isDescriptionExpanded = !_isDescriptionExpanded);
                },
                child: Text(
                  _isDescriptionExpanded ? 'Tutup Ringkasan <' : 'Baca Selengkapnya >',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryTerracotta,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    Color? iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.n200),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 14, color: iconColor ?? AppColors.primaryCoffee),
                const SizedBox(width: 4),
                Text(
                  value,
                  style: AppTypography.titleMedium.copyWith(fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 3),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: AppTypography.labelSmall.copyWith(fontSize: 10),
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  List<String> _getTagsForBook(String title) {
    final lower = title.toLowerCase();
    if (lower.contains('atomic')) {
      return ['Self-Development', 'Productivity', 'Habit'];
    } else if (lower.contains('stoic')) {
      return ['Philosophy', 'Mindfulness', 'Stoicism'];
    } else if (lower.contains('deep work')) {
      return ['Productivity', 'Focus', 'Career'];
    } else if (lower.contains('sapiens')) {
      return ['History', 'Anthropology', 'Science'];
    } else if (lower.contains('ikigai')) {
      return ['Life Purpose', 'Happiness', 'Health'];
    }
    return ['Non-Fiction', 'Inspirational', 'Personal Growth'];
  }

  String _getSynopsisForBook(String title) {
    final lower = title.toLowerCase();
    if (lower.contains('atomic')) {
      return 'Atomic Habits membahas bagaimana perubahan kecil yang konsisten dapat menghasilkan hasil luar biasa dalam hidup kita. James Clear menjelaskan prinsip empat pilar pembentukan kebiasaan: menjadikannya terlihat, menarik, mudah, dan memuaskan.';
    } else if (lower.contains('stoic')) {
      return '366 renungan harian tentang kebijaksanaan, ketabahan, dan seni menjalani hidup dari para filsuf Stoa terkemuka seperti Marcus Aurelius, Seneca, dan Epictetus.';
    } else if (lower.contains('deep work')) {
      return 'Panduan komprehensif untuk menguasai konsentrasi mendalam di dunia yang penuh distraksi, memungkinkan kita menyelesaikan pekerjaan berkualitas tinggi dalam waktu lebih singkat.';
    }
    return 'Buku ini mengajak pembaca merenungkan pola pikir dan kebiasaan sehari-hari untuk mengembangkan potensi diri dan menjalani hidup dengan lebih bermakna.';
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Buku?'),
        content: Text(
          'Buku "${widget.book.title}" beserta catatan dan highlight terkait akan dihapus secara permanen.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              Navigator.pop(context);
              await ref.read(libraryServiceProvider).deleteBook(widget.book);
            },
            child: const Text('Hapus', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
