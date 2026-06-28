import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import 'package:workout/ColorCategory.dart';
import 'package:workout/Constants.dart';
import 'package:workout/data/api_config.dart';
import 'package:workout/data/api_service.dart';
import 'package:workout/router/app_router.dart';

/// Halaman upload bukti transfer untuk flow manual_transfer.
///
/// Customer pilih image dari galeri atau kamera → preview → submit.
/// Setelah berhasil, kembali ke halaman MyPayments / Subscription
/// dan tampilkan toast konfirmasi. Status payment tetap 'pending'
/// sampai admin verify.
class UploadProofPage extends StatefulWidget {
  final String paymentId;
  final double? amount;
  final String? currency;

  const UploadProofPage({
    super.key,
    required this.paymentId,
    this.amount,
    this.currency,
  });

  @override
  State<UploadProofPage> createState() => _UploadProofPageState();
}

class _UploadProofPageState extends State<UploadProofPage> {
  final _picker = ImagePicker();
  XFile? _picked;
  bool _uploading = false;

  String _formatPrice() {
    if (widget.amount == null) return '-';
    final cur = (widget.currency ?? 'IDR').toUpperCase();
    if (cur == 'IDR') {
      return NumberFormat.currency(
        locale: 'id_ID',
        symbol: 'Rp ',
        decimalDigits: 0,
      ).format(widget.amount);
    }
    return '$cur ${widget.amount!.toStringAsFixed(2)}';
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final f = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 2048,
      );
      if (f == null) return;
      setState(() => _picked = f);
    } catch (e) {
      Fluttertoast.showToast(msg: 'Gagal memilih gambar: $e');
    }
  }

  Future<void> _submit() async {
    if (_picked == null) {
      Fluttertoast.showToast(msg: 'Pilih bukti transfer dulu');
      return;
    }
    if (widget.paymentId.isEmpty) {
      Fluttertoast.showToast(msg: 'Order ID tidak ditemukan');
      return;
    }

    setState(() => _uploading = true);
    try {
      await ApiService.uploadFile(
        ApiConfig.subscriptionPaymentProof(widget.paymentId),
        File(_picked!.path),
        fieldName: 'file',
      );
      if (!mounted) return;
      Fluttertoast.showToast(
        msg: 'Bukti pembayaran berhasil dikirim. Menunggu verifikasi admin.',
        backgroundColor: greenButton,
        textColor: Colors.white,
      );
      context.go(AppRoutes.myPayments);
    } on ApiException catch (e) {
      Fluttertoast.showToast(
        msg: e.message,
        backgroundColor: Colors.red.shade700,
        textColor: Colors.white,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Gagal upload: $e',
        backgroundColor: Colors.red.shade700,
        textColor: Colors.white,
      );
    } finally {
      if (mounted) setState(() => _uploading = false);
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
          'Upload Bukti Transfer',
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
              // Amount badge
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: blueButton.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: blueButton.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.payments_rounded, color: blueButton),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Nominal',
                            style: TextStyle(
                              fontFamily: fontFamily,
                              fontSize: 11,
                              color: subTextColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            _formatPrice(),
                            style: TextStyle(
                              fontFamily: fontFamily,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'Pilih bukti pembayaran',
                style: TextStyle(
                  fontFamily: fontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 12),

              // Image preview / placeholder
              GestureDetector(
                onTap: _picked == null
                    ? () => _showSourceSheet()
                    : () => _showSourceSheet(),
                child: Container(
                  height: 240,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: subTextColor.withOpacity(0.2),
                      style: BorderStyle.solid,
                      width: 1,
                    ),
                  ),
                  child: _picked == null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_photo_alternate_rounded,
                                size: 48,
                                color: subTextColor.withOpacity(0.6),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tap untuk pilih gambar',
                                style: TextStyle(
                                  fontFamily: fontFamily,
                                  color: subTextColor,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'JPG / PNG / WEBP',
                                style: TextStyle(
                                  fontFamily: fontFamily,
                                  color: subTextColor.withOpacity(0.7),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.file(
                            File(_picked!.path),
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        ),
                ),
              ),
              if (_picked != null) ...[
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () => setState(() => _picked = null),
                  icon: Icon(Icons.close_rounded,
                      size: 16, color: subTextColor),
                  label: Text(
                    'Hapus & Pilih Ulang',
                    style: TextStyle(
                      fontFamily: fontFamily,
                      color: subTextColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12.5,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _uploading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: greenButton,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _uploading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Text(
                        'Kirim Bukti Pembayaran',
                        style: TextStyle(
                          fontFamily: fontFamily,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: subTextColor.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: Icon(Icons.photo_library_rounded, color: blueButton),
              title: Text('Pilih dari Galeri',
                  style: TextStyle(fontFamily: Constants.fontsFamily)),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_camera_rounded, color: blueButton),
              title: Text('Ambil Foto',
                  style: TextStyle(fontFamily: Constants.fontsFamily)),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.camera);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
