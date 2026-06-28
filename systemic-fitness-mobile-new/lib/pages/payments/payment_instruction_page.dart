import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:workout/ColorCategory.dart';
import 'package:workout/Constants.dart';
import 'package:workout/models/payment_model.dart';
import 'package:workout/router/app_router.dart';

/// Halaman instruksi pembayaran setelah customer memilih plan + metode.
///
/// Mendukung dua flow:
///   1. Manual transfer → tampilkan rekening bank tujuan + tombol upload bukti
///   2. Midtrans Snap   → tampilkan tombol "Bayar Sekarang" yang membuka
///      Snap WebView (route midtransPayment).
///
/// Saat ini hanya tampilan instruksi & upload entry-point — verifikasi
/// status real-time akan ditangani via halaman MyPayments / webhook.
class PaymentInstructionPage extends StatelessWidget {
  final ClientPaymentRecord? payment;
  final BankAccount? bankAccount;
  final String? planName;

  const PaymentInstructionPage({
    super.key,
    this.payment,
    this.bankAccount,
    this.planName,
  });

  bool get _isMidtrans =>
      payment?.paymentType == 'midtrans_snap' &&
      (payment?.snapRedirectUrl != null && payment!.snapRedirectUrl!.isNotEmpty);

  String _formatPrice(double? amount, String? currency) {
    if (amount == null) return '-';
    final cur = (currency ?? 'IDR').toUpperCase();
    if (cur == 'IDR') {
      final fmt = NumberFormat.currency(
        locale: 'id_ID',
        symbol: 'Rp ',
        decimalDigits: 0,
      );
      return fmt.format(amount);
    }
    return '$cur ${amount.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final fontFamily = Constants.fontsFamily;

    return Scaffold(
      backgroundColor: bgDarkWhite,
      appBar: AppBar(
        backgroundColor: bgDarkWhite,
        elevation: 0,
        title: Text(
          'Instruksi Pembayaran',
          style: TextStyle(
            fontFamily: fontFamily,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Summary card
              _summaryCard(fontFamily),
              const SizedBox(height: 24),

              if (_isMidtrans)
                _midtransSection(context, fontFamily)
              else
                _manualTransferSection(context, fontFamily),

              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.go(AppRoutes.myPayments),
                child: Text(
                  'Lihat Riwayat Pembayaran',
                  style: TextStyle(
                    fontFamily: fontFamily,
                    color: blueButton,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Summary card ────────────────────────────────────────────────

  Widget _summaryCard(String fontFamily) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [blueButton.withOpacity(0.92), blueButton],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: blueButton.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            (planName ?? 'Subscription').toUpperCase(),
            style: TextStyle(
              fontFamily: fontFamily,
              color: Colors.white.withOpacity(0.85),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _formatPrice(payment?.amount, payment?.currency),
            style: TextStyle(
              fontFamily: fontFamily,
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Icon(Icons.receipt_long_rounded,
                  size: 14, color: Colors.white.withOpacity(0.85)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  payment?.id != null
                      ? 'Order ID: ${payment!.id}'
                      : 'Order ID: -',
                  style: TextStyle(
                    fontFamily: fontFamily,
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 11.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.access_time_rounded,
                  size: 14, color: Colors.white.withOpacity(0.85)),
              const SizedBox(width: 6),
              Text(
                'Status: ${(payment?.status ?? 'pending').toUpperCase()}',
                style: TextStyle(
                  fontFamily: fontFamily,
                  color: Colors.white.withOpacity(0.85),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Manual transfer ─────────────────────────────────────────────

  Widget _manualTransferSection(BuildContext context, String fontFamily) {
    final bank = bankAccount;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionHeader('Transfer Bank', Icons.account_balance_rounded, fontFamily),
        const SizedBox(height: 12),

        if (bank == null)
          _emptyState('Bank tujuan belum tersedia. Hubungi admin.', fontFamily)
        else
          _bankCard(context, bank, fontFamily),

        const SizedBox(height: 18),
        _instructionList(fontFamily),
        const SizedBox(height: 18),

        ElevatedButton.icon(
          onPressed: () {
            if (payment?.id == null) {
              Fluttertoast.showToast(msg: 'Order ID tidak ditemukan');
              return;
            }
            context.push(
              AppRoutes.uploadProof,
              extra: {
                'payment_id': payment!.id,
                'amount': payment?.amount,
                'currency': payment?.currency,
              },
            );
          },
          icon: const Icon(Icons.upload_file_rounded, color: Colors.white),
          label: Text(
            'Upload Bukti Transfer',
            style: TextStyle(
              fontFamily: fontFamily,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: greenButton,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _bankCard(BuildContext context, BankAccount bank, String fontFamily) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: blueButton.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  (bank.bankName ?? 'BANK').toUpperCase(),
                  style: TextStyle(
                    fontFamily: fontFamily,
                    color: blueButton,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            bank.accountNumber ?? '-',
            style: TextStyle(
              fontFamily: fontFamily,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: textColor,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'a.n. ${bank.accountHolder ?? '-'}',
            style: TextStyle(
              fontFamily: fontFamily,
              fontSize: 13,
              color: subTextColor,
            ),
          ),
          if (bank.branch != null && bank.branch!.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              bank.branch!,
              style: TextStyle(
                fontFamily: fontFamily,
                fontSize: 12,
                color: subTextColor.withOpacity(0.8),
              ),
            ),
          ],
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: () async {
              await Clipboard.setData(
                  ClipboardData(text: bank.accountNumber ?? ''));
              Fluttertoast.showToast(msg: 'Nomor rekening disalin');
            },
            icon: Icon(Icons.copy_rounded, size: 16, color: blueButton),
            label: Text(
              'Salin Nomor Rekening',
              style: TextStyle(
                fontFamily: fontFamily,
                color: blueButton,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: blueButton.withOpacity(0.5)),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _instructionList(String fontFamily) {
    final steps = [
      'Transfer **tepat** sebesar nominal di atas (termasuk angka unik kalau ada).',
      'Sertakan **Order ID** di berita transfer agar mempercepat verifikasi.',
      'Setelah transfer, **upload bukti** lewat tombol di bawah.',
      'Admin akan memverifikasi dalam **maks. 1×24 jam**.',
      'Status pembayaran bisa kamu cek di **Riwayat Pembayaran**.',
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cara Pembayaran',
            style: TextStyle(
              fontFamily: fontFamily,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          ...List.generate(steps.length, (i) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 18,
                    height: 18,
                    margin: const EdgeInsets.only(top: 1.5),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: blueButton.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${i + 1}',
                      style: TextStyle(
                        fontFamily: fontFamily,
                        fontSize: 10,
                        color: blueButton,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      steps[i].replaceAll('**', ''),
                      style: TextStyle(
                        fontFamily: fontFamily,
                        fontSize: 12.5,
                        color: subTextColor,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ── Midtrans (Snap) ─────────────────────────────────────────────

  Widget _midtransSection(BuildContext context, String fontFamily) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionHeader(
            'Midtrans Snap', Icons.credit_card_rounded, fontFamily),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'Lanjutkan ke halaman pembayaran Midtrans untuk memilih metode '
            '(VA Bank, QRIS, e-wallet, kartu kredit, dll). Status akan '
            'otomatis ter-update setelah pembayaran berhasil.',
            style: TextStyle(
              fontFamily: fontFamily,
              fontSize: 12.5,
              color: subTextColor,
              height: 1.45,
            ),
          ),
        ),
        const SizedBox(height: 18),
        ElevatedButton.icon(
          onPressed: () {
            context.push(
              AppRoutes.midtransPayment,
              extra: {
                'redirect_url': payment!.snapRedirectUrl!,
                'order_id': payment?.externalId,
              },
            );
          },
          icon: const Icon(Icons.payment_rounded, color: Colors.white),
          label: Text(
            'Bayar Sekarang',
            style: TextStyle(
              fontFamily: fontFamily,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: blueButton,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────

  Widget _sectionHeader(String title, IconData icon, String fontFamily) {
    return Row(
      children: [
        Icon(icon, size: 18, color: textColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontFamily: fontFamily,
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
      ],
    );
  }

  Widget _emptyState(String message, String fontFamily) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.amber.shade800),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontFamily: fontFamily,
                fontSize: 12.5,
                color: Colors.amber.shade900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
