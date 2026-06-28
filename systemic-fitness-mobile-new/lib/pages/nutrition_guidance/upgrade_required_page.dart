import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:workout/router/app_router.dart';

class NutritionGuidanceUpgradePage extends StatelessWidget {
  const NutritionGuidanceUpgradePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nutrition Guidance')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.lock_outline, size: 80, color: Colors.orange),
            const SizedBox(height: 24),
            const Text(
              'Fitur Khusus Member Berbayar',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'Nutrition Guidance & Monitoring Engine memberikan rekomendasi diet personal berdasarkan kondisi kesehatan, alergi, dan tujuan kamu — plus skor harian untuk memonitor kepatuhan.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.subscription),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Lihat Paket Berlangganan'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => context.pop(),
              child: const Text('Nanti Saja'),
            ),
          ],
        ),
      ),
    );
  }
}
