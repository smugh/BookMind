import 'dart:typed_data';
import 'package:epubx/epubx.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class EpubViewer extends StatefulWidget {
  final Uint8List bytes;
  final int initialPage;
  final Function(int page, int totalPages) onPageChanged;
  final Function(String selectedText, int page) onTextSelected;

  const EpubViewer({
    super.key,
    required this.bytes,
    required this.initialPage,
    required this.onPageChanged,
    required this.onTextSelected,
  });

  @override
  State<EpubViewer> createState() => _EpubViewerState();
}

class _EpubViewerState extends State<EpubViewer> {
  bool _isLoading = true;
  String? _errorMessage;
  int _currentChapterIndex = 0;
  final List<String> _chapterTexts = [];
  final List<String> _chapterTitles = [];
  final PageController _pageController = PageController();

  // Reader Customization (Mode Warna, Ukuran Teks, Font)
  double _fontSize = 16.0;
  Color _bgColor = AppColors.n100;
  Color _textColor = AppColors.n900;

  @override
  void initState() {
    super.initState();
    _loadEpub();
  }

  Future<void> _loadEpub() async {
    try {
      final book = await EpubReader.readBook(widget.bytes);

      final texts = <String>[];
      final titles = <String>[];

      for (var i = 0; i < (book.Chapters?.length ?? 0); i++) {
        final chapter = book.Chapters![i];
        final cleanText = _stripHtml(chapter.HtmlContent ?? '');
        if (cleanText.trim().isNotEmpty) {
          texts.add(cleanText);
          titles.add(chapter.Title ?? 'Bab ${titles.length + 1}');
        }
      }

      if (texts.isEmpty && book.Schema?.Package?.Spine?.Items != null) {
        // Fallback reading all items
        texts.add('Konten buku telah dimuat.');
        titles.add(book.Title ?? 'Buku');
      }

      setState(() {
        _chapterTexts.addAll(texts);
        _chapterTitles.addAll(titles);
        _isLoading = false;
        _currentChapterIndex = (widget.initialPage - 1).clamp(0, texts.isNotEmpty ? texts.length - 1 : 0);
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_pageController.hasClients && _currentChapterIndex > 0) {
          _pageController.jumpToPage(_currentChapterIndex);
        }
        widget.onPageChanged(_currentChapterIndex + 1, _chapterTexts.length);
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal membuka file EPUB: $e';
        _isLoading = false;
      });
    }
  }

  String _stripHtml(String htmlString) {
    return htmlString
        .replaceAll(RegExp(r'<style[\s\S]*?</style>'), '')
        .replaceAll(RegExp(r'<script[\s\S]*?</script>'), '')
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  void _showReaderSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tampilan Membaca', style: AppTypography.headlineMedium),
                  const SizedBox(height: 16),
                  Text('Mode Warna', style: AppTypography.titleMedium),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildThemeOption('Terang', AppColors.n100, AppColors.n900, setModalState),
                      const SizedBox(width: 8),
                      _buildThemeOption('Sepia', const Color(0xFFFBF0D9), const Color(0xFF5F4B32), setModalState),
                      const SizedBox(width: 8),
                      _buildThemeOption('Gelap', const Color(0xFF232323), const Color(0xFFE0E0E0), setModalState),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Ukuran Teks', style: AppTypography.titleMedium),
                      Text('${_fontSize.toInt()} px', style: AppTypography.labelSmall),
                    ],
                  ),
                  Slider(
                    value: _fontSize,
                    min: 12,
                    max: 28,
                    divisions: 8,
                    activeColor: AppColors.primaryCoffee,
                    onChanged: (val) {
                      setModalState(() => _fontSize = val);
                      setState(() => _fontSize = val);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildThemeOption(
    String label,
    Color bg,
    Color text,
    void Function(void Function()) setModalState,
  ) {
    final isSelected = _bgColor == bg;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setModalState(() {
            _bgColor = bg;
            _textColor = text;
          });
          setState(() {
            _bgColor = bg;
            _textColor = text;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? AppColors.primaryCoffee : AppColors.n300,
              width: isSelected ? 2 : 1,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: text,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primaryCoffee));
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(_errorMessage!, style: const TextStyle(color: AppColors.error)),
        ),
      );
    }

    return Container(
      color: _bgColor,
      child: Column(
        children: [
          // Sub-bar for EPUB controls (Chapter & theme settings)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _bgColor,
              border: Border(bottom: BorderSide(color: AppColors.n300.withOpacity(0.4))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _chapterTitles.isNotEmpty ? _chapterTitles[_currentChapterIndex] : '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontWeight: FontWeight.w600,
                      color: _textColor.withOpacity(0.8),
                      fontSize: 13,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.format_size, size: 20),
                  color: _textColor,
                  tooltip: 'Pengaturan Tampilan',
                  onPressed: _showReaderSettings,
                ),
              ],
            ),
          ),

          // Chapter Pages
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _chapterTexts.length,
              onPageChanged: (index) {
                setState(() => _currentChapterIndex = index);
                widget.onPageChanged(index + 1, _chapterTexts.length);
              },
              itemBuilder: (context, index) {
                final content = _chapterTexts[index];
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: SelectableText(
                    content,
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: _fontSize,
                      height: 1.65,
                      color: _textColor,
                    ),
                    contextMenuBuilder: (context, editableTextState) {
                      return AdaptiveTextSelectionToolbar.buttonItems(
                        anchors: editableTextState.contextMenuAnchors,
                        buttonItems: [
                          ContextMenuButtonItem(
                            onPressed: () {
                              final text = editableTextState.textEditingValue.selection.textInside(
                                editableTextState.textEditingValue.text,
                              );
                              widget.onTextSelected(text, _currentChapterIndex + 1);
                              editableTextState.hideToolbar();
                            },
                            label: 'Highlight & Note',
                          ),
                          ...editableTextState.contextMenuButtonItems,
                        ],
                      );
                    },
                  ),
                );
              },
            ),
          ),

          // Bottom EPUB pagination
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: _bgColor,
              border: Border(top: BorderSide(color: AppColors.n300.withOpacity(0.3))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  color: _textColor,
                  onPressed: _currentChapterIndex > 0
                      ? () => _pageController.previousPage(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeInOut,
                          )
                      : null,
                ),
                Text(
                  'Bab ${_currentChapterIndex + 1} dari ${_chapterTexts.length}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _textColor.withOpacity(0.7),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  color: _textColor,
                  onPressed: _currentChapterIndex < _chapterTexts.length - 1
                      ? () => _pageController.nextPage(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeInOut,
                          )
                      : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
