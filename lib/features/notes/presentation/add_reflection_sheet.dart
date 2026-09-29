import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/database/app_database.dart';
import '../../../data/database/database_provider.dart';

class AddReflectionSheet extends ConsumerStatefulWidget {
  final String bookId;
  final String? bookTitle;
  final int pageNumber;
  final String quoteText;
  final String? existingHighlightId;
  final String? existingNoteId;
  final String? initialReflection;
  final String? initialColor;
  final List<String>? initialTags;
  final bool initialIsSticky;

  const AddReflectionSheet({
    super.key,
    required this.bookId,
    this.bookTitle,
    required this.pageNumber,
    required this.quoteText,
    this.existingHighlightId,
    this.existingNoteId,
    this.initialReflection,
    this.initialColor,
    this.initialTags,
    this.initialIsSticky = true,
  });

  @override
  ConsumerState<AddReflectionSheet> createState() => _AddReflectionSheetState();
}

class _AddReflectionSheetState extends ConsumerState<AddReflectionSheet> {
  late final TextEditingController _reflectionController;
  late final TextEditingController _tagInputController;
  late String _selectedColor;
  late bool _isStickyNote;
  final List<String> _tags = [];
  bool _isSaving = false;

  final Map<String, Color> _colorOptions = {
    'yellow': AppColors.highlightYellow,
    'green': AppColors.highlightGreen,
    'blue': AppColors.highlightBlue,
  };

  @override
  void initState() {
    super.initState();
    _reflectionController = TextEditingController(text: widget.initialReflection ?? '');
    _tagInputController = TextEditingController();
    _selectedColor = widget.initialColor ?? 'yellow';
    _isStickyNote = widget.initialIsSticky;

    if (widget.initialTags != null) {
      for (final t in widget.initialTags!) {
        if (t.toLowerCase() == 'stickynote' || t.toLowerCase() == 'sticky-note') {
          _isStickyNote = true;
        } else {
          _tags.add(t);
        }
      }
    }
  }

  @override
  void dispose() {
    _reflectionController.dispose();
    _tagInputController.dispose();
    super.dispose();
  }

  void _addTag(String rawTag) {
    final clean = rawTag.trim().toLowerCase().replaceAll('#', '');
    if (clean.isNotEmpty && !_tags.contains(clean)) {
      setState(() {
        _tags.add(clean);
        _tagInputController.clear();
      });
    }
  }

