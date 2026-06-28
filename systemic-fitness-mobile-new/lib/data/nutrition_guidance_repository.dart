import 'package:workout/data/api_config.dart';
import 'package:workout/data/api_service.dart';
import 'package:workout/models/nutrition_guidance_model.dart';

/// Thin data layer for the Nutrition Guidance & Monitoring Engine endpoints.
/// All methods may throw [PaidSubscriptionRequiredException] if the user is
/// on the free plan.
class NutritionGuidanceRepository {
  static Future<NutritionHealthProfile> upsertProfile(
      NutritionHealthProfile profile) async {
    final res = await ApiService.postWithRetry(
      ApiConfig.nutritionGuidanceProfile,
      body: profile.toJson(),
    );
    return NutritionHealthProfile.fromJson(
      Map<String, dynamic>.from(res['data'] ?? {}),
    );
  }

  static Future<NutritionPlanResult> getPlan() async {
    final res = await ApiService.getWithRetry(ApiConfig.nutritionGuidancePlan);
    return NutritionPlanResult.fromJson(
      Map<String, dynamic>.from(res['data'] ?? {}),
    );
  }

  static Future<NutritionDailyLogResult> submitDailyLog(
      NutritionDailyLogInput input) async {
    final res = await ApiService.postWithRetry(
      ApiConfig.nutritionGuidanceDailyLog,
      body: input.toJson(),
    );
    return NutritionDailyLogResult.fromJson(
      Map<String, dynamic>.from(res['data'] ?? {}),
    );
  }

  static Future<NutritionDailyLogResult> getDailyResult({String? date}) async {
    final res = await ApiService.getWithRetry(
      ApiConfig.nutritionGuidanceDailyResult,
      queryParams: date != null ? {'date': date} : null,
    );
    return NutritionDailyLogResult.fromJson(
      Map<String, dynamic>.from(res['data'] ?? {}),
    );
  }

  /// Returns the authenticated user's most recent daily logs, newest first.
  static Future<List<NutritionDailyLogResult>> listRecentLogs({
    int limit = 30,
  }) async {
    final res = await ApiService.getWithRetry(
      ApiConfig.nutritionGuidanceDailyLogs,
      queryParams: {'limit': '$limit'},
    );
    final list = (res['data'] as List?) ?? const [];
    return list
        .map((e) =>
            NutritionDailyLogResult.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}
