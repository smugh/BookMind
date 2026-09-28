import 'package:flutter/material.dart';
import '../../../app/main_navigation_shell.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/bookmind_logo.dart';

class CoverScreen extends StatefulWidget {
  const CoverScreen({super.key});

  @override
  State<CoverScreen> createState() => _CoverScreenState();
}

class _CoverScreenState extends State<CoverScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<({String badge, String title, String subtitle})> _slides = const [
    (
      badge: 'Bebas Iklan · Tanpa Langganan · 100% Offline 🛡️',
      title: 'Fokus Upgrade Diri\nTanpa Distraksi.',
      subtitle:
          'Fokuskan upgrade diri tanpa ribet iklan atau subscribe. Simpan kutipan berharga, catat refleksi personal, dan bangun perpustakaan pengetahuan privat.',
    ),
    (
      badge: 'Highlight & Sticky Note 📌',
      title: 'Tangkap Setiap\nRefleksi & Ide.',
      subtitle:
          'Tandai kalimat penting, tempelkan sticky note interaktif di halaman buku yang dapat di-minimize, dan kembangkan pemikiranmu.',
    ),
    (
      badge: 'Statistik Berbasis Tanggal 📊',
      title: 'Pantau Habit &\nKonsistensi Harian.',
      subtitle:
          'Pantau progres membaca harian dengan kalender tanggal, streak membaca, jam baca paling aktif, dan grafik pertumbuhan bulanan.',
    ),
  ];

  void _navigateToHome() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const MainNavigationShell(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F2),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              children: [
            // Top Bar with Brand Logo & Skip
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const BookMindLogo(iconSize: 24, style: BookMindLogoStyle.horizontal),
                  TextButton(
                    onPressed: _navigateToHome,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.n500,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      visualDensity: VisualDensity.compact,
                    ),
                    child: Text(
                      'Lewati',
                      style: AppTypography.titleMedium.copyWith(
                        color: AppColors.n500,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // PageView Content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),

                        // Greeting / Tagline Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFDEEE9),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFF8D8CE)),
                          ),
                          child: Text(
                            slide.badge,
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryTerracotta,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Headline Serif
                        Text(
                          slide.title,
                          style: AppTypography.displayLarge.copyWith(
                            fontSize: 28,
                            height: 1.2,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryCoffee,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Subtitle
                        Text(
                          slide.subtitle,
                          style: AppTypography.bodyLarge.copyWith(
                            fontSize: 13.5,
                            height: 1.45,
                            color: AppColors.n700,
                          ),
                        ),
                        const Spacer(),

                        // Thematic Illustration Frame
                        Center(
                          child: Container(
                            constraints: const BoxConstraints(
                              maxWidth: 320,
                              maxHeight: 270,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: const Color(0xFFF4EAD9),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryCoffee.withOpacity(0.06),
                                  blurRadius: 24,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(12),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.asset(
                                'assets/images/onboarding_reader.png',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    height: 210,
                                    color: AppColors.primaryCream,
                                    child: const Center(
                                      child: Icon(
                                        Icons.auto_stories,
                                        size: 72,
                                        color: AppColors.primaryCoffee,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                        const Spacer(),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Dots Indicator
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _slides.length,
                  (index) {
                    final bool isActive = _currentPage == index;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: isActive ? 22 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppColors.primaryTerracotta
                            : const Color(0xFFE2D6C7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Tagline Pill Strip (Requirement 4)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8EE),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFF1DECB)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.workspace_premium_rounded, size: 15, color: Color(0xFFD97706)),
                  SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      'Fokus upgrade diri tanpa ribet iklan & subscribe',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryCoffee,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            // Bottom Sliding Arrow Button (Requirement 3)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 6, 24, 16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Column(
                  children: [
                    _SlideToStartButton(
                      onSlideComplete: _navigateToHome,
                    ),
                    const SizedBox(height: 6),

                    // Secondary Text Action
                    TextButton(
                      onPressed: _navigateToHome,
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primaryCoffee,
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        visualDensity: VisualDensity.compact,
                      ),
                      child: Text(
                        'Atau ketuk di sini untuk masuk langsung',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.n500,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  ),
);
  }
}

/// Interactive Sliding Button with Arrow knob
class _SlideToStartButton extends StatefulWidget {
  final VoidCallback onSlideComplete;

  const _SlideToStartButton({required this.onSlideComplete});

  @override
  State<_SlideToStartButton> createState() => _SlideToStartButtonState();
}

class _SlideToStartButtonState extends State<_SlideToStartButton>
    with SingleTickerProviderStateMixin {
  double _dragPosition = 0.0;
  late AnimationController _animController;
  Animation<double>? _resetAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _animController.addListener(() {
      if (_resetAnimation != null) {
        setState(() {
          _dragPosition = _resetAnimation!.value;
        });
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _completeSlide(double maxDrag) {
    _resetAnimation = Tween<double>(begin: _dragPosition, end: maxDrag).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _animController.forward(from: 0.0).then((_) {
      widget.onSlideComplete();
      // Reset back for subsequent interactions
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) {
          setState(() {
            _dragPosition = 0.0;
          });
        }
      });
    });
  }

  void _springBack() {
    _resetAnimation = Tween<double>(begin: _dragPosition, end: 0.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );
    _animController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    const double buttonHeight = 56.0;
    const double knobSize = 46.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxDrag = constraints.maxWidth - knobSize - 8.0;

        return Container(
          width: double.infinity,
          height: buttonHeight,
          decoration: BoxDecoration(
            color: const Color(0xFFF2ECE2),
            borderRadius: BorderRadius.circular(buttonHeight / 2),
            border: Border.all(color: const Color(0xFFE2D6C5), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryCoffee.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              // Sliding background highlight fill
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: _dragPosition + (knobSize / 2) + 4,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.primaryTerracotta.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(buttonHeight / 2),
                  ),
                ),
              ),

              // Centered Guidance Text with arrow chevrons
              Positioned.fill(
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Geser panah untuk masuk',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryCoffee.withOpacity(0.75),
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.double_arrow_rounded,
                        size: 16,
                        color: AppColors.primaryTerracotta.withOpacity(0.85),
                      ),
                    ],
                  ),
                ),
              ),

              // Draggable / Tap Arrow Knob
              Positioned(
                left: 4.0 + _dragPosition,
                child: GestureDetector(
                  onTap: () => _completeSlide(maxDrag),
                  onHorizontalDragUpdate: (details) {
                    setState(() {
                      _dragPosition = (_dragPosition + details.delta.dx).clamp(0.0, maxDrag);
                    });
                  },
                  onHorizontalDragEnd: (details) {
                    if (_dragPosition >= maxDrag * 0.65) {
                      _completeSlide(maxDrag);
                    } else {
                      _springBack();
                    }
                  },
                  child: Container(
                    width: knobSize,
                    height: knobSize,
                    decoration: BoxDecoration(
                      color: AppColors.primaryCoffee,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryCoffee.withOpacity(0.35),
                          blurRadius: 8,
                          offset: const Offset(2, 2),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
