import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/responsive.dart';

class ReadingStatsScreen extends StatefulWidget {
  final bool isTab;

  const ReadingStatsScreen({
    super.key,
    this.isTab = false,
  });

  @override
  State<ReadingStatsScreen> createState() => _ReadingStatsScreenState();
}

class _ReadingStatsScreenState extends State<ReadingStatsScreen> {
  String _selectedPeriod = 'Tahun';
  bool _hasDateTimePermission = false;
  DateTime _currentDeviceTime = DateTime.now();
  DateTimeRange? _customDateRange;

  int _selectedCalendarDay = 27; // Default to active day 27

  final List<String> _periods = ['Hari Ini', 'Minggu', 'Bulan', 'Tahun', 'Kustom'];

  // 30 days dataset for September 2026 calendar matrix
  final Map<int, ({int minutes, int pages, String book, List<String> sessions, bool hasSticky, bool hasNote})> _septemberDaysData = {
    1: (minutes: 30, pages: 20, book: 'Atomic Habits', sessions: ['20:00 - 20:30 WIB'], hasSticky: false, hasNote: true),
    2: (minutes: 40, pages: 28, book: 'The Daily Stoic', sessions: ['19:30 - 20:10 WIB'], hasSticky: true, hasNote: true),
    3: (minutes: 0, pages: 0, book: '-', sessions: [], hasSticky: false, hasNote: false),
    4: (minutes: 30, pages: 22, book: 'Atomic Habits', sessions: ['20:15 - 20:45 WIB'], hasSticky: false, hasNote: true),
    5: (minutes: 55, pages: 40, book: 'Atomic Habits', sessions: ['15:00 - 15:55 WIB'], hasSticky: true, hasNote: true),
    6: (minutes: 20, pages: 14, book: 'The Daily Stoic', sessions: ['08:00 - 08:20 WIB'], hasSticky: false, hasNote: false),
    7: (minutes: 45, pages: 32, book: 'Deep Work', sessions: ['20:00 - 20:45 WIB'], hasSticky: false, hasNote: true),
    8: (minutes: 35, pages: 24, book: 'Deep Work', sessions: ['19:00 - 19:35 WIB'], hasSticky: true, hasNote: true),
    9: (minutes: 0, pages: 0, book: '-', sessions: [], hasSticky: false, hasNote: false),
    10: (minutes: 25, pages: 16, book: 'Atomic Habits', sessions: ['21:00 - 21:25 WIB'], hasSticky: false, hasNote: false),
    11: (minutes: 40, pages: 28, book: 'Atomic Habits', sessions: ['20:30 - 21:10 WIB'], hasSticky: true, hasNote: true),
    12: (minutes: 30, pages: 20, book: 'The Daily Stoic', sessions: ['07:45 - 08:15 WIB'], hasSticky: false, hasNote: false),
    13: (minutes: 50, pages: 36, book: 'Sapiens', sessions: ['14:00 - 14:50 WIB'], hasSticky: true, hasNote: true),
    14: (minutes: 45, pages: 30, book: 'Sapiens', sessions: ['20:15 - 21:00 WIB'], hasSticky: false, hasNote: true),
    15: (minutes: 0, pages: 0, book: '-', sessions: [], hasSticky: false, hasNote: false),
    16: (minutes: 35, pages: 25, book: 'Atomic Habits', sessions: ['19:30 - 20:05 WIB'], hasSticky: true, hasNote: true),
    17: (minutes: 20, pages: 15, book: 'The Daily Stoic', sessions: ['08:00 - 08:20 WIB'], hasSticky: false, hasNote: true),
    18: (minutes: 40, pages: 26, book: 'Deep Work', sessions: ['21:00 - 21:40 WIB'], hasSticky: false, hasNote: false),
    19: (minutes: 30, pages: 22, book: 'Atomic Habits', sessions: ['20:00 - 20:30 WIB'], hasSticky: false, hasNote: true),
    20: (minutes: 60, pages: 44, book: 'Atomic Habits', sessions: ['15:00 - 16:00 WIB'], hasSticky: true, hasNote: true),
    21: (minutes: 25, pages: 18, book: 'The Daily Stoic', sessions: ['07:30 - 07:55 WIB'], hasSticky: false, hasNote: true),
    22: (minutes: 45, pages: 30, book: 'Atomic Habits', sessions: ['19:45 - 20:30 WIB'], hasSticky: true, hasNote: true),
    23: (minutes: 30, pages: 20, book: 'Deep Work', sessions: ['20:00 - 20:30 WIB'], hasSticky: false, hasNote: false),
    24: (minutes: 50, pages: 38, book: 'Deep Work', sessions: ['08:00 - 08:50 WIB'], hasSticky: true, hasNote: true),
    25: (minutes: 35, pages: 24, book: 'Atomic Habits', sessions: ['21:00 - 21:35 WIB'], hasSticky: false, hasNote: true),
    26: (minutes: 40, pages: 28, book: 'The Daily Stoic', sessions: ['14:00 - 14:45 WIB'], hasSticky: true, hasNote: true),
    27: (minutes: 45, pages: 32, book: 'Atomic Habits (Bab 4)', sessions: ['14:00 - 14:45 WIB', '20:15 - 20:45 WIB'], hasSticky: true, hasNote: true),
    28: (minutes: 20, pages: 15, book: 'Atomic Habits', sessions: ['07:30 - 07:50 WIB'], hasSticky: false, hasNote: false),
    29: (minutes: 0, pages: 0, book: '-', sessions: [], hasSticky: false, hasNote: false),
    30: (minutes: 0, pages: 0, book: '-', sessions: [], hasSticky: false, hasNote: false),
  };

