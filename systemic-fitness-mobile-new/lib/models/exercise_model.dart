class ExerciseModel {
  String? id;
  String? name;
  String? description;
  List<String>? muscleGroup;
  String? equipment;
  String? difficulty;
  String? videoUrl;
  String? thumbnailUrl;
  List<String>? instructions;
  bool? isSystem;
  String? createdBy;
  String? createdAt;

  ExerciseModel({
    this.id,
    this.name,
    this.description,
    this.muscleGroup,
    this.equipment,
    this.difficulty,
    this.videoUrl,
    this.thumbnailUrl,
    this.instructions,
    this.isSystem,
    this.createdBy,
    this.createdAt,
  });

  factory ExerciseModel.fromJson(Map<String, dynamic> json) => ExerciseModel(
    id: json['id'],
    name: json['name'],
    description: json['description'],
    muscleGroup: (json['muscle_group'] as List?)?.cast<String>(),
    equipment: json['equipment'],
    difficulty: json['difficulty'],
    videoUrl: json['video_url'],
    thumbnailUrl: json['thumbnail_url'],
    instructions: (json['instructions'] as List?)?.cast<String>(),
    isSystem: json['is_system'],
    createdBy: json['created_by'],
    createdAt: json['created_at'],
  );
}
