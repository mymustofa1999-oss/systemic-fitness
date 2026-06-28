import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:workout/ColorCategory.dart';
import 'package:workout/Constants.dart';
import 'package:workout/data/api_config.dart';
import 'package:workout/data/api_service.dart';
import 'package:workout/data/pref_data.dart';
import 'package:workout/models/program_model.dart';
import 'package:workout/models/user_model.dart';

class ActiveProgramPage extends StatefulWidget {
  const ActiveProgramPage({super.key});

  @override
  State<ActiveProgramPage> createState() => _ActiveProgramPageState();
}

class _ActiveProgramPageState extends State<ActiveProgramPage> {
  bool _isLoading = true;
  String? _error;
  UserModel? _user;
  ProgramModel? _program;

  // Derived from user stats
  String? _activeProgramId;
  String? _activeProgramName;
  double? _progressPct;

  // Derived from program schedule
  ProgramDay? _todayWorkout;
  List<ProgramDay> _currentWeekDays = [];
  int _currentWeek = 1;
  int _currentDayOfWeek = 1;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Get current user
      final user = await PrefData.getUser();
      if (user == null) {
        // Try fetching from API
        final meResponse = await ApiService.getWithRetry(ApiConfig.me);
        final meData = meResponse['data'];
        if (meData != null) {
          _user = UserModel.fromJson(meData);
        }
      } else {
        _user = user;
      }

      _activeProgramId = _user?.stats?.activeProgramId;
      _activeProgramName = _user?.stats?.activeProgramName;
      _progressPct = _user?.stats?.programProgressPct;

      if (_activeProgramId == null || _activeProgramId!.isEmpty) {
        setState(() => _isLoading = false);
        return;
      }

      // Fetch program detail
      final programResponse = await ApiService.getWithRetry(
        ApiConfig.programById(_activeProgramId!),
      );
      final programData = programResponse['data'];
      if (programData != null) {
        _program = ProgramModel.fromJson(programData);
        _computeSchedule();
      }

