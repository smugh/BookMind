import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/main_navigation_shell.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/services/app_settings_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/bookmind_logo.dart';

class CoverScreen extends ConsumerStatefulWidget {
  const CoverScreen({super.key});

  @override
  ConsumerState<CoverScreen> createState() => _CoverScreenState();
}

class _CoverScreenState extends ConsumerState<CoverScreen> {
  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const MainNavigationShell(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  ImageProvider _resolveCoverImage(String? customPath) {
    if (customPath != null && customPath.isNotEmpty) {
      if (!kIsWeb && File(customPath).existsSync()) {
        return FileImage(File(customPath));
      }
    }
    return const AssetImage('assets/images/onboarding_reader.png');
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(appSettingsProvider);
    final lang = settings.language;
    final coverImage = _resolveCoverImage(settings.coverImagePath);

    return Scaffold(
      backgroundColor: const Color(0xFF1E1713),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Full Page Background Image
          Image(
            image: coverImage,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: const Color(0xFF2B211B),
                child: const Center(
                  child: Icon(
                    Icons.auto_stories,
                    size: 96,
                    color: Color(0xFFC7B198),
                  ),
                ),
              );
            },
          ),

          // 2. High-contrast Dark/Warm Gradient Scrim
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.40),
                  Colors.black.withOpacity(0.25),
                  Colors.black.withOpacity(0.75),
                  const Color(0xFF160E0A).withOpacity(0.95),
                ],
                stops: const [0.0, 0.35, 0.70, 1.0],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // 3. Screen Content (Safe area)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Brand Bar (No skip button)
                  const Row(
                    children: [
                      BookMindLogo(
                        iconSize: 26,
                        style: BookMindLogoStyle.horizontal,
                      ),
                    ],
                  ),

                  const Spacer(flex: 2),

                  // Tagline Pill Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE07A5F).withOpacity(0.25),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFE07A5F).withOpacity(0.55),
                      ),
                    ),
                    child: Text(
                      AppStrings.tr('cover_badge', lang),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFFFD4C7),
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Headline Serif
                  Text(
                    AppStrings.tr('cover_headline', lang),
                    style: AppTypography.displayLarge.copyWith(
                      fontSize: 32,
                      height: 1.22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.6),
                          blurRadius: 12,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Subtitle
                  Text(
                    AppStrings.tr('cover_subtitle', lang),
                    style: AppTypography.bodyLarge.copyWith(
                      fontSize: 14,
                      height: 1.5,
                      color: const Color(0xFFE8DFD8),
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.7),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(flex: 1),

                  // Sole Interactive Element: Slide to Start Button
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 440),
                      child: _SlideToStartButton(
                        guideText: AppStrings.tr('slide_to_enter', lang),
                        onSlideComplete: _navigateToHome,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Creator Information in Footer
                  Center(
                    child: Text(
                      AppStrings.tr('created_by', lang),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.50),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Interactive Sliding Button with Arrow knob
/// The ONLY active interactive element on CoverScreen
class _SlideToStartButton extends StatefulWidget {
  final String guideText;
  final VoidCallback onSlideComplete;

  const _SlideToStartButton({
    required this.guideText,
    required this.onSlideComplete,
  });

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
    const double buttonHeight = 58.0;
    const double knobSize = 48.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxDrag = constraints.maxWidth - knobSize - 8.0;

        return Container(
          width: double.infinity,
          height: buttonHeight,
          decoration: BoxDecoration(
            color: const Color(0xFF2C221C).withOpacity(0.85),
            borderRadius: BorderRadius.circular(buttonHeight / 2),
            border: Border.all(
              color: const Color(0xFFE07A5F).withOpacity(0.40),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
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
                    color: AppColors.primaryTerracotta.withOpacity(0.35),
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
                        widget.guideText,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withOpacity(0.85),
                          letterSpacing: 0.4,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.double_arrow_rounded,
                        size: 16,
                        color: AppColors.primaryTerracotta.withOpacity(0.95),
                      ),
                    ],
                  ),
                ),
              ),

              // Draggable Arrow Knob
              Positioned(
                left: 4.0 + _dragPosition,
                child: GestureDetector(
                  onTap: () => _completeSlide(maxDrag),
                  onHorizontalDragUpdate: (details) {
                    setState(() {
                      _dragPosition =
                          (_dragPosition + details.delta.dx).clamp(0.0, maxDrag);
                    });
                  },
                  onHorizontalDragEnd: (details) {
                    if (_dragPosition >= maxDrag * 0.60) {
                      _completeSlide(maxDrag);
                    } else {
                      _springBack();
                    }
                  },
                  child: Container(
                    width: knobSize,
                    height: knobSize,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFE07A5F), Color(0xFFC85A3D)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryTerracotta.withOpacity(0.50),
                          blurRadius: 10,
                          offset: const Offset(1, 2),
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
