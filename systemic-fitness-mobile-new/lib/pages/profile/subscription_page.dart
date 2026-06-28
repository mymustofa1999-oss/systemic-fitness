import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:workout/ColorCategory.dart';
import 'package:workout/Constants.dart';
import 'package:workout/data/api_config.dart';
import 'package:workout/data/api_service.dart';
import 'package:workout/models/payment_model.dart';
import 'package:workout/router/app_router.dart';
import 'package:workout/widgets/loading_widget.dart';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  bool _isLoading = true;
  String? _error;
  List<PlanGroup> _planGroups = [];
  MySubscriptionResult? _mySub;
  bool _showAnnual = false;
  bool _subscribing = false;
  bool _cancelling = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        ApiService.getWithRetry(ApiConfig.subscriptionPlans),
        ApiService.getWithRetry(ApiConfig.subscriptionMe),
      ]);

      final plansData = results[0]['data'];
      final List<PlanGroup> groups = [];
      if (plansData is List) {
        for (final item in plansData) {
          groups.add(PlanGroup.fromJson(item));
        }
      }

      final subData = results[1]['data'];
      final mySub = subData != null
          ? MySubscriptionResult.fromJson(subData)
          : MySubscriptionResult();

      if (mounted) {
        setState(() {
          _planGroups = groups;
          _mySub = mySub;
          _isLoading = false;
        });
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _error = e.message;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Gagal memuat data langganan.';
          _isLoading = false;
        });
      }
    }
  }

  String _formatPrice(double? price, String? currency) {
    if (price == null) return 'Free';
    final cur = currency?.toUpperCase() ?? 'IDR';
    if (cur == 'IDR') {
      final formatter = NumberFormat('#,###', 'id_ID');
      return 'Rp ${formatter.format(price.toInt())}';
    }
    return '$cur ${price.toStringAsFixed(0)}';
  }

  Color _tierColor(String? tier) {
    switch (tier) {
      case 'pro':
        return blueButton;
      case 'elite':
        return const Color(0xFFD97706);
      default:
        return subTextColor;
    }
  }

  IconData _tierIcon(String? tier) {
    switch (tier) {
      case 'pro':
        return Icons.star;
      case 'elite':
        return Icons.workspace_premium;
      default:
        return Icons.bolt;
    }
  }

  Future<void> _onSubscribe(ClientPlan plan) async {
    if (_mySub?.hasSubscription == true) {
      Fluttertoast.showToast(
        msg: 'Kamu sudah punya langganan aktif. Batalkan dulu untuk ganti plan.',
        backgroundColor: Colors.red.shade700,
        textColor: Colors.white,
      );
      return;
    }

    // 1. Customer pilih metode pembayaran (manual / midtrans)
    final paymentType = await _pickPaymentMethod(plan);
    if (paymentType == null) return;

    setState(() => _subscribing = true);
    try {
      final res = await ApiService.postWithRetry(
        ApiConfig.subscriptionSubscribe,
        body: {
          'plan_id': plan.id,
          'payment_method': paymentType == 'midtrans_snap'
              ? 'midtrans'
              : 'bank_transfer',
          'payment_type': paymentType,
        },
      );

      if (!mounted) return;

      // Parse SubscribeResult dari response
      final data = Map<String, dynamic>.from(res['data'] ?? {});
      final subscribeResult = SubscribeResult.fromJson(data);

      await _loadData();
      if (!mounted) return;

      // Tutup loading state agar navigation lancar
      setState(() => _subscribing = false);

      // 2. Navigate ke halaman instruksi pembayaran
      await context.push(
        AppRoutes.paymentInstruction,
        extra: {
          'payment': subscribeResult.payment,
          'bank_account': subscribeResult.bankAccount,
          'plan_name': plan.name,
        },
      );

      // 3. Setelah customer kembali, reload data dan cek apakah payment sudah confirmed
      if (!mounted) return;
      await _loadData();
      // Hanya tampilkan modal jika subscription sudah aktif (payment confirmed)
      if (!mounted) return;
      if (_mySub?.subscription != null && _mySub!.subscription!.status == 'active') {
        await _showSubscriptionSuccessModal(plan);
      }
    } on ApiException catch (e) {
      Fluttertoast.showToast(
        msg: e.message,
        backgroundColor: Colors.red.shade700,
        textColor: Colors.white,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Gagal berlangganan. Coba lagi.',
        backgroundColor: Colors.red.shade700,
        textColor: Colors.white,
      );
    }
    if (mounted) setState(() => _subscribing = false);
  }

  /// Modal pilih metode pembayaran. Return:
  ///   - "manual_transfer"
  ///   - "midtrans_snap"
  ///   - null kalau customer batal
  Future<String?> _pickPaymentMethod(ClientPlan plan) async {
    final fontFamily = Constants.fontsFamily;
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: subTextColor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Pilih Metode Pembayaran',
                style: TextStyle(
                  fontFamily: fontFamily,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${plan.name} • ${_formatPrice(plan.price, plan.currency)}/'
                '${plan.billingPeriod == 'annual' ? 'tahun' : 'bulan'}',
                style: TextStyle(
                  fontFamily: fontFamily,
                  fontSize: 12.5,
                  color: subTextColor,
                ),
              ),
              const SizedBox(height: 18),

              _paymentMethodTile(
                icon: Icons.account_balance_rounded,
                title: 'Transfer Bank Manual',
                subtitle: 'Transfer ke rekening kami, upload bukti, '
                    'admin verifikasi (1×24 jam)',
                onTap: () => Navigator.pop(ctx, 'manual_transfer'),
                color: greenButton,
              ),
              const SizedBox(height: 10),
              _paymentMethodTile(
                icon: Icons.credit_card_rounded,
                title: 'Midtrans (Otomatis)',
                subtitle: 'VA Bank, QRIS, e-wallet, kartu kredit — '
                    'status update otomatis',
                onTap: () => Navigator.pop(ctx, 'midtrans_snap'),
                color: blueButton,
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(ctx, null),
                child: Text(
                  'Batal',
                  style: TextStyle(
                    fontFamily: fontFamily,
                    color: subTextColor,
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

  Widget _paymentMethodTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color color,
  }) {
    final fontFamily = Constants.fontsFamily;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            border: Border.all(color: color.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(12),
            color: color.withOpacity(0.04),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: fontFamily,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontFamily: fontFamily,
                        fontSize: 11.5,
                        color: subTextColor,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: color),
            ],
          ),
        ),
      ),
    );
  }

  /// Modal sukses berlangganan: jelaskan fitur yang baru di-unlock dan
  /// arahkan customer langsung ke Nutrition Guidance sebagai entry point
  /// utama. Tanpa modal ini fitur paid sangat mudah ke-skip karena
  /// customer harus discover sendiri lewat Quick Actions di Dashboard.
  Future<void> _showSubscriptionSuccessModal(ClientPlan plan) async {
    final fontFamily = Constants.fontsFamily;
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Celebration icon
              Center(
                child: Container(
                  width: 72,
                  height: 72,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: greenButton.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.celebration_rounded,
                    size: 40,
                    color: greenButton,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                'Selamat, Berlangganan Berhasil! 🎉',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: fontFamily,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Kamu sekarang berlangganan ${plan.name}. Setelah pembayaran terkonfirmasi, semua fitur premium di bawah ini langsung bisa kamu pakai:',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: fontFamily,
                  fontSize: 13,
                  color: subTextColor,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 18),

              // Feature list
              _featureRow(
                Icons.psychology_alt_rounded,
                'Nutrition Guidance',
                'Rencana diet personal berdasarkan kondisi kesehatan & alergi',
              ),
              const SizedBox(height: 10),
              _featureRow(
                Icons.assessment_rounded,
                'Paid Assessment',
                'Evaluasi fitness mendalam dengan rekomendasi program',
              ),
              const SizedBox(height: 10),
              _featureRow(
                Icons.workspace_premium_rounded,
                'Akses Premium',
                'Semua program, challenges, dan konten coach eksklusif',
              ),
              const SizedBox(height: 22),

              // Primary CTA: open Nutrition Guidance immediately
              ElevatedButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  context.push(AppRoutes.nutritionGuidanceIntro);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: greenButton,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Mulai Nutrition Guidance',
                  style: TextStyle(
                    fontFamily: fontFamily,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(
                  'Nanti Saja',
                  style: TextStyle(
                    fontFamily: fontFamily,
                    color: subTextColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _featureRow(IconData icon, String title, String desc) {
    final fontFamily = Constants.fontsFamily;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: blueButton.withOpacity(0.10),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: blueButton),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontFamily: fontFamily,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: TextStyle(
                  fontFamily: fontFamily,
                  fontSize: 12,
                  color: subTextColor,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _onCancel() async {
    final sub = _mySub?.subscription;
    if (sub?.id == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Batalkan Langganan?',
          style: TextStyle(
            fontFamily: Constants.fontsFamily,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Langganan ${sub?.planName} akan dibatalkan. Kamu tetap bisa mengakses fitur sampai masa aktif berakhir.',
          style: TextStyle(fontFamily: Constants.fontsFamily, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Tidak', style: TextStyle(fontFamily: Constants.fontsFamily)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Ya, Batalkan', style: TextStyle(fontFamily: Constants.fontsFamily, color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await ApiService.postWithRetry(ApiConfig.subscriptionCancel(sub!.id!));
      Fluttertoast.showToast(
        msg: 'Langganan berhasil dibatalkan.',
        backgroundColor: greenButton,
        textColor: Colors.white,
      );
      await _loadData();
    } on ApiException catch (e) {
      Fluttertoast.showToast(
        msg: e.message,
        backgroundColor: Colors.red.shade700,
        textColor: Colors.white,
      );
    } catch (_) {
      Fluttertoast.showToast(
        msg: 'Gagal membatalkan langganan.',
        backgroundColor: Colors.red.shade700,
        textColor: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: accentColor),
          onPressed: () {
            // Subscription bisa dibuka langsung via deep link / setelah login;
            // kalau stack kosong, fallback ke Profile tab supaya tidak crash.
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.profile);
            }
          },
        ),
        title: Text(
          'Langganan',
          style: TextStyle(
            fontFamily: Constants.fontsFamily,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: accentColor,
          ),
        ),
        centerTitle: true,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: LoadingWidget());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: subTextColor),
            const SizedBox(height: 12),
            Text(
              _error!,
              style: TextStyle(
                fontFamily: Constants.fontsFamily,
                fontSize: 14,
                color: subTextColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _loadData,
              child: Text(
                'Coba Lagi',
                style: TextStyle(
                  fontFamily: Constants.fontsFamily,
                  color: blueButton,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final subStatus = _mySub?.subscription?.status?.toLowerCase();
    final isPending = _mySub?.hasSubscription == true && subStatus == 'pending';
    final isActive = _mySub?.hasSubscription == true && subStatus == 'active';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Pending subscription banner — strict gating: sub created but
        // payment not yet verified. Show CTA to complete payment.
        if (isPending) ...[
          _buildPendingSubscriptionBanner(),
          const SizedBox(height: 20),
        ],

        // Active subscription card
        if (isActive) ...[
          _buildActiveSubscriptionCard(),
          const SizedBox(height: 20),
        ],

        // Comparison banner
        _buildComparisonBanner(),
        const SizedBox(height: 20),

        // Billing toggle
        _buildBillingToggle(),
        const SizedBox(height: 16),

        // Plan cards
        ..._planGroups.map((group) => _buildPlanGroupCard(group)),

        const SizedBox(height: 24),
      ],
    );
  }

  /// Banner untuk customer yang sudah subscribe tapi pembayarannya belum
  /// diverifikasi (status='pending'). Strict gating: customer harus
  /// menyelesaikan pembayaran sebelum subscription jadi 'active'.
  ///
  /// Berisi 2 aksi:
  ///   - Tap banner / "Lihat Detail" → MyPaymentsPage (lanjut bayar / upload bukti)
  ///   - "Batalkan" → confirm dialog → cancel pending sub via API
  Widget _buildPendingSubscriptionBanner() {
    final sub = _mySub!.subscription!;
    final fontFamily = Constants.fontsFamily;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.amber.shade600,
            Colors.amber.shade700,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.20),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.hourglass_top_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MENUNGGU PEMBAYARAN',
                      style: TextStyle(
                        fontFamily: fontFamily,
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      sub.planName ?? 'Langganan kamu',
                      style: TextStyle(
                        fontFamily: fontFamily,
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Selesaikan pembayaran agar langgananmu aktif',
                      style: TextStyle(
                        fontFamily: fontFamily,
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 12,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => context.push(AppRoutes.myPayments),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      alignment: Alignment.center,
                      child: Text(
                        'Lanjut Bayar',
                        style: TextStyle(
                          fontFamily: fontFamily,
                          color: Colors.amber.shade800,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Material(
                  color: Colors.white.withOpacity(0.20),
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: _cancelling
                        ? null
                        : () => _confirmCancelPendingSubscription(sub),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      alignment: Alignment.center,
                      child: _cancelling
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'Batalkan',
                              style: TextStyle(
                                fontFamily: fontFamily,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Confirm dialog lalu panggil POST /subscription/{id}/cancel.
  /// Strict gating: pending sub HARUS di-cancel dulu kalau customer mau
  /// pilih plan lain atau metode pembayaran yang berbeda.
  Future<void> _confirmCancelPendingSubscription(
    ClientSubscription sub,
  ) async {
    final fontFamily = Constants.fontsFamily;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Batalkan Langganan?',
          style: TextStyle(
            fontFamily: fontFamily,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'Pembayaran untuk ${sub.planName ?? 'langganan ini'} akan dibatalkan. '
          'Kamu bisa subscribe ulang dengan plan atau metode pembayaran lain kapan saja.',
          style: TextStyle(fontFamily: fontFamily, fontSize: 13.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Tidak',
              style: TextStyle(fontFamily: fontFamily, color: subTextColor),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(
              'Ya, Batalkan',
              style: TextStyle(
                fontFamily: fontFamily,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (sub.id == null) return;

    setState(() => _cancelling = true);
    try {
      await ApiService.postWithRetry(ApiConfig.subscriptionCancel(sub.id!));
      if (!mounted) return;
      Fluttertoast.showToast(
        msg: 'Langganan berhasil dibatalkan',
        backgroundColor: greenButton,
        textColor: Colors.white,
      );
      // Reload so banner disappears & plan cards re-enabled.
      await _loadData();
    } on ApiException catch (e) {
      if (!mounted) return;
      Fluttertoast.showToast(
        msg: e.message,
        backgroundColor: Colors.red.shade700,
        textColor: Colors.white,
      );
    } catch (e) {
      if (!mounted) return;
      Fluttertoast.showToast(
        msg: 'Gagal membatalkan langganan',
        backgroundColor: Colors.red.shade700,
        textColor: Colors.white,
      );
    } finally {
      if (mounted) setState(() => _cancelling = false);
    }
  }

  Widget _buildActiveSubscriptionCard() {
    final sub = _mySub!.subscription!;
    final days = _mySub!.daysRemaining ?? 0;
    final isActive = sub.status?.toLowerCase() == 'active';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_tierColor(sub.tier), _tierColor(sub.tier).withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _tierColor(sub.tier).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(_tierIcon(sub.tier), color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Langganan Aktif',
                    style: TextStyle(
                      fontFamily: Constants.fontsFamily,
                      fontSize: 13,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isActive ? Colors.white.withOpacity(0.2) : Colors.red.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isActive ? 'Active' : (sub.status ?? ''),
                  style: TextStyle(
                    fontFamily: Constants.fontsFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            sub.planName ?? '',
            style: TextStyle(
              fontFamily: Constants.fontsFamily,
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$days hari tersisa',
            style: TextStyle(
              fontFamily: Constants.fontsFamily,
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                (sub.billingPeriod ?? 'monthly').toUpperCase(),
                style: TextStyle(
                  fontFamily: Constants.fontsFamily,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white60,
                  letterSpacing: 1,
                ),
              ),
              GestureDetector(
                onTap: _onCancel,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white30),
                  ),
                  child: Text(
                    'Batalkan',
                    style: TextStyle(
                      fontFamily: Constants.fontsFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: blueButton.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: blueButton.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: blueButton, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  fontFamily: Constants.fontsFamily,
                  fontSize: 12,
                  color: accentColor,
                  height: 1.4,
                ),
                children: const [
                  TextSpan(text: 'Harga 1 sesi PT offline = '),
                  TextSpan(text: 'Rp 800.000', style: TextStyle(fontWeight: FontWeight.w700)),
                  TextSpan(text: '\nDi sini mulai '),
                  TextSpan(text: 'Rp 299.000', style: TextStyle(fontWeight: FontWeight.w700)),
                  TextSpan(text: ' / bulan full program + coaching'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBillingToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _showAnnual = false),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: !_showAnnual ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: !_showAnnual
                      ? [BoxShadow(color: Colors.black12, blurRadius: 4)]
                      : null,
                ),
                child: Center(
                  child: Text(
                    'Bulanan',
                    style: TextStyle(
                      fontFamily: Constants.fontsFamily,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: !_showAnnual ? accentColor : subTextColor,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _showAnnual = true),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _showAnnual ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: _showAnnual
                      ? [BoxShadow(color: Colors.black12, blurRadius: 4)]
                      : null,
                ),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Tahunan',
                        style: TextStyle(
                          fontFamily: Constants.fontsFamily,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _showAnnual ? accentColor : subTextColor,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: greenButton.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'HEMAT',
                          style: TextStyle(
                            fontFamily: Constants.fontsFamily,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: greenButton,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanGroupCard(PlanGroup group) {
    final plan = _showAnnual ? (group.annual ?? group.monthly) : group.monthly;
    if (plan == null) return const SizedBox.shrink();

    final isPopular = plan.isPopular == true || group.monthly?.isPopular == true;
    final color = _tierColor(group.tier);
    final isCurrentPlan = _mySub?.hasSubscription == true &&
        _mySub?.subscription?.planId == plan.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPopular ? color : borderColor,
          width: isPopular ? 2 : 1,
        ),
        boxShadow: isPopular
            ? [BoxShadow(color: color.withOpacity(0.12), blurRadius: 12, offset: const Offset(0, 4))]
            : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
      ),
      child: Column(
        children: [
          // Popular badge
          if (isPopular)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  topRight: Radius.circular(14),
                ),
              ),
              child: Center(
                child: Text(
                  'PALING POPULER',
                  style: TextStyle(
                    fontFamily: Constants.fontsFamily,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tier header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(_tierIcon(group.tier), color: color, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            plan.name ?? '',
                            style: TextStyle(
                              fontFamily: Constants.fontsFamily,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: accentColor,
                            ),
                          ),
                          if (plan.description != null)
                            Text(
                              plan.description!,
                              style: TextStyle(
                                fontFamily: Constants.fontsFamily,
                                fontSize: 12,
                                color: subTextColor,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Price
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatPrice(plan.price, plan.currency),
                      style: TextStyle(
                        fontFamily: Constants.fontsFamily,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: accentColor,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        '/ ${_showAnnual ? 'tahun' : 'bulan'}',
                        style: TextStyle(
                          fontFamily: Constants.fontsFamily,
                          fontSize: 13,
                          color: subTextColor,
                        ),
                      ),
                    ),
                  ],
                ),

                // Original price & discount
                if (_showAnnual && plan.originalPrice != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        _formatPrice(plan.originalPrice, plan.currency),
                        style: TextStyle(
                          fontFamily: Constants.fontsFamily,
                          fontSize: 14,
                          color: subTextColor,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: greenButton.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Hemat ${plan.discountPct}%',
                          style: TextStyle(
                            fontFamily: Constants.fontsFamily,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: greenButton,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '= ${_formatPrice((plan.price ?? 0) / 12, plan.currency)} / bulan',
                    style: TextStyle(
                      fontFamily: Constants.fontsFamily,
                      fontSize: 12,
                      color: subTextColor,
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                // Features
                if (plan.features != null && plan.features!.isNotEmpty) ...[
                  ...plan.features!.map(
                    (feature) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.check_circle, size: 18, color: greenButton),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              feature,
                              style: TextStyle(
                                fontFamily: Constants.fontsFamily,
                                fontSize: 13,
                                color: accentColor,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                // Subscribe button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: isCurrentPlan || _subscribing
                        ? null
                        : () => _onSubscribe(plan),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isCurrentPlan ? Colors.grey.shade300 : color,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: isPopular ? 2 : 0,
                    ),
                    child: _subscribing
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        : Text(
                            isCurrentPlan ? 'Plan Saat Ini' : 'Pilih Plan Ini',
                            style: TextStyle(
                              fontFamily: Constants.fontsFamily,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