      setState(() => _isLoading = false);
    } on ApiException catch (e) {
      setState(() {
        _error = e.message;
        _isLoading = false;
      });
      Fluttertoast.showToast(msg: e.message);
    } catch (e) {
      setState(() {
        _error = 'Failed to load active program';
        _isLoading = false;
      });
      Fluttertoast.showToast(msg: 'Failed to load active program');
    }
  }

  void _computeSchedule() {
    final now = DateTime.now();
    _currentDayOfWeek = now.weekday; // 1=Monday, 7=Sunday

    // Try to determine current week from user stats or default to 1
    _currentWeek = 1;

    final days = _program?.days ?? [];

    // Get current week's days
    _currentWeekDays = days
        .where((d) => d.weekNumber == _currentWeek)
        .toList()
      ..sort((a, b) => (a.dayOfWeek ?? 0).compareTo(b.dayOfWeek ?? 0));

    // Find today's workout
    _todayWorkout = days.firstWhere(
      (d) =>
          d.weekNumber == _currentWeek &&
          d.dayOfWeek == _currentDayOfWeek,
      orElse: () => ProgramDay(
        weekNumber: _currentWeek,
        dayOfWeek: _currentDayOfWeek,
        isRestDay: true,
      ),
    );
  }

  String _dayNameShort(int? dayOfWeek) {
    switch (dayOfWeek) {
      case 1:
        return 'Mon';
      case 2:
        return 'Tue';
      case 3:
        return 'Wed';
      case 4:
        return 'Thu';
      case 5:
        return 'Fri';
      case 6:
        return 'Sat';
      case 7:
        return 'Sun';
      default:
        return 'Day';
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
          'Active Program',
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
              : _activeProgramId == null || _activeProgramId!.isEmpty
                  ? _buildNoActiveProgram()
                  : _buildActiveProgramContent(),
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
              onPressed: _loadData,
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

  Widget _buildNoActiveProgram() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: primaryColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Icon(
                Icons.calendar_today_outlined,
                size: 36,
                color: subTextColor,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No Active Program',
              style: TextStyle(
                fontFamily: Constants.fontsFamily,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: accentColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start a training program to get a structured workout plan tailored to your goals.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: Constants.fontsFamily,
                fontSize: 14,
                color: subTextColor,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => context.push('/programs'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Browse Programs',
                  style: TextStyle(
                    fontFamily: Constants.fontsFamily,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveProgramContent() {
    final progress = (_progressPct ?? 0).clamp(0.0, 100.0);

    return RefreshIndicator(
      onRefresh: _loadData,
      color: accentColor,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Program info card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
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
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _activeProgramName ??
                              _program?.name ??
                              'Training Program',
                          style: TextStyle(
                            fontFamily: Constants.fontsFamily,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: accentColor,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          if (_activeProgramId != null) {
                            context.push('/programs/$_activeProgramId');
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: blueButton.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'View Details',
                            style: TextStyle(
                              fontFamily: Constants.fontsFamily,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: blueButton,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        'Week $_currentWeek',
                        style: TextStyle(
                          fontFamily: Constants.fontsFamily,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: accentColor,
                        ),
                      ),
                      Text(
                        ' of ${_program?.durationWeeks ?? '-'}',
                        style: TextStyle(
                          fontFamily: Constants.fontsFamily,
                          fontSize: 14,
                          color: subTextColor,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${progress.toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontFamily: Constants.fontsFamily,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: greenButton,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: progress / 100,
                      backgroundColor: primaryColor,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(greenButton),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Today's workout
            Text(
              "Today's Workout",
              style: TextStyle(
                fontFamily: Constants.fontsFamily,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: accentColor,
              ),
            ),
            const SizedBox(height: 10),
            _buildTodayWorkoutCard(),
            const SizedBox(height: 24),

            // Week overview
            Text(
              'Week $_currentWeek Overview',
              style: TextStyle(
                fontFamily: Constants.fontsFamily,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: accentColor,
              ),
            ),
            const SizedBox(height: 10),
            _buildWeekOverview(),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayWorkoutCard() {
    final isRestDay = _todayWorkout?.isRestDay ?? true;
    final workoutName = _todayWorkout?.workoutName;
    final workoutId = _todayWorkout?.workoutId;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isRestDay ? Colors.white : accentColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: isRestDay
          ? Column(
              children: [
                Icon(Icons.bedtime_outlined, size: 40, color: subTextColor),
                const SizedBox(height: 10),
                Text(
                  'Rest Day',
                  style: TextStyle(
                    fontFamily: Constants.fontsFamily,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: accentColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Take it easy and recover for tomorrow.',
                  style: TextStyle(
                    fontFamily: Constants.fontsFamily,
                    fontSize: 14,
                    color: subTextColor,
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.fitness_center,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _dayNameShort(_currentDayOfWeek),
                            style: TextStyle(
                              fontFamily: Constants.fontsFamily,
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                          Text(
                            workoutName ?? 'Workout',
                            style: TextStyle(
                              fontFamily: Constants.fontsFamily,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: () {
                      if (workoutId != null) {
                        context.push('/workouts/$workoutId/session');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: greenButton,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Start Workout',
                      style: TextStyle(
                        fontFamily: Constants.fontsFamily,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildWeekOverview() {
    // Build a map of days for the current week
    final dayMap = <int, ProgramDay>{};
    for (final day in _currentWeekDays) {
      if (day.dayOfWeek != null) {
        dayMap[day.dayOfWeek!] = day;
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: List.generate(7, (index) {
          final dayNum = index + 1;
          final day = dayMap[dayNum];
          final isToday = dayNum == _currentDayOfWeek;
          final isRestDay = day?.isRestDay ?? (day == null);
          final isPast = dayNum < _currentDayOfWeek;

          return Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              border: index < 6
                  ? Border(
                      bottom: BorderSide(color: Colors.grey.shade100),
                    )
                  : null,
            ),
            child: Row(
              children: [
                // Day circle
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isToday
                        ? accentColor
                        : isPast
                            ? greenButton.withOpacity(0.15)
                            : primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: isPast && !isToday
                        ? Icon(Icons.check, size: 18, color: greenButton)
                        : Text(
                            _dayNameShort(dayNum).substring(0, 1),
                            style: TextStyle(
                              fontFamily: Constants.fontsFamily,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: isToday
                                  ? Colors.white
                                  : subTextColor,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _dayNameShort(dayNum),
                        style: TextStyle(
                          fontFamily: Constants.fontsFamily,
                          fontSize: 13,
                          fontWeight:
                              isToday ? FontWeight.w700 : FontWeight.w500,
                          color: isToday ? accentColor : subTextColor,
                        ),
                      ),
                      Text(
                        isRestDay
                            ? 'Rest Day'
                            : day?.workoutName ?? 'Workout',
                        style: TextStyle(
                          fontFamily: Constants.fontsFamily,
                          fontSize: 12,
                          color: isRestDay
                              ? subTextColor.withOpacity(0.6)
                              : blueButton,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isToday)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: greenButton.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Today',
                      style: TextStyle(
                        fontFamily: Constants.fontsFamily,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: greenButton,
                      ),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
