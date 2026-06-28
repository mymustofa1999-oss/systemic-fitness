class Conversation {
  String? id;
  String? type;
  String? name;
  LastMessage? lastMessage;
  int? unreadCount;
  List<ConversationMember>? members;
  String? updatedAt;

  Conversation({
    this.id,
    this.type,
    this.name,
    this.lastMessage,
    this.unreadCount,
    this.members,
    this.updatedAt,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) => Conversation(
    id: json['id'],
    type: json['type'],
    name: json['name'],
    lastMessage: json['last_message'] != null ? LastMessage.fromJson(json['last_message']) : null,
    unreadCount: json['unread_count'],
    members: (json['members'] as List?)?.map((e) => ConversationMember.fromJson(e)).toList(),
    updatedAt: json['updated_at'],
  );
}

class LastMessage {
  String? content;
  String? senderName;
  String? createdAt;

  LastMessage({this.content, this.senderName, this.createdAt});

  factory LastMessage.fromJson(Map<String, dynamic> json) => LastMessage(
    content: json['content'],
    senderName: json['sender_name'],
    createdAt: json['created_at'],
  );
}

class ConversationMember {
  String? userId;
  String? fullName;
  String? avatarUrl;
  String? role;

  ConversationMember({this.userId, this.fullName, this.avatarUrl, this.role});

  factory ConversationMember.fromJson(Map<String, dynamic> json) => ConversationMember(
    userId: json['user_id'],
    fullName: json['full_name'],
    avatarUrl: json['avatar_url'],
    role: json['role'],
  );
}

class MessageModel {
  String? id;
  String? conversationId;
  String? senderId;
  String? senderName;
  String? senderAvatar;
  String? content;
  String? type;
  String? mediaUrl;
  bool? isRead;
  String? createdAt;

  MessageModel({
    this.id,
    this.conversationId,
    this.senderId,
    this.senderName,
    this.senderAvatar,
    this.content,
    this.type,
    this.mediaUrl,
    this.isRead,
    this.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) => MessageModel(
    id: json['id'],
    conversationId: json['conversation_id'],
    senderId: json['sender_id'],
    senderName: json['sender_name'],
    senderAvatar: json['sender_avatar'],
    content: json['content'],
    type: json['type'],
    mediaUrl: json['media_url'],
    isRead: json['is_read'],
    createdAt: json['created_at'],
  );
}
