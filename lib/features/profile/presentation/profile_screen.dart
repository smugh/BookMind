import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/services/app_settings_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/bookmind_logo.dart';
import '../../onboarding/presentation/cover_screen.dart';
import 'appearance_settings_screen.dart';
import 'reading_stats_screen.dart';
import 'widgets/export_notes_sheet.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    final lang = settings.language;

    final hasCustomProfile = settings.profileImagePath != null &&
        settings.profileImagePath!.isNotEmpty &&
        !kIsWeb &&
        File(settings.profileImagePath!).existsSync();

    return Scaffold(
      backgroundColor: AppColors.n100,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppStrings.tr('profile_title', lang),
          style: AppTypography.headlineMedium,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        children: [
          // User Profile Card (Tappable to change appearance/photo)
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AppearanceSettingsScreen(),
                ),
              );
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.n200),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryCoffee.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFFDE2D9),
                      border: Border.all(
                        color: AppColors.primaryTerracotta,
                        width: 2,
                      ),
                    ),
                    child: ClipOval(
                      child: hasCustomProfile
                          ? Image.file(
                              File(settings.profileImagePath!),
                              fit: BoxFit.cover,
                            )
                          : const Center(
                              child: Text(
                                'NP',
                                style: TextStyle(
                                  color: AppColors.primaryCoffee,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 19,
                                ),
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nadia Putri',
                          style: AppTypography.titleLarge.copyWith(fontSize: 17),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'nadia@email.com',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.n500,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios,
                      size: 14, color: AppColors.n500),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Motivational Banner Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFF7F0), Color(0xFFFDEEE9)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFF8D8CE)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF9DDD1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.auto_stories,
                    size: 20,
                    color: AppColors.primaryTerracotta,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lang == 'en'
                            ? 'Read with intention'
                            : 'Membaca dengan lebih sadar',
                        style: AppTypography.titleMedium.copyWith(
                          color: AppColors.primaryCoffee,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        lang == 'en'
                            ? 'Every book is a conversation with a wiser version of yourself.'
                            : 'Setiap buku adalah percakapan dengan versi diri yang lebih baik.',
                        style: AppTypography.bodyMedium.copyWith(
                          fontSize: 12,
                          color: AppColors.n700,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Main Menu List
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.n200),
            ),
            child: Column(
              children: [
                // 1. Target Membaca
                _buildMenuItem(
                  context,
                  icon: Icons.track_changes_outlined,
                  title: AppStrings.tr('reading_target', lang),
                  trailingText: AppStrings.tr('target_summary', lang),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ReadingStatsScreen(),
                      ),
                    );
                  },
                ),
                const Divider(height: 1, indent: 56),

                // 2. Statistik Membaca
                _buildMenuItem(
                  context,
                  icon: Icons.bar_chart_outlined,
                  title: AppStrings.tr('reading_stats', lang),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ReadingStatsScreen(),
                      ),
                    );
                  },
                ),
                const Divider(height: 1, indent: 56),

                // 3. Pengaturan Tampilan (Requirement 5)
                _buildMenuItem(
                  context,
                  icon: Icons.palette_outlined,
                  title: AppStrings.tr('appearance_settings', lang),
                  subtitleText: AppStrings.tr('appearance_subtitle', lang),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AppearanceSettingsScreen(),
                      ),
                    );
                  },
                ),
                const Divider(height: 1, indent: 56),

                // 4. Sinkronisasi & Backup (Requirement 4: Under Development Badge)
                _buildMenuItem(
                  context,
                  icon: Icons.cloud_sync_outlined,
                  title: AppStrings.tr('sync_and_backup', lang),
                  badgeWidget: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3E0),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFFFB74D)),
                    ),
                    child: Text(
                      AppStrings.tr('under_development', lang),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE65100),
                      ),
                    ),
                  ),
                  onTap: () {
                    _showUnderDevelopmentDialog(context, lang);
                  },
                ),
                const Divider(height: 1, indent: 56),

                // 5. Ekspor Catatan (Requirement 3: Working Export)
                _buildMenuItem(
                  context,
                  icon: Icons.file_upload_outlined,
                  title: AppStrings.tr('export_notes', lang),
                  subtitleText: 'Markdown (.md) & Teks (.txt)',
                  onTap: () {
                    ExportNotesSheet.show(context);
                  },
                ),
                const Divider(height: 1, indent: 56),

                // 6. Penggantian Bahasa (Requirement 6)
                _buildMenuItem(
                  context,
                  icon: Icons.translate_rounded,
                  title: AppStrings.tr('language', lang),
                  trailingText:
                      lang == 'en' ? 'English 🇬🇧' : 'Indonesia 🇮🇩',
                  onTap: () {
                    _showLanguageSelectorSheet(context, ref, lang);
                  },
                ),
                const Divider(height: 1, indent: 56),

                // 7. Tentang BookMind
                _buildMenuItem(
                  context,
                  icon: Icons.info_outline,
                  title: AppStrings.tr('about', lang),
                  onTap: () => _showAboutDialog(context, lang),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Logout Button
          InkWell(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Mode perpustakaan lokal 100% offline aktif.'),
                  backgroundColor: AppColors.primaryCoffee,
                ),
              );
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.n200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.logout, size: 18, color: AppColors.error),
                  const SizedBox(width: 8),
                  Text(
                    AppStrings.tr('logout', lang),
                    style:
                        AppTypography.titleMedium.copyWith(color: AppColors.error),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Footer Creator Information (Requirement 2)
          Center(
            child: Column(
              children: [
                Text(
                  'BookMind v1.0.0',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.n500.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  AppStrings.tr('created_by', lang),
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: AppColors.n500.withOpacity(0.65),
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitleText,
    String? trailingText,
    Widget? badgeWidget,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: AppColors.n700, size: 22),
      title: Text(
        title,
        style: AppTypography.titleMedium.copyWith(fontSize: 14),
      ),
      subtitle: subtitleText != null
          ? Text(
              subtitleText,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.n500,
                fontSize: 11.5,
              ),
            )
          : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (badgeWidget != null) ...[
            badgeWidget,
            const SizedBox(width: 8),
          ],
          if (trailingText != null) ...[
            Text(
              trailingText,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.n500,
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 6),
          ],
          const Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.n500),
        ],
      ),
    );
  }

  void _showUnderDevelopmentDialog(BuildContext context, String lang) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.n100,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.cloud_sync_outlined,
                color: Color(0xFFE65100), size: 26),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                AppStrings.tr('sync_dev_title', lang),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Text(
          AppStrings.tr('sync_dev_desc', lang),
          style: const TextStyle(fontSize: 13, height: 1.45, color: AppColors.n700),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryCoffee,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppStrings.tr('understood', lang)),
          ),
        ],
      ),
    );
  }

  void _showLanguageSelectorSheet(
      BuildContext context, WidgetRef ref, String currentLang) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.n100,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
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
            Text(
              AppStrings.tr('select_language', currentLang),
              style: AppTypography.titleLarge.copyWith(fontSize: 17),
            ),
            const SizedBox(height: 16),
            // Indonesia
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              tileColor: currentLang == 'id'
                  ? AppColors.primaryTerracotta.withOpacity(0.12)
                  : Colors.white,
              leading: const Text('🇮🇩', style: TextStyle(fontSize: 26)),
              title: Text(
                AppStrings.tr('lang_id', currentLang),
                style: TextStyle(
                  fontWeight:
                      currentLang == 'id' ? FontWeight.bold : FontWeight.w500,
                ),
              ),
              trailing: currentLang == 'id'
                  ? const Icon(Icons.check_circle,
                      color: AppColors.primaryTerracotta)
                  : null,
              onTap: () {
                ref.read(appSettingsProvider.notifier).setLanguage('id');
                Navigator.pop(ctx);
              },
            ),
            const SizedBox(height: 10),
            // English
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              tileColor: currentLang == 'en'
                  ? AppColors.primaryTerracotta.withOpacity(0.12)
                  : Colors.white,
              leading: const Text('🇬🇧', style: TextStyle(fontSize: 26)),
              title: Text(
                AppStrings.tr('lang_en', currentLang),
                style: TextStyle(
                  fontWeight:
                      currentLang == 'en' ? FontWeight.bold : FontWeight.w500,
                ),
              ),
              trailing: currentLang == 'en'
                  ? const Icon(Icons.check_circle,
                      color: AppColors.primaryTerracotta)
                  : null,
              onTap: () {
                ref.read(appSettingsProvider.notifier).setLanguage('en');
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context, String lang) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.n100,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const BookMindLogo(iconSize: 52),
            const SizedBox(height: 16),
            const Text(
              'BookMind v1.0.0',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              AppStrings.tr('created_by', lang),
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.primaryTerracotta,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              lang == 'en'
                  ? 'A peaceful, warm, and focused personal Ebook Reader & Knowledge Hub for deep reading and reflection.'
                  : 'Aplikasi Ebook Reader & Knowledge Hub pribadi yang tenang, hangat, dan fokus untuk pengalaman membaca yang mendalam.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: AppColors.n700, height: 1.4),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CoverScreen()),
              );
            },
            child: Text(
              lang == 'en' ? 'Open Cover Page' : 'Buka Cover Page',
              style: const TextStyle(color: AppColors.primaryTerracotta),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              AppStrings.tr('close', lang),
              style: const TextStyle(color: AppColors.primaryCoffee),
            ),
          ),
        ],
      ),
    );
  }
}
