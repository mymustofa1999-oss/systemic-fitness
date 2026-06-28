// SF Assessment v2 — Phase A/B/C, Chronobiology Window, System Score 35/35/30.
//
// Manual fromJson/toJson — konsisten dengan AssessmentModels.dart (v1).
// Reference: SF_Master_Platform_Spec.docx §03 + halaman 333–456.

// ═══════════════════════════════════════════════════════════════════
//  Master data (read-only) — fetched dari /api/master/*.
// ═══════════════════════════════════════════════════════════════════

class ConditionClassificationModel {
  final String id;
  final String slug;
  final String label;
  final String? description;
  final String focusPillar; // 'FC' | 'CC' | 'MC'

  ConditionClassificationModel({
    required this.id,
    required this.slug,
    required this.label,
    required this.focusPillar,
    this.description,
  });

  factory ConditionClassificationModel.fromJson(Map<String, dynamic> json) =>
      ConditionClassificationModel(
        id: json['id'] as String,
        slug: json['slug'] as String,
        label: json['label'] as String,
        description: json['description'] as String?,
        focusPillar: (json['focus_pillar'] as String?) ?? 'FC',
      );
}

class SpecificConditionModel {
  final String id;
  final String classificationId;
  final String? classificationSlug;
  final String slug;
  final String label;
  final String? description;
  final String? severityDefault; // mild | moderate | severe | monitor

  SpecificConditionModel({
    required this.id,
    required this.classificationId,
    required this.slug,
    required this.label,
    this.classificationSlug,
    this.description,
    this.severityDefault,
  });

  factory SpecificConditionModel.fromJson(Map<String, dynamic> json) =>
      SpecificConditionModel(
        id: json['id'] as String,
        classificationId: json['classification_id'] as String,
        classificationSlug: json['classification_slug'] as String?,
        slug: json['slug'] as String,
        label: json['label'] as String,
        description: json['description'] as String?,
        severityDefault: json['severity_default'] as String?,
      );
}

class PhysicalStatusLevelModel {
  final String id;
  final String slug;
  final String label;
  final String? description;
  final String routing; // 'waitlist' | 'preventive_movement_test' | 'continue'
  final String? waitlistMessage;

  PhysicalStatusLevelModel({
    required this.id,
    required this.slug,
    required this.label,
    required this.routing,
    this.description,
    this.waitlistMessage,
  });

  factory PhysicalStatusLevelModel.fromJson(Map<String, dynamic> json) =>
      PhysicalStatusLevelModel(
        id: json['id'] as String,
        slug: json['slug'] as String,
        label: json['label'] as String,
        description: json['description'] as String?,
        routing: (json['routing'] as String?) ?? 'continue',
        waitlistMessage: json['waitlist_message'] as String?,
      );
}

// ═══════════════════════════════════════════════════════════════════
//  Phase A — input
// ═══════════════════════════════════════════════════════════════════

class PhaseAMovementTest {
  int squat;    // 0..2
  int hipHinge; // 0..2
  int overhead; // 0..2

  PhaseAMovementTest({
    this.squat = 0,
    this.hipHinge = 0,
    this.overhead = 0,
  });

  int get total => squat + hipHinge + overhead;

  Map<String, dynamic> toJson() => {
        'squat': squat,
        'hip_hinge': hipHinge,
        'overhead': overhead,
      };

  factory PhaseAMovementTest.fromJson(Map<String, dynamic> json) =>
      PhaseAMovementTest(
        squat: (json['squat'] as num?)?.toInt() ?? 0,
        hipHinge: (json['hip_hinge'] as num?)?.toInt() ?? 0,
        overhead: (json['overhead'] as num?)?.toInt() ?? 0,
      );
}

class PhaseAInput {
  // Q1: 'level_0_1' | 'level_2_3' | 'level_4_5_perf'
  String physicalStatusLevel;

  // Q2 branching
  bool hasMedicalCondition;
  String? classificationSlug;     // when hasMedicalCondition = true
  String? specificConditionSlug;  // when hasMedicalCondition = true
  String? seriousConditionNote;
  String? gender;                 // 'women' | 'men' (when no medical)
  String? ageBucket;              // '35_45' | '46_60' (when no medical)

  // Q3: 'control_medical' | 'hormonal_feminine' | 'stamina_masculine'
  String? primaryGoal;

  // Movement test (preventive path = Level 4-5 + no medical)
  PhaseAMovementTest? movementTest;

