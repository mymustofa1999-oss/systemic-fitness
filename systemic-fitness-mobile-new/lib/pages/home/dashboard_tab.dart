import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:workout/ColorCategory.dart';
import 'package:workout/ConstantWidget.dart';
import 'package:workout/Constants.dart';
import 'package:workout/SizeConfig.dart';
import 'package:workout/Widgets.dart';
import 'package:workout/data/api_config.dart';
import 'package:workout/data/api_service.dart';
import 'package:workout/data/nutrition_guidance_repository.dart';
import 'package:workout/data/pref_data.dart';
import 'package:workout/models/payment_model.dart';
import 'package:workout/models/user_model.dart';
import 'package:workout/models/health_article_model.dart';
import 'package:workout/models/doctor_video_model.dart';
import 'package:workout/online_models/AssessmentV2Models.dart';
import 'package:workout/router/app_router.dart';
import 'package:workout/util/subscription_helper.dart';

class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  UserModel? _user;
  UserStats? _stats;
  bool _isLoading = true;
  String? _error;
  bool _hasAssessment = false;
  AssessmentV2Result? _latestAssessment;

  bool _showNutritionGuidanceBanner = false;
  bool _isFree = true;

  List<HealthArticleModel> _healthArticles = [];
  List<DoctorVideoModel> _doctorVideos = [];

  // Promo carousel state — auto-scroll setiap 4 detik
  final PageController _promoController = PageController();
  Timer? _promoTimer;
  int _promoIndex = 0;
  @override
  void initState() {
    super.initState();
    _loadData();
    _startPromoAutoScroll();
  }

  @override
  void dispose() {
    _promoTimer?.cancel();
    _promoController.dispose();
    super.dispose();
  }

  void _startPromoAutoScroll() {
    _promoTimer?.cancel();
    _promoTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || !_promoController.hasClients || _promoBanners.isEmpty) return;
      final next = (_promoIndex + 1) % _promoBanners.length;
      _promoController.animateToPage(
        next,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
      );
    });
  }

  // Daftar promo banner — dynamic dari API /promotions/active.
  // Fallback ke list kosong jika API gagal (banner section hidden).
  List<Map<String, dynamic>> _promoBanners = [];

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      _user = await PrefData.getUser();
      _hasAssessment = await PrefData.hasCompletedAssessment();

      // ─── Promo banners from API ─────────────────────────────────
      // Best-effort: fetch dynamic promotions. Fallback ke list kosong
      // jika API gagal — banner section akan hidden.
      try {
        final promoResp = await ApiService.getWithRetry(
          ApiConfig.promotionsActive,
        );
        final promoList = (promoResp['data'] as List?) ?? [];
        _promoBanners = promoList.cast<Map<String, dynamic>>();
      } catch (_) {
        _promoBanners = [];
      }

      // Fetch the most recent V2 assessment so the dashboard card can
      // surface scores + a "View detail / Upgrade / Re-take" CTA.
      // Best-effort: failures are silently ignored — the card just hides.
      try {
        final assResp = await ApiService.getWithRetry(
          ApiConfig.assessmentV2Latest,
        );
        if (assResp['success'] == true && assResp['data'] != null) {
          _latestAssessment = AssessmentV2Result.fromJson(
            Map<String, dynamic>.from(assResp['data']),
          );
          // If the server has data but the local flag wasn't set yet
          // (e.g. user submitted before this build), reconcile it now.
          if (!_hasAssessment) {
            _hasAssessment = true;
            await PrefData.setHasCompletedAssessment(true);
          }
        }
      } catch (_) {
        // ignore — assessment card will just not render
      }

      if (_user?.id != null) {
        final response = await ApiService.getWithRetry(
          ApiConfig.userStats(_user!.id!),
        );
        final data = response['data'];
        if (data != null) {
          _stats = UserStats.fromJson(data);
        }
      }

      // ─── Subscription check & Nutrition Guidance onboarding check ────
      _isFree = true;
      _showNutritionGuidanceBanner = false;
      try {
        final subRes =
            await ApiService.getWithRetry(ApiConfig.subscriptionMe);
        final sub = MySubscriptionResult.fromJson(
          Map<String, dynamic>.from(subRes['data'] ?? {}),
        );
        _isFree = !isPaidActive(sub);
        if (!_isFree) {
          try {
            // Kalau plan ada → profile sudah dibuat → banner tidak perlu
            await NutritionGuidanceRepository.getPlan();
          } on ApiException catch (e) {
            // 404 = profile belum dibuat → tampilkan banner
            if (e.statusCode == 404) {
              _showNutritionGuidanceBanner = true;
            }
          } catch (_) {
            // network/other error → silent
          }
        }
      } catch (_) {
        _isFree = true;
      }

      // ─── Health News from API ─────────────────────────────────
      try {
        final articlesResp = await ApiService.getWithRetry(ApiConfig.healthNews);
        final articlesList = (articlesResp['data'] as List?) ?? [];
        _healthArticles = articlesList
            .map((json) => HealthArticleModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } catch (e) {
        debugPrint('[Dashboard] Error fetching health news: $e');
        _healthArticles = [];
      }

      // ─── Doctor Recommendation Videos from API ───────────────────────
      try {
        final videosResp = await ApiService.getWithRetry(ApiConfig.doctorVideos);
        final videosList = (videosResp['data'] as List?) ?? [];
        _doctorVideos = videosList
            .map((json) => DoctorVideoModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } catch (e) {
        debugPrint('[Dashboard] Error fetching doctor videos: $e');
        _doctorVideos = [];
      }
    } on ApiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Failed to load dashboard data';
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ─── Nutrition Guidance entry (paid only) ────────────────────

  Future<void> _openNutritionGuidance() async {
    try {
      final res = await ApiService.getWithRetry(ApiConfig.subscriptionMe);
      final sub = MySubscriptionResult.fromJson(
          Map<String, dynamic>.from(res['data'] ?? {}));
      if (!mounted) return;
      if (isPaidActive(sub)) {
        context.push(AppRoutes.nutritionGuidanceIntro);
      } else {
        context.push(AppRoutes.nutritionGuidanceUpgrade);
      }
    } catch (_) {
      if (!mounted) return;
      // On error, let backend gate decide.
      context.push(AppRoutes.nutritionGuidanceIntro);
    }
  }

  // ─── Nutrition Guidance onboarding banner ────────────────────
  //
  // Hanya tampil kalau user paid aktif tapi belum buat health profile.
  // Tujuannya: prevent fitur paid ke-skip karena entry point utamanya
  // (Quick Action #8) susah ditemukan tanpa horizontal scroll.
  // Auto-hide setelah profile dibuat (berikutnya `_loadData()` jalan,
  // `getPlan()` akan return 200 dan flag-nya jadi false).
  Widget _buildNutritionGuidanceBanner(double textMargin) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: textMargin / 2,
        vertical: textMargin / 2,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(
            ConstantWidget.getScreenPercentSize(context, 1.8),
          ),
          onTap: () => context.push(AppRoutes.nutritionGuidanceIntro),
          child: Container(
            padding: EdgeInsets.all(
              ConstantWidget.getScreenPercentSize(context, 2),
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                ConstantWidget.getScreenPercentSize(context, 1.8),
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  greenButton.withOpacity(0.92),
                  greenButton,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: greenButton.withOpacity(0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Icon bubble
                Container(
                  width: ConstantWidget.getScreenPercentSize(context, 6),
                  height: ConstantWidget.getScreenPercentSize(context, 6),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.20),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.psychology_alt_rounded,
                    color: Colors.white,
                    size: ConstantWidget.getScreenPercentSize(context, 3.2),
                  ),
                ),
                SizedBox(
                  width: ConstantWidget.getWidthPercentSize(context, 3),
                ),
                // Text content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'BARU UNTUK KAMU',
                              style: TextStyle(
                                fontFamily: Constants.fontsFamily,
                                fontSize: ConstantWidget.getScreenPercentSize(
                                    context, 1.1),
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: ConstantWidget.getScreenPercentSize(
                            context, 0.5),
                      ),
                      Text(
                        'Mulai Panduan Nutrisi Personal',
                        style: TextStyle(
                          fontFamily: Constants.fontsFamily,
                          fontSize: ConstantWidget.getScreenPercentSize(
                              context, 1.85),
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(
                        height: ConstantWidget.getScreenPercentSize(
                            context, 0.3),
                      ),
                      Text(
                        'Buat profil kesehatan untuk dapat rencana diet yang sesuai kondisimu',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: Constants.fontsFamily,
                          fontSize: ConstantWidget.getScreenPercentSize(
                              context, 1.45),
                          color: Colors.white.withOpacity(0.9),
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                // Arrow
                Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: ConstantWidget.getScreenPercentSize(context, 2.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Assessment section ──────────────────────────────────────
  //
  // Three states:
  //   1. No assessment yet              → CTA banner "Take assessment"
  //   2. Has assessment (free tier)     → score card + Upgrade CTA
  //   3. Has assessment (paid tier)     → score card + Re-take CTA only

  Widget _buildAssessmentBanner(double textMargin) {
    return InkWell(
      // SF Phase 5: arahkan ke Assessment v2 (Phase A/B/C). Flow v1 lama
      // tetap accessible via halaman /assessment/intro untuk user yang
      // sudah submit data v1 (akses dari sana, bukan dari dashboard).
      onTap: () => context.push(AppRoutes.assessmentV2Intro),
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: (textMargin / 2),
          vertical: textMargin / 2,
        ),
        padding: EdgeInsets.all(textMargin),
        decoration: BoxDecoration(
          color: accentColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(Icons.assignment_outlined,
                color: Colors.white, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Complete your Basic Assessment',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Sleep, movement, and metabolic baseline',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white),
          ],
        ),
      ),
    );
  }

  Color _classColor(String cls) {
    switch (cls) {
      case 'optimal':
      case 'stable':
      case 'efficient':
        return Colors.green;
      case 'compromised':
      case 'compensation':
      case 'at_risk':
        return Colors.orange;
      default:
        return Colors.red;
    }
  }

  Widget _buildLatestAssessmentCard(double textMargin) {
    final r = _latestAssessment!;
    final isPaid = !_isFree;
    final daysSince = DateTime.now().difference(r.createdAt).inDays;
    // Re-assessment cadence: nudge users to re-take after 8 weeks (56 days).
    // Assessment is a snapshot of their current state — re-assessing
    // regularly is how progress gets measured over time.
    final reassessDue = daysSince >= 56;
    final systemScore = (r.systemScore ?? 0.0).toInt();
    final restScore = (r.restScore ?? 0.0).toInt();
    final movementScore = (r.movementScore ?? 0.0).toInt();
    final nutritionScore = r.nutritionScore != null ? r.nutritionScore!.toInt() : null;

    final systemScoreColor = _classColor(
      systemScore >= 80
          ? 'optimal'
          : systemScore >= 60
              ? 'compromised'
              : 'critical',
    );

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: textMargin / 2,
        vertical: textMargin / 2,
      ),
      padding: EdgeInsets.all(textMargin),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: subTextColor.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row: title + tier badge
          Row(
            children: [
              const Icon(Icons.assignment_outlined,
                  color: Colors.black87, size: 20),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Hasil Assessment Terbaru',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isPaid
                      ? Colors.purple.withOpacity(0.12)
                      : subTextColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isPaid ? 'PAID' : 'FREE',
                  style: TextStyle(
                    color: isPaid ? Colors.purple : subTextColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          if (reassessDue) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.shade300),
              ),
              child: Row(
                children: [
                  Icon(Icons.schedule, size: 14, color: Colors.amber.shade800),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Re-assessment due — $daysSince hari sejak assessment terakhir',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.amber.shade900,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),

          // Score ring + pillar bars
          Row(
            children: [
              CircularPercentIndicator(
                radius: 42,
                lineWidth: 8,
                percent: (systemScore / 100).clamp(0.0, 1.0),
                center: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$systemScore',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'System',
                      style: TextStyle(
                        color: subTextColor,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
                progressColor: systemScoreColor,
                backgroundColor: subTextColor.withOpacity(0.12),
                circularStrokeCap: CircularStrokeCap.round,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMiniBar('Sleep', restScore),
                    const SizedBox(height: 6),
                    _buildMiniBar('Movement', movementScore),
                    if (nutritionScore != null) ...[
                      const SizedBox(height: 6),
                      _buildMiniBar('Nutrition', nutritionScore),
                    ],
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          _buildScoreExplainer(systemScore, systemScoreColor, subTextColor),

          if (r.flags.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: r.flags
                  .map((f) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          f,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ],

          const SizedBox(height: 16),

          // CTAs
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () =>
                      context.push('/assessment/result/${r.id}'),
                  icon: const Icon(Icons.visibility_outlined, size: 16),
                  label: const Text('Detail'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black87,
                    side: BorderSide(color: subTextColor.withOpacity(0.3)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  // Free users → Subscription page (pilih tier dulu).
                  // Paid users → langsung Re-take Paid wizard.
                  onPressed: () => context.push(
                    isPaid
                        ? AppRoutes.assessmentPaid
                        : AppRoutes.subscription,
                  ),
                  icon: Icon(
                    isPaid ? Icons.refresh : Icons.workspace_premium,
                    size: 16,
                  ),
                  label: Text(isPaid ? 'Re-take Paid' : 'Upgrade Plan'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),
          Center(
            child: TextButton(
              onPressed: () => context.push(AppRoutes.assessmentHistory),
              child: Text(
                'Lihat semua histori →',
                style: TextStyle(
                  color: subTextColor,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreExplainer(int score, Color color, Color subTextColor) {
    late final String tier;
    late final String rangeLabel;
    late final String meaning;
    late final String action;
    late final IconData icon;
    late final List<Color> gradient;

    if (score >= 80) {
      tier = 'Optimal';
      rangeLabel = '80 – 100';
      meaning =
          'Kondisi sistem tubuhmu dalam performa terbaik. Recovery, energi, dan kapasitas fisik berjalan seimbang.';
      action =
          'Pertahankan rutinitas tidur, latihan, dan nutrisi. Fokus pada progressive overload & variasi latihan.';
      icon = Icons.emoji_events_rounded;
      // Fresh green → teal
      gradient = const [Color(0xFF22C55E), Color(0xFF0EA5A4)];
    } else if (score >= 60) {
      tier = 'Compromised';
      rangeLabel = '60 – 79';
      meaning =
          'Ada beberapa pilar yang belum optimal sehingga dapat menurunkan recovery, fokus, dan performa latihan.';
      action =
          'Perbaiki pilar dengan skor terendah (lihat bar di atas). Evaluasi kualitas tidur, hidrasi, dan konsistensi gerak harian.';
      icon = Icons.warning_amber_rounded;
      // Amber → deep orange
      gradient = const [Color(0xFFFBBF24), Color(0xFFF97316)];
    } else {
      tier = 'Critical';
      rangeLabel = '0 – 59';
      meaning =
          'Sistem tubuh sedang dalam tekanan tinggi. Risiko cedera, kelelahan kronis, dan gangguan metabolik meningkat.';
      action =
          'Prioritaskan recovery: tidur cukup, turunkan intensitas latihan sementara, dan konsultasi dengan coach untuk rencana pemulihan.';
      icon = Icons.error_rounded;
      // Hot pink → red
      gradient = const [Color(0xFFF43F5E), Color(0xFFB91C1C)];
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: gradient.last.withOpacity(0.35),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.22),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 18, color: Colors.white),
              ),
              const SizedBox(width: 8),
              Text(
                'Skor $score • $tier',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(20),
                  border:
                      Border.all(color: Colors.white.withOpacity(0.5), width: 1),
                ),
                child: Text(
                  rangeLabel,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'APA ARTINYA?',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            meaning,
            style: TextStyle(
              fontSize: 12,
              height: 1.45,
              color: Colors.white.withOpacity(0.95),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'YANG PERLU DILAKUKAN',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            action,
            style: TextStyle(
              fontSize: 12,
              height: 1.45,
              color: Colors.white.withOpacity(0.95),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                _rangeChip('0–59', 'Critical', tier == 'Critical'),
                const SizedBox(width: 6),
                _rangeChip('60–79', 'Compromised', tier == 'Compromised'),
                const SizedBox(width: 6),
                _rangeChip('80–100', 'Optimal', tier == 'Optimal'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _rangeChip(String range, String label, bool active) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              range,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: active ? Colors.black87 : Colors.white,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: active
                    ? Colors.black54
                    : Colors.white.withOpacity(0.85),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniBar(String label, int score) {
    final color = _classColor(
      score >= 80 ? 'optimal' : score >= 60 ? 'compromised' : 'critical',
    );
    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: TextStyle(color: subTextColor, fontSize: 11),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (score / 100).clamp(0.0, 1.0),
              minHeight: 6,
              color: color,
              backgroundColor: subTextColor.withOpacity(0.12),
            ),
          ),
        ),
        const SizedBox(width: 6),
        SizedBox(
          width: 24,
          child: Text(
            '$score',
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    double textMargin = SizeConfig.safeBlockHorizontal! * 3.5;
    double sliderHeight = SizeConfig.safeBlockVertical! * 22;
    double sliderRadius = Constants.getPercentSize(sliderHeight, 12);

    if (_isLoading) {
      return Container(
        color: bgDarkWhite,
        child: Center(child: getProgressDialog()),
      );
    }

    if (_error != null) {
      return _buildError(textMargin);
    }

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: bgDarkWhite,
      child: RefreshIndicator(
        onRefresh: _loadData,
        color: accentColor,
        child: ListView(
          scrollDirection: Axis.vertical,
          children: [
            // Greeting header (avatar + nama + tanggal + notif)
            _buildGreetingHeader(textMargin),

            // Promo banner carousel (full image, auto-scroll)
            if (_promoBanners.isNotEmpty)
              _buildPromoCarousel(textMargin),

            // Assessment section: CTA banner if no assessment yet,
            // otherwise the latest score card with detail / upgrade /
            // re-take actions.
            if (_isFree) ...[
              // Free clients keep access to the Training Card (shared free program).
              _buildTrainingCardEntry(textMargin),
              if (!_hasAssessment || _latestAssessment == null)
                _buildFreePlanOverlay(textMargin)
              else ...[
                _buildLatestAssessmentCard(textMargin),
                _buildFreePlanDetailsCard(textMargin),
                _buildRecommendedSection(textMargin),
                _buildHealthNewsSection(textMargin),
                _buildDoctorVideosSection(textMargin),
                _buildTipOfTheDay(textMargin),
              ],
            ] else ...[
              if (!_hasAssessment || _latestAssessment == null)
                _buildAssessmentBanner(textMargin)
              else
                _buildLatestAssessmentCard(textMargin),

              // Nutrition Guidance onboarding nudge — only for paid users
              // who haven't created their health profile yet. Auto-hides
              // after the profile is created.
              if (_showNutritionGuidanceBanner)
                _buildNutritionGuidanceBanner(textMargin),

              // Weekly goal progress ring
              _buildWeeklyGoalCard(textMargin),

              // Active Program section (carousel-style like Challenges)
              if (_stats?.activeProgramId != null) ...[
                Padding(
                  padding: EdgeInsets.all(textMargin),
                  child: getTitleTexts(context, 'Active Program'),
                ),
                _buildActiveProgramCard(
                    sliderHeight, sliderRadius, textMargin),
                SizedBox(
                  height: ConstantWidget.getScreenPercentSize(context, 1.6),
                ),
              ],

              // Recommended For You — adaptive berdasarkan assessment
              _buildRecommendedSection(textMargin),

              // Recent Activity (latihan terakhir)
              if ((_stats?.lastWorkoutAt ?? '').isNotEmpty)
                _buildRecentActivityCard(textMargin),

              // Quick Actions section (3-column grid, no horizontal scroll)
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: textMargin,
                  vertical: textMargin * 0.6,
                ),
                child: getTitleTexts(context, 'Quick Actions'),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: textMargin),
                child: GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  primary: false,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: textMargin * 0.6,
                  mainAxisSpacing: textMargin * 0.6,
                  childAspectRatio: 1,
                  children: [
                    _buildQuickActionGridCard(
                      'Log\nProgress',
                      'Chart.svg',
                      2,
                      () => context.push(AppRoutes.logProgress),
                    ),
                    _buildQuickActionGridCard(
                      'Nutrition\nGuidance',
                      'CPU.svg',
                      7,
                      () => _openNutritionGuidance(),
                    ),
                    _buildQuickActionGridCard(
                      'Jadwal',
                      'Clock.svg',
                      10,
                      () => context.push(AppRoutes.scheduling),
                    ),
                    _buildQuickActionGridCard(
                      'Formulir',
                      'Setting.svg',
                      12,
                      () => context.push(AppRoutes.forms),
                    ),
                  ],
                ),
              ),
              _buildHealthNewsSection(textMargin),
              _buildDoctorVideosSection(textMargin),
              // Tip of the Day
              _buildTipOfTheDay(textMargin),
            ],

            SizedBox(
              height: ConstantWidget.getScreenPercentSize(context, 2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFreePlanOverlay(double textMargin) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: textMargin / 2, vertical: textMargin),
      padding: EdgeInsets.all(textMargin * 1.2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: kSfWarmGold.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: kSfWarmGold.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Elegant premium badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: kSfWarmGold.withOpacity(0.1),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.stars_rounded,
                  color: kSfWarmGold,
                  size: 16,
                ),
                const SizedBox(width: 6),
                getCustomText(
                  'FREE PLAN',
                  kSfWarmGold,
                  1,
                  TextAlign.center,
                  FontWeight.w700,
                  ConstantWidget.getPercentSize(textMargin, 75),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          // Heading
          getCustomText(
            'Mulai Perjalanan Kebugaran Anda',
            kSfCharcoal,
            2,
            TextAlign.center,
            FontWeight.w800,
            ConstantWidget.getScreenPercentSize(context, 2.2),
          ),
          const SizedBox(height: 10),
          // Body text
          getCustomText(
            'Lengkapi Penilaian Assessment V2 untuk melihat analisis tubuh Anda dan dapatkan rekomendasi program latihan terbaik dari pelatih profesional kami.',
            kSfCharcoal.withOpacity(0.7),
            5,
            TextAlign.center,
            FontWeight.w400,
            ConstantWidget.getScreenPercentSize(context, 1.6),
          ),
          const SizedBox(height: 24),
          // CTA Button
          ConstantWidget.getButtonWidget(
            context,
            'Mulai Assessment V2',
            kSfWarmGold,
            () {
              context.push(AppRoutes.assessmentV2Intro);
            },
          ),
          const SizedBox(height: 14),
          // Upgrade CTA
          TextButton(
            onPressed: () {
              context.push(AppRoutes.subscription);
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: getCustomText(
              'Pelajari Paket Langganan Premium →',
              kSfWarmGold,
              1,
              TextAlign.center,
              FontWeight.w600,
              ConstantWidget.getScreenPercentSize(context, 1.6),
            ),
          ),
        ],
      ),
    );
  }

  // Tappable entry to the Training Card. Free clients still have it — the API
  // serves them the shared "free" program template.
  Widget _buildTrainingCardEntry(double textMargin) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: textMargin / 2,
        vertical: textMargin / 2,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push(AppRoutes.trainingCard),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: EdgeInsets.all(textMargin),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [kSfWarmGold, kSfWarmGold.withOpacity(0.82)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: kSfWarmGold.withOpacity(0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.fitness_center_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      getCustomText(
                        'Training Card',
                        Colors.white,
                        1,
                        TextAlign.left,
                        FontWeight.w700,
                        15,
                      ),
                      const SizedBox(height: 2),
                      getCustomText(
                        'Lihat program latihan gratismu',
                        Colors.white.withOpacity(0.9),
                        2,
                        TextAlign.left,
                        FontWeight.w400,
                        12,
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFreePlanDetailsCard(double textMargin) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: textMargin / 2,
        vertical: textMargin / 2,
      ),
      padding: EdgeInsets.all(textMargin),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            kSfWarmGold.withOpacity(0.08),
            kSfWarmGold.withOpacity(0.02),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kSfWarmGold.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline_rounded, color: kSfWarmGold, size: 20),
              const SizedBox(width: 8),
              getCustomText(
                'Paket Aktif: Free Plan',
                kSfCharcoal,
                1,
                TextAlign.left,
                FontWeight.w700,
                14,
              ),
            ],
          ),
          const SizedBox(height: 10),
          getCustomText(
            'Anda telah berhasil menyelesaikan Assessment V2! Namun, Anda belum memiliki akses ke fitur Premium.',
            kSfCharcoal.withOpacity(0.8),
            3,
            TextAlign.left,
            FontWeight.w400,
            12,
          ),
          const SizedBox(height: 12),
          // Locked features list
          _buildLockedFeatureRow('Program latihan harian khusus'),
          const SizedBox(height: 6),
          _buildLockedFeatureRow('Panduan nutrisi harian & rencana makan AI'),
          const SizedBox(height: 6),
          _buildLockedFeatureRow('Konsultasi privat & obrolan langsung dengan pelatih'),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.push(AppRoutes.subscription),
              style: ElevatedButton.styleFrom(
                backgroundColor: kSfWarmGold,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                'Upgrade ke Premium Sekarang',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLockedFeatureRow(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.lock_outline_rounded, color: kSfCharcoal.withOpacity(0.4), size: 14),
        const SizedBox(width: 8),
        Expanded(
          child: getCustomText(
            text,
            kSfCharcoal.withOpacity(0.6),
            2,
            TextAlign.left,
            FontWeight.w500,
            11,
          ),
        ),
      ],
    );
  }

  // ─── Tip of the Day ──────────────────────────────────────────
  // Konten ringan harian (rotasi by day-of-year) supaya halaman terasa
  // "hidup" tanpa butuh API.
  Widget _buildTipOfTheDay(double textMargin) {
    final tips = <Map<String, dynamic>>[
      {
        'category': 'NUTRITION',
        'title': 'Hidrasi adalah pondasi performa',
        'body':
            'Minum 30–35 ml air per kg berat badan setiap hari. Mulai pagimu dengan segelas air sebelum kafein.',
        'icon': Icons.local_drink_rounded,
        'color': const Color(0xFF0EA5E9),
      },
      {
        'category': 'RECOVERY',
        'title': 'Tidur = sesi latihan tak kasat mata',
        'body':
            'Otot tumbuh saat tidur, bukan saat angkat beban. Target 7–9 jam berkualitas setiap malam.',
        'icon': Icons.bedtime_rounded,
        'color': const Color(0xFF8B5CF6),
      },
      {
        'category': 'TRAINING',
        'title': 'Konsistensi mengalahkan intensitas',
        'body':
            '4 sesi sederhana per minggu yang konsisten lebih efektif daripada 1 sesi maksimal lalu menghilang.',
        'icon': Icons.fitness_center_rounded,
        'color': const Color(0xFFF97316),
      },
      {
        'category': 'MINDSET',
        'title': 'Progress, bukan kesempurnaan',
        'body':
            'Lewatkan satu sesi tidak menghapus minggumu. Yang penting kembali ke jalur di sesi berikutnya.',
        'icon': Icons.psychology_rounded,
        'color': const Color(0xFFEC4899),
      },
      {
        'category': 'NUTRITION',
        'title': 'Protein di setiap waktu makan',
        'body':
            'Sebar 1.6–2.2 g protein/kg BB ke dalam 3–4 waktu makan untuk sintesis otot optimal.',
        'icon': Icons.restaurant_rounded,
        'color': const Color(0xFF10B981),
      },
      {
        'category': 'RECOVERY',
        'title': 'Mobility 5 menit > tidak sama sekali',
        'body':
            'Stretching ringan setelah latihan menjaga rentang gerak dan mengurangi risiko cedera.',
        'icon': Icons.self_improvement_rounded,
        'color': const Color(0xFF14B8A6),
      },
      {
        'category': 'TRAINING',
        'title': 'Catat angka, lihat polanya',
        'body':
            'Tracking beban dan repetisi adalah cara paling jujur untuk tahu apakah kamu progress.',
        'icon': Icons.show_chart_rounded,
        'color': const Color(0xFF6366F1),
      },
    ];

    final now = DateTime.now();
    final dayOfYear =
        now.difference(DateTime(now.year, 1, 1)).inDays;
    final tip = tips[dayOfYear % tips.length];
    final tipColor = tip['color'] as Color;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: textMargin / 2,
        vertical: textMargin / 2,
      ),
      padding: EdgeInsets.all(textMargin),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: subTextColor.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: tipColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              tip['icon'] as IconData,
              color: tipColor,
              size: 26,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: tipColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        tip['category'] as String,
                        style: TextStyle(
                          color: tipColor,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Tip Hari Ini',
                      style: TextStyle(
                        color: subTextColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  tip['title'] as String,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tip['body'] as String,
                  style: TextStyle(
                    color: subTextColor,
                    fontSize: 11.5,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Promo Banner Image ──────────────────────────────────────
  // Support both network image (image_url dari API) dan local asset
  // (image fallback). Jika keduanya kosong, tampilkan placeholder.
  Widget _buildBannerImage(Map<String, dynamic> banner) {
    final imageUrl = (banner['image_url'] ?? '').toString();
    final assetImage = (banner['image'] ?? '').toString();

    if (imageUrl.isNotEmpty) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          color: subTextColor.withOpacity(0.2),
          child: const Icon(Icons.image_not_supported, color: Colors.white),
        ),
      );
    } else if (assetImage.isNotEmpty) {
      return Image.asset(
        assetImage,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          color: subTextColor.withOpacity(0.2),
          child: const Icon(Icons.image_not_supported, color: Colors.white),
        ),
      );
    } else {
      return Container(
        color: accentColor.withOpacity(0.8),
        child: const Icon(Icons.campaign_outlined, color: Colors.white, size: 48),
      );
    }
  }

  // ─── Promo Banner Carousel ───────────────────────────────────
  // Full-image PageView dengan auto-scroll + dots indicator. Setiap
  // banner navigate ke route yang relevan. Data dinamis dari API
  // /promotions/active — field: image_url, badge, title, subtitle, route.
  Widget _buildPromoCarousel(double textMargin) {
    final height = 170.0;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: textMargin / 2,
        vertical: textMargin / 2,
      ),
      child: Column(
        children: [
          SizedBox(
            height: height,
            child: PageView.builder(
              controller: _promoController,
              itemCount: _promoBanners.length,
              onPageChanged: (i) => setState(() => _promoIndex = i),
              itemBuilder: (context, i) {
                final banner = _promoBanners[i];
                final route = (banner['route'] ?? '').toString();
                return GestureDetector(
                  onTap: route.isNotEmpty
                      ? () => context.push(route)
                      : null,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Full image — support both network (image_url)
                          // and local asset (image) fallback
                          _buildBannerImage(banner),
                          // Dark gradient overlay agar text terbaca
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withOpacity(0.0),
                                  Colors.black.withOpacity(0.65),
                                ],
                                stops: const [0.4, 1.0],
                              ),
                            ),
                          ),
                          // Badge top-left
                          if ((banner['badge'] ?? '').toString().isNotEmpty)
                            Positioned(
                              top: 12,
                              left: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: accentColor,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  (banner['badge'] ?? '').toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ),
                            ),
                          // Title + subtitle bottom-left
                          Positioned(
                            left: 16,
                            right: 16,
                            bottom: 16,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  (banner['title'] ?? '').toString(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black54,
                                        blurRadius: 4,
                                        offset: Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  (banner['subtitle'] ?? banner['description'] ?? '').toString(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          // Dots indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_promoBanners.length, (i) {
              final active = i == _promoIndex;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: active ? 20 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: active ? accentColor : subTextColor.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ─── Weekly Goal ─────────────────────────────────────────────
  // Visual progress ring untuk goal mingguan (default 5 workout/minggu) +
  // 2 metric pendamping: streak harian & total exercise minutes. Memberi
  // user feedback langsung tentang konsistensi mereka.
  Widget _buildWeeklyGoalCard(double textMargin) {
    const weeklyGoal = 5; // target workout per minggu
    final done = _stats?.workoutsThisWeek ?? 0;
    final percent = (done / weeklyGoal).clamp(0.0, 1.0);
    final streak = _stats?.currentStreakDays ?? 0;
    final totalMin = _stats?.totalExerciseMinutes ?? 0;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: textMargin / 2,
        vertical: textMargin / 2,
      ),
      padding: EdgeInsets.all(textMargin),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: subTextColor.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircularPercentIndicator(
            radius: 44,
            lineWidth: 9,
            percent: percent,
            animation: true,
            animationDuration: 800,
            circularStrokeCap: CircularStrokeCap.round,
            progressColor: accentColor,
            backgroundColor: subTextColor.withOpacity(0.12),
            center: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$done/$weeklyGoal',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  'workouts',
                  style: TextStyle(
                    color: subTextColor,
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Goal Mingguan',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  done >= weeklyGoal
                      ? 'Target tercapai! 🎉'
                      : 'Lagi ${weeklyGoal - done} workout untuk capai target',
                  style: TextStyle(
                    color: subTextColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _miniMetric(
                      icon: Icons.local_fire_department_rounded,
                      iconColor: Colors.deepOrange,
                      value: '$streak',
                      label: 'hari\nstreak',
                    ),
                    const SizedBox(width: 14),
                    _miniMetric(
                      icon: Icons.timer_outlined,
                      iconColor: Colors.blueAccent,
                      value: _formatMinutes(totalMin),
                      label: 'total\nlatihan',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniMetric({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 16),
        ),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 13,
                height: 1.1,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: subTextColor,
                fontSize: 8.5,
                height: 1.1,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatMinutes(int minutes) {
    if (minutes >= 60) {
      final h = minutes ~/ 60;
      final m = minutes % 60;
      return m == 0 ? '${h}j' : '${h}j${m}m';
    }
    return '${minutes}m';
  }

  // ─── Today's Plan ────────────────────────────────────────────
  // Hero card di bawah greeting. Dua state:
  //   1. Punya active program → tampilkan nama program + progress + CTA "Mulai"
  //   2. Belum ada            → CTA browse programs
  // Karena belum ada endpoint "workout terjadwal hari ini", kita derive dari
  // data _stats yang sudah dimuat di _loadData. Saat endpoint tersedia
  // (mis. /programs/today) cukup ganti sumber data di sini.
  Widget _buildTodaysPlanCard(double textMargin) {
    final hasProgram = _stats?.activeProgramId != null;
    final progressPct = (_stats?.programProgressPct ?? 0).toDouble();

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: textMargin / 2,
        vertical: textMargin / 2,
      ),
      padding: EdgeInsets.all(textMargin),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: hasProgram
              ? const [Color(0xFF6366F1), Color(0xFF8B5CF6)]
              : const [Color(0xFF64748B), Color(0xFF475569)],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: (hasProgram
                    ? const Color(0xFF6366F1)
                    : Colors.black)
                .withOpacity(0.25),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.22),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "TODAY'S PLAN",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const Spacer(),
              Icon(
                hasProgram
                    ? Icons.fitness_center_rounded
                    : Icons.add_task_rounded,
                color: Colors.white.withOpacity(0.85),
                size: 18,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            hasProgram
                ? (_stats?.activeProgramName ?? 'Latihan Hari Ini')
                : 'Belum ada program aktif',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            hasProgram
                ? 'Lanjutkan perjalanan latihanmu hari ini'
                : 'Pilih program yang sesuai dengan tujuanmu',
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
          if (hasProgram) ...[
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: (progressPct / 100).clamp(0.0, 1.0),
                minHeight: 7,
                backgroundColor: Colors.white.withOpacity(0.22),
                valueColor:
                    const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${progressPct.toStringAsFixed(0)}% selesai',
              style: TextStyle(
                color: Colors.white.withOpacity(0.85),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => context.push(
                    hasProgram
                        ? AppRoutes.activeProgram
                        : AppRoutes.programs,
                  ),
                  icon: Icon(
                    hasProgram
                        ? Icons.play_arrow_rounded
                        : Icons.search_rounded,
                    size: 18,
                  ),
                  label: Text(
                    hasProgram ? 'Mulai Latihan' : 'Cari Program',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: hasProgram
                        ? const Color(0xFF6366F1)
                        : const Color(0xFF475569),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              if (hasProgram) ...[
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    onPressed: () =>
                        context.push(AppRoutes.workouts),
                    icon: const Icon(
                      Icons.list_alt_rounded,
                      color: Colors.white,
                    ),
                    tooltip: 'Lihat semua sesi',
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // ─── Greeting header ─────────────────────────────────────────
  // Top section dashboard: avatar + sapaan kontekstual (pagi/siang/sore/malam)
  // + tanggal hari ini + tombol notifikasi. Ini menggantikan tampilan dashboard
  // yang sebelumnya langsung mulai dari assessment card sehingga terasa kosong.
  Widget _buildGreetingHeader(double textMargin) {
    final now = DateTime.now();
    final hour = now.hour;
    String greeting;
    IconData greetingIcon;
    if (hour < 11) {
      greeting = 'Selamat Pagi';
      greetingIcon = Icons.wb_sunny_outlined;
    } else if (hour < 15) {
      greeting = 'Selamat Siang';
      greetingIcon = Icons.wb_sunny;
    } else if (hour < 18) {
      greeting = 'Selamat Sore';
      greetingIcon = Icons.wb_twilight;
    } else {
      greeting = 'Selamat Malam';
      greetingIcon = Icons.nightlight_round;
    }

    final firstName = (_user?.fullName ?? 'Athlete').split(' ').first;
    final dateStr = _formatIndoDate(now);
    final avatarUrl = _user?.avatarUrl;
    final initial = firstName.isNotEmpty ? firstName[0].toUpperCase() : 'A';

    return Container(
      margin: EdgeInsets.fromLTRB(
        textMargin / 2,
        textMargin,
        textMargin / 2,
        textMargin / 2,
      ),
      padding: EdgeInsets.all(textMargin),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          GestureDetector(
            onTap: () => context.push(AppRoutes.profile),
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.25),
                  width: 2,
                ),
                color: accentColor.withOpacity(0.25),
                image: (avatarUrl != null && avatarUrl.isNotEmpty)
                    ? DecorationImage(
                        image: NetworkImage(avatarUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              alignment: Alignment.center,
              child: (avatarUrl == null || avatarUrl.isEmpty)
                  ? Text(
                      initial,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          // Greeting + name + date
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(greetingIcon,
                        size: 13, color: Colors.amber.shade300),
                    const SizedBox(width: 5),
                    Text(
                      greeting,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.75),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  firstName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  dateStr,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.55),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatIndoDate(DateTime d) {
    const days = [
      'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'
    ];
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${days[d.weekday - 1]}, ${d.day} ${months[d.month - 1]} ${d.year}';
  }

  // ─── Recommended For You ─────────────────────────────────────
  // Carousel rekomendasi adaptif. Bila user sudah punya assessment,
  // pillar dengan skor terendah dipromosikan ke depan (misal Sleep low →
  // Recovery Yoga di posisi pertama). Bila belum, fallback ke 4 kategori
  // umum. Setiap kartu navigate ke listing workouts dengan filter.
  Widget _buildRecommendedSection(double textMargin) {
    final base = <Map<String, dynamic>>[
      {
        'title': 'Recovery Yoga',
        'subtitle': 'Tidur lebih nyenyak',
        'icon': Icons.self_improvement_rounded,
        'colors': const [Color(0xFF8B5CF6), Color(0xFF6366F1)],
        'tag': 'sleep',
      },
      {
        'title': 'Mobility Flow',
        'subtitle': 'Lepas kaku gerakan',
        'icon': Icons.accessibility_new_rounded,
        'colors': const [Color(0xFF14B8A6), Color(0xFF0EA5E9)],
        'tag': 'movement',
      },
      {
        'title': 'HIIT Burner',
        'subtitle': 'Boost metabolik',
        'icon': Icons.local_fire_department_rounded,
        'colors': const [Color(0xFFF97316), Color(0xFFEF4444)],
        'tag': 'metabolic',
      },
      {
        'title': 'Strength Basic',
        'subtitle': 'Bangun fondasi',
        'icon': Icons.fitness_center_rounded,
        'colors': const [Color(0xFF6366F1), Color(0xFF1E40AF)],
        'tag': 'strength',
      },
    ];

    // Re-rank berdasarkan pillar terlemah dari assessment terbaru.
    final r = _latestAssessment;
    if (r != null) {
      final pillarScores = <String, int>{
        'sleep': (r.restScore ?? 0.0).toInt(),
        'movement': (r.movementScore ?? 0.0).toInt(),
        'metabolic': (r.nutritionScore ?? 0.0).toInt(),
      };
      final sortedTags = pillarScores.entries.toList()
        ..sort((a, b) => a.value.compareTo(b.value));
      // Naikkan kartu yang tag-nya cocok dengan pillar terlemah ke depan.
      for (var i = sortedTags.length - 1; i >= 0; i--) {
        final tag = sortedTags[i].key;
        final idx = base.indexWhere((c) => c['tag'] == tag);
        if (idx > 0) {
          final card = base.removeAt(idx);
          base.insert(0, card);
        }
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
              textMargin, textMargin, textMargin, textMargin / 2),
          child: Row(
            children: [
              Expanded(child: getTitleTexts(context, 'Untuk Kamu')),
              GestureDetector(
                onTap: () => context.go(AppRoutes.workouts),
                child: Text(
                  'Lihat semua →',
                  style: TextStyle(
                    color: subTextColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            primary: false,
            shrinkWrap: true,
            itemCount: base.length,
            padding: EdgeInsets.only(left: textMargin, right: textMargin / 2),
            itemBuilder: (context, i) {
              final card = base[i];
              final colors = card['colors'] as List<Color>;
              return GestureDetector(
                onTap: () => context.go(AppRoutes.workouts),
                child: Container(
                  width: 160,
                  margin: EdgeInsets.only(right: textMargin / 2),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: colors,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: colors.last.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.22),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          card['icon'] as IconData,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            card['title'] as String,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            card['subtitle'] as String,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.85),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ─── Recent Activity ─────────────────────────────────────────
  // Menampilkan latihan terakhir dengan relative-time untuk dorong
  // re-engagement ("ulangi" / "lanjutkan").
  Widget _buildRecentActivityCard(double textMargin) {
    final raw = _stats?.lastWorkoutAt;
    DateTime? last;
    if (raw != null && raw.isNotEmpty) {
      last = DateTime.tryParse(raw)?.toLocal();
    }
    final relative = last == null ? '-' : _relativeTime(last);

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: textMargin / 2,
        vertical: textMargin / 2,
      ),
      padding: EdgeInsets.all(textMargin),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: subTextColor.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.history_rounded,
              color: accentColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Latihan Terakhir',
                  style: TextStyle(
                    color: subTextColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  relative,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          OutlinedButton.icon(
            onPressed: () => context.go(AppRoutes.workouts),
            icon: const Icon(Icons.replay_rounded, size: 16),
            label: const Text('Ulangi'),
            style: OutlinedButton.styleFrom(
              foregroundColor: accentColor,
              side: BorderSide(color: accentColor.withOpacity(0.4)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _relativeTime(DateTime t) {
    final diff = DateTime.now().difference(t);
    if (diff.inMinutes < 1) return 'baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    if (diff.inDays < 7) return '${diff.inDays} hari lalu';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()} minggu lalu';
    return '${(diff.inDays / 30).floor()} bulan lalu';
  }

  Widget _buildStatCard(
      String value, String label, String icon, double textMargin) {
    double padding = ConstantWidget.getScreenPercentSize(context, 2);
    return Expanded(
      child: ConstantWidget.getShadowWidget(
        widget: Column(
          children: [
            SvgPicture.asset(
              Constants.assetsImagePath + icon,
              height: ConstantWidget.getScreenPercentSize(context, 4),
            ),
            SizedBox(
              height: ConstantWidget.getScreenPercentSize(context, 1.5),
            ),
            ConstantWidget.getTextWidget(
              value,
              textColor,
              TextAlign.start,
              FontWeight.w600,
              ConstantWidget.getScreenPercentSize(context, 2),
            ),
            SizedBox(
              height: ConstantWidget.getScreenPercentSize(context, 0.5),
            ),
            ConstantWidget.getTextWidget(
              label,
              subTextColor,
              TextAlign.start,
              FontWeight.w400,
              ConstantWidget.getScreenPercentSize(context, 1.6),
            ),
          ],
        ),
        margin: (textMargin / 2),
        radius: ConstantWidget.getScreenPercentSize(context, 2),
        topPadding: padding,
        bottomPadding: padding,
      ),
      flex: 1,
    );
  }

  Widget _buildActiveProgramCard(
      double sliderHeight, double sliderRadius, double textMargin) {
    double progress = (_stats?.programProgressPct ?? 0.0) / 100;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: textMargin),
      child: InkWell(
        onTap: () => context.push(AppRoutes.activeProgram),
        child: Container(
          width: double.infinity,
          height: sliderHeight,
          decoration: getDefaultDecoration(
            bgColor: category7,
            radius: sliderRadius,
          ),
          padding: EdgeInsets.symmetric(
            vertical: ConstantWidget.getPercentSize(sliderHeight, 15),
            horizontal: ConstantWidget.getWidthPercentSize(context, 4),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ConstantWidget.getTextWidgetWithFont(
                _stats?.activeProgramName ?? 'Current Program',
                textColor,
                TextAlign.start,
                FontWeight.w700,
                ConstantWidget.getPercentSize(sliderHeight, 11),
                Constants.fontsFamily,
              ),
              SizedBox(
                height: ConstantWidget.getPercentSize(sliderHeight, 3),
              ),
              ConstantWidget.getTextWidgetWithFont(
                'Tap to view details',
                textColor,
                TextAlign.start,
                FontWeight.w400,
                Constants.getPercentSize(sliderHeight, 8.5),
                Constants.fontsFamily,
              ),
              Expanded(child: Container(), flex: 1),
              LinearPercentIndicator(
                width: ConstantWidget.getWidthPercentSize(context, 80),
                lineHeight:
                    ConstantWidget.getPercentSize(sliderHeight, 4.5),
                percent: progress.clamp(0.0, 1.0),
                padding: EdgeInsets.zero,
                backgroundColor: Colors.white,
                barRadius: Radius.circular(
                  ConstantWidget.getPercentSize(sliderHeight, 8),
                ),
                progressColor: greenButton,
              ),
              SizedBox(
                height: ConstantWidget.getPercentSize(sliderHeight, 4),
              ),
              ConstantWidget.getTextWidgetWithFont(
                '${(_stats?.programProgressPct ?? 0).toStringAsFixed(0)}%',
                textColor,
                TextAlign.start,
                FontWeight.w400,
                Constants.getPercentSize(sliderHeight, 8),
                Constants.fontsFamily,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionGridCard(
    String label,
    String svgIcon,
    int index,
    VoidCallback onTap,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double size = constraints.maxWidth;
        final double radius = size * 0.12;
        return Material(
          color: getCellColor(index),
          borderRadius: BorderRadius.circular(radius),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: EdgeInsets.all(size * 0.08),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    Constants.assetsImagePath + svgIcon,
                    height: size * 0.3,
                    color: textColor,
                  ),
                  SizedBox(height: size * 0.06),
                  ConstantWidget.getTextWidgetWithFont(
                    label,
                    textColor,
                    TextAlign.center,
                    FontWeight.bold,
                    size * 0.11,
                    Constants.fontsFamily,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildError(double textMargin) {
    return Container(
      color: bgDarkWhite,
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(textMargin * 2),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: subTextColor),
              SizedBox(
                height: ConstantWidget.getScreenPercentSize(context, 2),
              ),
              ConstantWidget.getTextWidget(
                _error ?? 'Something went wrong',
                subTextColor,
                TextAlign.center,
                FontWeight.w400,
                ConstantWidget.getScreenPercentSize(context, 2),
              ),
              SizedBox(
                height: ConstantWidget.getScreenPercentSize(context, 2),
              ),
              ConstantWidget.getButtonWidget(
                  context, 'Retry', accentColor, _loadData),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHealthNewsSection(double textMargin) {
    if (_healthArticles.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
              textMargin, textMargin, textMargin, textMargin / 2),
          child: getTitleTexts(context, 'Berita Kesehatan'),
        ),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _healthArticles.length,
            padding: EdgeInsets.only(left: textMargin, right: textMargin / 2),
            itemBuilder: (context, i) {
              final article = _healthArticles[i];
              return GestureDetector(
                onTap: () => _showArticleDetail(article),
                child: Container(
                  width: 220,
                  margin: EdgeInsets.only(right: textMargin / 2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                        child: article.imageUrl != null && article.imageUrl!.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: article.imageUrl!,
                                height: 90,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: Colors.grey.shade100,
                                  child: const Center(
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.grey),
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: Colors.grey.shade200,
                                  child: const Icon(Icons.image_not_supported, color: Colors.grey),
                                ),
                              )
                            : Container(
                                height: 90,
                                color: Colors.grey.shade200,
                                child: const Icon(Icons.image, color: Colors.grey),
                              ),
                      ),
                      Expanded(
                        child: Padding(
                           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                           child: Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                             children: [
                               Text(
                                 (Localizations.localeOf(context).languageCode == 'en' && article.titleEn != null && article.titleEn!.isNotEmpty)
                                     ? article.titleEn!
                                     : article.title ?? '',
                                 maxLines: 2,
                                 overflow: TextOverflow.ellipsis,
                                 style: TextStyle(
                                   fontFamily: Constants.fontsFamily,
                                   fontSize: 13,
                                   fontWeight: FontWeight.bold,
                                   color: textColor,
                                 ),
                               ),
                               Row(
                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                 children: [
                                   Expanded(
                                     child: Text(
                                       article.source ?? 'Systemic Fitness',
                                       maxLines: 1,
                                       overflow: TextOverflow.ellipsis,
                                       style: TextStyle(
                                         fontFamily: Constants.fontsFamily,
                                         fontSize: 11,
                                         color: subTextColor,
                                       ),
                                     ),
                                   ),
                                 ],
                               ),
                             ],
                           ),
                         ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showArticleDetail(HealthArticleModel article) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          height: MediaQuery.of(context).size.height * 0.85,
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    if (article.imageUrl != null && article.imageUrl!.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: CachedNetworkImage(
                          imageUrl: article.imageUrl!,
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                    const SizedBox(height: 16),
                    Text(
                      (Localizations.localeOf(context).languageCode == 'en' && article.titleEn != null && article.titleEn!.isNotEmpty)
                          ? article.titleEn!
                          : article.title ?? '',
                      style: TextStyle(
                        fontFamily: Constants.fontsFamily,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      Localizations.localeOf(context).languageCode == 'en'
                          ? 'Source: ${article.source ?? "Systemic Fitness"}'
                          : 'Sumber: ${article.source ?? "Systemic Fitness"}',
                      style: TextStyle(
                        fontFamily: Constants.fontsFamily,
                        fontSize: 12,
                        color: subTextColor,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const Divider(height: 24),
                    Text(
                      (Localizations.localeOf(context).languageCode == 'en' && article.contentEn != null && article.contentEn!.isNotEmpty)
                          ? article.contentEn!
                          : article.content ?? '',
                      style: TextStyle(
                        fontFamily: Constants.fontsFamily,
                        fontSize: 14,
                        color: textColor,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDoctorVideosSection(double textMargin) {
    if (_doctorVideos.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
              textMargin, textMargin, textMargin, textMargin / 2),
          child: getTitleTexts(context, 'Rekomendasi Video Dokter'),
        ),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _doctorVideos.length,
            padding: EdgeInsets.only(left: textMargin, right: textMargin / 2),
            itemBuilder: (context, i) {
              final video = _doctorVideos[i];
              return GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => DoctorVideoPlayerDialog(video: video),
                  );
                },
                child: Container(
                  width: 220,
                  margin: EdgeInsets.only(right: textMargin / 2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                            ),
                            child: video.thumbnailUrl != null && video.thumbnailUrl!.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: video.thumbnailUrl!,
                                    height: 90,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Container(
                                      color: Colors.grey.shade100,
                                      child: const Center(
                                        child: SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.grey),
                                        ),
                                      ),
                                    ),
                                    errorWidget: (context, url, error) => Container(
                                      color: Colors.grey.shade200,
                                      child: const Icon(Icons.broken_image, color: Colors.grey),
                                    ),
                                  )
                                : Container(
                                    height: 90,
                                    color: Colors.grey.shade200,
                                    child: const Icon(Icons.video_library, color: Colors.grey),
                                  ),
                          ),
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.2),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(16),
                                  topRight: Radius.circular(16),
                                ),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.play_circle_fill,
                                  color: Colors.white,
                                  size: 36,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                (Localizations.localeOf(context).languageCode == 'en' && video.titleEn != null && video.titleEn!.isNotEmpty)
                                    ? video.titleEn!
                                    : video.title ?? '',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: Constants.fontsFamily,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                              Text(
                                '${video.doctorName ?? ""} (${video.doctorSpecialty ?? ""})',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: Constants.fontsFamily,
                                  fontSize: 11,
                                  color: subTextColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class DoctorVideoPlayerDialog extends StatefulWidget {
  final DoctorVideoModel video;
  const DoctorVideoPlayerDialog({super.key, required this.video});

  @override
  State<DoctorVideoPlayerDialog> createState() => _DoctorVideoPlayerDialogState();
}

class _DoctorVideoPlayerDialogState extends State<DoctorVideoPlayerDialog> {
  YoutubePlayerController? _controller;

  @override
  void initState() {
    super.initState();
    final videoId = YoutubePlayer.convertUrlToId(widget.video.videoUrl ?? '');
    if (videoId != null) {
      _controller = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(
          autoPlay: true,
          mute: false,
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Container(
        color: Colors.black,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_controller != null)
              YoutubePlayer(
                controller: _controller!,
                showVideoProgressIndicator: true,
              )
            else
              Container(
                height: 200,
                color: Colors.black,
                child: const Center(
                  child: Text(
                    'Cannot load video URL',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          (Localizations.localeOf(context).languageCode == 'en' && widget.video.titleEn != null && widget.video.titleEn!.isNotEmpty)
                              ? widget.video.titleEn!
                              : widget.video.title ?? '',
                          style: TextStyle(
                            fontFamily: Constants.fontsFamily,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${widget.video.doctorName ?? ""} (${widget.video.doctorSpecialty ?? ""})',
                          style: TextStyle(
                            fontFamily: Constants.fontsFamily,
                            fontSize: 12,
                            color: subTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.black54),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
