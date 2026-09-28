import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/database/app_database.dart';
import '../../../data/database/database_provider.dart';
import '../../notes/presentation/add_reflection_sheet.dart';
import '../../profile/presentation/widgets/export_notes_sheet.dart';
import '../../reader/presentation/reader_screen.dart';

final knowledgeSearchQueryProvider = StateProvider<String>((ref) => '');
final knowledgeSelectedBookIdProvider = StateProvider<String?>((ref) => null);
final knowledgeSelectedTagIdProvider = StateProvider<String?>((ref) => null);
final knowledgeActiveTabProvider = StateProvider<String>((ref) => 'Semua');

class KnowledgeHubScreen extends ConsumerWidget {
  const KnowledgeHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(appDatabaseProvider);
    final searchQuery = ref.watch(knowledgeSearchQueryProvider);
    final selectedBookId = ref.watch(knowledgeSelectedBookIdProvider);
    final selectedTagId = ref.watch(knowledgeSelectedTagIdProvider);
    final activeTab = ref.watch(knowledgeActiveTabProvider);

    final notesStream = db.watchAllNotesWithDetails(
      searchQuery: searchQuery,
      filterBookId: selectedBookId,
      filterTagId: selectedTagId,
    );

    final allBooksAsync = ref.watch(allBooksStreamProvider);
    final allTagsAsync = ref.watch(allTagsStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.n100,
      appBar: AppBar(
        title: Text('Catatan Saya', style: AppTypography.headlineLarge),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Cari catatan',
            onPressed: () {
              // Focus or toggle search
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            tooltip: 'Menu lainnya',
            onPressed: () {
              _showExportSheet(context, ref);
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Filter Tabs & Search Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: Column(
              children: [
                // Filter Tabs: Semua, Highlight, Catatan, Bookmark
                _buildTypeTabs(ref, activeTab),
                const SizedBox(height: 10),

                // Filter Dropdowns / Chips (Buku & Tag)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // Filter by Book chip
                      allBooksAsync.when(
                        data: (books) {
                          final selectedBook =
                              books.where((b) => b.id == selectedBookId).firstOrNull;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: FilterChip(
                              label: Text(
                                selectedBook != null
                                    ? selectedBook.title
                                    : 'Semua Buku',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              selected: selectedBookId != null,
                              selectedColor: AppColors.primaryCream,
                              backgroundColor: Colors.white,
                              side: const BorderSide(color: AppColors.n300),
                              onSelected: (_) => _showBookFilterDialog(
                                  context, ref, books, selectedBookId),
                            ),
                          );
                        },
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                      ),

                      // Filter by Tag chip
                      allTagsAsync.when(
                        data: (tags) {
                          final selectedTag =
                              tags.where((t) => t.id == selectedTagId).firstOrNull;
                          return FilterChip(
                            label: Text(
                              selectedTag != null
                                  ? '#${selectedTag.name}'
                                  : 'Semua Tag',
                            ),
                            selected: selectedTagId != null,
                            selectedColor: AppColors.lavender,
                            backgroundColor: Colors.white,
                            side: const BorderSide(color: AppColors.n300),
                            onSelected: (_) => _showTagFilterDialog(
                                context, ref, tags, selectedTagId),
                          );
                        },
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                      ),

                      if (selectedBookId != null || selectedTagId != null)
                        TextButton(
                          onPressed: () {
                            ref
                                .read(knowledgeSelectedBookIdProvider.notifier)
                                .state = null;
                            ref
                                .read(knowledgeSelectedTagIdProvider.notifier)
                                .state = null;
                          },
                          child: const Text('Reset',
                              style: TextStyle(
                                  fontSize: 12, color: AppColors.primaryTerracotta)),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Notes List
          Expanded(
            child: StreamBuilder<List<NoteWithDetails>>(
              stream: notesStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primaryCoffee),
                  );
                }

                var items = snapshot.data ?? [];

                // Filter by active Tab
                if (activeTab == 'Highlight') {
                  items = items.where((i) => i.note.reflectionText.isEmpty).toList();
                } else if (activeTab == 'Catatan') {
                  items = items.where((i) => i.note.reflectionText.isNotEmpty).toList();
                }

                if (items.isEmpty) {
                  return _buildEmptyState(context);
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return _buildNoteCard(context, ref, item);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add note to current active book
          allBooksAsync.whenData((books) {
            if (books.isNotEmpty) {
              final book = books.first;
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (ctx) => AddReflectionSheet(
                  bookId: book.id,
                  pageNumber: book.lastReadPage,
                  quoteText: 'Kutipan inspirasi dari ${book.title}',
                ),
              );
            }
          });
        },
        backgroundColor: AppColors.primaryCoffee,
        foregroundColor: Colors.white,
        tooltip: 'Tambah Catatan',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTypeTabs(WidgetRef ref, String activeTab) {
    final tabs = ['Semua', 'Highlight', 'Catatan', 'Bookmark'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: tabs.map((tab) {
          final isSelected = activeTab == tab;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: InkWell(
              onTap: () {
                ref.read(knowledgeActiveTabProvider.notifier).state = tab;
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryCoffee : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? AppColors.primaryCoffee : AppColors.n300,
                  ),
                ),
                child: Text(
                  tab,
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
    );
  }

  Widget _buildNoteCard(
      BuildContext context, WidgetRef ref, NoteWithDetails item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.n200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quote row with terracotta quote mark
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '“',
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 26,
                  height: 1.1,
                  color: AppColors.primaryTerracotta,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.highlight.selectedText,
                  style: AppTypography.quoteText.copyWith(
                    fontSize: 14,
                    height: 1.45,
                    color: AppColors.n900,
                  ),
                ),
              ),
            ],
          ),

          // Separate Reflection Box underneath (Screen 8 style)
          if (item.note.reflectionText.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFBF8F3),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFF2E9DA)),
              ),
              child: Text(
                item.note.reflectionText,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.n900,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ),
          ],

          // Tags row
          if (item.tags.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: item.tags.map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.lavender,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '#${tag.name}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.primaryCoffee,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],

          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 10),

          // Footer row (Book title, Hal, Date, Actions)
          Row(
            children: [
              Expanded(
                child: Text(
                  '${item.book.title} · Hal. ${item.highlight.pageNumber} · ${DateFormatter.formatShortDate(item.note.createdAt)}',
                  style: AppTypography.labelSmall.copyWith(
                    fontSize: 11,
                    color: AppColors.n500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_horiz, size: 20, color: AppColors.n500),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onSelected: (val) {
                  if (val == 'edit') {
                    _editNote(context, item);
                  } else if (val == 'delete') {
                    _confirmDeleteNote(context, ref, item);
                  }
                },
                itemBuilder: (ctx) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined, size: 16),
                        SizedBox(width: 8),
                        Text('Edit Refleksi'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, size: 16, color: AppColors.error),
                        SizedBox(width: 8),
                        Text('Hapus', style: TextStyle(color: AppColors.error)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 4),
              // DEEP LINK ACTION
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (ctx) => ReaderScreen(
                        book: item.book,
                        initialPage: item.highlight.pageNumber,
                      ),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryCream,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFEADBCE)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.open_in_new, size: 13, color: AppColors.primaryCoffee),
                      const SizedBox(width: 4),
                      Text(
                        'Buka',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.primaryCoffee,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _editNote(BuildContext context, NoteWithDetails item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AddReflectionSheet(
        bookId: item.book.id,
        pageNumber: item.highlight.pageNumber,
        quoteText: item.highlight.selectedText,
        existingHighlightId: item.highlight.id,
        existingNoteId: item.note.id,
        initialReflection: item.note.reflectionText,
        initialColor: item.highlight.color,
        initialTags: item.tags.map((t) => t.name).toList(),
      ),
    );
  }

  void _confirmDeleteNote(
      BuildContext context, WidgetRef ref, NoteWithDetails item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Catatan?'),
        content: const Text('Catatan ini akan dihapus secara permanen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(appDatabaseProvider).deleteNote(item.note.id);
            },
            child: const Text('Hapus', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.sticky_note_2_outlined,
                size: 64, color: AppColors.primaryTerracotta),
            const SizedBox(height: 16),
            Text('Belum Ada Catatan', style: AppTypography.headlineLarge),
            const SizedBox(height: 8),
            Text(
              'Sorot teks di buku Anda lalu simpan refleksi untuk membangun basis pengetahuan di sini.',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  void _showBookFilterDialog(BuildContext context, WidgetRef ref,
      List<BookEntry> books, String? currentBookId) {
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Filter Berdasarkan Buku'),
        children: [
          SimpleDialogOption(
            onPressed: () {
              ref.read(knowledgeSelectedBookIdProvider.notifier).state = null;
              Navigator.pop(ctx);
            },
            child: const Text('Semua Buku',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ...books.map((book) => SimpleDialogOption(
                onPressed: () {
                  ref.read(knowledgeSelectedBookIdProvider.notifier).state =
                      book.id;
                  Navigator.pop(ctx);
                },
                child: Text(book.title),
              )),
        ],
      ),
    );
  }

  void _showTagFilterDialog(BuildContext context, WidgetRef ref,
      List<TagEntry> tags, String? currentTagId) {
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Filter Berdasarkan Tag'),
        children: [
          SimpleDialogOption(
            onPressed: () {
              ref.read(knowledgeSelectedTagIdProvider.notifier).state = null;
              Navigator.pop(ctx);
            },
            child: const Text('Semua Tag',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ...tags.map((tag) => SimpleDialogOption(
                onPressed: () {
                  ref.read(knowledgeSelectedTagIdProvider.notifier).state =
                      tag.id;
                  Navigator.pop(ctx);
                },
                child: Text('#${tag.name}'),
              )),
        ],
      ),
    );
  }

  void _showExportSheet(BuildContext context, WidgetRef ref) {
    ExportNotesSheet.show(context);
  }
}
