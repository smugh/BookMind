import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/services/app_settings_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class AppearanceSettingsScreen extends ConsumerWidget {
  const AppearanceSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    final lang = settings.language;

    final hasCustomProfile = settings.profileImagePath != null &&
        settings.profileImagePath!.isNotEmpty;
    final hasCustomCover =
        settings.coverImagePath != null && settings.coverImagePath!.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.n100,
      appBar: AppBar(
        title: Text(
          AppStrings.tr('appearance_title', lang),
          style: AppTypography.headlineMedium,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // Section 1: User Profile Photo
          _buildSectionCard(
            context,
            title: AppStrings.tr('profile_photo_section', lang),
            description: AppStrings.tr('profile_photo_desc', lang),
            child: Column(
              children: [
                const SizedBox(height: 8),
                Center(
                  child: Stack(
                    children: [
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFFDE2D9),
                          border: Border.all(
                            color: AppColors.primaryTerracotta,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryCoffee.withOpacity(0.12),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: hasCustomProfile &&
                                  !kIsWeb &&
                                  File(settings.profileImagePath!).existsSync()
                              ? Image.file(
                                  File(settings.profileImagePath!),
                                  fit: BoxFit.cover,
                                )
                              : Center(
                                  child: Text(
                                    settings.userName
                                        .trim()
                                        .split(RegExp(r'\s+'))
                                        .where((s) => s.isNotEmpty)
                                        .map((s) => s[0].toUpperCase())
                                        .take(2)
                                        .join(),
                                    style: const TextStyle(
                                      color: AppColors.primaryCoffee,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 32,
                                    ),
                                  ),
                                ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: AppColors.primaryCoffee,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: hasCustomProfile
                        ? const Color(0xFFE8F5E9)
                        : const Color(0xFFF0EBE1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    hasCustomProfile
                        ? AppStrings.tr('custom_photo_active', lang)
                        : AppStrings.tr('original_app_default', lang),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: hasCustomProfile
                          ? const Color(0xFF2E7D32)
                          : AppColors.n700,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.photo_library_outlined, size: 18),
                        label: Text(AppStrings.tr('change_profile_photo', lang)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryCoffee,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          final success = await ref
                              .read(appSettingsProvider.notifier)
                              .pickAndSetProfileImage();
                          if (success && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Foto profil berhasil diperbarui!'),
                                backgroundColor: AppColors.primaryCoffee,
                              ),
                            );
                          }
                        },
                      ),
                    ),
                    if (hasCustomProfile) ...[
                      const SizedBox(width: 10),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: const BorderSide(color: Color(0xFFE57373)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          await ref
                              .read(appSettingsProvider.notifier)
                              .resetProfileImage();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Foto profil dikembalikan ke default'),
                              ),
                            );
                          }
                        },
                        child: const Icon(Icons.restart_alt, size: 20),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Section 2: Cover Screen Image
          _buildSectionCard(
            context,
            title: AppStrings.tr('cover_photo_section', lang),
            description: AppStrings.tr('cover_photo_desc', lang),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                Container(
                  height: 180,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.n200, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryCoffee.withOpacity(0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        hasCustomCover &&
                                !kIsWeb &&
                                File(settings.coverImagePath!).existsSync()
                            ? Image.file(
                                File(settings.coverImagePath!),
                                fit: BoxFit.cover,
                              )
                            : Image.asset(
                                'assets/images/onboarding_cover_prd.png',
                                fit: BoxFit.cover,
                              ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.7),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                        Positioned(
                          left: 12,
                          bottom: 12,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppStrings.tr('cover_headline', lang)
                                    .replaceAll('\n', ' '),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                hasCustomCover
                                    ? AppStrings.tr('custom_photo_active', lang)
                                    : AppStrings.tr('original_app_default', lang),
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon:
                            const Icon(Icons.add_photo_alternate_outlined, size: 18),
                        label: Text(AppStrings.tr('change_cover_photo', lang)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryTerracotta,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          final success = await ref
                              .read(appSettingsProvider.notifier)
                              .pickAndSetCoverImage();
                          if (success && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Foto cover berhasil diperbarui!'),
                                backgroundColor: AppColors.primaryCoffee,
                              ),
                            );
                          }
                        },
                      ),
                    ),
                    if (hasCustomCover) ...[
                      const SizedBox(width: 10),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: const BorderSide(color: Color(0xFFE57373)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          await ref
                              .read(appSettingsProvider.notifier)
                              .resetCoverImage();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Foto cover dikembalikan ke default original'),
                              ),
                            );
                          }
                        },
                        child: const Icon(Icons.restart_alt, size: 20),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required String description,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.n200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.titleLarge.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.n500,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
