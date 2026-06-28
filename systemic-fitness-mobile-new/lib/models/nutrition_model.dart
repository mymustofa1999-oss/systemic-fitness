class MealPlan {
  String? id;
  String? name;
  String? description;
  int? dailyCalories;
  double? proteinG;
  double? carbsG;
  double? fatG;
  String? createdBy;
  String? createdAt;

  MealPlan({
    this.id,
    this.name,
    this.description,
    this.dailyCalories,
    this.proteinG,
    this.carbsG,
    this.fatG,
    this.createdBy,
    this.createdAt,
  });

  factory MealPlan.fromJson(Map<String, dynamic> json) => MealPlan(
    id: json['id'],
    name: json['name'],
    description: json['description'],
    dailyCalories: json['daily_calories'],
    proteinG: (json['protein_g'] as num?)?.toDouble(),
    carbsG: (json['carbs_g'] as num?)?.toDouble(),
    fatG: (json['fat_g'] as num?)?.toDouble(),
    createdBy: json['created_by'],
    createdAt: json['created_at'],
  );
}

class NutritionLog {
  String? id;
  String? mealType;
  String? foodName;
  int? calories;
  double? proteinG;
  double? carbsG;
  double? fatG;
  String? photoUrl;
  String? loggedAt;

  NutritionLog({
    this.id,
    this.mealType,
    this.foodName,
    this.calories,
    this.proteinG,
    this.carbsG,
    this.fatG,
    this.photoUrl,
    this.loggedAt,
  });

  factory NutritionLog.fromJson(Map<String, dynamic> json) => NutritionLog(
    id: json['id'],
    mealType: json['meal_type'],
    foodName: json['food_name'],
    calories: json['calories'],
    proteinG: (json['protein_g'] as num?)?.toDouble(),
    carbsG: (json['carbs_g'] as num?)?.toDouble(),
    fatG: (json['fat_g'] as num?)?.toDouble(),
    photoUrl: json['photo_url'],
    loggedAt: json['logged_at'],
  );

  Map<String, dynamic> toJson() => {
    'meal_type': mealType,
    'food_name': foodName,
    'calories': calories,
    'protein_g': proteinG,
    'carbs_g': carbsG,
    'fat_g': fatG,
    'photo_url': photoUrl,
  };
}

class DailyNutrition {
  String? date;
  int? totalCalories;
  double? totalProteinG;
  double? totalCarbsG;
  double? totalFatG;
  List<NutritionLog>? meals;

  DailyNutrition({
    this.date,
    this.totalCalories,
    this.totalProteinG,
    this.totalCarbsG,
    this.totalFatG,
    this.meals,
  });

  factory DailyNutrition.fromJson(Map<String, dynamic> json) => DailyNutrition(
    date: json['date'],
    totalCalories: json['total_calories'],
    totalProteinG: (json['total_protein_g'] as num?)?.toDouble(),
    totalCarbsG: (json['total_carbs_g'] as num?)?.toDouble(),
    totalFatG: (json['total_fat_g'] as num?)?.toDouble(),
    meals: (json['meals'] as List?)?.map((e) => NutritionLog.fromJson(e)).toList(),
  );
}
