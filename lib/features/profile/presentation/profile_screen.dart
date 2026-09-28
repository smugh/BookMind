import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/bookmind_logo.dart';
import '../../onboarding/presentation/cover_screen.dart';
import 'reading_stats_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.n100,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Profil Saya', style: AppTypography.headlineMedium),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        children: [
          // User Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.n200),
            ),
            child: Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFFDE2D9),
                    border: Border.all(color: AppColors.primaryTerracotta, width: 2),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'NP',
                    style: TextStyle(
                      color: AppColors.primaryCoffee,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
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
                        style: AppTypography.bodyMedium.copyWith(color: AppColors.n500),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.n500),
              ],
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
                        'Membaca dengan lebih sadar',
                        style: AppTypography.titleMedium.copyWith(
                          color: AppColors.primaryCoffee,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Setiap buku adalah percakapan dengan versi diri yang lebih baik.',
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

          // Menu List
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.n200),
            ),
            child: Column(
              children: [
                _buildMenuItem(
                  context,
                  icon: Icons.track_changes_outlined,
                  title: 'Target Membaca',
                  trailingText: '12 buku tahun ini',
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
                _buildMenuItem(
                  context,
                  icon: Icons.bar_chart_outlined,
                  title: 'Statistik Membaca',
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
                _buildMenuItem(
                  context,
                  icon: Icons.palette_outlined,
                  title: 'Pengaturan Tampilan',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Pengaturan tampilan dapat disesuaikan saat membaca buku.'),
                      ),
                    );
                  },
                ),
                const Divider(height: 1, indent: 56),
                _buildMenuItem(
                  context,
                  icon: Icons.cloud_sync_outlined,
                  title: 'Sinkronisasi & Backup',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Semua database dan catatan tersimpan aman secara offline.'),
                        backgroundColor: AppColors.primaryCoffee,
                      ),
                    );
                  },
                ),
                const Divider(height: 1, indent: 56),
                _buildMenuItem(
                  context,
                  icon: Icons.file_upload_outlined,
                  title: 'Ekspor Catatan',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Ekspor catatan ke Markdown / TXT tersedia di Tab Catatan.'),
                      ),
                    );
                  },
                ),
                const Divider(height: 1, indent: 56),
                _buildMenuItem(
                  context,
                  icon: Icons.info_outline,
                  title: 'Tentang BookMind',
                  onTap: () => _showAboutDialog(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Logout Button
          InkWell(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Mode akun lokal aktif')),
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
                    'Keluar dari Akun',
                    style: AppTypography.titleMedium.copyWith(color: AppColors.error),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? trailingText,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: AppColors.n700, size: 22),
      title: Text(title, style: AppTypography.titleMedium.copyWith(fontSize: 14)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingText != null) ...[
            Text(
              trailingText,
              style: AppTypography.labelSmall.copyWith(color: AppColors.n500),
            ),
            const SizedBox(width: 6),
          ],
          const Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.n500),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.n100,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BookMindLogo(iconSize: 52),
            SizedBox(height: 16),
            Text(
              'BookMind v1.0.0',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            SizedBox(height: 8),
            Text(
              'Aplikasi Ebook Reader & Knowledge Hub pribadi yang tenang, hangat, dan fokus untuk pengalaman membaca yang mendalam.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppColors.n700, height: 1.4),
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
            child: const Text('Buka Cover Page', style: TextStyle(color: AppColors.primaryTerracotta)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup', style: TextStyle(color: AppColors.primaryCoffee)),
          ),
        ],
      ),
    );
  }
}
