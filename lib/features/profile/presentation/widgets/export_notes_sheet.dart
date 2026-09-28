import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/services/app_settings_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../data/database/app_database.dart';
import '../../../../data/database/database_provider.dart';

class ExportNotesSheet extends ConsumerStatefulWidget {
  const ExportNotesSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ExportNotesSheet(),
    );
  }

  @override
  ConsumerState<ExportNotesSheet> createState() => _ExportNotesSheetState();
}

class _ExportNotesSheetState extends ConsumerState<ExportNotesSheet> {
  bool _isLoading = true;
  List<NoteWithDetails> _notes = [];
  String? _statusMessage;
  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    final db = ref.read(appDatabaseProvider);
    try {
      final list = await db.watchAllNotesWithDetails().first;
      if (mounted) {
        setState(() {
          _notes = list;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _generateMarkdown() {
    final buf = StringBuffer();
    buf.writeln('# 📚 BookMind - Ekspor Catatan & Refleksi');
    buf.writeln('Tanggal Ekspor: ${DateTime.now().toLocal()}');
    buf.writeln('Total Catatan: ${_notes.length}\n');
    buf.writeln('---\n');

    for (final item in _notes) {
      buf.writeln('### 📖 ${item.book.title}');
      buf.writeln('**Penulis**: ${item.book.author} | **Halaman**: ${item.highlight.pageNumber}');
      buf.writeln('> "${item.highlight.selectedText}"\n');
      buf.writeln('**Refleksi Personal**:');
      buf.writeln(item.note.reflectionText);
      if (item.tags.isNotEmpty) {
        final tagsStr = item.tags.map((t) => '#${t.name}').join(' ');
        buf.writeln('\n**Tag**: $tagsStr');
      }
      buf.writeln('\n---\n');
    }
    return buf.toString();
  }

  String _generatePlainText() {
    final buf = StringBuffer();
    buf.writeln('BOOKMIND - EKSPOR CATATAN & REFLEKSI');
    buf.writeln('Tanggal Ekspor: ${DateTime.now().toLocal()}');
    buf.writeln('Total Catatan: ${_notes.length}');
    buf.writeln('========================================\n');

    for (final item in _notes) {
      buf.writeln('BUKU: ${item.book.title} (${item.book.author})');
      buf.writeln('HALAMAN: ${item.highlight.pageNumber}');
      buf.writeln('KUTIPAN: "${item.highlight.selectedText}"');
      buf.writeln('REFLEKSI: ${item.note.reflectionText}');
      if (item.tags.isNotEmpty) {
        buf.writeln('TAG: ${item.tags.map((t) => '#${t.name}').join(', ')}');
      }
      buf.writeln('----------------------------------------\n');
    }
    return buf.toString();
  }

  Future<void> _copyToClipboard(bool isMarkdown, String lang) async {
    final text = isMarkdown ? _generateMarkdown() : _generatePlainText();
    await Clipboard.setData(ClipboardData(text: text));
    setState(() {
      _isSuccess = true;
      _statusMessage = AppStrings.tr('copy_success', lang);
    });
  }

  Future<void> _saveToFile(bool isMarkdown, String lang) async {
    try {
      final text = isMarkdown ? _generateMarkdown() : _generatePlainText();
      final ext = isMarkdown ? 'md' : 'txt';
      final fileName =
          'bookmind_notes_${DateTime.now().millisecondsSinceEpoch}.$ext';

      String savedPath;
      if (kIsWeb) {
        await Clipboard.setData(ClipboardData(text: text));
        savedPath = 'Clipboard (Web Mode)';
      } else {
        Directory dir;
        try {
          final downloadDir = await getDownloadsDirectory();
          dir = downloadDir ?? await getApplicationDocumentsDirectory();
        } catch (_) {
          dir = await getApplicationDocumentsDirectory();
        }

        final file = File(p.join(dir.path, fileName));
        await file.writeAsString(text);
        savedPath = file.path;
      }

      setState(() {
        _isSuccess = true;
        _statusMessage = '${AppStrings.tr('export_success', lang)}\n$savedPath';
      });
    } catch (e) {
      setState(() {
        _isSuccess = false;
        _statusMessage = 'Gagal menyimpan berkas: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(appSettingsProvider);
    final lang = settings.language;

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: AppColors.n100,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryCoffee.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.file_upload_outlined,
                  color: AppColors.primaryCoffee,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.tr('export_title', lang),
                      style: AppTypography.titleLarge.copyWith(fontSize: 17),
                    ),
                    Text(
                      _isLoading
                          ? 'Memuat catatan...'
                          : '${_notes.length} catatan refleksi ditemukan',
                      style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.n500, fontSize: 12),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            AppStrings.tr('export_desc', lang),
            style: AppTypography.bodyMedium.copyWith(color: AppColors.n700, fontSize: 13),
          ),
          const SizedBox(height: 16),
          if (_statusMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: _isSuccess ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isSuccess ? const Color(0xFF81C784) : const Color(0xFFE57373),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _isSuccess ? Icons.check_circle : Icons.error_outline,
                    color: _isSuccess ? const Color(0xFF2E7D32) : AppColors.error,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _statusMessage!,
                      style: TextStyle(
                        fontSize: 12,
                        color: _isSuccess ? const Color(0xFF1B5E20) : AppColors.error,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_notes.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                AppStrings.tr('export_empty', lang),
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.n500, fontSize: 13),
              ),
            )
          else ...[
            // Markdown Export Card
            _buildExportOptionCard(
              context,
              icon: Icons.description_outlined,
              title: AppStrings.tr('export_markdown', lang),
              subtitle: AppStrings.tr('export_markdown_desc', lang),
              onSaveFile: () => _saveToFile(true, lang),
              onCopy: () => _copyToClipboard(true, lang),
              lang: lang,
            ),
            const SizedBox(height: 12),
            // Plain Text Export Card
            _buildExportOptionCard(
              context,
              icon: Icons.text_snippet_outlined,
              title: AppStrings.tr('export_txt', lang),
              subtitle: AppStrings.tr('export_txt_desc', lang),
              onSaveFile: () => _saveToFile(false, lang),
              onCopy: () => _copyToClipboard(false, lang),
              lang: lang,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildExportOptionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onSaveFile,
    required VoidCallback onCopy,
    required String lang,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.n200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primaryCoffee, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTypography.titleMedium.copyWith(fontSize: 14)),
                    Text(subtitle,
                        style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.n500, fontSize: 11.5)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.copy, size: 16),
                  label: Text(AppStrings.tr('copy_clipboard', lang)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryCoffee,
                    side: const BorderSide(color: AppColors.n300),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: onCopy,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.download, size: 16),
                  label: Text(AppStrings.tr('save_to_file', lang)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryCoffee,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: onSaveFile,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
