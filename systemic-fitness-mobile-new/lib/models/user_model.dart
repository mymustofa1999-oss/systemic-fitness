class UserModel {
  String? id;
  String? email;
  String? fullName;
  String? phone;
  String? avatarUrl;
  String? role;
  String? status;
  String? timezone;
  String? createdAt;
  UserProfile? profile;
  UserStats? stats;

  UserModel({
    this.id,
    this.email,
    this.fullName,
    this.phone,
    this.avatarUrl,
    this.role,
    this.status,
    this.timezone,
    this.createdAt,
    this.profile,
    this.stats,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'],
    email: json['email'],
    fullName: json['full_name'],
    phone: json['phone'],
    avatarUrl: json['avatar_url'],
    role: json['role'],
    status: json['status'],
    timezone: json['timezone'],
    createdAt: json['created_at'],
    profile: json['profile'] != null ? UserProfile.fromJson(json['profile']) : null,
    stats: json['stats'] != null ? UserStats.fromJson(json['stats']) : null,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'full_name': fullName,
    'phone': phone,
    'avatar_url': avatarUrl,
    'role': role,
    'status': status,
    'timezone': timezone,
    'created_at': createdAt,
    if (profile != null) 'profile': profile!.toJson(),
    if (stats != null) 'stats': {
      'total_workouts': stats!.totalWorkouts,
      'workouts_this_week': stats!.workoutsThisWeek,
      'workouts_this_month': stats!.workoutsThisMonth,
      'current_streak_days': stats!.currentStreakDays,
      'longest_streak_days': stats!.longestStreakDays,
      'total_exercise_minutes': stats!.totalExerciseMinutes,
      'active_program_name': stats!.activeProgramName,
      'active_program_id': stats!.activeProgramId,
      'program_progress_pct': stats!.programProgressPct,
      'last_workout_at': stats!.lastWorkoutAt,
    },
  };
}

class UserProfile {
  String? dateOfBirth;
  String? gender;
  double? heightCm;
  double? weightKg;
  String? fitnessGoal;
  String? experienceLevel;
  String? medicalNotes;
  String? emergencyContact;

  UserProfile({
    this.dateOfBirth,
    this.gender,
    this.heightCm,
    this.weightKg,
    this.fitnessGoal,
    this.experienceLevel,
    this.medicalNotes,
    this.emergencyContact,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    dateOfBirth: json['date_of_birth'],
    gender: json['gender'],
    heightCm: (json['height_cm'] as num?)?.toDouble(),
    weightKg: (json['weight_kg'] as num?)?.toDouble(),
    fitnessGoal: json['fitness_goal'],
    experienceLevel: json['experience_level'],
    medicalNotes: json['medical_notes'],
    emergencyContact: json['emergency_contact'],
  );

  Map<String, dynamic> toJson() => {
    'date_of_birth': dateOfBirth,
    'gender': gender,
    'height_cm': heightCm,
    'weight_kg': weightKg,
    'fitness_goal': fitnessGoal,
    'experience_level': experienceLevel,
    'medical_notes': medicalNotes,
    'emergency_contact': emergencyContact,
  };
}

class UserStats {
  int? totalWorkouts;
  int? workoutsThisWeek;
  int? workoutsThisMonth;
  int? currentStreakDays;
  int? longestStreakDays;
  int? totalExerciseMinutes;
  String? activeProgramName;
  String? activeProgramId;
  double? programProgressPct;
  String? lastWorkoutAt;

  UserStats({
    this.totalWorkouts,
    this.workoutsThisWeek,
    this.workoutsThisMonth,
    this.currentStreakDays,
    this.longestStreakDays,
    this.totalExerciseMinutes,
    this.activeProgramName,
    this.activeProgramId,
    this.programProgressPct,
    this.lastWorkoutAt,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) => UserStats(
    totalWorkouts: json['total_workouts'],
    workoutsThisWeek: json['workouts_this_week'],
    workoutsThisMonth: json['workouts_this_month'],
    currentStreakDays: json['current_streak_days'],
    longestStreakDays: json['longest_streak_days'],
    totalExerciseMinutes: json['total_exercise_minutes'],
    activeProgramName: json['active_program_name'],
    activeProgramId: json['active_program_id'],
    programProgressPct: (json['program_progress_pct'] as num?)?.toDouble(),
    lastWorkoutAt: json['last_workout_at'],
  );
}
