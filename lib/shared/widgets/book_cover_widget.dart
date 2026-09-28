import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/book_file_storage.dart';
import '../../data/database/app_database.dart';

class BookCoverWidget extends StatelessWidget {
  final BookEntry book;
  final double width;
  final double height;
  final double borderRadius;

  const BookCoverWidget({
    super.key,
    required this.book,
    this.width = 90,
    this.height = 130,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 10,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: book.coverPath == null
            ? _buildAestheticCover()
            : FutureBuilder<Uint8List?>(
                future: BookFileStorage.readBytes(book.coverPath!),
                builder: (context, snapshot) {
                  if (snapshot.hasData &&
                      snapshot.data != null &&
                      snapshot.data!.isNotEmpty) {
                    return Image.memory(
                      snapshot.data!,
                      fit: BoxFit.cover,
                      width: width,
                      height: height,
                    );
                  }
                  return _buildAestheticCover();
                },
              ),
      ),
    );
  }

  Widget _buildAestheticCover() {
    final lowerTitle = book.title.toLowerCase();

    // Specific famous books matching design mockup exactly
    if (lowerTitle.contains('atomic habit')) {
      return _renderStylizedCover(
        bgColor: const Color(0xFFFAF6F0),
        borderColor: const Color(0xFFE8DFD0),
        titleColor: const Color(0xFF221F1F),
        authorColor: const Color(0xFF6B4E3D),
        accentColor: AppColors.primaryTerracotta,
        motif: 'dots',
      );
    } else if (lowerTitle.contains('daily stoic')) {
      return _renderStylizedCover(
        bgColor: const Color(0xFF5A4333),
        borderColor: const Color(0xFF453225),
        titleColor: const Color(0xFFF8EEDD),
        authorColor: const Color(0xFFD5C4A1),
        accentColor: const Color(0xFFD5C4A1),
        motif: 'arch',
      );
    } else if (lowerTitle.contains('deep work')) {
      return _renderStylizedCover(
        bgColor: const Color(0xFFD97757),
        borderColor: const Color(0xFFC06243),
        titleColor: Colors.white,
        authorColor: const Color(0xFFFFF0EB),
        accentColor: Colors.white70,
        motif: 'bold',
      );
    } else if (lowerTitle.contains('sapiens')) {
      return _renderStylizedCover(
        bgColor: const Color(0xFFF5EBE1),
        borderColor: const Color(0xFFE2D0C0),
        titleColor: const Color(0xFF8B261D),
        authorColor: const Color(0xFF5A4333),
        accentColor: const Color(0xFF8B261D),
        motif: 'human',
      );
    } else if (lowerTitle.contains('ikigai')) {
      return _renderStylizedCover(
        bgColor: const Color(0xFFE0F2FE),
        borderColor: const Color(0xFFBAE6FD),
        titleColor: const Color(0xFF0369A1),
        authorColor: const Color(0xFF0C4A6E),
        accentColor: const Color(0xFF38BDF8),
        motif: 'zen',
      );
    } else if (lowerTitle.contains('mindset')) {
      return _renderStylizedCover(
        bgColor: const Color(0xFFEDE9FE),
        borderColor: const Color(0xFFDDD6FE),
        titleColor: const Color(0xFF5B21B6),
        authorColor: const Color(0xFF6D28D9),
        accentColor: const Color(0xFF8B5CF6),
        motif: 'spark',
      );
    } else if (lowerTitle.contains('thinking') && lowerTitle.contains('slow')) {
      return _renderStylizedCover(
        bgColor: const Color(0xFFFAF9F6),
        borderColor: const Color(0xFFE5E5E0),
        titleColor: const Color(0xFF1E293B),
        authorColor: const Color(0xFF64748B),
        accentColor: AppColors.primaryTerracotta,
        motif: 'line',
      );
    } else if (lowerTitle.contains('dopamine')) {
      return _renderStylizedCover(
        bgColor: const Color(0xFFFED7AA),
        borderColor: const Color(0xFFFDBA74),
        titleColor: const Color(0xFF7C2D12),
        authorColor: const Color(0xFF9A3412),
        accentColor: const Color(0xFFEA580C),
        motif: 'dots',
      );
    } else if (lowerTitle.contains('psychology of money')) {
      return _renderStylizedCover(
        bgColor: const Color(0xFFDCFCE7),
        borderColor: const Color(0xFFBBF7D0),
        titleColor: const Color(0xFF14532D),
        authorColor: const Color(0xFF166534),
        accentColor: const Color(0xFF15803D),
        motif: 'arch',
      );
    }

    // Default harmonic variants
    final hash = book.title.hashCode.abs();
    final variants = [
      (
        const Color(0xFF6B4E3D),
        const Color(0xFF523B2D),
        Colors.white,
        const Color(0xFFF8EEDD),
        AppColors.primaryTerracotta,
      ),
      (
        const Color(0xFFF8EEDD),
        const Color(0xFFE9DCBF),
        const Color(0xFF6B4E3D),
        const Color(0xFF8B6A56),
        AppColors.primaryTerracotta,
      ),
      (
        const Color(0xFFD97757),
        const Color(0xFFC06243),
        Colors.white,
        const Color(0xFFFDE2D9),
        Colors.white70,
      ),
      (
        const Color(0xFF2C3E50),
        const Color(0xFF1A252F),
        Colors.white,
        const Color(0xFFBDC3C7),
        const Color(0xFF3498DB),
      ),
      (
        const Color(0xFFF1F5F9),
        const Color(0xFFE2E8F0),
        const Color(0xFF1E293B),
        const Color(0xFF64748B),
        AppColors.primaryCoffee,
      ),
    ];

    final chosen = variants[hash % variants.length];
    return _renderStylizedCover(
      bgColor: chosen.$1,
      borderColor: chosen.$2,
      titleColor: chosen.$3,
      authorColor: chosen.$4,
      accentColor: chosen.$5,
      motif: 'classic',
    );
  }

  Widget _renderStylizedCover({
    required Color bgColor,
    required Color borderColor,
    required Color titleColor,
    required Color authorColor,
    required Color accentColor,
    required String motif,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: borderColor, width: 1),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: width > 100 ? 12 : 7,
        vertical: height > 140 ? 12 : 8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Top Header (Tag/Icon)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  book.fileType.toUpperCase(),
                  style: TextStyle(
                    fontSize: width > 100 ? 9 : 7,
                    fontWeight: FontWeight.bold,
                    color: titleColor,
                  ),
                ),
              ),
              Icon(
                Icons.auto_stories,
                size: width > 100 ? 14 : 10,
                color: titleColor.withOpacity(0.4),
              ),
            ],
          ),

          // Title & Motif
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (motif == 'dots') ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    4,
                    (i) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      width: 3,
                      height: 3,
                      decoration: BoxDecoration(
                        color: accentColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
              ],
              Text(
                book.title,
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.lora(
                  fontSize: width > 100 ? 15 : 10.5,
                  fontWeight: FontWeight.bold,
                  color: titleColor,
                  height: 1.15,
                ),
              ),
              if (width > 80) ...[
                const SizedBox(height: 4),
                Container(
                  width: width * 0.35,
                  height: 1.5,
                  color: accentColor.withOpacity(0.6),
                ),
              ],
            ],
          ),

          // Author at bottom
          Text(
            book.author,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(
              fontSize: width > 100 ? 10 : 8,
              fontWeight: FontWeight.w500,
              color: authorColor,
            ),
          ),
        ],
      ),
    );
  }
}
