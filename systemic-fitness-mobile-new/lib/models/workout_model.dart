class WorkoutModel {
  String? id;
  String? name;
  String? description;
  String? type;
  int? estimatedDurationMin;
  String? createdBy;
  bool? isTemplate;
  String? createdAt;
  List<WorkoutExercise>? exercises;

  WorkoutModel({
    this.id,
    this.name,
    this.description,
    this.type,
    this.estimatedDurationMin,
    this.createdBy,
    this.isTemplate,
    this.createdAt,
    this.exercises,
  });

  factory WorkoutModel.fromJson(Map<String, dynamic> json) => WorkoutModel(
    id: json['id'],
    name: json['name'],
    description: json['description'],
    type: json['type'],
    estimatedDurationMin: json['estimated_duration_min'],
    createdBy: json['created_by'],
    isTemplate: json['is_template'],
    createdAt: json['created_at'],
    exercises: (json['exercises'] as List?)?.map((e) => WorkoutExercise.fromJson(e)).toList(),
  );
}

class WorkoutExercise {
  String? id;
  String? exerciseId;
  String? exerciseName;
  List<String>? muscleGroup;
  String? equipment;
  int? orderIndex;
  int? sets;
  String? reps;
  double? weightKg;
  int? restSeconds;
  String? notes;
  int? supersetGroup;

  WorkoutExercise({
    this.id,
    this.exerciseId,
    this.exerciseName,
    this.muscleGroup,
    this.equipment,
    this.orderIndex,
    this.sets,
    this.reps,
    this.weightKg,
    this.restSeconds,
    this.notes,
    this.supersetGroup,
  });

  factory WorkoutExercise.fromJson(Map<String, dynamic> json) => WorkoutExercise(
    id: json['id'],
    exerciseId: json['exercise_id'],
    exerciseName: json['exercise_name'],
    muscleGroup: (json['muscle_group'] as List?)?.cast<String>(),
    equipment: json['equipment'],
    orderIndex: json['order_index'],
    sets: json['sets'],
    reps: json['reps']?.toString(),
    weightKg: (json['weight_kg'] as num?)?.toDouble(),
    restSeconds: json['rest_seconds'],
    notes: json['notes'],
    supersetGroup: json['superset_group'],
  );
}
