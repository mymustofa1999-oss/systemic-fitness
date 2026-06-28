import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:workout/ColorCategory.dart';
import 'package:workout/Constants.dart';
import 'package:workout/data/api_config.dart';
import 'package:workout/data/api_service.dart';
import 'package:workout/models/program_model.dart';

class ProgramDetailPage extends StatefulWidget {
  final String programId;

  const ProgramDetailPage({super.key, required this.programId});

  @override
  State<ProgramDetailPage> createState() => _ProgramDetailPageState();
}

class _ProgramDetailPageState extends State<ProgramDetailPage>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  String? _error;
  ProgramModel? _program;
  TabController? _tabController;

  // Organized days by week
  Map<int, List<ProgramDay>> _weeklySchedule = {};

  @override
  void initState() {
    super.initState();
    _fetchProgram();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  Future<void> _fetchProgram() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await ApiService.getWithRetry(
        ApiConfig.programById(widget.programId),
      );
      final data = response['data'];
      if (data != null) {
        final program = ProgramModel.fromJson(data);
        _organizeSchedule(program);
        setState(() {
          _program = program;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Program not found';
          _isLoading = false;
        });
      }
    } on ApiException catch (e) {
      setState(() {
        _error = e.message;
        _isLoading = false;
      });
      Fluttertoast.showToast(msg: e.message);
    } catch (e) {
      setState(() {
        _error = 'Failed to load program';
        _isLoading = false;
      });
      Fluttertoast.showToast(msg: 'Failed to load program');
    }
  }

  void _organizeSchedule(ProgramModel program) {
    final schedule = <int, List<ProgramDay>>{};
    final days = program.days ?? [];

    for (final day in days) {
      final week = day.weekNumber ?? 1;
      schedule.putIfAbsent(week, () => []);
      schedule[week]!.add(day);
    }

    // Sort days within each week
    for (final week in schedule.keys) {
      schedule[week]!.sort(
        (a, b) => (a.dayOfWeek ?? 0).compareTo(b.dayOfWeek ?? 0),
      );
    }

    _weeklySchedule = Map.fromEntries(
      schedule.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );

    final totalWeeks =
        program.durationWeeks ?? (_weeklySchedule.isNotEmpty ? _weeklySchedule.keys.last : 1);
    _tabController?.dispose();
    _tabController = TabController(
      length: totalWeeks,
      vsync: this,
    );
  }

  Color _difficultyColor(String? difficulty) {
    switch (difficulty?.toLowerCase()) {
      case 'beginner':
        return greenButton;
      case 'intermediate':
        return Colors.orange;
      case 'advanced':
        return Colors.red;
      default:
        return subTextColor;
    }
  }

  String _dayName(int? dayOfWeek) {
    switch (dayOfWeek) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return 'Day $dayOfWeek';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Program Detail',
          style: TextStyle(
            fontFamily: Constants.fontsFamily,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: accentColor,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.black))
          : _error != null
              ? _buildErrorState()
              : _program == null
                  ? _buildEmptyState()
                  : _buildContent(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 56, color: subTextColor),
            const SizedBox(height: 16),
            Text(
              _error ?? 'Something went wrong',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: Constants.fontsFamily,
                fontSize: 16,
                color: subTextColor,
              ),
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: _fetchProgram,
              child: Text(
                'Retry',
                style: TextStyle(
                  fontFamily: Constants.fontsFamily,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: blueButton,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today_outlined, size: 56, color: subTextColor),
          const SizedBox(height: 16),
          Text(
            'Program not found',
            style: TextStyle(
              fontFamily: Constants.fontsFamily,
              fontSize: 16,
              color: subTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final program = _program!;
    final totalWeeks = program.durationWeeks ??
        (_weeklySchedule.isNotEmpty ? _weeklySchedule.keys.last : 1);

    return Column(
      children: [
        // Program info header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                program.name ?? 'Untitled Program',
                style: TextStyle(
                  fontFamily: Constants.fontsFamily,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: accentColor,
                ),
              ),
              if (program.description != null &&
                  program.description!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  program.description!,
                  style: TextStyle(
                    fontFamily: Constants.fontsFamily,
                    fontSize: 14,
                    color: subTextColor,
                    height: 1.5,
                  ),
                ),
              ],
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildChip(
                    '${program.durationWeeks ?? 0} weeks',
                    Icons.calendar_month_outlined,
                    blueButton,
                  ),
                  if (program.difficulty != null)
                    _buildChip(
                      program.difficulty!,
                      Icons.speed,
                      _difficultyColor(program.difficulty),
                    ),
                  if (program.goal != null && program.goal!.isNotEmpty)
                    _buildChip(
                      program.goal!,
                      Icons.flag_outlined,
                      accentColor,
                    ),
                ],
              ),
            ],
          ),
        ),

        // Weekly tabs
        if (_tabController != null && totalWeeks > 0)
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: accentColor,
              unselectedLabelColor: subTextColor,
              indicatorColor: accentColor,
              indicatorWeight: 2.5,
              labelStyle: TextStyle(
                fontFamily: Constants.fontsFamily,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: TextStyle(
                fontFamily: Constants.fontsFamily,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              tabs: List.generate(
                totalWeeks,
                (i) => Tab(text: 'Week ${i + 1}'),
              ),
            ),
          ),

        // Weekly schedule content
        Expanded(
          child: _tabController != null && totalWeeks > 0
              ? TabBarView(
                  controller: _tabController,
                  children: List.generate(totalWeeks, (weekIdx) {
                    final weekNumber = weekIdx + 1;
                    final days = _weeklySchedule[weekNumber] ?? [];
                    return _buildWeekContent(days, weekNumber);
                  }),
                )
              : Center(
                  child: Text(
                    'No schedule available',
                    style: TextStyle(
                      fontFamily: Constants.fontsFamily,
                      fontSize: 16,
                      color: subTextColor,
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildChip(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: Constants.fontsFamily,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekContent(List<ProgramDay> days, int weekNumber) {
    if (days.isEmpty) {
      // Show 7 days with rest day for unscheduled days
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 7,
        itemBuilder: (context, index) {
          return _buildDayCard(
            dayOfWeek: index + 1,
            isRestDay: true,
            workoutName: null,
            workoutId: null,
          );
        },
      );
    }

    // Build full 7-day view, filling in rest for missing days
    final dayMap = <int, ProgramDay>{};
    for (final day in days) {
      if (day.dayOfWeek != null) {
        dayMap[day.dayOfWeek!] = day;
      }
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 7,
      itemBuilder: (context, index) {
        final dayNum = index + 1;
        final day = dayMap[dayNum];
        return _buildDayCard(
          dayOfWeek: dayNum,
          isRestDay: day?.isRestDay ?? (day == null),
          workoutName: day?.workoutName,
          workoutId: day?.workoutId,
          workoutType: day?.workoutType,
        );
      },
    );
  }

  Widget _buildDayCard({
    required int dayOfWeek,
    required bool isRestDay,
    String? workoutName,
    String? workoutId,
    String? workoutType,
  }) {
    return GestureDetector(
      onTap: (!isRestDay && workoutId != null)
          ? () => context.push('/workouts/$workoutId')
          : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Day indicator
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isRestDay
                    ? primaryColor
                    : accentColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  _dayName(dayOfWeek).substring(0, 3),
                  style: TextStyle(
                    fontFamily: Constants.fontsFamily,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isRestDay ? subTextColor : Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _dayName(dayOfWeek),
                    style: TextStyle(
                      fontFamily: Constants.fontsFamily,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: accentColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isRestDay
                        ? 'Rest Day'
                        : workoutName ?? 'Workout',
                    style: TextStyle(
                      fontFamily: Constants.fontsFamily,
                      fontSize: 13,
                      color: isRestDay
                          ? subTextColor
                          : blueButton,
                      fontWeight:
                          isRestDay ? FontWeight.w400 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (!isRestDay && workoutId != null)
              Icon(Icons.chevron_right, color: subTextColor, size: 20),
            if (isRestDay)
              Icon(Icons.bedtime_outlined, color: subTextColor, size: 18),
          ],
        ),
      ),
    );
  }
}
