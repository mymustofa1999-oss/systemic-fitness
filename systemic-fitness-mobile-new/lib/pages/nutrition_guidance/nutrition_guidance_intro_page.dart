import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:workout/data/api_service.dart';
import 'package:workout/data/nutrition_guidance_repository.dart';
import 'package:workout/router/app_router.dart';

/// Landing page that loads the user's existing plan (if any) and routes
/// to the form (first time) or the plan page (returning user).
class NutritionGuidanceIntroPage extends StatefulWidget {
  const NutritionGuidanceIntroPage({super.key});

  @override
  State<NutritionGuidanceIntroPage> createState() =>
      _NutritionGuidanceIntroPageState();
}

class _NutritionGuidanceIntroPageState
    extends State<NutritionGuidanceIntroPage> {
  bool _checking = true;

  @override
  void initState() {
    super.initState();
    _checkProfile();
  }

  Future<void> _checkProfile() async {
    try {
      await NutritionGuidanceRepository.getPlan();
      if (!mounted) return;
      // pushReplacement preserves the dashboard in the nav stack so back
      // returns to it instead of exiting the app.
      context.pushReplacement(AppRoutes.nutritionGuidancePlan);
    } on PaidSubscriptionRequiredException {
      if (!mounted) return;
      context.pushReplacement(AppRoutes.nutritionGuidanceUpgrade);
    } on ApiException catch (e) {
      if (!mounted) return;
      // 404 = profile not yet created → show intro
      setState(() => _checking = false);
      if (e.statusCode != 404) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _checking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Nutrition Guidance')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            const Icon(Icons.restaurant_menu, size: 72, color: Colors.green),
            const SizedBox(height: 24),
            const Text(
              'Panduan Nutrisi Personal',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'Lengkapi profil kesehatanmu untuk mendapatkan rencana diet yang disesuaikan dengan kondisi medis, alergi, dan tujuanmu. Lalu pantau kepatuhanmu setiap hari.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () => context.push(AppRoutes.nutritionGuidanceProfile),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Lengkapi Profil Kesehatan'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
