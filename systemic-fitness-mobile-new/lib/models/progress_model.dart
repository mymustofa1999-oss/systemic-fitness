class ProgressLog {
  String? id;
  String? exerciseId;
  String? exerciseName;
  String? workoutId;
  String? loggedAt;
  List<SetData>? sets;
  String? notes;
  String? mood;

  ProgressLog({
    this.id,
    this.exerciseId,
    this.exerciseName,
    this.workoutId,
    this.loggedAt,
    this.sets,
    this.notes,
    this.mood,
  });

  factory ProgressLog.fromJson(Map<String, dynamic> json) => ProgressLog(
    id: json['id'],
    exerciseId: json['exercise_id'],
    exerciseName: json['exercise_name'],
    workoutId: json['workout_id'],
    loggedAt: json['logged_at'],
    sets: (json['sets'] as List?)?.map((e) => SetData.fromJson(e)).toList(),
    notes: json['notes'],
    mood: json['mood'],
  );
}

class SetData {
  int? setNumber;
  int? reps;
  double? weightKg;
  int? durationSec;
  int? rpe;
  bool? completed;

  SetData({
    this.setNumber,
    this.reps,
    this.weightKg,
    this.durationSec,
    this.rpe,
    this.completed,
  });

  factory SetData.fromJson(Map<String, dynamic> json) => SetData(
    setNumber: json['set_number'],
    reps: json['reps'],
    weightKg: (json['weight_kg'] as num?)?.toDouble(),
    durationSec: json['duration_sec'],
    rpe: json['rpe'],
    completed: json['completed'],
  );

  Map<String, dynamic> toJson() => {
    'set_number': setNumber,
    'reps': reps,
    'weight_kg': weightKg,
    'duration_sec': durationSec,
    'rpe': rpe,
    'completed': completed,
  };
}

class BodyMetric {
  String? id;
  String? loggedAt;
  double? weightKg;
  double? bodyFatPct;
  double? muscleMassKg;
  List<String>? photoUrls;
  String? notes;

  BodyMetric({
    this.id,
    this.loggedAt,
    this.weightKg,
    this.bodyFatPct,
    this.muscleMassKg,
    this.photoUrls,
    this.notes,
  });

  factory BodyMetric.fromJson(Map<String, dynamic> json) => BodyMetric(
    id: json['id'],
    loggedAt: json['logged_at'],
    weightKg: (json['weight_kg'] as num?)?.toDouble(),
    bodyFatPct: (json['body_fat_pct'] as num?)?.toDouble(),
    muscleMassKg: (json['muscle_mass_kg'] as num?)?.toDouble(),
    photoUrls: (json['photo_urls'] as List?)?.cast<String>(),
    notes: json['notes'],
  );
}

class ChartDataPoint {
  String? date;
  double? value;

  ChartDataPoint({this.date, this.value});

  factory ChartDataPoint.fromJson(Map<String, dynamic> json) => ChartDataPoint(
    date: json['date'],
    value: (json['value'] as num?)?.toDouble(),
  );
}
