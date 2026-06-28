import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:workout/ColorCategory.dart';
import 'package:workout/Constants.dart';
import 'package:workout/router/app_router.dart';

/// Halaman hasil pembayaran Midtrans.
///
/// Ditampilkan setelah WebView mendeteksi redirect ke finish URL.
/// Menerima `status` ('success', 'pending', 'error') dan `orderId`
/// opsional untuk ditampilkan.
class PaymentResultPage extends StatelessWidget {
  final String status; // 'success' | 'pending' | 'error'
  final String? orderId;

  const PaymentResultPage({
    super.key,
    required this.status,
    this.orderId,
  });

  @override
  Widget build(BuildContext context) {
    final fontFamily = Constants.fontsFamily;
    final isSuccess = status == 'success' || status == 'settlement' || status == 'capture';
    final isPending = status == 'pending';

    final IconData icon;
    final Color iconBgColor;
    final Color iconColor;
    final String title;
    final String subtitle;

    if (isSuccess) {
      icon = Icons.check_circle_rounded;
      iconBgColor = const Color(0xFF10B981).withOpacity(0.12);
      iconColor = const Color(0xFF10B981);
      title = 'Pembayaran Berhasil! 🎉';
      subtitle =
          'Terima kasih! Langganan kamu sudah aktif. '
          'Nikmati semua fitur premium Systemic Fitness.';
    } else if (isPending) {
      icon = Icons.schedule_rounded;
      iconBgColor = const Color(0xFFF59E0B).withOpacity(0.12);
      iconColor = const Color(0xFFF59E0B);
      title = 'Menunggu Pembayaran';
      subtitle =
          'Silakan selesaikan pembayaran sesuai instruksi. '
          'Status akan diperbarui otomatis setelah kami menerima pembayaran.';
    } else {
      icon = Icons.cancel_rounded;
      iconBgColor = const Color(0xFFEF4444).withOpacity(0.12);
      iconColor = const Color(0xFFEF4444);
      title = 'Pembayaran Gagal';
      subtitle =
          'Pembayaran tidak berhasil diproses. '
          'Silakan coba lagi atau gunakan metode pembayaran lain.';
    }

    return Scaffold(
      backgroundColor: bgDarkWhite,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // ── Icon ────────────────────────────────
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 56, color: iconColor),
              ),
              const SizedBox(height: 28),

              // ── Title ───────────────────────────────
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: fontFamily,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 12),

              // ── Subtitle ────────────────────────────
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: fontFamily,
                  fontSize: 14,
                  color: subTextColor,
                  height: 1.6,
                ),
              ),

              // ── Order ID ────────────────────────────
              if (orderId != null && orderId!.isNotEmpty) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.receipt_long_rounded,
                          size: 16, color: subTextColor),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'Order: ${orderId!}',
                          style: TextStyle(
                            fontFamily: fontFamily,
                            fontSize: 12,
                            color: subTextColor,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const Spacer(flex: 3),

              // ── Primary CTA ─────────────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.go(AppRoutes.myPayments),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: blueButton,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Lihat Riwayat Pembayaran',
                    style: TextStyle(
                      fontFamily: fontFamily,
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // ── Secondary CTA ───────────────────────
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => context.go(AppRoutes.dashboard),
                  child: Text(
                    'Kembali ke Beranda',
                    style: TextStyle(
                      fontFamily: fontFamily,
                      color: subTextColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
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
