// Models for Level 5/6 guided session progress logs & workout reminders.

class WorkoutSessionLog {
  String? id;
  String? trainerCardId;
  String? sessionType; // "full" | "daily"
  String? level;
  int? durationSeconds;
  String? completedAt;

  WorkoutSessionLog({
    this.id,
    this.trainerCardId,
    this.sessionType,
    this.level,
    this.durationSeconds,
    this.completedAt,
  });

  factory WorkoutSessionLog.fromJson(Map<String, dynamic> json) => WorkoutSessionLog(
        id: json['id'],
        trainerCardId: json['trainer_card_id'],
        sessionType: json['session_type'],
        level: json['level'],
        durationSeconds: json['duration_seconds'],
        completedAt: json['completed_at'],
      );
}

class WorkoutSessionStats {
  final int totalSessions;
  final int totalSeconds;
  final int fullSessions;
  final int dailySessions;
  final int currentStreak;
  final int thisWeekCount;
  final String? lastSessionAt;

  WorkoutSessionStats({
    this.totalSessions = 0,
    this.totalSeconds = 0,
    this.fullSessions = 0,
    this.dailySessions = 0,
    this.currentStreak = 0,
    this.thisWeekCount = 0,
    this.lastSessionAt,
  });

  factory WorkoutSessionStats.fromJson(Map<String, dynamic> json) => WorkoutSessionStats(
        totalSessions: json['total_sessions'] ?? 0,
        totalSeconds: json['total_seconds'] ?? 0,
        fullSessions: json['full_sessions'] ?? 0,
        dailySessions: json['daily_sessions'] ?? 0,
        currentStreak: json['current_streak'] ?? 0,
        thisWeekCount: json['this_week_count'] ?? 0,
        lastSessionAt: json['last_session_at'],
      );
}

class WorkoutReminder {
  bool enabled;
  List<int> daysOfWeek; // 0=Sun .. 6=Sat
  String remindAt; // "HH:MM"
  String timezone;

  WorkoutReminder({
    this.enabled = false,
    List<int>? daysOfWeek,
    this.remindAt = '07:00',
    this.timezone = 'Asia/Jakarta',
  }) : daysOfWeek = daysOfWeek ?? [];

  factory WorkoutReminder.fromJson(Map<String, dynamic> json) => WorkoutReminder(
        enabled: json['enabled'] ?? false,
        daysOfWeek: (json['days_of_week'] as List?)
                ?.map((e) => (e as num).toInt())
                .toList() ??
            [],
        remindAt: json['remind_at'] ?? '07:00',
        timezone: json['timezone'] ?? 'Asia/Jakarta',
      );

  Map<String, dynamic> toJson() => {
        'enabled': enabled,
        'days_of_week': daysOfWeek,
        'remind_at': remindAt,
        'timezone': timezone,
      };
}
