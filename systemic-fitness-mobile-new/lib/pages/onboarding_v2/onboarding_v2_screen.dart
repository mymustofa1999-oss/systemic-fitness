import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../ColorCategory.dart';
import '../../data/pref_data.dart';
import '../../router/app_router.dart';
import '../../util/sf_typography.dart';
import 'slide_1_signal.dart';
import 'slide_2_method.dart';
import 'slide_3_programs.dart';
import 'slide_4_score.dart';

// SF Onboarding v2 — wrapper PageView 4 slide.
// Reference: WhatsApp mockup 2026-04-20 at 07.32.19.jpeg + (1)/(2)/(20).jpeg
//
// Background: kSfDeepNavy (#0A1628). Pattern: StatefulWidget + setState +
// PageController, sesuai project preference (no Riverpod/Bloc).

class OnboardingV2Screen extends StatefulWidget {
  const OnboardingV2Screen({super.key});

  @override
  State<OnboardingV2Screen> createState() => _OnboardingV2ScreenState();
}

class _OnboardingV2ScreenState extends State<OnboardingV2Screen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  static const _totalSlides = 4;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int idx) {
    if (_currentIndex != idx) {
      setState(() => _currentIndex = idx);
    }
  }

  Future<void> _onNextPressed() async {
    if (_currentIndex < _totalSlides - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    } else {
      await PrefData.setIsIntro(false);
      if (!mounted) return;
      // Final CTA: arahkan ke login. Setelah login, splash logic akan
      // arahkan ke Assessment v2 (Phase 5) atau dashboard.
      context.go(AppRoutes.login);
    }
  }

  Future<void> _onSkipPressed() async {
    await PrefData.setIsIntro(false);
    if (!mounted) return;
    context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final isLastSlide = _currentIndex == _totalSlides - 1;
    final progressLabel = 'SLIDE ${_currentIndex + 1} / $_totalSlides';

    return Scaffold(
      backgroundColor: kSfDeepNavy,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: kSfDeepNavy,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
          systemNavigationBarColor: kSfDeepNavy,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top bar: progress label + Skip
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 14, 16, 4),
                child: Row(
                  children: [
                    Text(
                      progressLabel,
                      style: SfTypography.label(
                        fontSize: 11,
                        color: Colors.white.withOpacity(0.55),
                        letterSpacing: 1.4,
                      ),
                    ),
                    const Spacer(),
                    if (!isLastSlide)
                      TextButton(
                        onPressed: _onSkipPressed,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Lewati',
                          style: SfTypography.body(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.55),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Slides
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  physics: const ClampingScrollPhysics(),
                  children: const [
                    OnboardingSlide1(),
                    OnboardingSlide2(),
                    OnboardingSlide3(),
                    OnboardingSlide4(),
                  ],
                ),
              ),

              // Page indicator dots
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_totalSlides, (i) {
                    final active = i == _currentIndex;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOut,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: active ? 22 : 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: active
                            ? kSfWarmGold
                            : Colors.white.withOpacity(0.22),
                        borderRadius: BorderRadius.circular(99),
                      ),
                    );
                  }),
                ),
              ),

              // CTA
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 18),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _onNextPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isLastSlide ? kSfWarmGold : kSfMidnightBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      isLastSlide ? 'Temukan Program Saya  →' : 'Lanjut  →',
                      style: SfTypography.ctaPrimary(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
