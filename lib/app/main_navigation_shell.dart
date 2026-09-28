import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/responsive.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/knowledge_hub/presentation/knowledge_hub_screen.dart';
import '../features/knowledge_hub/presentation/search_screen.dart';
import '../features/library/presentation/library_screen.dart';
import '../features/profile/presentation/reading_stats_screen.dart';
import '../shared/widgets/bookmind_logo.dart';

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;

  void _goToLibrary() {
    setState(() => _currentIndex = 1);
  }

  void _goToStats() {
    setState(() => _currentIndex = 3);
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = Responsive.isTabletOrDesktop(context);

    final pages = [
      HomeScreen(
        onSeeAllLibrary: _goToLibrary,
        onGoToStats: _goToStats,
      ),
      const LibraryScreen(),
      const KnowledgeHubScreen(),
      const ReadingStatsScreen(isTab: true),
      const GlobalSearchScreen(),
    ];

    const destinations = [
      (
        icon: Icons.home_outlined,
        selectedIcon: Icons.home,
        label: 'Beranda',
      ),
      (
        icon: Icons.auto_stories_outlined,
        selectedIcon: Icons.auto_stories,
        label: 'Perpustakaan',
      ),
      (
        icon: Icons.sticky_note_2_outlined,
        selectedIcon: Icons.sticky_note_2,
        label: 'Catatan',
      ),
      (
        icon: Icons.bar_chart_outlined,
        selectedIcon: Icons.bar_chart,
        label: 'Statistik',
      ),
      (
        icon: Icons.search_outlined,
        selectedIcon: Icons.search,
        label: 'Pencarian',
      ),
    ];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_currentIndex != 0) {
          setState(() => _currentIndex = 0);
        } else {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        body: isTablet
            ? Row(
                children: [
                  // Tablet Side Navigation Rail
                  NavigationRail(
                    selectedIndex: _currentIndex,
                    onDestinationSelected: (index) {
                      setState(() => _currentIndex = index);
                    },
                    backgroundColor: Colors.white,
                    indicatorColor: AppColors.primaryCream,
                    labelType: NavigationRailLabelType.all,
                    leading: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: BookMindLogo(iconSize: 28, style: BookMindLogoStyle.iconOnly),
                    ),
                    selectedIconTheme: const IconThemeData(color: AppColors.primaryCoffee),
                    unselectedIconTheme: const IconThemeData(color: AppColors.n500),
                    selectedLabelTextStyle: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryCoffee,
                    ),
                    unselectedLabelTextStyle: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.n500,
                    ),
                    destinations: destinations
                        .map(
                          (d) => NavigationRailDestination(
                            icon: Icon(d.icon),
                            selectedIcon: Icon(d.selectedIcon),
                            label: Text(d.label),
                          ),
                        )
                        .toList(),
                  ),
                  const VerticalDivider(width: 1, thickness: 1, color: AppColors.n200),
                  Expanded(
                    child: IndexedStack(
                      index: _currentIndex,
                      children: pages,
                    ),
                  ),
                ],
              )
            : IndexedStack(
                index: _currentIndex,
                children: pages,
              ),
        bottomNavigationBar: isTablet
            ? null
            : NavigationBarTheme(
                data: NavigationBarThemeData(
                  labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>(
                    (states) => TextStyle(
                      fontSize: 10.5,
                      fontWeight: states.contains(WidgetState.selected)
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: states.contains(WidgetState.selected)
                          ? AppColors.primaryCoffee
                          : AppColors.n500,
                    ),
                  ),
                ),
                child: NavigationBar(
                  selectedIndex: _currentIndex,
                  onDestinationSelected: (index) {
                    setState(() => _currentIndex = index);
                  },
                  backgroundColor: Colors.white,
                  indicatorColor: AppColors.primaryCream,
                  elevation: 3,
                  destinations: destinations
                      .map(
                        (d) => NavigationDestination(
                          icon: Icon(d.icon),
                          selectedIcon: Icon(d.selectedIcon, color: AppColors.primaryCoffee),
                          label: d.label,
                        ),
                      )
                      .toList(),
                ),
              ),
      ),
    );
  }
}
