import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:workout/ColorCategory.dart';
import 'package:workout/Constants.dart';
import 'package:workout/router/app_router.dart';

/// Halaman pembayaran Midtrans Snap — in-app WebView.
///
/// Membuka `snap_redirect_url` di dalam WebView sehingga customer
/// tidak keluar dari aplikasi. Saat Midtrans redirect ke finish URL,
/// WebView mendeteksi URL tersebut dan navigate ke halaman result
/// native (PaymentResultPage).
///
/// Tidak menggunakan Midtrans SDK Flutter — hanya WebView biasa yang
/// memuat halaman Snap standar.
class MidtransPaymentPage extends StatefulWidget {
  final String redirectUrl;
  final String? orderId;

  const MidtransPaymentPage({
    super.key,
    required this.redirectUrl,
    this.orderId,
  });

  @override
  State<MidtransPaymentPage> createState() => _MidtransPaymentPageState();
}

class _MidtransPaymentPageState extends State<MidtransPaymentPage> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;

  // Finish URL yang diset di API → Midtrans redirect ke sini setelah bayar
  static const _finishHost = 'systemicfitnesshealth.com';
  static const _finishPath = '/payment/finish';

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  void _initWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) setState(() => _isLoading = true);
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _isLoading = false);
          },
          onWebResourceError: (error) {
            if (mounted) {
              setState(() {
                _hasError = true;
                _errorMessage = error.description;
                _isLoading = false;
              });
            }
          },
          onNavigationRequest: (request) {
            final uri = Uri.tryParse(request.url);
            if (uri == null) return NavigationDecision.navigate;

            // ── Intercept finish URL ──────────────────────────
            // Midtrans redirects to:
            //   https://systemicfitnesshealth.com/payment/finish
            //     ?order_id=...&status_code=...&transaction_status=...
            if (uri.host.contains(_finishHost) &&
                uri.path.contains(_finishPath)) {
              _handleFinishRedirect(uri);
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.redirectUrl));
  }

  void _handleFinishRedirect(Uri uri) {
    final transactionStatus =
        uri.queryParameters['transaction_status'] ?? 'pending';
    final orderId =
        uri.queryParameters['order_id'] ?? widget.orderId ?? '';

    // Map Midtrans transaction_status to our result status
    final String status;
    switch (transactionStatus) {
      case 'settlement':
      case 'capture':
        status = 'success';
        break;
      case 'pending':
        status = 'pending';
        break;
      default:
        status = 'error';
    }

    if (!mounted) return;
    context.go(
      AppRoutes.paymentResult,
      extra: {
        'status': status,
        'orderId': orderId,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final fontFamily = Constants.fontsFamily;

    if (_hasError) {
      return Scaffold(
        backgroundColor: bgDarkWhite,
        appBar: _buildAppBar(fontFamily),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.wifi_off_rounded,
                    size: 40,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Gagal Memuat Halaman',
                  style: TextStyle(
                    fontFamily: fontFamily,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _errorMessage ?? 'Periksa koneksi internet dan coba lagi.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: fontFamily,
                    fontSize: 13,
                    color: subTextColor,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _hasError = false;
                      _isLoading = true;
                    });
                    _controller.loadRequest(Uri.parse(widget.redirectUrl));
                  },
                  icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                  label: Text(
                    'Coba Lagi',
                    style: TextStyle(
                      fontFamily: fontFamily,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: blueButton,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(fontFamily),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            Container(
              color: Colors.white,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Color(0xFF2563EB),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Memuat halaman pembayaran...',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  AppBar _buildAppBar(String fontFamily) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 1,
      title: Text(
        'Pembayaran',
        style: TextStyle(
          fontFamily: fontFamily,
          fontWeight: FontWeight.w700,
          fontSize: 17,
          color: textColor,
        ),
      ),
      leading: IconButton(
        icon: Icon(Icons.close_rounded, color: textColor),
        onPressed: () => _showExitConfirmation(),
      ),
    );
  }

  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Batalkan Pembayaran?'),
        content: const Text(
          'Kalau kamu keluar sekarang, pembayaran tidak akan dibatalkan. '
          'Kamu bisa melanjutkan nanti di Riwayat Pembayaran.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Lanjut Bayar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.pop();
            },
            child: const Text(
              'Keluar',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