  final List<({String label, int pages, double heightRatio})> _yearData = const [
    (label: 'Jan', pages: 120, heightRatio: 0.35),
    (label: 'Feb', pages: 180, heightRatio: 0.50),
    (label: 'Mar', pages: 90, heightRatio: 0.25),
    (label: 'Apr', pages: 210, heightRatio: 0.60),
    (label: 'Mei', pages: 260, heightRatio: 0.72),
    (label: 'Jun', pages: 150, heightRatio: 0.42),
    (label: 'Jul', pages: 240, heightRatio: 0.68),
    (label: 'Agu', pages: 320, heightRatio: 0.90),
    (label: 'Sep', pages: 280, heightRatio: 0.78),
    (label: 'Okt', pages: 190, heightRatio: 0.52),
    (label: 'Nov', pages: 140, heightRatio: 0.38),
    (label: 'Des', pages: 170, heightRatio: 0.46),
  ];

  final List<({String label, int pages, double heightRatio})> _monthData = const [
    (label: 'Mgg 1', pages: 110, heightRatio: 0.75),
    (label: 'Mgg 2', pages: 140, heightRatio: 0.95),
    (label: 'Mgg 3', pages: 95, heightRatio: 0.65),
    (label: 'Mgg 4', pages: 135, heightRatio: 0.90),
  ];

  final List<({String label, int pages, double heightRatio})> _weekData = const [
    (label: 'Sen', pages: 18, heightRatio: 0.60),
    (label: 'Sel', pages: 24, heightRatio: 0.80),
    (label: 'Rab', pages: 12, heightRatio: 0.40),
    (label: 'Kam', pages: 30, heightRatio: 1.00),
    (label: 'Jum', pages: 20, heightRatio: 0.65),
    (label: 'Sab', pages: 25, heightRatio: 0.83),
    (label: 'Min', pages: 16, heightRatio: 0.53),
  ];

  final List<({String label, int pages, double heightRatio})> _todayData = const [
    (label: '08:00', pages: 6, heightRatio: 0.30),
    (label: '12:00', pages: 8, heightRatio: 0.40),
    (label: '16:00', pages: 4, heightRatio: 0.20),
    (label: '20:00', pages: 20, heightRatio: 1.00),
  ];