  PhaseAInput({
    this.physicalStatusLevel = 'level_4_5_perf',
    this.hasMedicalCondition = false,
    this.classificationSlug,
    this.specificConditionSlug,
    this.seriousConditionNote,
    this.gender,
    this.ageBucket,
    this.primaryGoal,
    this.movementTest,
  });

  Map<String, dynamic> toJson() {
    final m = <String, dynamic>{
      'physical_status_level': physicalStatusLevel,
      'has_medical_condition': hasMedicalCondition,
    };
    if (classificationSlug != null) m['classification_slug'] = classificationSlug;
    if (specificConditionSlug != null) m['specific_condition_slug'] = specificConditionSlug;
    if (seriousConditionNote != null && seriousConditionNote!.isNotEmpty) {
      m['serious_condition_note'] = seriousConditionNote;
    }
    if (gender != null) m['gender'] = gender;
    if (ageBucket != null) m['age_bucket'] = ageBucket;
    if (primaryGoal != null) m['primary_goal'] = primaryGoal;
    if (movementTest != null) m['movement_test'] = movementTest!.toJson();
    return m;
  }

  factory PhaseAInput.fromJson(Map<String, dynamic> json) => PhaseAInput(
        physicalStatusLevel: (json['physical_status_level'] as String?) ?? 'level_4_5_perf',
        hasMedicalCondition: (json['has_medical_condition'] as bool?) ?? false,
        classificationSlug: json['classification_slug'] as String?,
        specificConditionSlug: json['specific_condition_slug'] as String?,
        seriousConditionNote: json['serious_condition_note'] as String?,
        gender: json['gender'] as String?,
        ageBucket: json['age_bucket'] as String?,
        primaryGoal: json['primary_goal'] as String?,
        movementTest: json['movement_test'] != null
            ? PhaseAMovementTest.fromJson(
                json['movement_test'] as Map<String, dynamic>)
            : null,
      );
}

// ═══════════════════════════════════════════════════════════════════
//  Phase B — input (Rest Audit + Chronobiology)
// ═══════════════════════════════════════════════════════════════════

class PhaseBInput {
  double durationHours;       // 4.0..10.0
  int consistency;            // 1..3
  int sleepLatency;           // 1..4
  int morningReadiness;       // 1..3
  int wakeFrequency;          // 1..4
  int preSleepHabit;          // 1..3
  int bedtimeBucket;          // 1..5
  int wakeTimeBucket;         // 1..5
  String activityProfile;     // executive | creative | traveller | homemaker | shift_worker | mixed
  int dinnerTime;             // 1..5

  PhaseBInput({
    this.durationHours = 7.0,
    this.consistency = 2,
    this.sleepLatency = 2,
    this.morningReadiness = 2,
    this.wakeFrequency = 1,
    this.preSleepHabit = 2,
    this.bedtimeBucket = 3,
    this.wakeTimeBucket = 3,
    this.activityProfile = 'executive',
    this.dinnerTime = 2,
  });

  Map<String, dynamic> toJson() => {
        'duration_hours': durationHours,
        'consistency': consistency,
        'sleep_latency': sleepLatency,
        'morning_readiness': morningReadiness,
        'wake_frequency': wakeFrequency,
        'pre_sleep_habit': preSleepHabit,
        'bedtime_bucket': bedtimeBucket,
        'wake_time_bucket': wakeTimeBucket,
        'activity_profile': activityProfile,
        'dinner_time': dinnerTime,
      };

  factory PhaseBInput.fromJson(Map<String, dynamic> json) => PhaseBInput(
        durationHours: (json['duration_hours'] as num?)?.toDouble() ?? 7.0,
        consistency: (json['consistency'] as num?)?.toInt() ?? 2,
        sleepLatency: (json['sleep_latency'] as num?)?.toInt() ?? 2,
        morningReadiness: (json['morning_readiness'] as num?)?.toInt() ?? 2,
        wakeFrequency: (json['wake_frequency'] as num?)?.toInt() ?? 1,
        preSleepHabit: (json['pre_sleep_habit'] as num?)?.toInt() ?? 2,
        bedtimeBucket: (json['bedtime_bucket'] as num?)?.toInt() ?? 3,
        wakeTimeBucket: (json['wake_time_bucket'] as num?)?.toInt() ?? 3,
        activityProfile: (json['activity_profile'] as String?) ?? 'executive',
        dinnerTime: (json['dinner_time'] as num?)?.toInt() ?? 2,
      );
}

