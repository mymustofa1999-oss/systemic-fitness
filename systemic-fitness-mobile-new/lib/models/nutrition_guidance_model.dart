// Models for the Nutrition Guidance & Monitoring Engine.
// Mirrors backend structs in internal/model/models.go.

class NutritionHealthProfile {
  String? userId;
  String? gender; // male | female
  String? ageGroup; // under_18 | 18_40 | 41_60 | over_60
  String? femaleCondition; // normal | pregnant | menopause
  String? goal; // maintenance | fat_loss | recovery
  double? weightKg;
  List<String> allergies;
  List<String> conditions;

  NutritionHealthProfile({
    this.userId,
    this.gender,
    this.ageGroup,
    this.femaleCondition,
    this.goal,
    this.weightKg,
    this.allergies = const [],
    this.conditions = const [],
  });

  factory NutritionHealthProfile.fromJson(Map<String, dynamic> json) =>
      NutritionHealthProfile(
        userId: json['user_id'],
        gender: json['gender'],
        ageGroup: json['age_group'],
        femaleCondition: json['female_condition'],
        goal: json['goal'],
        weightKg: (json['weight_kg'] as num?)?.toDouble(),
        allergies: (json['allergies'] as List?)?.cast<String>() ?? const [],
        conditions: (json['conditions'] as List?)?.cast<String>() ?? const [],
      );

  Map<String, dynamic> toJson() => {
    if (gender != null) 'gender': gender,
    if (ageGroup != null) 'age_group': ageGroup,
    if (femaleCondition != null && femaleCondition!.isNotEmpty)
      'female_condition': femaleCondition,
    if (goal != null) 'goal': goal,
    if (weightKg != null) 'weight_kg': weightKg,
    'allergies': allergies,
    'conditions': conditions,
  };
}

class DietPlan {
  List<String> allowedFoods;
  List<String> limitedFoods;
  List<String> avoidFoods;

  DietPlan({
    this.allowedFoods = const [],
    this.limitedFoods = const [],
    this.avoidFoods = const [],
  });

  factory DietPlan.fromJson(Map<String, dynamic> json) => DietPlan(
    allowedFoods: (json['allowed_foods'] as List?)?.cast<String>() ?? const [],
    limitedFoods: (json['limited_foods'] as List?)?.cast<String>() ?? const [],
    avoidFoods: (json['avoid_foods'] as List?)?.cast<String>() ?? const [],
  );
}

class NutritionPlanResult {
  DietPlan dietPlan;
  Map<String, dynamic> nutritionRules;
  int dailyScore;
  String status;
  List<String> insight;

  NutritionPlanResult({
    required this.dietPlan,
    this.nutritionRules = const {},
    this.dailyScore = 0,
    this.status = 'stable',
    this.insight = const [],
  });

  factory NutritionPlanResult.fromJson(Map<String, dynamic> json) =>
      NutritionPlanResult(
        dietPlan: DietPlan.fromJson(json['diet_plan'] ?? {}),
        nutritionRules: Map<String, dynamic>.from(json['nutrition_rules'] ?? {}),
        dailyScore: json['daily_score'] ?? 0,
        status: json['status'] ?? 'stable',
        insight: (json['insight'] as List?)?.cast<String>() ?? const [],
      );
}

class NutritionDailyLogInput {
  String logDate; // YYYY-MM-DD
  bool vegetableIntake;
  bool proteinIntake;
  bool hydrationOk;
  bool sugarExcess;
  bool dietViolation;

  NutritionDailyLogInput({
    required this.logDate,
    this.vegetableIntake = false,
    this.proteinIntake = false,
    this.hydrationOk = false,
    this.sugarExcess = false,
    this.dietViolation = false,
  });

  Map<String, dynamic> toJson() => {
    'log_date': logDate,
    'vegetable_intake': vegetableIntake,
    'protein_intake': proteinIntake,
    'hydration_ok': hydrationOk,
    'sugar_excess': sugarExcess,
    'diet_violation': dietViolation,
  };
}

class NutritionAlert {
  bool triggered;
  String message;

  NutritionAlert({this.triggered = false, this.message = ''});

  factory NutritionAlert.fromJson(Map<String, dynamic> json) => NutritionAlert(
    triggered: json['alert'] ?? false,
    message: json['message'] ?? '',
  );
}

class NutritionDailyLogResult {
  String logDate;
  int dailyScore;
  String status;
  NutritionAlert? alert;

  NutritionDailyLogResult({
    required this.logDate,
    this.dailyScore = 0,
    this.status = 'stable',
    this.alert,
  });

  factory NutritionDailyLogResult.fromJson(Map<String, dynamic> json) =>
      NutritionDailyLogResult(
        logDate: json['log_date'] ?? '',
        dailyScore: json['daily_score'] ?? 0,
        status: json['status'] ?? 'stable',
        alert: json['alert'] != null
            ? NutritionAlert.fromJson(Map<String, dynamic>.from(json['alert']))
            : null,
      );
}

/// Health condition codes (must match backend constants).
class HealthConditions {
  static const hypertension = 'hypertension';
  static const diabetes = 'diabetes';
  static const kidney = 'kidney';
  static const gout = 'gout';
  static const heart = 'heart';
  static const cancer = 'cancer';
  static const autoimmune = 'autoimmune';
  static const hormonal = 'hormonal';

  static const all = <String>[
    hypertension,
    diabetes,
    kidney,
    gout,
    heart,
    cancer,
    autoimmune,
    hormonal,
  ];

  static const labels = <String, String>{
    hypertension: 'Hipertensi',
    diabetes: 'Diabetes',
    kidney: 'Ginjal',
    gout: 'Asam Urat',
    heart: 'Jantung',
    cancer: 'Kanker',
    autoimmune: 'Autoimun',
    hormonal: 'Hormonal',
  };
}