  Future<void> _saveNote() async {
    if (_reflectionController.text.trim().isEmpty && widget.quoteText.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tuliskan refleksi atau catatan Anda terlebih dahulu'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    final db = ref.read(appDatabaseProvider);
    const uuid = Uuid();

    try {
      final highlightId = widget.existingHighlightId ?? uuid.v4();
      final noteId = widget.existingNoteId ?? uuid.v4();
      final quote = widget.quoteText.trim().isNotEmpty
          ? widget.quoteText
          : 'Catatan Halaman ${widget.pageNumber}';

      if (widget.existingHighlightId == null) {
        // Insert new highlight
        await db.insertHighlight(
          HighlightsCompanion(
            id: drift.Value(highlightId),
            bookId: drift.Value(widget.bookId),
            pageNumber: drift.Value(widget.pageNumber),
            selectedText: drift.Value(quote),
            color: drift.Value(_selectedColor),
            createdAt: drift.Value(DateTime.now()),
          ),
        );
      }

      final reflectionText = _reflectionController.text.trim();

      if (widget.existingNoteId == null) {
        // Insert new note
        await db.insertNote(
          NotesCompanion(
            id: drift.Value(noteId),
            highlightId: drift.Value(highlightId),
            reflectionText: drift.Value(reflectionText),
            createdAt: drift.Value(DateTime.now()),
          ),
        );
      } else {
        // Update existing note
        await db.updateNoteReflection(noteId, reflectionText);
      }

      // Handle sticky note tag
      final finalTags = List<String>.from(_tags);
      if (_isStickyNote && !finalTags.contains('stickynote')) {
        finalTags.add('stickynote');
      } else if (!_isStickyNote) {
        finalTags.remove('stickynote');
      }

      // Save tags
      await db.setTagsForNote(noteId, finalTags);

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan catatan: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final allTagsAsync = ref.watch(allTagsStreamProvider);
    final activeHighlightColor = _colorOptions[_selectedColor] ?? AppColors.highlightYellow;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFAF7F2),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 14,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.n300,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Top Header: Title & Page Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.existingNoteId == null ? 'Tambah Refleksi' : 'Edit Refleksi',
                  style: AppTypography.headlineMedium.copyWith(fontSize: 18),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDEEE9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFF8D8CE)),
                  ),
                  child: Text(
                    'Hal. ${widget.pageNumber}',
                    style: const TextStyle(
                      color: AppColors.primaryTerracotta,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            if (widget.quoteText.trim().isNotEmpty) ...[
            // 1. COVER POPUP: Highlighted Text Banner
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFEFE6D8), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryCoffee.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Cover Header Strip
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: activeHighlightColor.withOpacity(0.35),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                      border: Border(
                        bottom: BorderSide(color: activeHighlightColor.withOpacity(0.5)),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.format_quote_rounded,
                          size: 16,
                          color: AppColors.primaryCoffee,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Kutipan yang Dihighlight',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryCoffee.withOpacity(0.9),
                          ),
                        ),
                        const Spacer(),
                        if (widget.bookTitle != null)
                          Text(
                            widget.bookTitle!,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.n700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Cover Quote Content
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '“',
                          style: TextStyle(
                            fontFamily: 'serif',
                            fontSize: 28,
                            height: 1,
                            color: AppColors.primaryTerracotta,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.quoteText,
                            style: AppTypography.quoteText.copyWith(
                              fontSize: 14,
                              height: 1.5,
                              color: AppColors.primaryCoffee,
                            ),
                            maxLines: 5,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Highlight Color Selector inside Cover Footer
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFAFAF7),
                      borderRadius: BorderRadius.vertical(bottom: Radius.circular(14)),
                    ),
                    child: Row(
                      children: [
                        const Text(
                          'Warna Highlight:',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.n700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 10),
                        ..._colorOptions.entries.map((entry) {
                          final isSelected = _selectedColor == entry.key;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedColor = entry.key),
                            child: Container(
                              margin: const EdgeInsets.only(right: 8),
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                color: entry.value,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected ? AppColors.primaryCoffee : Colors.black12,
                                  width: isSelected ? 2.5 : 1,
                                ),
                              ),
                              child: isSelected
                                  ? const Icon(Icons.check, size: 14, color: AppColors.n900)
                                  : null,
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFEFE6D8), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryCoffee.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDEEE9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.edit_note,
                        size: 24,
                        color: AppColors.primaryTerracotta,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Catatan Halaman ${widget.pageNumber}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryCoffee,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.bookTitle ?? 'Tuliskan catatan atau pemikiran Anda di bawah',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.n500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // 2. DI BAWAH COVER: Catatan Refleksi (Format PRD)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Catatan Refleksi',
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryCoffee,
                  ),
                ),
                const Text(
                  'PRD Module 4',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.n500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Reflection Text Field with PRD Placeholder
            TextField(
              controller: _reflectionController,
              maxLines: 4,
              style: const TextStyle(fontSize: 14, height: 1.4, color: AppColors.n900),
              decoration: InputDecoration(
                hintText: 'Tulis pemikiran, refleksi, atau tindakan dari kutipan ini...',
                hintStyle: const TextStyle(
                  fontSize: 13,
                  color: AppColors.n500,
                  height: 1.4,
                ),
                fillColor: Colors.white,
                filled: true,
                contentPadding: const EdgeInsets.all(14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFE5DCD0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFE5DCD0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.primaryTerracotta, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // 3. STICKY NOTE OPTION (Point 6)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF9C3),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFFDE047)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFACC15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('📌', style: TextStyle(fontSize: 16)),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tempel Sticky Note di Halaman',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF713F12),
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Dapat di-minimize & tetap menempel pada teks',
                          style: TextStyle(fontSize: 11, color: Color(0xFF854D0E)),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _isStickyNote,
                    onChanged: (val) {
                      setState(() => _isStickyNote = val);
                    },
                    activeColor: AppColors.primaryTerracotta,
                    activeTrackColor: const Color(0xFFF8D8CE),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 4. TAGS SECTION (PRD Module 5)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tag & Kategori',
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryCoffee,
                  ),
                ),
                const Text(
                  'Multi-tag per note',
                  style: TextStyle(fontSize: 11, color: AppColors.n500),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Existing selected tags chips
            if (_tags.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: _tags.map((tag) {
                    return Chip(
                      label: Text('#$tag'),
                      backgroundColor: const Color(0xFFF3EBE1),
                      labelStyle: const TextStyle(
                        color: AppColors.primaryCoffee,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      deleteIcon: const Icon(Icons.close, size: 14, color: AppColors.primaryCoffee),
                      onDeleted: () {
                        setState(() => _tags.remove(tag));
                      },
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      side: const BorderSide(color: Color(0xFFE5D7C5)),
                    );
                  }).toList(),
                ),
              ),

            // Input new tag
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _tagInputController,
                    decoration: InputDecoration(
                      hintText: 'Ketik tag baru (misal: habit, mindset)...',
                      hintStyle: const TextStyle(fontSize: 12, color: AppColors.n500),
                      fillColor: Colors.white,
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE5DCD0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE5DCD0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.primaryTerracotta),
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.add_circle, color: AppColors.primaryCoffee),
                        onPressed: () => _addTag(_tagInputController.text),
                      ),
                    ),
                    onSubmitted: _addTag,
                  ),
                ),
              ],
            ),

            // Quick tag suggestions from DB
            allTagsAsync.when(
              data: (existingTags) {
                final suggestions = existingTags
                    .where((t) => !_tags.contains(t.name.toLowerCase()) && t.name.toLowerCase() != 'stickynote')
                    .take(6)
                    .toList();
                if (suggestions.isEmpty) return const SizedBox.shrink();

                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Wrap(
                    spacing: 6,
                    children: suggestions.map((tag) {
                      return ActionChip(
                        label: Text('+ #${tag.name}'),
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: AppColors.n300),
                        labelStyle: const TextStyle(fontSize: 11, color: AppColors.n700),
                        onPressed: () => _addTag(tag.name),
                      );
                    }).toList(),
                  ),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),

            const SizedBox(height: 20),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Color(0xFFD6C8B8)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text(
                      'Batal',
                      style: TextStyle(
                        color: AppColors.primaryCoffee,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveNote,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryCoffee,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text(
                            'Simpan Catatan & Highlight',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