// ═══════════════════════════════════════════════════════════════════
//  Phase C — input (Nutrition Assessment)
// ═══════════════════════════════════════════════════════════════════

class PhaseCInput {
  int mealPattern;          // 1..5
  int foodDominance;        // 1..5
  int hydration;            // 1..4
  List<String> routineFoods;
  List<String> restrictions;
  String? restrictionNote;
  List<String> supplements;
  String? supplementNote;
  String nutritionGoal;     // blood_sugar | anti_inflammation | energy_vitality | hormonal_balance | weight | muscle_recovery | organ_health

  PhaseCInput({
    this.mealPattern = 1,
    this.foodDominance = 4,
    this.hydration = 3,
    this.routineFoods = const [],
    this.restrictions = const [],
    this.restrictionNote,
    this.supplements = const [],
    this.supplementNote,
    this.nutritionGoal = 'energy_vitality',
  });

  Map<String, dynamic> toJson() {
    final m = <String, dynamic>{
      'meal_pattern': mealPattern,
      'food_dominance': foodDominance,
      'hydration': hydration,
      'nutrition_goal': nutritionGoal,
    };
    if (routineFoods.isNotEmpty) m['routine_foods'] = routineFoods;
    if (restrictions.isNotEmpty) m['restrictions'] = restrictions;
    if (restrictionNote != null && restrictionNote!.isNotEmpty) {
      m['restriction_note'] = restrictionNote;
    }
    if (supplements.isNotEmpty) m['supplements'] = supplements;
    if (supplementNote != null && supplementNote!.isNotEmpty) {
      m['supplement_note'] = supplementNote;
    }
    return m;
  }

  factory PhaseCInput.fromJson(Map<String, dynamic> json) => PhaseCInput(
        mealPattern: (json['meal_pattern'] as num?)?.toInt() ?? 1,
        foodDominance: (json['food_dominance'] as num?)?.toInt() ?? 4,
        hydration: (json['hydration'] as num?)?.toInt() ?? 3,
        routineFoods: ((json['routine_foods'] as List?) ?? const [])
            .map((e) => e.toString())
            .toList(),
        restrictions: ((json['restrictions'] as List?) ?? const [])
            .map((e) => e.toString())
            .toList(),
        restrictionNote: json['restriction_note'] as String?,
        supplements: ((json['supplements'] as List?) ?? const [])
            .map((e) => e.toString())
            .toList(),
        supplementNote: json['supplement_note'] as String?,
        nutritionGoal:
            (json['nutrition_goal'] as String?) ?? 'energy_vitality',
      );
}

// ═══════════════════════════════════════════════════════════════════
//  Output — Chronobiology + Result
// ═══════════════════════════════════════════════════════════════════

class ChronobiologyWindow {
  final String idealStart;
  final String idealEnd;
  final String? altStart;
  final String? altEnd;
  final String? avoid;
  final String? overrideReason;
  final String? hardCap;

  ChronobiologyWindow({
    required this.idealStart,
    required this.idealEnd,
    this.altStart,
    this.altEnd,
    this.avoid,
    this.overrideReason,
    this.hardCap,
  });

  factory ChronobiologyWindow.fromJson(Map<String, dynamic> json) =>
      ChronobiologyWindow(
        idealStart: (json['ideal_start'] as String?) ?? '',
        idealEnd: (json['ideal_end'] as String?) ?? '',
        altStart: json['alt_start'] as String?,
        altEnd: json['alt_end'] as String?,
        avoid: json['avoid'] as String?,
        overrideReason: json['override_reason'] as String?,
        hardCap: json['hard_cap'] as String?,
      );
}

class SequenceFormula {
  final String? general;
  final String? specific;
  final String cardio;

  SequenceFormula({
    this.general,
    this.specific,
    required this.cardio,
  });

  factory SequenceFormula.fromJson(Map<String, dynamic> json) =>
      SequenceFormula(
        general: json['general'] as String?,
        specific: json['specific'] as String?,
        cardio: (json['cardio'] as String?) ?? '',
      );
}

class LoadWeight {
  final String level1;
  final String level2;
  final String level3;
  final String level4;
  final String level5;

  LoadWeight({
    required this.level1,
    required this.level2,
    required this.level3,
    required this.level4,
    required this.level5,
  });

