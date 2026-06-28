import '../../online_models/AssessmentV2Models.dart';

/// In-memory singleton untuk hold Phase A/B/C input antar screens.
/// Kalau aplikasi di-kill saat tengah-tengah, draft hilang — flow akan
/// dimulai dari awal lagi (intent: assessment cepat <7 menit, tidak perlu
/// persist disk).
class AssessmentV2Draft {
  AssessmentV2Draft._();
  static final AssessmentV2Draft instance = AssessmentV2Draft._();

  PhaseAInput phaseA = PhaseAInput();
  PhaseBInput? phaseB;
  PhaseCInput? phaseC;

  /// Reset semua input (panggil saat mulai asesmen baru).
  void reset() {
    phaseA = PhaseAInput();
    phaseB = null;
    phaseC = null;
  }
}
