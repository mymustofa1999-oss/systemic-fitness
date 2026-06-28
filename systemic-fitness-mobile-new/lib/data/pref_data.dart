import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workout/models/user_model.dart';

class PrefData {
  static final ValueNotifier<String> localeNotifier = ValueNotifier<String>('id');
  static const String _keyLocale = 'locale';

  static Future<void> setLocale(String locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLocale, locale);
    localeNotifier.value = locale;
  }

  static Future<String> getLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final loc = prefs.getString(_keyLocale) ?? 'id';
    localeNotifier.value = loc;
    return loc;
  }

  static const String _keyAccessToken = 'access_token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyUserData = 'user_data';
  static const String _keyFcmToken = 'fcm_token';
  static const String _keyHasAssessment = 'has_completed_assessment';
  static const String _keyAssessmentSkipped = 'assessment_skipped';

  // Legacy keys (backward compatible with old PrefData)
  static const String _pkgName = 'yoga_workout_ui';
  static const String _keyRemindTime = '${_pkgName}ttsSetRemindTime';
  static const String _keyRemindDays = '${_pkgName}ttsSetRemindDays';
  static const String _keyRemindAmPm = '${_pkgName}ttsSetRemindAmPm';
  static const String _keyTrainingRest = '${_pkgName}ttsTrainingRest';
  static const String _keyReminderOn = '${_pkgName}ttsIsReminderOn';
  static const String _keyCalorieBurn = '${_pkgName}ttsCalorieBurn';
  static const String _keyDailyGoal = '${_pkgName}ttsCalorieBurnDailyGoal';
  static const String _keyIsFirst = '${_pkgName}ttsIsFirstIntro';
  static const String _keyHeight = '${_pkgName}ttsHeightKeys';
  static const String _keyWeight = '${_pkgName}ttsWeightKeys';
  static const String _keyIsMale = '${_pkgName}ttsGenderKeys';
  static const String _keyIsKg = '${_pkgName}ttsIsKgUNit';
  static const String _keyIsSoundOn = '${_pkgName}soundIsMutes';
  static const String _keyIsTtsOn = '${_pkgName}ttsIsMutes';
  static const String _keyIsIntro = '${_pkgName}isIntro';
  static const String _keySignIn = '${_pkgName}signIn';

  // ─── Token Management ─────────────────────────────────────

  static Future<void> setTokens(String accessToken, String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAccessToken, accessToken);
    await prefs.setString(_keyRefreshToken, refreshToken);
  }

  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyAccessToken);
  }

  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyRefreshToken);
  }

  // ─── User Data ────────────────────────────────────────────

  static Future<void> setUser(Map<String, dynamic> userJson) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserData, jsonEncode(userJson));
  }

  static Future<UserModel?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_keyUserData);
    if (data == null) return null;
    return UserModel.fromJson(jsonDecode(data));
  }

  // ─── Auth State ───────────────────────────────────────────

  static Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  static Future<void> setIsSignIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keySignIn, value);
  }

  static Future<bool> getIsSignIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keySignIn) ?? false;
  }

  // ─── FCM Token ────────────────────────────────────────────

  static Future<void> setFcmToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyFcmToken, token);
  }

  static Future<String?> getFcmToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyFcmToken);
  }

  // ─── Assessment State ─────────────────────────────────────

  static Future<void> setHasCompletedAssessment(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyHasAssessment, value);
  }

  static Future<bool> hasCompletedAssessment() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyHasAssessment) ?? false;
  }

  static Future<void> setAssessmentSkipped(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAssessmentSkipped, value);
  }

  static Future<bool> getAssessmentSkipped() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyAssessmentSkipped) ?? false;
  }

  // ─── Clear All ────────────────────────────────────────────

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyAccessToken);
    await prefs.remove(_keyRefreshToken);
    await prefs.remove(_keyUserData);
    await prefs.remove(_keySignIn);
    await prefs.remove(_keyFcmToken);
    await prefs.remove(_keyHasAssessment);
    await prefs.remove(_keyAssessmentSkipped);
    // Force a flush so the next read (e.g. router redirect callback)
    // sees the cleared state, not stale in-memory cache.
    await prefs.reload();
  }

  // ─── Legacy Preferences (backward compatible) ─────────────

  static Future<void> setIsIntro(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsIntro, value);
  }

  static Future<bool> getIsIntro() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsIntro) ?? true;
  }

  static Future<void> setIsFirst(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsFirst, value);
  }

  static Future<bool> getIsFirst() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsFirst) ?? true;
  }

  static Future<void> setHeight(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyHeight, value);
  }

  static Future<double> getHeight() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_keyHeight) ?? 170;
  }

  static Future<void> setWeight(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyWeight, value);
  }

  static Future<double> getWeight() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_keyWeight) ?? 70;
  }

  static Future<void> setIsMale(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsMale, value);
  }

  static Future<bool> getIsMale() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsMale) ?? true;
  }

  static Future<void> setIsKgUnit(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsKg, value);
  }

  static Future<bool> getIsKgUnit() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsKg) ?? true;
  }

  static Future<void> setIsSoundOn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsSoundOn, value);
  }

  static Future<bool> getIsSoundOn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsSoundOn) ?? true;
  }

  static Future<void> setIsTtsOn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsTtsOn, value);
  }

  static Future<bool> getIsTtsOn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsTtsOn) ?? true;
  }

  static Future<void> setReminderOn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyReminderOn, value);
  }

  static Future<bool> getReminderOn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyReminderOn) ?? true;
  }

  static Future<void> setRemindTime(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyRemindTime, value);
  }

  static Future<String> getRemindTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyRemindTime) ?? '5:30';
  }

  static Future<void> setRemindDays(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyRemindDays, value);
  }

  static Future<String> getRemindDays() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyRemindDays) ?? '';
  }

  static Future<void> setRemindAmPm(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyRemindAmPm, value);
  }

  static Future<String> getRemindAmPm() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyRemindAmPm) ?? 'AM';
  }

  static Future<void> setTrainingRest(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyTrainingRest, value);
  }

  static Future<int> getTrainingRest() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyTrainingRest) ?? 10;
  }

  static Future<void> setCalorieBurn(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyCalorieBurn, value);
  }

  static Future<int> getCalorieBurn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyCalorieBurn) ?? 0;
  }

  static Future<void> setDailyGoal(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyDailyGoal, value);
  }

  static Future<int> getDailyGoal() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyDailyGoal) ?? 200;
  }
}
