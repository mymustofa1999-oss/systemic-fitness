class AnnouncementModel {
  String? id;
  String? title;
  String? body;
  String? imageUrl;
  String? status;
  List<String>? targetRoles;
  String? publishedAt;
  String? createdBy;
  String? createdAt;
  String? updatedAt;
  bool? isRead;

  AnnouncementModel({
    this.id,
    this.title,
    this.body,
    this.imageUrl,
    this.status,
    this.targetRoles,
    this.publishedAt,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
    this.isRead,
  });

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) =>
      AnnouncementModel(
        id: json['id'],
        title: json['title'],
        body: json['body'],
        imageUrl: json['image_url'],
        status: json['status'],
        targetRoles: (json['target_roles'] as List?)?.cast<String>(),
        publishedAt: json['published_at'],
        createdBy: json['created_by'],
        createdAt: json['created_at'],
        updatedAt: json['updated_at'],
        isRead: json['is_read'],
      );

  bool get isUnread => isRead != true;
}
