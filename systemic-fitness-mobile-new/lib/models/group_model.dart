class GroupModel {
  String? id;
  String? name;
  String? description;
  String? imageUrl;
  int? maxMembers;
  int? memberCount;
  String? createdBy;
  String? createdAt;
  String? updatedAt;

  GroupModel({
    this.id,
    this.name,
    this.description,
    this.imageUrl,
    this.maxMembers,
    this.memberCount,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  factory GroupModel.fromJson(Map<String, dynamic> json) => GroupModel(
        id: json['id'],
        name: json['name'],
        description: json['description'],
        imageUrl: json['image_url'],
        maxMembers: json['max_members'],
        memberCount: json['member_count'],
        createdBy: json['created_by'],
        createdAt: json['created_at'],
        updatedAt: json['updated_at'],
      );
}

class GroupMember {
  String? id;
  String? groupId;
  String? userId;
  String? fullName;
  String? email;
  String? avatarUrl;
  String? role;
  String? joinedAt;

  GroupMember({
    this.id,
    this.groupId,
    this.userId,
    this.fullName,
    this.email,
    this.avatarUrl,
    this.role,
    this.joinedAt,
  });

  factory GroupMember.fromJson(Map<String, dynamic> json) => GroupMember(
        id: json['id'],
        groupId: json['group_id'],
        userId: json['user_id'],
        fullName: json['full_name'],
        email: json['email'],
        avatarUrl: json['avatar_url'],
        role: json['role'],
        joinedAt: json['joined_at'],
      );
}
