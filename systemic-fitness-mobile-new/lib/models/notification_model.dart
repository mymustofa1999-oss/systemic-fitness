class NotificationModel {
  String? id;
  String? userId;
  String? title;
  String? body;
  String? type;
  Map<String, dynamic>? data;
  String? status;
  bool? sentViaPush;
  String? pushSentAt;
  String? readAt;
  String? createdAt;

  NotificationModel({
    this.id,
    this.userId,
    this.title,
    this.body,
    this.type,
    this.data,
    this.status,
    this.sentViaPush,
    this.pushSentAt,
    this.readAt,
    this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) => NotificationModel(
    id: json['id'],
    userId: json['user_id'],
    title: json['title'],
    body: json['body'],
    type: json['type'],
    data: json['data'] != null ? Map<String, dynamic>.from(json['data']) : null,
    status: json['status'],
    sentViaPush: json['sent_via_push'],
    pushSentAt: json['push_sent_at'],
    readAt: json['read_at'],
    createdAt: json['created_at'],
  );

  bool get isUnread => status == 'unread';
}

class BroadcastNotification {
  String? id;
  String? title;
  String? body;
  String? type;
  List<String>? targetRoles;
  String? imageUrl;
  String? scheduledAt;
  String? sentAt;
  int? sentCount;
  String? createdBy;
  String? createdAt;

  BroadcastNotification({
    this.id,
    this.title,
    this.body,
    this.type,
    this.targetRoles,
    this.imageUrl,
    this.scheduledAt,
    this.sentAt,
    this.sentCount,
    this.createdBy,
    this.createdAt,
  });

  factory BroadcastNotification.fromJson(Map<String, dynamic> json) => BroadcastNotification(
    id: json['id'],
    title: json['title'],
    body: json['body'],
    type: json['type'],
    targetRoles: (json['target_roles'] as List?)?.cast<String>(),
    imageUrl: json['image_url'],
    scheduledAt: json['scheduled_at'],
    sentAt: json['sent_at'],
    sentCount: json['sent_count'],
    createdBy: json['created_by'],
    createdAt: json['created_at'],
  );
}
