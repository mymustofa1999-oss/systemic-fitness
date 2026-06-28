import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:workout/ColorCategory.dart';
import 'package:workout/ConstantWidget.dart';
import 'package:workout/Constants.dart';
import 'package:workout/SizeConfig.dart';
import 'package:workout/data/api_config.dart';
import 'package:workout/data/api_service.dart';
import 'package:workout/router/app_router.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _isSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetLink() async {
    if (_emailController.text.trim().isEmpty) {
      Fluttertoast.showToast(
        msg: 'Please enter your email',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ApiService.post(
        ApiConfig.forgotPassword,
        body: {'email': _emailController.text.trim()},
      );

      setState(() => _isSent = true);

      Fluttertoast.showToast(
        msg: 'Reset link sent! Check your email.',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: greenButton,
        textColor: Colors.white,
      );

      await Future.delayed(const Duration(seconds: 2));
      if (mounted) context.go(AppRoutes.login);
    } on ApiException catch (e) {
      Fluttertoast.showToast(
        msg: e.message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red.shade700,
        textColor: Colors.white,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Connection error. Please try again.',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red.shade700,
        textColor: Colors.white,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return Scaffold(
      backgroundColor: kSfWarmWhite,
      appBar: AppBar(
        backgroundColor: kSfWarmWhite,
        elevation: 0,
        toolbarHeight: 0,
      ),
      body: Container(
        child: Column(
          children: [
            ConstantWidget.getLoginAppBar(context, function: () {
              context.pop();
            }),
            Expanded(
              flex: 1,
              child: ListView(
                padding: EdgeInsets.symmetric(
                  horizontal:
                      ConstantWidget.getWidthPercentSize(context, 3),
                ),
                children: [
                  SizedBox(
                    height: ConstantWidget.getScreenPercentSize(
                        context, 2.5),
                  ),
                  ConstantWidget.getTextWidget(
                    'Forgot Password',
                    textColor,
                    TextAlign.left,
                    FontWeight.bold,
                    ConstantWidget.getScreenPercentSize(context, 3),
                  ),
                  SizedBox(
                    height: ConstantWidget.getScreenPercentSize(
                        context, 1.4),
                  ),
                  ConstantWidget.getTextWidget(
                    "Enter your email address and we'll send you a link to reset your password.",
                    textColor,
                    TextAlign.left,
                    FontWeight.w400,
                    ConstantWidget.getScreenPercentSize(context, 2),
                  ),
                  SizedBox(
                    height: ConstantWidget.getScreenPercentSize(
                        context, 3),
                  ),
                  if (_isSent) ...[
                    // Success state
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(
                        ConstantWidget.getScreenPercentSize(
                            context, 2.5),
                      ),
                      decoration: getDefaultDecoration(
                        bgColor: greenButton.withOpacity(0.1),
                        radius: ConstantWidget.getScreenPercentSize(
                            context, 1.5),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.check_circle,
                              color: greenButton, size: 48),
                          SizedBox(
                            height:
                                ConstantWidget.getScreenPercentSize(
                                    context, 1.5),
                          ),
                          ConstantWidget.getTextWidget(
                            'Email Sent!',
                            textColor,
                            TextAlign.center,
                            FontWeight.w600,
                            ConstantWidget.getScreenPercentSize(
                                context, 2.2),
                          ),
                          SizedBox(
                            height:
                                ConstantWidget.getScreenPercentSize(
                                    context, 1),
                          ),
                          ConstantWidget.getTextWidget(
                            'Check your inbox for a password reset link.',
                            subTextColor,
                            TextAlign.center,
                            FontWeight.w400,
                            ConstantWidget.getScreenPercentSize(
                                context, 1.7),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: ConstantWidget.getScreenPercentSize(
                          context, 3),
                    ),
                    ConstantWidget.getButtonWidget(
                      context,
                      'Back to Login',
                      kSfWarmGold,
                      () => context.go(AppRoutes.login),
                    ),
                  ] else ...[
                    ConstantWidget.getDefaultTextFiledWidget(
                      context,
                      'Email',
                      _emailController,
                    ),
                    SizedBox(
                      height: ConstantWidget.getScreenPercentSize(
                          context, 2),
                    ),
                    _isLoading
                        ? Center(
                            child: CircularProgressIndicator(
                              color: kSfWarmGold,
                            ),
                          )
                        : ConstantWidget.getButtonWidget(
                            context,
                            'Send Reset Link',
                            kSfWarmGold,
                            () {
                              _sendResetLink();
                            },
                          ),
                    SizedBox(
                      height: ConstantWidget.getScreenPercentSize(
                          context, 2),
                    ),
                    Center(
                      child: InkWell(
                        onTap: () => context.pop(),
                        child: ConstantWidget.getTextWidget(
                          'Back to Login',
                          kSfSystemBlue,
                          TextAlign.center,
                          FontWeight.w500,
                          ConstantWidget.getScreenPercentSize(
                              context, 1.8),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
