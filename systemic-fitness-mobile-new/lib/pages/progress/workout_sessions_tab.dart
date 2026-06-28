import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:workout/ColorCategory.dart';
import 'package:workout/Constants.dart';
import 'package:workout/data/api_config.dart';
import 'package:workout/data/api_service.dart';
import 'package:workout/online_models/WorkoutSession.dart';
import 'package:workout/widgets/loading_widget.dart';

const List<String> _dayLabels = ['Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab'];

String _formatDuration(int totalSeconds) {
  final m = totalSeconds ~/ 60;
  final h = m ~/ 60;
  final rem = m % 60;
  if (h > 0) return '${h}j ${rem}m';
  return '$m mnt';
}

String _formatDate(String? iso) {
  if (iso == null) return '';
  try {
    final d = DateTime.parse(iso).toLocal();
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  } catch (_) {
    return iso;
  }
}

class WorkoutSessionsTab extends StatefulWidget {
  const WorkoutSessionsTab({super.key});

  @override
  State<WorkoutSessionsTab> createState() => _WorkoutSessionsTabState();
}

class _WorkoutSessionsTabState extends State<WorkoutSessionsTab> {
  bool _loading = true;
  String _filter = 'all'; // all | full | daily

  WorkoutSessionStats _stats = WorkoutSessionStats();
  List<WorkoutSessionLog> _sessions = [];

