class ProgramModel {
  String? id;
  String? name;
  String? description;
  int? durationWeeks;
  String? difficulty;
  String? goal;
  String? createdBy;
  bool? isTemplate;
  String? createdAt;
  List<ProgramDay>? days;

  ProgramModel({
    this.id,
    this.name,
    this.description,
    this.durationWeeks,
    this.difficulty,
    this.goal,
    this.createdBy,
    this.isTemplate,
    this.createdAt,
    this.days,
  });

  factory ProgramModel.fromJson(Map<String, dynamic> json) => ProgramModel(
    id: json['id'],
    name: json['name'],
    description: json['description'],
    durationWeeks: json['duration_weeks'],
    difficulty: json['difficulty'],
    goal: json['goal'],
    createdBy: json['created_by'],
    isTemplate: json['is_template'],
    createdAt: json['created_at'],
    days: (json['days'] as List?)?.map((e) => ProgramDay.fromJson(e)).toList(),
  );
}

class ProgramDay {
  String? id;
  int? weekNumber;
  int? dayOfWeek;
  String? workoutId;
  String? workoutName;
  String? workoutType;
  bool? isRestDay;

  ProgramDay({
    this.id,
    this.weekNumber,
    this.dayOfWeek,
    this.workoutId,
    this.workoutName,
    this.workoutType,
    this.isRestDay,
  });

  factory ProgramDay.fromJson(Map<String, dynamic> json) => ProgramDay(
    id: json['id'],
    weekNumber: json['week_number'],
    dayOfWeek: json['day_of_week'],
    workoutId: json['workout_id'],
    workoutName: json['workout_name'],
    workoutType: json['workout_type'],
    isRestDay: json['is_rest_day'],
  );
}

class UserProgram {
  String? id;
  String? userId;
  String? programId;
  String? assignedBy;
  String? startDate;
  String? endDate;
  String? status;
  int? currentWeek;
  int? currentDay;

  UserProgram({
    this.id,
    this.userId,
    this.programId,
    this.assignedBy,
    this.startDate,
    this.endDate,
    this.status,
    this.currentWeek,
    this.currentDay,
  });

  factory UserProgram.fromJson(Map<String, dynamic> json) => UserProgram(
    id: json['id'],
    userId: json['user_id'],
    programId: json['program_id'],
    assignedBy: json['assigned_by'],
    startDate: json['start_date'],
    endDate: json['end_date'],
    status: json['status'],
    currentWeek: json['current_week'],
    currentDay: json['current_day'],
  );
}