  factory LoadWeight.fromJson(Map<String, dynamic> json) => LoadWeight(
        level1: (json['level_1'] as String?) ?? '',
        level2: (json['level_2'] as String?) ?? '',
        level3: (json['level_3'] as String?) ?? '',
        level4: (json['level_4'] as String?) ?? '',
        level5: (json['level_5'] as String?) ?? '',
      );
}

class ProgramMapRecommendation {
  final SequenceFormula formula;
  final LoadWeight weight;

  ProgramMapRecommendation({
    required this.formula,
    required this.weight,
  });

  factory ProgramMapRecommendation.fromJson(Map<String, dynamic> json) =>
      ProgramMapRecommendation(
        formula: SequenceFormula.fromJson(json['formula'] as Map<String, dynamic>),
        weight: LoadWeight.fromJson(json['weight'] as Map<String, dynamic>),
      );
}

class AssessmentV2Result {
  final String id;
  final String? userId;
  final String version; // 'v2'
  final String status;
  final PhaseAInput phaseA;
  final PhaseBInput? phaseB;
  final PhaseCInput? phaseC;
  final String physicalStatusLevel;
  final String programType;
  final ChronobiologyWindow? chronobiologyWindow;
  final double? restScore;
  final double? nutritionScore;
  final double? movementScore;
  final double? systemScore;
  final ProgramMapRecommendation? programMap;
  final List<String> flags;
  final List<String> recommendations;
  final DateTime createdAt;

  AssessmentV2Result({
    required this.id,
    required this.version,
    required this.status,
    required this.phaseA,
    required this.physicalStatusLevel,
    required this.programType,
    required this.flags,
    required this.recommendations,
    required this.createdAt,
    this.userId,
    this.phaseB,
    this.phaseC,
    this.chronobiologyWindow,
    this.restScore,
    this.nutritionScore,
    this.movementScore,
    this.systemScore,
    this.programMap,
  });

  factory AssessmentV2Result.fromJson(Map<String, dynamic> json) =>
      AssessmentV2Result(
        id: json['id'] as String,
        userId: json['user_id'] as String?,
        version: (json['version'] as String?) ?? 'v2',
        status: (json['status'] as String?) ?? 'submitted',
        phaseA: PhaseAInput.fromJson(json['phase_a'] as Map<String, dynamic>),
        phaseB: json['phase_b'] != null
            ? PhaseBInput.fromJson(json['phase_b'] as Map<String, dynamic>)
            : null,
        phaseC: json['phase_c'] != null
            ? PhaseCInput.fromJson(json['phase_c'] as Map<String, dynamic>)
            : null,
        physicalStatusLevel:
            (json['physical_status_level'] as String?) ?? 'level_4_5_perf',
        programType: (json['program_type'] as String?) ?? 'preventive',
        chronobiologyWindow: json['chronobiology_window'] != null
            ? ChronobiologyWindow.fromJson(
                json['chronobiology_window'] as Map<String, dynamic>)
            : null,
        restScore: (json['rest_score'] as num?)?.toDouble(),
        nutritionScore: (json['nutrition_score'] as num?)?.toDouble(),
        movementScore: (json['movement_score'] as num?)?.toDouble(),
        systemScore: (json['system_score'] as num?)?.toDouble(),
        programMap: json['program_map'] != null
            ? ProgramMapRecommendation.fromJson(
                json['program_map'] as Map<String, dynamic>)
            : null,
        flags: ((json['flags'] as List?) ?? const [])
            .map((e) => e.toString())
            .toList(),
        recommendations: ((json['recommendations'] as List?) ?? const [])
            .map((e) => e.toString())
            .toList(),
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  // ─── Pretty label helpers (untuk UI) ────────────────────────────

  String get prettyProgramType {
    switch (programType) {
      case 'condition_specific': return 'Condition-Specific';
      case 'preventive': return 'Preventive Optimization';
      case 'performance_women_35_45': return 'Performance Women 35–45';
      case 'performance_women_46_60': return 'Performance Women 46–60';
      case 'performance_men_35_45': return 'Performance Men 35–45';
      case 'performance_men_46_60': return 'Performance Men 46–60';
      case 'waitlist': return 'Waitlist';
    }
    return programType;
  }

  String get scoreTier {
    final s = systemScore ?? 0;
    if (s >= 80) return 'OPTIMAL';
    if (s >= 60) return 'STABLE';
    if (s >= 40) return 'COMPROMISED';
    return 'CRITICAL';
  }
}
