import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:workout/ColorCategory.dart';
import 'package:workout/ConstantWidget.dart';
import 'package:workout/data/api_config.dart';
import 'package:workout/data/api_service.dart';
import 'package:workout/data/pref_data.dart';
import 'package:workout/router/app_router.dart';

/// Landing page shown after registration (or via dashboard CTA) that
/// explains the Basic Assessment and lets the user start or skip.
///
/// Also shows an "upgrade → complete paid assessment" banner when the
/// user already has an active paid subscription but hasn't completed
/// a paid assessment yet. This is the Phase 1 upgrade-prompt flow:
/// after upgrading to Basic/Pro/Elite, users are nudged to fill the
/// paid wizard with their metabolic lab values so the trainer can
/// review and produce a full systemic diagnosis.
class AssessmentIntroPage extends StatefulWidget {
  const AssessmentIntroPage({super.key});

  @override
  State<AssessmentIntroPage> createState() => _AssessmentIntroPageState();
}

class _AssessmentIntroPageState extends State<AssessmentIntroPage> {
  bool _showUpgradeBanner = false;

  @override
  void initState() {
    super.initState();
    _checkUpgradePrompt();
  }

  /// Shows the upgrade prompt when:
  ///   1. User has an active paid subscription, AND
  ///   2. User has NOT completed a paid assessment yet.
  ///
  /// Runs in the background; any failure silently hides the banner
  /// so the page remains usable.
  Future<void> _checkUpgradePrompt() async {
    try {
      final subFuture = ApiService.getWithRetry(ApiConfig.subscriptionMe);

      bool hasPaidAssessment = false;
      try {
        await ApiService.getWithRetry(
          ApiConfig.assessmentLatest,
          queryParams: {'tier': 'paid'},
        );
        hasPaidAssessment = true;
      } on ApiException catch (e) {
        if (e.statusCode != 404) rethrow;
      }

      final subResp = await subFuture;
      final data = subResp['data'];
      final sub = (data is Map<String, dynamic>) ? data['subscription'] : null;
      final status = (sub is Map<String, dynamic>)
          ? (sub['status'] as String?)?.toLowerCase()
          : null;
      final isActive = status == 'active';

      if (!mounted) return;
      setState(() {
        _showUpgradeBanner = isActive && !hasPaidAssessment;
      });
    } catch (e) {
      debugPrint('[AssessmentIntro] upgrade prompt check failed: $e');
    }
  }

  Future<void> _skip(BuildContext context) async {
    await PrefData.setAssessmentSkipped(true);
    if (context.mounted) context.go(AppRoutes.dashboard);
  }

  @override
  Widget build(BuildContext context) {
    final defMargin = ConstantWidget.getScreenPercentSize(context, 4);

    return Scaffold(
      backgroundColor: bgDarkWhite,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: defMargin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: ConstantWidget.getScreenPercentSize(context, 4)),
              ConstantWidget.getCustomText(
                'Basic Assessment',
                Colors.black,
                1,
                TextAlign.left,
                FontWeight.w700,
                ConstantWidget.getScreenPercentSize(context, 4),
              ),
              SizedBox(height: ConstantWidget.getScreenPercentSize(context, 1)),
              ConstantWidget.getCustomText(
                'Mari kita lihat kondisi tubuhmu sekarang. Ini adalah evaluasi dasar untuk 3 sistem inti.',
                subTextColor,
                3,
                TextAlign.left,
                FontWeight.w400,
                ConstantWidget.getScreenPercentSize(context, 2),
              ),
              SizedBox(height: ConstantWidget.getScreenPercentSize(context, 3)),
              if (_showUpgradeBanner) _UpgradeBanner(
                onTap: () => context.push(AppRoutes.assessmentPaid),
              ),
              SizedBox(height: ConstantWidget.getScreenPercentSize(context, 2)),
              _PillarCard(
                emoji: '😴',
                title: 'Recovery System',
                subtitle: 'Sleep & nervous system audit',
              ),
              _PillarCard(
                emoji: '🤸',
                title: 'Movement System',
                subtitle: 'Mobility & stability screening',
              ),
              _PillarCard(
                emoji: '🧪',
                title: 'Metabolic System',
                subtitle: 'Lab data (Paid)',
              ),
              const Spacer(),
              ConstantWidget.getButtonWidget(
                context,
                _showUpgradeBanner
                    ? 'Lengkapi Paid Assessment'
                    : 'Mulai Free Assessment',
                accentColor,
                () => context.go(
                  _showUpgradeBanner
                      ? AppRoutes.assessmentPaid
                      : AppRoutes.assessmentFree,
                ),
              ),
              SizedBox(height: ConstantWidget.getScreenPercentSize(context, 1)),
              TextButton(
                onPressed: () => _skip(context),
                child: Text(
                  'Lewati untuk sekarang',
                  style: TextStyle(color: subTextColor),
                ),
              ),
              SizedBox(height: ConstantWidget.getScreenPercentSize(context, 1)),
            ],
          ),
        ),
      ),
    );
  }
}

class _UpgradeBanner extends StatelessWidget {
  final VoidCallback onTap;
  const _UpgradeBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [accentColor.withOpacity(0.9), Colors.deepOrange.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            const Icon(Icons.workspace_premium, color: Colors.white, size: 28),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Upgrade Aktif!',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Lengkapi paid assessment kamu untuk diagnosis lengkap '
                    'dari trainer.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 14),
          ],
        ),
      ),
    );
  }
}

class _PillarCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  const _PillarCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        vertical: ConstantWidget.getScreenPercentSize(context, 0.8),
      ),
      padding: EdgeInsets.all(
        ConstantWidget.getScreenPercentSize(context, 2),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: subTextColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 32)),
          SizedBox(width: ConstantWidget.getScreenPercentSize(context, 2)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(color: subTextColor, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