  void _requestDateTimePermission() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.access_time_filled_rounded,
                color: Color(0xFFD97706),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Izin Akses Waktu & Tanggal',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'BookMind memerlukan izin akses tanggal dan waktu perangkat Android Anda untuk:',
              style: TextStyle(fontSize: 13, color: AppColors.n700, height: 1.4),
            ),
            const SizedBox(height: 12),
            _buildPermissionFeatureItem(
              icon: Icons.timer_outlined,
              text: 'Mencatat durasi dan timestamp sesi membaca secara real-time.',
            ),
            const SizedBox(height: 8),
            _buildPermissionFeatureItem(
              icon: Icons.calendar_month_outlined,
              text: 'Mengelompokkan statistik harian, mingguan, dan target tahunan.',
            ),
            const SizedBox(height: 8),
            _buildPermissionFeatureItem(
              icon: Icons.lock_clock_outlined,
              text: 'Semua data waktu diproses lokal secara offline dan aman.',
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFAF7F2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFF3E8D6)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 16, color: AppColors.primaryCoffee),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Waktu saat ini: ${DateFormatter.formatTimeOnly(_currentDeviceTime)}',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Nanti Saja', style: TextStyle(color: AppColors.n500)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _hasDateTimePermission = true;
                _currentDeviceTime = DateTime.now();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✓ Izin akses tanggal & waktu Android berhasil diaktifkan!'),
                  backgroundColor: AppColors.primaryCoffee,
                  duration: Duration(seconds: 3),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryCoffee,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Izinkan Akses'),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionFeatureItem({required IconData icon, required String text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.primaryTerracotta),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 12, color: AppColors.n700),
          ),
        ),
      ],
    );
  }

  Future<void> _selectCustomDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 1),
      initialDateRange: _customDateRange ??
          DateTimeRange(
            start: now.subtract(const Duration(days: 30)),
            end: now,
          ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryCoffee,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.n900,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _customDateRange = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String booksFinished = '12';
    String pagesRead = '2.340';
    String readingTime = '48j 30m';
    String avgDailyTime = '42m/hari';
    String notesCreated = '28';
    String highlightsCount = '96';

    List<({String label, int pages, double heightRatio})> activeChartData = _yearData;

    if (_selectedPeriod == 'Hari Ini') {
      booksFinished = '0';
      pagesRead = '38';
      readingTime = '45m';
      avgDailyTime = '45m/hari';
      notesCreated = '3';
      highlightsCount = '8';
      activeChartData = _todayData;
    } else if (_selectedPeriod == 'Minggu') {
      booksFinished = '1';
      pagesRead = '145';
      readingTime = '4j 15m';
      avgDailyTime = '36m/hari';
      notesCreated = '7';
      highlightsCount = '24';
      activeChartData = _weekData;
    } else if (_selectedPeriod == 'Bulan') {
      booksFinished = '3';
      pagesRead = '480';
      readingTime = '12j 50m';
      avgDailyTime = '38m/hari';
      notesCreated = '15';
      highlightsCount = '42';
      activeChartData = _monthData;
    } else if (_selectedPeriod == 'Kustom') {
      if (_customDateRange != null) {
        final days = _customDateRange!.duration.inDays + 1;
        pagesRead = '${days * 18}';
        readingTime = '${(days * 0.6).toStringAsFixed(1)}j';
        avgDailyTime = '36m/hari';
        notesCreated = '${(days * 0.4).ceil()}';
        highlightsCount = '${days * 2}';
      }
    }

    final isTablet = Responsive.isTabletOrDesktop(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF7F2),
        elevation: 0,
        title: Text('Statistik Membaca', style: AppTypography.headlineLarge),
        leading: widget.isTab
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.primaryCoffee),
                onPressed: () => Navigator.pop(context),
              ),
        actions: [
          IconButton(
            icon: const Icon(Icons.access_time, color: AppColors.primaryCoffee),
            tooltip: 'Izin Tanggal & Waktu',
            onPressed: _requestDateTimePermission,
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined, color: AppColors.primaryCoffee),
            tooltip: 'Bagikan Statistik',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Statistik siap dibagikan ke catatan Anda'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1040),
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            children: [
              // Android Date & Time Permission Banner
              _buildDateTimePermissionBanner(context),
              const SizedBox(height: 16),

              // Period Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _periods.map((p) {
                    final isSelected = _selectedPeriod == p;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: InkWell(
                        onTap: () {
                          if (p == 'Kustom') {
                            _selectCustomDateRange();
                          }
                          setState(() => _selectedPeriod = p);
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primaryCoffee : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? AppColors.primaryCoffee : AppColors.n300,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (p == 'Kustom') ...[
                                Icon(
                                  Icons.calendar_today_outlined,
                                  size: 13,
                                  color: isSelected ? Colors.white : AppColors.n700,
                                ),
                                const SizedBox(width: 4),
                              ],
                              Text(
                                p,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : AppColors.n700,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              if (_selectedPeriod == 'Kustom' && _customDateRange != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.n300),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.date_range, size: 14, color: AppColors.primaryTerracotta),
                      const SizedBox(width: 6),
                      Text(
                        '${DateFormatter.formatShortDate(_customDateRange!.start)} - ${DateFormatter.formatShortDate(_customDateRange!.end)}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),

              // 6 Quick Metric Stat Boxes
              GridView.count(
                crossAxisCount: isTablet ? 3 : 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: isTablet ? 2.0 : 1.6,
                children: [
                  _buildStatBox(
                    icon: Icons.bookmark_added_outlined,
                    iconColor: const Color(0xFFE11D48),
                    iconBg: const Color(0xFFFFE4E6),
                    value: booksFinished,
                    label: 'Buku Selesai',
                  ),
                  _buildStatBox(
                    icon: Icons.menu_book_outlined,
                    iconColor: const Color(0xFFD97706),
                    iconBg: const Color(0xFFFEF3C7),
                    value: pagesRead,
                    label: 'Halaman Dibaca',
                  ),
                  _buildStatBox(
                    icon: Icons.access_time_filled_rounded,
                    iconColor: const Color(0xFFEA580C),
                    iconBg: const Color(0xFFFFEDD5),
                    value: readingTime,
                    label: 'Total Waktu Baca',
                  ),
                  _buildStatBox(
                    icon: Icons.timelapse_rounded,
                    iconColor: const Color(0xFF0284C7),
                    iconBg: const Color(0xFFE0F2FE),
                    value: avgDailyTime,
                    label: 'Rata-rata Waktu',
                  ),
                  _buildStatBox(
                    icon: Icons.edit_note_outlined,
                    iconColor: const Color(0xFF059669),
                    iconBg: const Color(0xFFD1FAE5),
                    value: notesCreated,
                    label: 'Catatan Dibuat',
                  ),
                  _buildStatBox(
                    icon: Icons.brush_outlined,
                    iconColor: const Color(0xFF7C3AED),
                    iconBg: const Color(0xFFEDE9FE),
                    value: highlightsCount,
                    label: 'Highlight',
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Active Reading Hours Section
              _buildActiveReadingHoursSection(),
              const SizedBox(height: 24),

              // 2. TAMPILAN STATISTIK BERUPA TANGGAL & GRAFIK (Responsive Side-by-Side on Tablet)
              if (isTablet) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildDateCalendarStatsSection()),
                    const SizedBox(width: 16),
                    Expanded(child: _buildMonthlyBarChartSection(pagesRead, readingTime, activeChartData)),
                  ],
                ),
                const SizedBox(height: 24),
              ] else ...[
                _buildDateCalendarStatsSection(),
                const SizedBox(height: 24),
                _buildMonthlyBarChartSection(pagesRead, readingTime, activeChartData),
                const SizedBox(height: 24),
              ],

          // Recent Session Logs with Timestamps
          _buildRecentSessionLogs(),
          const SizedBox(height: 24),

          // Genre Favorit Section
          Text('Genre Favorit', style: AppTypography.headlineMedium),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.n200),
            ),
            child: Column(
              children: [
                _buildGenreRow(
                  icon: '🌱',
                  title: 'Self-Development',
                  percentage: 40,
                  color: AppColors.primaryTerracotta,
                ),
                const SizedBox(height: 14),
                _buildGenreRow(
                  icon: '🧠',
                  title: 'Psychology',
                  percentage: 25,
                  color: AppColors.primaryCoffee,
                ),
                const SizedBox(height: 14),
                _buildGenreRow(
                  icon: '💼',
                  title: 'Business & Productivity',
                  percentage: 20,
                  color: const Color(0xFFD97706),
                ),
                const SizedBox(height: 14),
                _buildGenreRow(
                  icon: '🏛️',
                  title: 'Philosophy',
                  percentage: 15,
                  color: const Color(0xFF059669),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Achievement Badge Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFF7ED), Color(0xFFFEE2E2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFED7AA)),
            ),
            child: Column(
              children: [
                const Row(
                  children: [
                    Text('🏆', style: TextStyle(fontSize: 28)),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hebat! Target Membaca Tercapai',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryCoffee,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Kamu telah menyelesaikan 12 buku tahun ini 🎉',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.n700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    '"A reader today, a better me tomorrow."',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryCoffee,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 36),
        ],
      ),
    ),
  ),
);
  }

  /// TAMPILAN STATISTIK BERUPA TANGGAL (Requirement 2)
  Widget _buildDateCalendarStatsSection() {
    final selectedDayData = _septemberDaysData[_selectedCalendarDay] ??
        (minutes: 0, pages: 0, book: '-', sessions: <String>[], hasSticky: false, hasNote: false);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8DFD1), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryCoffee.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title & Month Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kalender Tanggal Membaca',
                    style: AppTypography.headlineMedium.copyWith(fontSize: 16),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'September 2026 · Habit Harian',
                    style: TextStyle(fontSize: 12, color: AppColors.n500),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.local_fire_department_rounded, size: 14, color: Color(0xFFD97706)),
                    SizedBox(width: 4),
                    Text(
                      '14 Hari Streak',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF92400E),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Day of Week Header
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _CalendarWeekdayHeader('Sen'),
              _CalendarWeekdayHeader('Sel'),
              _CalendarWeekdayHeader('Rab'),
              _CalendarWeekdayHeader('Kam'),
              _CalendarWeekdayHeader('Jum'),
              _CalendarWeekdayHeader('Sab'),
              _CalendarWeekdayHeader('Min'),
            ],
          ),
          const SizedBox(height: 8),

          // Calendar Days Grid (September 2026 starts on Tuesday -> 1 empty offset on Monday)
          _buildCalendarMatrixGrid(),
          const SizedBox(height: 14),

          // Heatmap Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Intensitas:', style: TextStyle(fontSize: 10.5, color: AppColors.n500)),
              const SizedBox(width: 8),
              _buildLegendDot(const Color(0xFFF5EFE6), '0m'),
              const SizedBox(width: 8),
              _buildLegendDot(const Color(0xFFFED7AA), '<25m'),
              const SizedBox(width: 8),
              _buildLegendDot(const Color(0xFFFB923C), '25-45m'),
              const SizedBox(width: 8),
              _buildLegendDot(const Color(0xFFEA580C), '>45m'),
            ],
          ),
          const SizedBox(height: 16),

          // Interactive Selected Date Detail Card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFDF8),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFF1DECB)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.event_available_rounded, size: 16, color: AppColors.primaryTerracotta),
                        const SizedBox(width: 6),
                        Text(
                          'Tanggal $_selectedCalendarDay September 2026',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryCoffee,
                          ),
                        ),
                      ],
                    ),
                    if (selectedDayData.minutes > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primaryTerracotta.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${selectedDayData.minutes} Menit · ${selectedDayData.pages} Hal',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryTerracotta,
                          ),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.n200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Istirahat',
                          style: TextStyle(fontSize: 11, color: AppColors.n700),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),

                if (selectedDayData.minutes > 0) ...[
                  Row(
                    children: [
                      const Icon(Icons.auto_stories, size: 14, color: AppColors.n500),
                      const SizedBox(width: 6),
                      Text(
                        'Buku: ${selectedDayData.book}',
                        style: const TextStyle(fontSize: 12, color: AppColors.n700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.schedule, size: 14, color: AppColors.n500),
                      const SizedBox(width: 6),
                      Text(
                        'Sesi: ${selectedDayData.sessions.join(' & ')}',
                        style: const TextStyle(fontSize: 12, color: AppColors.n700),
                      ),
                    ],
                  ),
                  if (selectedDayData.hasSticky || selectedDayData.hasNote) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        if (selectedDayData.hasSticky)
                          Container(
                            margin: const EdgeInsets.only(right: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF9C3),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: const Color(0xFFFDE047)),
                            ),
                            child: const Text(
                              '📌 Ada Sticky Note',
                              style: TextStyle(fontSize: 10, color: Color(0xFF713F12), fontWeight: FontWeight.bold),
                            ),
                          ),
                        if (selectedDayData.hasNote)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFECFDF5),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: const Color(0xFFA7F3D0)),
                            ),
                            child: const Text(
                              '✍️ Ada Refleksi',
                              style: TextStyle(fontSize: 10, color: Color(0xFF065F46), fontWeight: FontWeight.bold),
                            ),
                          ),
                      ],
                    ),
                  ],
                ] else ...[
                  const Text(
                    'Tidak ada sesi membaca pada tanggal ini. Ketuk tanggal lain untuk melihat riwayat aktivitas.',
                    style: TextStyle(fontSize: 11.5, color: AppColors.n500),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black12, width: 0.5),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.n700)),
      ],
    );
  }

  Widget _buildCalendarMatrixGrid() {
    // September 1, 2026 is Tuesday. Monday is offset 1.
    final List<Widget> dayWidgets = [];

    // Empty cell for Monday Aug 31
    dayWidgets.add(const SizedBox(width: 38, height: 38));

    for (int day = 1; day <= 30; day++) {
      final data = _septemberDaysData[day];
      final minutes = data?.minutes ?? 0;
      final isSelected = _selectedCalendarDay == day;
      final isToday = day == 27 || day == 28;

      Color cellBg;
      Color textColor;
      if (minutes == 0) {
        cellBg = const Color(0xFFF7F2EB);
        textColor = AppColors.n500;
      } else if (minutes < 25) {
        cellBg = const Color(0xFFFED7AA);
        textColor = const Color(0xFF7C2D12);
      } else if (minutes <= 45) {
        cellBg = const Color(0xFFFB923C);
        textColor = Colors.white;
      } else {
        cellBg = const Color(0xFFEA580C);
        textColor = Colors.white;
      }

      dayWidgets.add(
        GestureDetector(
          onTap: () {
            setState(() => _selectedCalendarDay = day);
          },
          child: Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: cellBg,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected
                    ? AppColors.primaryCoffee
                    : (isToday ? AppColors.primaryTerracotta : Colors.transparent),
                width: isSelected ? 2.5 : (isToday ? 2.0 : 0.0),
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.primaryCoffee.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      )
                    ]
                  : null,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  '$day',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected || isToday || minutes > 0
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: textColor,
                  ),
                ),
                if (data?.hasSticky == true)
                  Positioned(
                    top: 2,
                    right: 4,
                    child: Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFACC15),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 6,
      mainAxisSpacing: 6,
      children: dayWidgets,
    );
  }

  /// Section Bar Chart Bulanan
  Widget _buildMonthlyBarChartSection(
    String pagesRead,
    String readingTime,
    List<({String label, int pages, double heightRatio})> activeChartData,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Grafik Halaman Dibaca', style: AppTypography.headlineMedium),
            Text(
              '$pagesRead hal ($readingTime)',
              style: AppTypography.labelSmall.copyWith(color: AppColors.n500),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.n200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 140,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: activeChartData.map((data) {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Tooltip(
                              message: '${data.pages} halaman',
                              child: Container(
                                height: (100 * data.heightRatio).clamp(8.0, 110.0),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryTerracotta,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              data.label,
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.n500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateTimePermissionBanner(BuildContext context) {
    if (_hasDateTimePermission) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFECFDF5),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFA7F3D0)),
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Color(0xFF059669), size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Izin Waktu Android Aktif',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF065F46),
                    ),
                  ),
                  Text(
                    DateFormatter.formatFullIndonesianDateTime(_currentDeviceTime),
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF047857),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.refresh, size: 18, color: Color(0xFF059669)),
              tooltip: 'Perbarui Waktu Sistem',
              onPressed: () {
                setState(() => _currentDeviceTime = DateTime.now());
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Waktu analitik berhasil disinkronkan dengan jam Android.'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: _requestDateTimePermission,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFBEB),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFFDE68A)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.schedule_rounded,
                color: Color(0xFFD97706),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Perlu Izin Akses Waktu & Tanggal',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF92400E),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Izinkan akses jam Android untuk melacak durasi dan sesi membaca harian.',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.amber.shade900,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _hasDateTimePermission = true;
                  _currentDeviceTime = DateTime.now();
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✓ Izin akses tanggal & waktu Android berhasil diaktifkan!'),
                    backgroundColor: AppColors.primaryCoffee,
                    duration: Duration(seconds: 3),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryCoffee,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                visualDensity: VisualDensity.compact,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Izinkan', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveReadingHoursSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.n200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDE9FE),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.nightlight_round, size: 16, color: Color(0xFF7C3AED)),
                  ),
                  const SizedBox(width: 8),
                  Text('Jam Baca Paling Aktif', style: AppTypography.titleMedium),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primaryTerracotta.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '20:00 - 21:30 WIB',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryTerracotta,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'Distribusi Waktu Berdasarkan Jam dalam Sehari:',
            style: TextStyle(fontSize: 12, color: AppColors.n500),
          ),
          const SizedBox(height: 10),
          _buildTimeSlotRow('Pagi Hari (06:00 - 12:00 WIB)', 0.15, '15%'),
          const SizedBox(height: 8),
          _buildTimeSlotRow('Siang & Sore (12:00 - 18:00 WIB)', 0.23, '23%'),
          const SizedBox(height: 8),
          _buildTimeSlotRow('Malam Hari (18:00 - 24:00 WIB)', 0.62, '62% (Favorit)'),
        ],
      ),
    );
  }

  Widget _buildTimeSlotRow(String title, double ratio, String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontSize: 11, color: AppColors.n700)),
            Text(
              text,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primaryCoffee),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: ratio,
            backgroundColor: AppColors.n200,
            valueColor: AlwaysStoppedAnimation<Color>(
              ratio > 0.5 ? AppColors.primaryTerracotta : AppColors.primaryCoffee,
            ),
            minHeight: 5,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentSessionLogs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Riwayat Sesi Membaca', style: AppTypography.headlineMedium),
            Text(
              'Berdasarkan Waktu',
              style: AppTypography.labelSmall.copyWith(color: AppColors.n500),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.n200),
          ),
          child: Column(
            children: [
              _buildSessionRow(
                bookTitle: 'Atomic Habits',
                dateStr: 'Hari Ini, 27 Sep 2026',
                timeRangeStr: '20:15 - 20:45 WIB',
                durationStr: '30 menit',
                pagesStr: '24 hal',
              ),
              const Divider(height: 1, indent: 56),
              _buildSessionRow(
                bookTitle: 'The Daily Stoic',
                dateStr: 'Kemarin, 26 Sep 2026',
                timeRangeStr: '14:00 - 14:45 WIB',
                durationStr: '45 menit',
                pagesStr: '32 hal',
              ),
              const Divider(height: 1, indent: 56),
              _buildSessionRow(
                bookTitle: 'Deep Work',
                dateStr: 'Jumat, 25 Sep 2026',
                timeRangeStr: '06:30 - 07:15 WIB',
                durationStr: '45 menit',
                pagesStr: '18 hal',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSessionRow({
    required String bookTitle,
    required String dateStr,
    required String timeRangeStr,
    required String durationStr,
    required String pagesStr,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFFDEEE9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.menu_book_rounded,
              size: 20,
              color: AppColors.primaryTerracotta,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bookTitle,
                  style: AppTypography.titleMedium.copyWith(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  '$dateStr · $timeRangeStr',
                  style: const TextStyle(fontSize: 11, color: AppColors.n500),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                durationStr,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryCoffee,
                ),
              ),
              Text(
                pagesStr,
                style: const TextStyle(fontSize: 10, color: AppColors.n500),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.n200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: iconColor),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.headlineMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.n500,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenreRow({
    required String icon,
    required String title,
    required int percentage,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(icon, style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 8),
                Text(title, style: AppTypography.titleMedium),
              ],
            ),
            Text(
              '$percentage%',
              style: AppTypography.titleMedium.copyWith(color: AppColors.n700),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: AppColors.n200,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}

class _CalendarWeekdayHeader extends StatelessWidget {
  final String text;
  const _CalendarWeekdayHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 38,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: AppColors.n500,
        ),
      ),
    );
  }
}
