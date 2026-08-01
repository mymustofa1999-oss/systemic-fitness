import { SystemicSessionLog } from "@/hooks/useSystemicSessionLog";

export function calculateSystemicScore(log: Partial<SystemicSessionLog>) {
  let p1_score = 0;
  let p2_score = 0;
  let p3_score = 0;
  let total_systemic_score = 0;
  let systemic_status = "Non-Adaptive";

  const delta_sbp =
    log.bp_systolic_post && log.bp_systolic_pre
      ? log.bp_systolic_post - log.bp_systolic_pre
      : 0;
  const delta_dbp =
    log.bp_diastolic_post && log.bp_diastolic_pre
      ? log.bp_diastolic_post - log.bp_diastolic_pre
      : 0;
  const delta_hr =
    log.hr_post && log.hr_pre ? log.hr_post - log.hr_pre : 0;

  // P1 Score
  if (delta_sbp > 25 || delta_dbp > 15) {
    p1_score = 0;
  } else if (
    (delta_sbp >= 16 && delta_sbp <= 25) ||
    (delta_dbp >= 11 && delta_dbp <= 15)
  ) {
    p1_score = 0.5;
  } else {
    p1_score = 1.0;
  }

  // P2 Score
  if (delta_hr > 40) {
    p2_score = 0;
  } else if (delta_hr >= 26 && delta_hr <= 40) {
    p2_score = 0.5;
  } else {
    p2_score = 1.0;
  }

  // P3 Score
  const hasSymptom = !!log.symptom && log.symptom.trim() !== "";
  if (!hasSymptom) {
    p3_score = 1.0;
  } else {
    if (log.session_stopped || !log.resolved_under_5_min) {
      p3_score = 0;
    } else {
      p3_score = 0.5;
    }
  }

  total_systemic_score = p1_score + p2_score + p3_score;

  // Status
  if (log.session_stopped) {
    systemic_status = "Non-Adaptive";
  } else if (total_systemic_score === 3.0) {
    systemic_status = "Adaptive";
  } else if (total_systemic_score >= 2.0) {
    systemic_status = "Acceptable";
  } else if (total_systemic_score >= 1.0) {
    systemic_status = "Suboptimal";
  } else {
    systemic_status = "Non-Adaptive";
  }

  // Dietary Risk
  let dr_risk_count = 0;
  if (log.dr_low_fiber_intake) dr_risk_count++;
  if (log.dr_cakes_pastries) dr_risk_count++;
  if (log.dr_starchy_foods) dr_risk_count++;
  if (log.dr_sugary_drinks) dr_risk_count++;
  if (log.dr_butter_fatty) dr_risk_count++;
  if (log.dr_large_carb_portion) dr_risk_count++;
  if (log.dr_seafood_organ_meats) dr_risk_count++;

  let dr_risk_score = 0;
  let dr_risk_status = "Ready";
  if (log.dr_none_of_above || dr_risk_count === 0) {
    dr_risk_score = 1.0;
    dr_risk_status = "Ready";
  } else if (dr_risk_count === 1) {
    dr_risk_score = 0.5;
    dr_risk_status = "Monitor";
  } else {
    dr_risk_score = 0;
    dr_risk_status = "Needs Attention";
  }

  // Hydration
  let hydration_score = 1.0;
  let hydration_status = "Well Hydrated";
  if (log.hydration === "Mildly Dehydrated — around 1-1.5 L") {
    hydration_score = 0.5;
    hydration_status = "Mildly Dehydrated";
  } else if (log.hydration === "Poor Hydration — less than 1 L") {
    hydration_score = 0;
    hydration_status = "Poor Hydration";
  }

  // Sleep
  let sleep_score = 1.0;
  let sleep_status = "Good Recovery";
  if (log.sleep_recovery === "Monitor — woke up once or twice") {
    sleep_score = 0.5;
    sleep_status = "Monitor";
  } else if (log.sleep_recovery === "Poor Recovery — slept poorly") {
    sleep_score = 0;
    sleep_status = "Poor Recovery";
  }

  // Activity
  let activity_score = 1.0;
  let activity_status = "Active";
  if (log.daily_activity === "Low Activity — mostly sitting") {
    activity_score = 0.5;
    activity_status = "Low Activity";
  } else if (log.daily_activity === "Sedentary — bed rest / complete inactivity") {
    activity_score = 0;
    activity_status = "Sedentary";
  }

  const total_habit_score =
    dr_risk_score + hydration_score + sleep_score + activity_score;
  let lifestyle_status = "Excellent Lifestyle";
  if (total_habit_score >= 4.0) {
    lifestyle_status = "Excellent Lifestyle";
  } else if (total_habit_score >= 3.0) {
    lifestyle_status = "Good Lifestyle";
  } else if (total_habit_score >= 2.0) {
    lifestyle_status = "Moderate Lifestyle";
  } else {
    lifestyle_status = "Low Lifestyle";
  }

  return {
    delta_sbp,
    delta_dbp,
    delta_hr,
    p1_score,
    p2_score,
    p3_score,
    total_systemic_score,
    systemic_status,
    dr_risk_count,
    dr_risk_status,
    dr_risk_score,
    hydration_status,
    hydration_score,
    sleep_status,
    sleep_score,
    activity_status,
    activity_score,
    total_habit_score,
    lifestyle_status,
  };
}
