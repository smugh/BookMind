import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/responsive.dart';
import '../../../data/database/app_database.dart';
import '../../../data/database/database_provider.dart';

class ReadingStatsScreen extends ConsumerStatefulWidget {
  final bool isTab;

  const ReadingStatsScreen({
    super.key,
    this.isTab = false,
  });

  @override
  ConsumerState<ReadingStatsScreen> createState() => _ReadingStatsScreenState();
}

class _ReadingStatsScreenState extends ConsumerState<ReadingStatsScreen> {
  String _selectedPeriod = 'Hari Ini';
  bool _hasDateTimePermission = false;
  DateTime _currentDeviceTime = DateTime.now();
  DateTimeRange? _customDateRange;

  late DateTime _chartSelectedDate;
  String _selectedChartBookId = 'all';
  late int _selectedCalendarDay;
  late DateTime _calendarMonth;
  bool _showAllSessions = false;

  final List<String> _periods = ['Hari Ini', 'Minggu', 'Bulan', 'Tahun', 'Kustom'];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _chartSelectedDate = DateTime(now.year, now.month, now.day);
    _selectedCalendarDay = now.day;
    _calendarMonth = DateTime(now.year, now.month);
  }

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
              'Book&Mind memerlukan izin akses tanggal dan waktu perangkat Android Anda untuk:',
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
    final booksAsync = ref.watch(allBooksStreamProvider);
    final notesAsync = ref.watch(allNotesStreamProvider);
    final sessionsAsync = ref.watch(allReadingSessionsStreamProvider);

    final allBooks = booksAsync.valueOrNull ?? [];
    final allNotes = notesAsync.valueOrNull ?? [];
    final allSessions = sessionsAsync.valueOrNull ?? [];

    // Triggered strictly by recorded reading sessions (Requirement 1, 2, 4)
    final bool hasData = allSessions.isNotEmpty;

    final totalReadingSeconds = allSessions.fold<int>(0, (sum, s) => sum + s.session.durationSeconds);
    final totalReadingMinutes = totalReadingSeconds ~/ 60;
    final totalPagesRead = allSessions.fold<int>(0, (sum, s) => sum + s.session.pagesRead);
    final realFinishedCount = allBooks.where((b) => b.totalPages > 0 && b.lastReadPage >= b.totalPages).length;
    final realNotesCount = allNotes.length;
    final realHighlightsCount = allNotes.map((n) => n.highlight.id).toSet().length;

    String booksFinished = hasData ? '$realFinishedCount' : '0';
    String pagesRead = hasData ? '$totalPagesRead' : '0';
    String readingTime = '0m';
    if (hasData) {
      if (totalReadingMinutes >= 60) {
        final hours = totalReadingMinutes ~/ 60;
        final mins = totalReadingMinutes % 60;
        readingTime = '${hours}j ${mins}m';
      } else if (totalReadingMinutes > 0) {
        readingTime = '${totalReadingMinutes}m';
      } else {
        readingTime = '${totalReadingSeconds}s';
      }
    }

    final distinctActiveDays = allSessions
        .map((s) => '${s.session.startTime.year}-${s.session.startTime.month}-${s.session.startTime.day}')
        .toSet()
        .length;
    String avgDailyTime = hasData
        ? '${(totalReadingMinutes / (distinctActiveDays > 0 ? distinctActiveDays : 1)).round()}m/hari'
        : '0m/hari';
    String notesCreated = '$realNotesCount';
    String highlightsCount = '$realHighlightsCount';

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

              // Active Reading Hours Section (Requirement 3)
              _buildActiveReadingHoursSection(allSessions),
              const SizedBox(height: 24),

              // 2. TAMPILAN STATISTIK BERUPA TANGGAL & GRAFIK (Responsive Side-by-Side on Tablet)
              if (isTablet) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildDateCalendarStatsSection(allSessions)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildHourlyDailyChartSection(allBooks, allSessions)),
                  ],
                ),
                const SizedBox(height: 24),
              ] else ...[
                _buildDateCalendarStatsSection(allSessions),
                const SizedBox(height: 24),
                _buildHourlyDailyChartSection(allBooks, allSessions),
                const SizedBox(height: 24),
              ],

              // Recent Session Logs with Timestamps (Requirement 6)
              _buildRecentSessionLogs(allSessions),
              const SizedBox(height: 24),

              // Genre Favorit Section (Requirement 7)
              _buildGenreSection(allBooks, allSessions, hasData),
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
                Row(
                  children: [
                    Text(booksFinished != '0' ? '🏆' : '🌱', style: const TextStyle(fontSize: 28)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booksFinished != '0'
                                ? 'Hebat! Target Membaca Tercapai'
                                : 'Mulai Perjalanan Membacamu',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryCoffee,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            booksFinished != '0'
                                ? 'Kamu telah menyelesaikan $booksFinished buku tahun ini 🎉'
                                : 'Buka buku di perpustakaan untuk mulai membaca hari ini 📖✨',
                            style: const TextStyle(
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
                  child: Text(
                    booksFinished != '0'
                        ? '"A reader today, a better me tomorrow."'
                        : '"Langkah pertama adalah awal dari seribu kebiasaan baik."',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
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

  /// TAMPILAN STATISTIK BERUPA TANGGAL (Requirement 4)
  Widget _buildDateCalendarStatsSection(List<ReadingSessionWithBook> allSessions) {
    final selectedDaySessions = allSessions.where((s) =>
      s.session.startTime.year == _calendarMonth.year &&
      s.session.startTime.month == _calendarMonth.month &&
      s.session.startTime.day == _selectedCalendarDay
    ).toList();

    final selectedDayMinutes = selectedDaySessions.fold<int>(0, (sum, s) => sum + s.session.durationSeconds) ~/ 60;
    final selectedDayPages = selectedDaySessions.fold<int>(0, (sum, s) => sum + s.session.pagesRead);
    final selectedDayBooks = selectedDaySessions.map((s) => s.book.title).toSet().toList();

    // Calculate streak from reading sessions
    int streak = 0;
    DateTime checkDate = DateTime.now();
    final readToday = allSessions.any((s) =>
      s.session.startTime.year == checkDate.year &&
      s.session.startTime.month == checkDate.month &&
      s.session.startTime.day == checkDate.day
    );
    if (!readToday) {
      checkDate = checkDate.subtract(const Duration(days: 1));
    }
    while (true) {
      final hasRead = allSessions.any((s) =>
        s.session.startTime.year == checkDate.year &&
        s.session.startTime.month == checkDate.month &&
        s.session.startTime.day == checkDate.day
      );
      if (hasRead) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    final monthName = DateFormatter.indonesianMonths[(_calendarMonth.month - 1).clamp(0, 11)];

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
                  Text(
                    '$monthName ${_calendarMonth.year} · Habit Harian',
                    style: const TextStyle(fontSize: 12, color: AppColors.n500),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: streak > 0 ? const Color(0xFFFEF3C7) : AppColors.n200,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: streak > 0 ? const Color(0xFFFDE68A) : Colors.transparent),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.local_fire_department_rounded,
                      size: 14,
                      color: streak > 0 ? const Color(0xFFD97706) : AppColors.n500,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$streak Hari Streak',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: streak > 0 ? const Color(0xFF92400E) : AppColors.n700,
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

          // Calendar Days Grid
          _buildCalendarMatrixGrid(allSessions),
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
                          'Tanggal $_selectedCalendarDay $monthName ${_calendarMonth.year}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryCoffee,
                          ),
                        ),
                      ],
                    ),
                    if (selectedDayMinutes > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primaryTerracotta.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$selectedDayMinutes Menit · $selectedDayPages Hal',
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

                if (selectedDayMinutes > 0) ...[
                  Row(
                    children: [
                      const Icon(Icons.auto_stories, size: 14, color: AppColors.n500),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Buku: ${selectedDayBooks.join(', ')}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12, color: AppColors.n700),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.schedule, size: 14, color: AppColors.n500),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Sesi: ${selectedDaySessions.map((s) => '${DateFormatter.formatTimeOnly(s.session.startTime)} (${s.session.pagesRead} hal)').join(', ')}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12, color: AppColors.n700),
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  const Text(
                    'Tidak ada sesi membaca pada tanggal ini. Ketuk tanggal lain atau tekan tombol Start di reader untuk mencatat waktu baca.',
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

  Widget _buildCalendarMatrixGrid(List<ReadingSessionWithBook> allSessions) {
    final firstDay = DateTime(_calendarMonth.year, _calendarMonth.month, 1);
    final offset = (firstDay.weekday - 1) % 7;
    final totalDays = DateTime(_calendarMonth.year, _calendarMonth.month + 1, 0).day;
    final now = DateTime.now();

    final List<Widget> dayWidgets = [];

    for (int i = 0; i < offset; i++) {
      dayWidgets.add(const SizedBox(width: 38, height: 38));
    }

    for (int day = 1; day <= totalDays; day++) {
      final daySessions = allSessions.where((s) =>
        s.session.startTime.year == _calendarMonth.year &&
        s.session.startTime.month == _calendarMonth.month &&
        s.session.startTime.day == day
      ).toList();

      final minutes = daySessions.fold<int>(0, (sum, s) => sum + s.session.durationSeconds) ~/ 60;
      final isSelected = _selectedCalendarDay == day;
      final isToday = now.year == _calendarMonth.year && now.month == _calendarMonth.month && now.day == day;

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
            setState(() {
              _selectedCalendarDay = day;
              _chartSelectedDate = DateTime(_calendarMonth.year, _calendarMonth.month, day);
            });
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
            child: Text(
              '$day',
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected || isToday || minutes > 0 ? FontWeight.bold : FontWeight.normal,
                color: textColor,
              ),
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

  /// GRAFIK HALAMAN BACA HARIAN (Requirement 5)
  Widget _buildHourlyDailyChartSection(
    List<BookEntry> allBooks,
    List<ReadingSessionWithBook> allSessions,
  ) {
    // Filter sessions by selected date and selected book
    final daySessions = allSessions.where((s) {
      final dateMatches = s.session.startTime.year == _chartSelectedDate.year &&
          s.session.startTime.month == _chartSelectedDate.month &&
          s.session.startTime.day == _chartSelectedDate.day;
      if (!dateMatches) return false;
      if (_selectedChartBookId != 'all') {
        return s.session.bookId == _selectedChartBookId;
      }
      return true;
    }).toList();

    // 8 time intervals of 3 hours: 00:00, 03:00, 06:00, 09:00, 12:00, 15:00, 18:00, 21:00
    const List<({String label, int startHour, int endHour})> hourlySlots = [
      (label: '00:00', startHour: 0, endHour: 3),
      (label: '03:00', startHour: 3, endHour: 6),
      (label: '06:00', startHour: 6, endHour: 9),
      (label: '09:00', startHour: 9, endHour: 12),
      (label: '12:00', startHour: 12, endHour: 15),
      (label: '15:00', startHour: 15, endHour: 18),
      (label: '18:00', startHour: 18, endHour: 21),
      (label: '21:00', startHour: 21, endHour: 24),
    ];

    final slotData = hourlySlots.map((slot) {
      final pagesInSlot = daySessions
          .where((s) => s.session.startTime.hour >= slot.startHour && s.session.startTime.hour < slot.endHour)
          .fold<int>(0, (sum, s) => sum + s.session.pagesRead);
      return (label: slot.label, startHour: slot.startHour, endHour: slot.endHour, pages: pagesInSlot);
    }).toList();

    final totalDayPages = slotData.fold<int>(0, (sum, s) => sum + s.pages);
    final maxPagesInSlot = slotData.fold<int>(0, (maxVal, s) => s.pages > maxVal ? s.pages : maxVal);

    final dateDisplay = DateFormatter.formatShortDate(_chartSelectedDate);
    final isToday = DateTime.now().year == _chartSelectedDate.year &&
        DateTime.now().month == _chartSelectedDate.month &&
        DateTime.now().day == _chartSelectedDate.day;
    final dateLabel = isToday ? 'Hari Ini ($dateDisplay)' : dateDisplay;

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
          // Header Card Title (Requirement 5)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Grafik Halaman Baca Harian',
                      style: AppTypography.headlineMedium.copyWith(fontSize: 16),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Distribusi halaman dibaca berdasarkan jam',
                      style: TextStyle(fontSize: 12, color: AppColors.n500),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: totalDayPages > 0 ? const Color(0xFFFEF3C7) : AppColors.n200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$totalDayPages Hal Dibaca',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: totalDayPages > 0 ? const Color(0xFF92400E) : AppColors.n700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Dropdown Pulldown Pilihan Judul Buku (Requirement 5)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFFAF7F2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE8DFD1)),
            ),
            child: Row(
              children: [
                const Icon(Icons.book_outlined, size: 16, color: AppColors.primaryCoffee),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedChartBookId,
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down, size: 20, color: AppColors.primaryCoffee),
                      items: [
                        DropdownMenuItem<String>(
                          value: 'all',
                          child: Text(
                            'Semua Buku (${allBooks.length})',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryCoffee),
                          ),
                        ),
                        ...allBooks.map((b) => DropdownMenuItem<String>(
                          value: b.id,
                          child: Text(
                            b.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 13, color: AppColors.n900),
                          ),
                        )),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedChartBookId = val);
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Date Selector Berkolerasi (Requirement 5)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, size: 22, color: AppColors.primaryCoffee),
                tooltip: 'Hari Sebelumnya',
                onPressed: () {
                  setState(() {
                    _chartSelectedDate = _chartSelectedDate.subtract(const Duration(days: 1));
                    _selectedCalendarDay = _chartSelectedDate.day;
                    _calendarMonth = DateTime(_chartSelectedDate.year, _chartSelectedDate.month);
                  });
                },
              ),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _chartSelectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) {
                    setState(() {
                      _chartSelectedDate = picked;
                      _selectedCalendarDay = picked.day;
                      _calendarMonth = DateTime(picked.year, picked.month);
                    });
                  }
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7ED),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFFED7AA)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.primaryTerracotta),
                      const SizedBox(width: 6),
                      Text(
                        dateLabel,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryCoffee,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_drop_down, size: 16, color: AppColors.primaryCoffee),
                    ],
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right, size: 22, color: AppColors.primaryCoffee),
                tooltip: 'Hari Berikutnya',
                onPressed: () {
                  setState(() {
                    _chartSelectedDate = _chartSelectedDate.add(const Duration(days: 1));
                    _selectedCalendarDay = _chartSelectedDate.day;
                    _calendarMonth = DateTime(_chartSelectedDate.year, _chartSelectedDate.month);
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Area Grafik
          if (totalDayPages == 0)
            Container(
              height: 160,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFFAF7F2),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFF0EAE1)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.bar_chart_outlined, size: 36, color: AppColors.n500),
                  const SizedBox(height: 8),
                  Text(
                    'Tidak ada aktivitas membaca pada $dateDisplay',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.n700),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Buka buku di perpustakaan lalu tekan tombol Start untuk mencatat statistik.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, color: AppColors.n500),
                  ),
                ],
              ),
            )
          else ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Y-Axis: Jumlah Halaman (Maks: $maxPagesInSlot hal)',
                  style: const TextStyle(fontSize: 10.5, color: AppColors.n500),
                ),
                const Text(
                  'X-Axis: Jam WIB',
                  style: TextStyle(fontSize: 10.5, color: AppColors.n500),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 150,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: slotData.map((data) {
                  final heightRatio = maxPagesInSlot > 0 ? (data.pages / maxPagesInSlot) : 0.0;
                  final barHeight = (100 * heightRatio).clamp(data.pages > 0 ? 12.0 : 4.0, 100.0);

                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (data.pages > 0)
                            Text(
                              '${data.pages}',
                              style: const TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryTerracotta,
                              ),
                            )
                          else
                            const SizedBox(height: 12),
                          const SizedBox(height: 2),
                          Tooltip(
                            message: '${data.label} WIB: ${data.pages} halaman dibaca',
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              height: barHeight,
                              decoration: BoxDecoration(
                                color: data.pages > 0 ? AppColors.primaryTerracotta : const Color(0xFFE5E5E0),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            data.label,
                            style: TextStyle(
                              fontSize: 9.5,
                              color: data.pages > 0 ? AppColors.n900 : AppColors.n500,
                              fontWeight: data.pages > 0 ? FontWeight.bold : FontWeight.normal,
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
        ],
      ),
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

  Widget _buildActiveReadingHoursSection(List<ReadingSessionWithBook> sessions) {
    if (sessions.isEmpty) {
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
                    color: AppColors.n200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '0% Sesi Aktif',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.n700),
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
            _buildTimeSlotRow('Pagi Hari (06:00 - 12:00 WIB)', 0.0, '0%'),
            const SizedBox(height: 8),
            _buildTimeSlotRow('Siang & Sore (12:00 - 18:00 WIB)', 0.0, '0%'),
            const SizedBox(height: 8),
            _buildTimeSlotRow('Malam Hari (18:00 - 24:00 WIB)', 0.0, '0%'),
            const SizedBox(height: 8),
            _buildTimeSlotRow('Dini Hari (00:00 - 06:00 WIB)', 0.0, '0%'),
          ],
        ),
      );
    }

    final morningCount = sessions.where((s) => s.session.startTime.hour >= 6 && s.session.startTime.hour < 12).length;
    final afternoonCount = sessions.where((s) => s.session.startTime.hour >= 12 && s.session.startTime.hour < 18).length;
    final eveningCount = sessions.where((s) => s.session.startTime.hour >= 18 && s.session.startTime.hour < 24).length;
    final nightCount = sessions.where((s) => s.session.startTime.hour >= 0 && s.session.startTime.hour < 6).length;

    final total = sessions.length;
    final morningPct = ((morningCount / total) * 100).round();
    final afternoonPct = ((afternoonCount / total) * 100).round();
    final eveningPct = ((eveningCount / total) * 100).round();
    final nightPct = ((nightCount / total) * 100).round();

    String favoriteBadge = 'Malam Hari';
    if (morningCount >= afternoonCount && morningCount >= eveningCount && morningCount >= nightCount) {
      favoriteBadge = 'Pagi ($morningPct%)';
    } else if (afternoonCount >= morningCount && afternoonCount >= eveningCount && afternoonCount >= nightCount) {
      favoriteBadge = 'Siang ($afternoonPct%)';
    } else if (eveningCount >= morningCount && eveningCount >= afternoonCount && eveningCount >= nightCount) {
      favoriteBadge = 'Malam ($eveningPct%)';
    } else {
      favoriteBadge = 'Dini Hari ($nightPct%)';
    }

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
                child: Text(
                  favoriteBadge,
                  style: const TextStyle(
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
          _buildTimeSlotRow('Pagi Hari (06:00 - 12:00 WIB)', morningCount / total, '$morningPct%'),
          const SizedBox(height: 8),
          _buildTimeSlotRow('Siang & Sore (12:00 - 18:00 WIB)', afternoonCount / total, '$afternoonPct%'),
          const SizedBox(height: 8),
          _buildTimeSlotRow('Malam Hari (18:00 - 24:00 WIB)', eveningCount / total, '$eveningPct%'),
          const SizedBox(height: 8),
          _buildTimeSlotRow('Dini Hari (00:00 - 06:00 WIB)', nightCount / total, '$nightPct%'),
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

  /// RIWAYAT SESI MEMBACA (Requirement 6)
  Widget _buildRecentSessionLogs(List<ReadingSessionWithBook> sessions) {
    if (sessions.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Riwayat Sesi Membaca', style: AppTypography.headlineMedium),
              Text(
                '0 Sesi',
                style: AppTypography.labelSmall.copyWith(color: AppColors.n500),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.n200),
            ),
            alignment: Alignment.center,
            child: const Column(
              children: [
                Icon(Icons.history_toggle_off, size: 36, color: AppColors.n500),
                SizedBox(height: 8),
                Text(
                  'Belum Ada Riwayat Sesi (0)',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.n700),
                ),
                SizedBox(height: 4),
                Text(
                  'Sesi membaca beserta durasi dan halaman akan tercatat di sini setelah Anda mulai membaca buku.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: AppColors.n500),
                ),
              ],
            ),
          ),
        ],
      );
    }

    final displayedSessions = _showAllSessions ? sessions : sessions.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Riwayat Sesi Membaca', style: AppTypography.headlineMedium),
            Text(
              '${sessions.length} Sesi',
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
              for (int i = 0; i < displayedSessions.length; i++) ...[
                if (i > 0) const Divider(height: 1, indent: 56),
                _buildSessionRow(
                  bookTitle: displayedSessions[i].book.title,
                  dateStr: DateFormatter.formatShortDate(displayedSessions[i].session.startTime),
                  timeRangeStr:
                      '${DateFormatter.formatTimeOnly(displayedSessions[i].session.startTime)} - ${DateFormatter.formatTimeOnly(displayedSessions[i].session.endTime)}',
                  durationStr: displayedSessions[i].session.durationSeconds >= 60
                      ? '${displayedSessions[i].session.durationSeconds ~/ 60} menit'
                      : '${displayedSessions[i].session.durationSeconds} detik',
                  pagesStr: '${displayedSessions[i].session.pagesRead} hal (Hal ${displayedSessions[i].session.startPage} - ${displayedSessions[i].session.endPage})',
                ),
              ],
              if (sessions.length > 3) ...[
                const Divider(height: 1),
                InkWell(
                  onTap: () {
                    setState(() {
                      _showAllSessions = !_showAllSessions;
                    });
                  },
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _showAllSessions
                              ? 'Tampilkan Lebih Sedikit'
                              : 'Lihat Selengkapnya (${sessions.length} Sesi)',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryTerracotta,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          _showAllSessions ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                          size: 18,
                          color: AppColors.primaryTerracotta,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  /// GENRE FAVORIT SECTION (Requirement 7)
  Widget _buildGenreSection(
    List<BookEntry> allBooks,
    List<ReadingSessionWithBook> allSessions,
    bool hasData,
  ) {
    // Collect weights (duration or count) per genre
    final Map<String, int> genreWeights = {};

    if (allSessions.isNotEmpty) {
      for (final s in allSessions) {
        final g = s.book.genre.trim().isNotEmpty ? s.book.genre.trim() : 'Umum';
        final duration = s.session.durationSeconds > 0 ? s.session.durationSeconds : 60;
        genreWeights[g] = (genreWeights[g] ?? 0) + duration;
      }
    } else if (allBooks.isNotEmpty) {
      for (final b in allBooks) {
        final g = b.genre.trim().isNotEmpty ? b.genre.trim() : 'Umum';
        genreWeights[g] = (genreWeights[g] ?? 0) + 1;
      }
    }

    final hasGenreData = genreWeights.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Genre Favorit', style: AppTypography.headlineMedium),
        const SizedBox(height: 14),
        if (!hasGenreData)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.n200),
            ),
            alignment: Alignment.center,
            child: const Column(
              children: [
                Icon(Icons.category_outlined, size: 36, color: AppColors.n500),
                SizedBox(height: 8),
                Text(
                  'Belum Ada Data Genre (0%)',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.n700),
                ),
                SizedBox(height: 4),
                Text(
                  'Genre buku favorit Anda akan muncul setelah Anda mulai membaca buku.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: AppColors.n500),
                ),
              ],
            ),
          )
        else
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.n200),
            ),
            child: Builder(
              builder: (context) {
                final totalWeight = genreWeights.values.fold<int>(0, (a, b) => a + b);
                final sortedGenres = genreWeights.keys.toList()
                  ..sort((a, b) => (genreWeights[b] ?? 0).compareTo(genreWeights[a] ?? 0));

                return Column(
                  children: [
                    for (int i = 0; i < sortedGenres.length; i++) ...[
                      if (i > 0) const SizedBox(height: 14),
                      () {
                        final genreName = sortedGenres[i];
                        final weight = genreWeights[genreName] ?? 0;
                        final percentage = totalWeight > 0 ? ((weight / totalWeight) * 100).round() : 0;
                        final style = _getGenreStyle(genreName);
                        return _buildGenreRow(
                          icon: style.icon,
                          title: genreName,
                          percentage: percentage > 0 ? percentage : 1,
                          color: style.color,
                        );
                      }(),
                    ],
                  ],
                );
              },
            ),
          ),
      ],
    );
  }

  ({String icon, Color color}) _getGenreStyle(String genre) {
    final lower = genre.toLowerCase();
    if (lower.contains('self') || lower.contains('diri')) {
      return (icon: '🌱', color: AppColors.primaryTerracotta);
    } else if (lower.contains('psycho') || lower.contains('psikologi')) {
      return (icon: '🧠', color: AppColors.primaryCoffee);
    } else if (lower.contains('busin') || lower.contains('bisnis') || lower.contains('productiv') || lower.contains('kerja')) {
      return (icon: '💼', color: const Color(0xFFD97706));
    } else if (lower.contains('philo') || lower.contains('filsafat') || lower.contains('stoic')) {
      return (icon: '🏛️', color: const Color(0xFF059669));
    } else if (lower.contains('hist') || lower.contains('sejarah') || lower.contains('scien') || lower.contains('sains')) {
      return (icon: '🔬', color: const Color(0xFF2563EB));
    } else if (lower.contains('fict') || lower.contains('fiksi') || lower.contains('novel') || lower.contains('sastra')) {
      return (icon: '📚', color: const Color(0xFF7C3AED));
    } else if (lower.contains('bio')) {
      return (icon: '👤', color: const Color(0xFFDB2777));
    } else if (lower.contains('tech') || lower.contains('tekno')) {
      return (icon: '💻', color: const Color(0xFF0284C7));
    }
    return (icon: '📖', color: AppColors.primaryCoffee);
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
