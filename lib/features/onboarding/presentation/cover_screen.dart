import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/main_navigation_shell.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/services/app_settings_service.dart';
import '../../../core/theme/app_colors.dart';
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
    return const AssetImage('assets/images/onboarding_cover_prd.png');
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
          // 1. Full Page Background Image (PRD cover or user custom photo)
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

          // 2. High-contrast Dark/Warm Gradient Scrim (Keeps upper HD artwork vivid, darkens bottom for readability)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.transparent,
                  Colors.black.withOpacity(0.35),
                  const Color(0xFF160E0A).withOpacity(0.92),
                ],
                stops: const [0.0, 0.45, 0.72, 1.0],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // 3. Screen Content (No active menus or buttons except slide slider)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // If custom cover photo is used, show brand logo dynamically
                  if (settings.coverImagePath != null && settings.coverImagePath!.isNotEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 16),
                        child: BookMindLogo(
                          style: BookMindLogoStyle.vertical,
                          iconSize: 52,
                        ),
                      ),
                    ),

                  const Spacer(),

                  // Tagline Pill Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
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
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFFFD4C7),
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Motivational Quotes Carousel (Multiple Quotes to inspire user)
                  _MotivationalQuotesCarousel(lang: lang),

                  const SizedBox(height: 18),

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

                  const SizedBox(height: 14),

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

/// Motivational Quotes Carousel Widget
/// Cycles through inspiring quotes encouraging reading as an essential life habit
class _MotivationalQuotesCarousel extends StatefulWidget {
  final String lang;

  const _MotivationalQuotesCarousel({required this.lang});

  @override
  State<_MotivationalQuotesCarousel> createState() =>
      _MotivationalQuotesCarouselState();
}

class _MotivationalQuotesCarouselState
    extends State<_MotivationalQuotesCarousel> {
  late final PageController _pageController;
  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startAutoSlide();
  }

  void _startAutoSlide() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 5500), (timer) {
      if (!mounted) return;
      final quotes = AppStrings.getMotivationalQuotes(widget.lang);
      if (quotes.isEmpty) return;
      final nextPage = (_currentIndex + 1) % quotes.length;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final quotes = AppStrings.getMotivationalQuotes(widget.lang);

    return Container(
      constraints: const BoxConstraints(minHeight: 165),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1713).withOpacity(0.82),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE07A5F).withOpacity(0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.40),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(17),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header Bar of Quote Card
            Padding(
              padding: const EdgeInsets.only(left: 14, right: 14, top: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.format_quote_rounded,
                        color: Color(0xFFE07A5F),
                        size: 20,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        AppStrings.tr('motivation_header', widget.lang),
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.1,
                          color: Color(0xFFFFD4C7),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${_currentIndex + 1}/${quotes.length}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.55),
                    ),
                  ),
                ],
              ),
            ),

            // Quote Page View
            SizedBox(
              height: 104,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemCount: quotes.length,
                itemBuilder: (context, index) {
                  final item = quotes[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '“${item['quote']}”',
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13.5,
                            height: 1.45,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFFFBF8F5),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '— ${item['tag']}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFE07A5F).withOpacity(0.95),
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Dot Indicators
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(quotes.length, (index) {
                  final isActive = index == _currentIndex;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: isActive ? 18 : 6,
                    height: 5,
                    decoration: BoxDecoration(
                      color: isActive
                          ? const Color(0xFFE07A5F)
                          : Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Interactive Sliding Button with Arrow knob
/// The ONLY active interactive element on CoverScreen to navigate to Home
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

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _completeSlide(maxDrag),
          onHorizontalDragUpdate: (details) {
            setState(() {
              _dragPosition =
                  (_dragPosition + details.delta.dx).clamp(0.0, maxDrag);
            });
          },
          onHorizontalDragEnd: (details) {
            if (_dragPosition >= maxDrag * 0.35) {
              _completeSlide(maxDrag);
            } else {
              _springBack();
            }
          },
          child: Container(
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

                // Arrow Knob
                Positioned(
                  left: 4.0 + _dragPosition,
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
              ],
            ),
          ),
        );
      },
    );
  }
}
