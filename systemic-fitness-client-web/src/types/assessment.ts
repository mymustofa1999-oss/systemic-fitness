export interface PhaseAMovementTest {
  squat: number;
  hipHinge: number;
  overhead: number;
}

export interface PhaseAInput {
  physicalStatusLevel: string; // 'level_0_1' | 'level_2_3' | 'level_4_5_perf'
  hasMedicalCondition: boolean;
  classificationSlug?: string;
  specificConditionSlug?: string;
  seriousConditionNote?: string;
  gender?: string; // 'women' | 'men'
  ageBucket?: string; // '35_45' | '46_60'
  primaryGoal?: string; // 'control_medical' | 'hormonal_feminine' | 'stamina_masculine'
  movementTest?: PhaseAMovementTest;
}

export interface PhaseBInput {
  durationHours: number; // 4.0..10.0
  consistency: number; // 1..3
  sleepLatency: number; // 1..4
  morningReadiness: number; // 1..3
  wakeFrequency: number; // 1..4
  preSleepHabit: number; // 1..3
  bedtimeBucket: number; // 1..5
  wakeTimeBucket: number; // 1..5
  activityProfile: string; // executive | creative | traveller | homemaker | shift_worker | mixed
  dinnerTime: number; // 1..5
}

export interface PhaseCInput {
  mealPattern: number; // 1..5
  foodDominance: number; // 1..5
  hydration: number; // 1..4
  routineFoods: string[];
  restrictions: string[];
  restrictionNote?: string;
  supplements: string[];
  supplementNote?: string;
  nutritionGoal: string;
}

export interface AssessmentV2Draft {
  phaseA: PhaseAInput;
  phaseB?: PhaseBInput;
  phaseC?: PhaseCInput;
}
