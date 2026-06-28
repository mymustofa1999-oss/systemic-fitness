import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:workout/ColorCategory.dart';
import 'package:workout/Constants.dart';
import 'package:workout/data/api_config.dart';
import 'package:workout/data/api_service.dart';
import 'package:workout/models/payment_model.dart';

/// Riwayat pembayaran customer.
///
/// Menampilkan daftar `payment_records` dari endpoint
/// GET /subscription/payments dengan badge status (pending/completed/
/// failed/refunded), nominal, tanggal, dan indikator bukti transfer.
class MyPaymentsPage extends StatefulWidget {
  const MyPaymentsPage({super.key});

  @override
  State<MyPaymentsPage> createState() => _MyPaymentsPageState();
}

class _MyPaymentsPageState extends State<MyPaymentsPage> {
  List<ClientPaymentRecord> _records = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await ApiService.getWithRetry(
        ApiConfig.subscriptionPayments,
        queryParams: {'page': '1', 'limit': '50'},
      );
      if (!mounted) return;
      final list = (res['data'] as List?) ?? [];
      setState(() {
        _records = list
            .map((e) => ClientPaymentRecord.fromJson(
                Map<String, dynamic>.from(e as Map)))
            .toList();
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Gagal memuat riwayat pembayaran';
        _loading = false;
      });
    }
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
          'Riwayat Pembayaran',
          style: TextStyle(
            fontFamily: fontFamily,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: textColor),
            onPressed: _load,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildError(fontFamily)
              : _records.isEmpty
                  ? _buildEmpty(fontFamily)
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _records.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, i) => _paymentCard(_records[i]),
                      ),
                    ),
    );
  }

  Widget _paymentCard(ClientPaymentRecord r) {
    final fontFamily = Constants.fontsFamily;
    final statusInfo = _statusInfo(r.status ?? 'pending');

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: subTextColor.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _formatAmount(r.amount, r.currency),
                  style: TextStyle(
                    fontFamily: fontFamily,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                  ),
                ),
              ),
              _statusBadge(statusInfo, fontFamily),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.calendar_today_rounded,
                  size: 12, color: subTextColor),
              const SizedBox(width: 4),
              Text(
                _formatDate(r.createdAt),
                style: TextStyle(
                  fontFamily: fontFamily,
                  fontSize: 11.5,
                  color: subTextColor,
                ),
              ),
              const SizedBox(width: 12),
              Icon(_paymentIcon(r.paymentType),
                  size: 12, color: subTextColor),
              const SizedBox(width: 4),
              Text(
                _paymentLabel(r.paymentType),
                style: TextStyle(
                  fontFamily: fontFamily,
                  fontSize: 11.5,
                  color: subTextColor,
                ),
              ),
            ],
          ),
          if (r.id != null) ...[
            const SizedBox(height: 4),
            Text(
              'Order ID: ${r.id}',
              style: TextStyle(
                fontFamily: fontFamily,
                fontSize: 10.5,
                color: subTextColor.withOpacity(0.7),
              ),
            ),
          ],
          // Manual transfer + status pending → tombol upload bukti
          if ((r.status ?? '') == 'pending' &&
              r.paymentType == 'manual_transfer' &&
              !r.hasProof) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  if (r.id == null) return;
                  context.push(
                    '/payments/upload-proof',
                    extra: {
                      'payment_id': r.id,
                      'amount': r.amount,
                      'currency': r.currency,
                    },
                  );
                },
                icon: Icon(Icons.upload_file_rounded,
                    size: 16, color: greenButton),
                label: Text(
                  'Upload Bukti Transfer',
                  style: TextStyle(
                    fontFamily: fontFamily,
                    color: greenButton,
                    fontWeight: FontWeight.w600,
                    fontSize: 12.5,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: greenButton.withOpacity(0.6)),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
          if ((r.status ?? '') == 'pending' && r.hasProof) ...[
            const SizedBox(height: 10),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.hourglass_top_rounded,
                      size: 14, color: Colors.amber.shade800),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Bukti sudah dikirim, menunggu verifikasi admin',
                      style: TextStyle(
                        fontFamily: fontFamily,
                        fontSize: 11.5,
                        color: Colors.amber.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _statusBadge(_StatusInfo info, String fontFamily) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: info.color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        info.label,
        style: TextStyle(
          fontFamily: fontFamily,
          color: info.color,
          fontWeight: FontWeight.w700,
          fontSize: 10.5,
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────

  String _formatAmount(double? amount, String? currency) {
    if (amount == null) return '-';
    final cur = (currency ?? 'IDR').toUpperCase();
    if (cur == 'IDR') {
      return NumberFormat.currency(
        locale: 'id_ID',
        symbol: 'Rp ',
        decimalDigits: 0,
      ).format(amount);
    }
    return '$cur ${amount.toStringAsFixed(2)}';
  }

  String _formatDate(String? iso) {
    if (iso == null) return '-';
    try {
      final dt = DateTime.parse(iso).toLocal();
      return DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(dt);
    } catch (_) {
      return iso;
    }
  }

  IconData _paymentIcon(String? paymentType) {
    switch (paymentType) {
      case 'midtrans_snap':
        return Icons.credit_card_rounded;
      case 'manual_transfer':
      default:
        return Icons.account_balance_rounded;
    }
  }

  String _paymentLabel(String? paymentType) {
    switch (paymentType) {
      case 'midtrans_snap':
        return 'Midtrans';
      case 'manual_transfer':
      default:
        return 'Transfer Bank';
    }
  }

  _StatusInfo _statusInfo(String status) {
    switch (status) {
      case 'completed':
        return _StatusInfo('LUNAS', greenButton);
      case 'failed':
        return _StatusInfo('GAGAL', Colors.red.shade600);
      case 'refunded':
        return _StatusInfo('REFUND', Colors.blueGrey);
      case 'pending':
      default:
        return _StatusInfo('MENUNGGU', Colors.amber.shade800);
    }
  }

  Widget _buildError(String fontFamily) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline,
                size: 56, color: subTextColor.withOpacity(0.4)),
            const SizedBox(height: 12),
            Text(
              _error ?? 'Terjadi kesalahan',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: fontFamily,
                color: subTextColor,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _load,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(String fontFamily) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_rounded,
                size: 64, color: subTextColor.withOpacity(0.4)),
            const SizedBox(height: 12),
            Text(
              'Belum ada pembayaran',
              style: TextStyle(
                fontFamily: fontFamily,
                fontWeight: FontWeight.w700,
                color: textColor,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Riwayat transaksi langgananmu akan muncul di sini',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: fontFamily,
                color: subTextColor,
                fontSize: 12.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusInfo {
  final String label;
  final Color color;
  _StatusInfo(this.label, this.color);
}
