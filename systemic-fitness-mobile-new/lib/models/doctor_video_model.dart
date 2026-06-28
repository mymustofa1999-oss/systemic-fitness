class DoctorVideoModel {
  String? id;
  String? title;
  String? titleEn;
  String? description;
  String? descriptionEn;
  String? videoUrl;
  String? thumbnailUrl;
  String? doctorName;
  String? doctorSpecialty;
  bool? isPublished;
  String? createdAt;
  String? updatedAt;

  DoctorVideoModel({
    this.id,
    this.title,
    this.titleEn,
    this.description,
    this.descriptionEn,
    this.videoUrl,
    this.thumbnailUrl,
    this.doctorName,
    this.doctorSpecialty,
    this.isPublished,
    this.createdAt,
    this.updatedAt,
  });

  factory DoctorVideoModel.fromJson(Map<String, dynamic> json) =>
      DoctorVideoModel(
        id: json['id'],
        title: json['title'],
        titleEn: json['title_en'],
        description: json['description'],
        descriptionEn: json['description_en'],
        videoUrl: json['video_url'],
        thumbnailUrl: json['thumbnail_url'],
        doctorName: json['doctor_name'],
        doctorSpecialty: json['doctor_specialty'],
        isPublished: json['is_published'],
        createdAt: json['created_at'],
        updatedAt: json['updated_at'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'title_en': titleEn,
        'description': description,
        'description_en': descriptionEn,
        'video_url': videoUrl,
        'thumbnail_url': thumbnailUrl,
        'doctor_name': doctorName,
        'doctor_specialty': doctorSpecialty,
        'is_published': isPublished,
        'created_at': createdAt,
        'updated_at': updatedAt,
      };
}
