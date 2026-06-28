class DLMovementModel {
  String? id;
  String? name;
  String? nameEn;
  String? bodyPart;
  String? description;
  String? descriptionEn;
  String? videoUrlMale;
  String? videoUrlFemale;
  String? imageUrl;
  String? duration;
  List<String>? instructions;
  List<String>? instructionsEn;
  String? equipment;
  List<String>? categories;
  String? type;
  String? pattern;
  int? level;
  String? createdAt;
  String? updatedAt;

  DLMovementModel({
    this.id,
    this.name,
    this.nameEn,
    this.bodyPart,
    this.description,
    this.descriptionEn,
    this.videoUrlMale,
    this.videoUrlFemale,
    this.imageUrl,
    this.duration,
    this.instructions,
    this.instructionsEn,
    this.equipment,
    this.categories,
    this.type,
    this.pattern,
    this.level,
    this.createdAt,
    this.updatedAt,
  });

  factory DLMovementModel.fromJson(Map<String, dynamic> json) => DLMovementModel(
    id: json['id'],
    name: json['name'],
    nameEn: json['name_en'],
    bodyPart: json['body_part'],
    description: json['description'],
    descriptionEn: json['description_en'],
    videoUrlMale: json['video_url_male'],
    videoUrlFemale: json['video_url_female'],
    imageUrl: json['image_url'],
    duration: json['duration'],
    instructions: (json['instructions'] as List?)?.cast<String>(),
    instructionsEn: (json['instructions_en'] as List?)?.cast<String>(),
    equipment: json['equipment'],
    categories: (json['categories'] as List?)?.cast<String>(),
    type: json['type'],
    pattern: json['pattern'],
    level: json['level'] != null ? int.tryParse(json['level'].toString()) ?? json['level'] as int? : null,
    createdAt: json['created_at'],
    updatedAt: json['updated_at'],
  );
}