  // Reminder local state
  WorkoutReminder _reminder = WorkoutReminder();
  bool _savingReminder = false;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() => _loading = true);
    await Future.wait([_fetchStats(), _fetchSessions(), _fetchReminder()]);
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _fetchStats() async {
    try {
      final res = await ApiService.getWithRetry(ApiConfig.workoutSessionStats);
      final data = res['data'];
      if (data is Map<String, dynamic> && mounted) {
        setState(() => _stats = WorkoutSessionStats.fromJson(data));
      }
    } catch (_) {/* keep defaults */}
  }

  Future<void> _fetchSessions() async {
    try {
      final res = await ApiService.getWithRetry(
        ApiConfig.workoutSessions,
        queryParams: {
          if (_filter != 'all') 'session_type': _filter,
          'limit': '50',
        },
      );
      final data = res['data'];
      final List<WorkoutSessionLog> list = [];
      if (data is List) {
        for (final item in data) {
          list.add(WorkoutSessionLog.fromJson(item));
        }
      }
      if (mounted) setState(() => _sessions = list);
    } catch (_) {
      if (mounted) setState(() => _sessions = []);
    }
  }

  Future<void> _fetchReminder() async {
    try {
      final res = await ApiService.getWithRetry(ApiConfig.workoutReminder);
      final data = res['data'];
      if (data is Map<String, dynamic> && mounted) {
        setState(() => _reminder = WorkoutReminder.fromJson(data));
      }
    } catch (_) {/* keep defaults */}
  }

  Future<void> _saveReminder() async {
    setState(() => _savingReminder = true);
    try {
      await ApiService.putWithRetry(
        ApiConfig.workoutReminder,
        body: _reminder.toJson(),
      );
      Fluttertoast.showToast(msg: 'Pengaturan reminder disimpan.');
    } catch (e) {
      Fluttertoast.showToast(msg: 'Gagal menyimpan reminder.');
    } finally {
      if (mounted) setState(() => _savingReminder = false);
    }
  }

  Future<void> _pickTime() async {
    final parts = _reminder.remindAt.split(':');
    final initial = TimeOfDay(
      hour: int.tryParse(parts.isNotEmpty ? parts[0] : '7') ?? 7,
      minute: int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0,
    );
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked != null) {
      setState(() {
        _reminder.remindAt =
            '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: LoadingWidget());
    }
    return RefreshIndicator(
      onRefresh: _loadAll,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildStatsRow(),
          const SizedBox(height: 16),
          _buildReminderCard(),
          const SizedBox(height: 16),
          _buildFilterChips(),
          const SizedBox(height: 12),
          ..._buildHistory(),
        ],
      ),
    );
  }

  // ── Stats ──────────────────────────────────────────────────────────

  Widget _buildStatsRow() {
    return Row(
      children: [
        _statCard(Icons.local_fire_department, '${_stats.currentStreak}', 'Beruntun'),
        const SizedBox(width: 10),
        _statCard(Icons.fitness_center, '${_stats.totalSessions}', 'Total Sesi'),
        const SizedBox(width: 10),
        _statCard(Icons.timer_outlined, _formatDuration(_stats.totalSeconds), 'Total Waktu'),
        const SizedBox(width: 10),
        _statCard(Icons.calendar_today, '${_stats.thisWeekCount}', 'Minggu Ini'),
      ],
    );
  }

  Widget _statCard(IconData icon, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: kSfWarmGold, size: 20),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontFamily: Constants.fontsFamily,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: accentColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: Constants.fontsFamily,
                fontSize: 9,
                color: subTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Reminder ───────────────────────────────────────────────────────

  Widget _buildReminderCard() {
    final enabled = _reminder.enabled;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: kSfWarmGold.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.notifications_active_outlined, color: kSfWarmGold, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reminder Latihan',
                      style: TextStyle(
                        fontFamily: Constants.fontsFamily,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: accentColor,
                      ),
                    ),
                    Text(
                      'Ingatkan saya sesuai jadwal',
                      style: TextStyle(
                        fontFamily: Constants.fontsFamily,
                        fontSize: 11,
                        color: subTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: enabled,
                activeColor: kSfWarmGold,
                onChanged: (v) => setState(() => _reminder.enabled = v),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Opacity(
            opacity: enabled ? 1 : 0.5,
            child: IgnorePointer(
              ignoring: !enabled,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: List.generate(7, (idx) {
                      final active = _reminder.daysOfWeek.contains(idx);
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(right: idx < 6 ? 6 : 0),
                          child: GestureDetector(
                            onTap: () => setState(() {
                              if (active) {
                                _reminder.daysOfWeek.remove(idx);
                              } else {
                                _reminder.daysOfWeek.add(idx);
                                _reminder.daysOfWeek.sort();
                              }
                            }),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: active ? kSfWarmGold : Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: active ? kSfWarmGold : borderColor),
                              ),
                              child: Text(
                                _dayLabels[idx],
                                style: TextStyle(
                                  fontFamily: Constants.fontsFamily,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: active ? Colors.white : subTextColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Jam pengingat',
                        style: TextStyle(
                          fontFamily: Constants.fontsFamily,
                          fontSize: 13,
                          color: accentColor,
                        ),
                      ),
                      GestureDetector(
                        onTap: _pickTime,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: borderColor),
                          ),
                          child: Text(
                            _reminder.remindAt,
                            style: TextStyle(
                              fontFamily: Constants.fontsFamily,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: accentColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kSfWarmGold,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _savingReminder ? null : _saveReminder,
              child: _savingReminder
                  ? const SizedBox(
                      width: 18, height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text(
                      'Simpan Reminder',
                      style: TextStyle(
                        fontFamily: Constants.fontsFamily,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Filter + History ───────────────────────────────────────────────

  Widget _buildFilterChips() {
    Widget chip(String key, String label) {
      final active = _filter == key;
      return GestureDetector(
        onTap: () {
          if (_filter == key) return;
          setState(() => _filter = key);
          _fetchSessions();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: active ? kSfWarmGold : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: active ? kSfWarmGold : borderColor),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: Constants.fontsFamily,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: active ? Colors.white : subTextColor,
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        chip('all', 'Semua'),
        const SizedBox(width: 8),
        chip('full', 'Full Program'),
        const SizedBox(width: 8),
        chip('daily', 'Daily Reset'),
      ],
    );
  }

  List<Widget> _buildHistory() {
    if (_sessions.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.only(top: 32),
          child: Column(
            children: [
              Icon(Icons.event_note_outlined, color: subTextColor, size: 40),
              const SizedBox(height: 12),
              Text(
                'Belum Ada Sesi',
                style: TextStyle(
                  fontFamily: Constants.fontsFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: accentColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Selesaikan sesi di Training Card dan tekan "Akhiri Sesi".',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: Constants.fontsFamily,
                  fontSize: 12,
                  color: subTextColor,
                ),
              ),
            ],
          ),
        ),
      ];
    }

    return _sessions.map((s) {
      final isFull = s.sessionType == 'full';
      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: kSfWarmGold.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.fitness_center, color: kSfWarmGold, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isFull ? 'Full Program' : 'Daily Reset',
                    style: TextStyle(
                      fontFamily: Constants.fontsFamily,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: accentColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatDate(s.completedAt),
                    style: TextStyle(
                      fontFamily: Constants.fontsFamily,
                      fontSize: 12,
                      color: subTextColor,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Icon(Icons.timer_outlined, color: kSfWarmGold, size: 14),
                const SizedBox(width: 4),
                Text(
                  _formatDuration(s.durationSeconds ?? 0),
                  style: TextStyle(
                    fontFamily: Constants.fontsFamily,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: kSfWarmGold,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }).toList();
  }
}
