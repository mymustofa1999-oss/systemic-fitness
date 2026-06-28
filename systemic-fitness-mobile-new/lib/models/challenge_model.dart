class ChallengeModel {
  String? id;
  String? name;
  String? description;
  String? imageUrl;
  String? status;
  String? startDate;
  String? endDate;
  String? goalType;
  double? goalValue;
  int? maxParticipants;
  String? createdBy;
  String? createdAt;
  String? updatedAt;
  int? participantCount;

  ChallengeModel({
    this.id,
    this.name,
    this.description,
    this.imageUrl,
    this.status,
    this.startDate,
    this.endDate,
    this.goalType,
    this.goalValue,
    this.maxParticipants,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
    this.participantCount,
  });

  factory ChallengeModel.fromJson(Map<String, dynamic> json) => ChallengeModel(
        id: json['id'],
        name: json['name'],
        description: json['description'],
        imageUrl: json['image_url'],
        status: json['status'],
        startDate: json['start_date'],
        endDate: json['end_date'],
        goalType: json['goal_type'],
        goalValue: (json['goal_value'] as num?)?.toDouble(),
        maxParticipants: json['max_participants'],
        createdBy: json['created_by'],
        createdAt: json['created_at'],
        updatedAt: json['updated_at'],
        participantCount: json['participant_count'],
      );

  bool get isActive => status == 'active';

  int get daysRemaining {
    if (endDate == null) return 0;
    final end = DateTime.tryParse(endDate!);
    if (end == null) return 0;
    return end.difference(DateTime.now()).inDays.clamp(0, 9999);
  }
}

class ChallengeParticipant {
  String? id;
  String? challengeId;
  String? userId;
  String? fullName;
  String? avatarUrl;
  double? progressValue;
  String? joinedAt;
  String? completedAt;

  ChallengeParticipant({
    this.id,
    this.challengeId,
    this.userId,
    this.fullName,
    this.avatarUrl,
    this.progressValue,
    this.joinedAt,
    this.completedAt,
  });

  factory ChallengeParticipant.fromJson(Map<String, dynamic> json) =>
      ChallengeParticipant(
        id: json['id'],
        challengeId: json['challenge_id'],
        userId: json['user_id'],
        fullName: json['full_name'],
        avatarUrl: json['avatar_url'],
        progressValue: (json['progress_value'] as num?)?.toDouble(),
        joinedAt: json['joined_at'],
        completedAt: json['completed_at'],
      );
}
