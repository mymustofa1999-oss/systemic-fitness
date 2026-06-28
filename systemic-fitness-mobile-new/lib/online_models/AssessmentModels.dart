// Assessment request + response models for systemic-fitness-api.
//
// Manual fromJson/toJson pattern — consistent with the rest of
// lib/online_models/. Do NOT add json_serializable codegen here.

// ════════════════════════════════════════════════════════════════
//  Input side — what the mobile sends when submitting
// ════════════════════════════════════════════════════════════════

class SleepInputModel {
  double durationHours;
  int consistency;        // 1..3
  int latencyMinutes;     // 0..240
  int morningReadiness;   // 1..3
  int wakeFrequency;      // 0..10
  int preSleepHabit;      // 1..3

  SleepInputModel({
    this.durationHours = 7,
    this.consistency = 2,
    this.latencyMinutes = 15,
    this.morningReadiness = 2,
    this.wakeFrequency = 0,
    this.preSleepHabit = 2,
  });

  Map<String, dynamic> toJson() => {
    'duration_hours': durationHours,
    'consistency': consistency,
    'latency_minutes': latencyMinutes,
    'morning_readiness': morningReadiness,
    'wake_frequency': wakeFrequency,
    'pre_sleep_habit': preSleepHabit,
  };

  factory SleepInputModel.fromJson(Map<String, dynamic> json) => SleepInputModel(
    durationHours: (json['duration_hours'] as num?)?.toDouble() ?? 7,
    consistency: (json['consistency'] as num?)?.toInt() ?? 2,
    latencyMinutes: (json['latency_minutes'] as num?)?.toInt() ?? 15,
    morningReadiness: (json['morning_readiness'] as num?)?.toInt() ?? 2,
    wakeFrequency: (json['wake_frequency'] as num?)?.toInt() ?? 0,
    preSleepHabit: (json['pre_sleep_habit'] as num?)?.toInt() ?? 2,
  );
}

class MovementInputModel {
  int squat;      // 1..3
  int hipHinge;   // 1..3
  int overhead;   // 1..3

  MovementInputModel({
    this.squat = 2,
    this.hipHinge = 2,
    this.overhead = 2,
  });

  Map<String, dynamic> toJson() => {
    'squat': squat,
    'hip_hinge': hipHinge,
    'overhead': overhead,
  };

  factory MovementInputModel.fromJson(Map<String, dynamic> json) => MovementInputModel(
    squat: (json['squat'] as num?)?.toInt() ?? 2,
    hipHinge: (json['hip_hinge'] as num?)?.toInt() ?? 2,
    overhead: (json['overhead'] as num?)?.toInt() ?? 2,
  );
}

class MetabolicInputModel {
  double hbA1c;
  double ldl;
  double triglyceride;
  List<String> medications;

  MetabolicInputModel({
    this.hbA1c = 5.5,
    this.ldl = 100,
    this.triglyceride = 140,
    this.medications = const [],
  });

  Map<String, dynamic> toJson() => {
    'hba1c': hbA1c,
    'ldl': ldl,
    'triglyceride': triglyceride,
    if (medications.isNotEmpty) 'medications': medications,
  };

  factory MetabolicInputModel.fromJson(Map<String, dynamic> json) => MetabolicInputModel(
    hbA1c: (json['hba1c'] as num?)?.toDouble() ?? 5.5,
    ldl: (json['ldl'] as num?)?.toDouble() ?? 100,
    triglyceride: (json['triglyceride'] as num?)?.toDouble() ?? 140,
    medications: (json['medications'] as List?)
            ?.map((e) => e.toString())
            .toList() ??
        const [],
  );
}

// ════════════════════════════════════════════════════════════════
//  Result side — what the backend returns
// ════════════════════════════════════════════════════════════════

class AssessmentScores {
  final int sleep;
  final int recovery;
  final int movement;
  final int? metabolic;
  final int system;

  AssessmentScores({
    required this.sleep,
    required this.recovery,
    required this.movement,
    this.metabolic,
    required this.system,
  });

  factory AssessmentScores.fromJson(Map<String, dynamic> json) {
    return AssessmentScores(
      sleep: (json['sleep_score'] as num?)?.toInt() ?? 0,
      recovery: (json['recovery_score'] as num?)?.toInt() ?? 0,
      movement: (json['movement_score'] as num?)?.toInt() ?? 0,
      metabolic: (json['metabolic_score'] as num?)?.toInt(),
      system: (json['system_score'] as num?)?.toInt() ?? 0,
    );
  }
}

class AssessmentResultModel {
  final String id;
  final String? userId;
  final String tier;      // 'free' | 'paid'
  final String status;    // 'submitted' | 'verified' | 'revised'
  final AssessmentScores scores;
  final String sleepClass;
  final String movementClass;
  final String? metabolicClass;
  final List<String> flags;
  final String insight;
  final List<String> recommendations;
  final String? reviewerNotes;
  final DateTime createdAt;
  // Raw user inputs — present on detail endpoints, may be null on
  // list endpoints depending on backend payload shape.
  final SleepInputModel? sleep;
  final MovementInputModel? movement;
  final MetabolicInputModel? metabolic;

  AssessmentResultModel({
    required this.id,
    this.userId,
    required this.tier,
    required this.status,
    required this.scores,
    required this.sleepClass,
    required this.movementClass,
    this.metabolicClass,
    required this.flags,
    required this.insight,
    required this.recommendations,
    this.reviewerNotes,
    required this.createdAt,
    this.sleep,
    this.movement,
    this.metabolic,
  });

  factory AssessmentResultModel.fromJson(Map<String, dynamic> json) {
    final sleepRaw = json['sleep'];
    final movementRaw = json['movement'];
    final metabolicRaw = json['metabolic'];
    return AssessmentResultModel(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String?,
      tier: json['tier'] as String? ?? 'free',
      status: json['status'] as String? ?? 'submitted',
      scores: json['scores'] != null
          ? AssessmentScores.fromJson(json['scores'] as Map<String, dynamic>)
          : AssessmentScores(sleep: 0, recovery: 0, movement: 0, system: 0),
      sleepClass: json['sleep_class'] as String? ?? '',
      movementClass: json['movement_class'] as String? ?? '',
      metabolicClass: json['metabolic_class'] as String?,
      flags: (json['flags'] as List?)?.map((e) => e.toString()).toList() ?? [],
      insight: json['insight'] as String? ?? '',
      recommendations: (json['recommendations'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      reviewerNotes: json['reviewer_notes'] as String?,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
      sleep: sleepRaw is Map<String, dynamic>
          ? SleepInputModel.fromJson(sleepRaw)
          : null,
      movement: movementRaw is Map<String, dynamic>
          ? MovementInputModel.fromJson(movementRaw)
          : null,
      metabolic: metabolicRaw is Map<String, dynamic>
          ? MetabolicInputModel.fromJson(metabolicRaw)
          : null,
    );
  }
}
