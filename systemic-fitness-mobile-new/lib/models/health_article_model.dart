class HealthArticleModel {
  String? id;
  String? title;
  String? titleEn;
  String? content;
  String? contentEn;
  String? imageUrl;
  String? source;
  bool? isPublished;
  String? createdAt;
  String? updatedAt;

  HealthArticleModel({
    this.id,
    this.title,
    this.titleEn,
    this.content,
    this.contentEn,
    this.imageUrl,
    this.source,
    this.isPublished,
    this.createdAt,
    this.updatedAt,
  });

  factory HealthArticleModel.fromJson(Map<String, dynamic> json) =>
      HealthArticleModel(
        id: json['id'],
        title: json['title'],
        titleEn: json['title_en'],
        content: json['content'],
        contentEn: json['content_en'],
        imageUrl: json['image_url'],
        source: json['source'],
        isPublished: json['is_published'],
        createdAt: json['created_at'],
        updatedAt: json['updated_at'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'title_en': titleEn,
        'content': content,
        'content_en': contentEn,
        'image_url': imageUrl,
        'source': source,
        'is_published': isPublished,
        'created_at': createdAt,
        'updated_at': updatedAt,
      };
}
