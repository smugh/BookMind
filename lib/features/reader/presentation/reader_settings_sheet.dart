import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class ReaderSettings {
  final String colorMode; // 'terang', 'sepia', 'gelap'
  final double fontSize;
  final String fontFamily; // 'Serif', 'Sans Serif', 'Lora', 'Inter'
  final bool alignLeft;
  final double lineSpacing;
  final double pageMargin;
  final bool showNotesOnPage; // default: false (hidden by default so original text is not disturbed)

  const ReaderSettings({
    this.colorMode = 'terang',
    this.fontSize = 16.0,
    this.fontFamily = 'Lora',
    this.alignLeft = true,
    this.lineSpacing = 1.6,
    this.pageMargin = 16.0,
    this.showNotesOnPage = false,
  });

  ReaderSettings copyWith({
    String? colorMode,
    double? fontSize,
    String? fontFamily,
    bool? alignLeft,
    double? lineSpacing,
    double? pageMargin,
    bool? showNotesOnPage,
  }) {
    return ReaderSettings(
      colorMode: colorMode ?? this.colorMode,
      fontSize: fontSize ?? this.fontSize,
      fontFamily: fontFamily ?? this.fontFamily,
      alignLeft: alignLeft ?? this.alignLeft,
      lineSpacing: lineSpacing ?? this.lineSpacing,
      pageMargin: pageMargin ?? this.pageMargin,
      showNotesOnPage: showNotesOnPage ?? this.showNotesOnPage,
    );
  }
}

class ReaderSettingsSheet extends StatefulWidget {
  final ReaderSettings settings;
  final ValueChanged<ReaderSettings> onSettingsChanged;

  const ReaderSettingsSheet({
    super.key,
    required this.settings,
    required this.onSettingsChanged,
  });

  @override
  State<ReaderSettingsSheet> createState() => _ReaderSettingsSheetState();
}

class _ReaderSettingsSheetState extends State<ReaderSettingsSheet> {
  late ReaderSettings _currentSettings;

  @override
  void initState() {
    super.initState();
    _currentSettings = widget.settings;
  }

  void _update(ReaderSettings newSettings) {
    setState(() => _currentSettings = newSettings);
    widget.onSettingsChanged(newSettings);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.n100,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
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

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Tampilan Membaca', style: AppTypography.headlineMedium),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // 1. Mode Warna (Terang, Sepia, Gelap)
          Text('Mode Warna', style: AppTypography.titleMedium),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildColorModeOption('terang', 'Terang', Colors.white, AppColors.n900),
              const SizedBox(width: 10),
              _buildColorModeOption('sepia', 'Sepia', const Color(0xFFF8EEDD), const Color(0xFF5A4333)),
              const SizedBox(width: 10),
              _buildColorModeOption('gelap', 'Gelap', const Color(0xFF1E1E1E), Colors.white),
            ],
          ),
          const SizedBox(height: 20),

          // 2. Ukuran Teks (Slider from A to A)
          Text('Ukuran Teks', style: AppTypography.titleMedium),
          Row(
            children: [
              const Text('A', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              Expanded(
                child: Slider(
                  value: _currentSettings.fontSize,
                  min: 12,
                  max: 24,
                  divisions: 6,
                  activeColor: AppColors.primaryCoffee,
                  inactiveColor: AppColors.n300,
                  onChanged: (val) {
                    _update(_currentSettings.copyWith(fontSize: val));
                  },
                ),
              ),
              const Text('A', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 14),

          // 3. Jenis Font
          Text('Jenis Font', style: AppTypography.titleMedium),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['Lora', 'Serif', 'Sans Serif', 'Inter'].map((font) {
                final isSelected = _currentSettings.fontFamily == font;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: InkWell(
                    onTap: () {
                      _update(_currentSettings.copyWith(fontFamily: font));
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primaryCoffee : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? AppColors.primaryCoffee : AppColors.n300,
                        ),
                      ),
                      child: Text(
                        font,
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppColors.n900,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 18),

          // 4. Rata Kiri Switch
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Rata Kiri', style: AppTypography.titleMedium),
              Switch(
                value: _currentSettings.alignLeft,
                activeColor: AppColors.primaryCoffee,
                onChanged: (val) {
                  _update(_currentSettings.copyWith(alignLeft: val));
                },
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 5. Tampilkan Catatan di Teks Switch
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tampilkan Catatan di Teks', style: AppTypography.titleMedium),
                    const SizedBox(height: 2),
                    const Text(
                      'Tampilkan sticky note langsung di antara teks buku (default sembunyi)',
                      style: TextStyle(fontSize: 11, color: AppColors.n500),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _currentSettings.showNotesOnPage,
                activeColor: AppColors.primaryCoffee,
                onChanged: (val) {
                  _update(_currentSettings.copyWith(showNotesOnPage: val));
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildColorModeOption(String mode, String label, Color bg, Color text) {
    final isSelected = _currentSettings.colorMode == mode;
    return Expanded(
      child: InkWell(
        onTap: () => _update(_currentSettings.copyWith(colorMode: mode)),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primaryCoffee : AppColors.n300,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? AppColors.primaryCoffee : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? AppColors.primaryCoffee : AppColors.n500,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: text,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
