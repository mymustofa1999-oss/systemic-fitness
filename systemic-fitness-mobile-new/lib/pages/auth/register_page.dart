import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:workout/ColorCategory.dart';
import 'package:workout/ConstantWidget.dart';
import 'package:workout/Constants.dart';
import 'package:workout/SizeConfig.dart';
import 'package:workout/data/api_config.dart';
import 'package:workout/data/api_service.dart';
import 'package:workout/data/fcm_service.dart';
import 'package:workout/data/pref_data.dart';
import 'package:workout/models/auth_model.dart';
import 'package:workout/router/app_router.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_fullNameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty ||
        _passwordController.text.isEmpty) {
      Fluttertoast.showToast(
        msg: 'Please fill in all fields',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      return;
    }

    final emailRegex = RegExp(r'^[\w\.\-\+]+@[\w\-]+\.\w{2,}$');
    if (!emailRegex.hasMatch(_emailController.text.trim())) {
      Fluttertoast.showToast(
        msg: 'Please enter a valid email address',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      return;
    }

    if (_passwordController.text.length < 8) {
      Fluttertoast.showToast(
        msg: 'Password must be at least 8 characters',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      Fluttertoast.showToast(
        msg: 'Passwords do not match',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await ApiService.post(
        ApiConfig.register,
        body: {
          'full_name': _fullNameController.text.trim(),
          'email': _emailController.text.trim(),
          'phone': _phoneController.text.trim(),
          'password': _passwordController.text,
        },
        skipAuthRefresh: true,
      );

      final data = response['data'];
      if (data != null) {
        final loginResponse = LoginResponse.fromJson(data);
        await PrefData.setTokens(
          loginResponse.tokens.accessToken,
          loginResponse.tokens.refreshToken,
        );
        await PrefData.setUser(loginResponse.user.toJson());
        await PrefData.setIsSignIn(true);

        FcmService.registerDeviceToken();

        // SF Phase 5: user baru langsung ke Assessment v2.
        if (mounted) context.go(AppRoutes.assessmentV2Intro);
      }
    } on ApiException catch (e) {
      String msg = e.message;
      if (e.errors != null && e.errors!.isNotEmpty) {
        msg = e.errors!.join('\n');
      }
      Fluttertoast.showToast(
        msg: msg,
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

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.translucent,
      child: Scaffold(
        backgroundColor: kSfWarmWhite,
        appBar: AppBar(
          backgroundColor: kSfWarmWhite,
          toolbarHeight: 0,
          elevation: 0,
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
                      "Sign Up",
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
                      "Create your account to start your fitness journey!",
                      textColor,
                      TextAlign.left,
                      FontWeight.w400,
                      ConstantWidget.getScreenPercentSize(context, 2),
                    ),
                    SizedBox(
                      height: ConstantWidget.getScreenPercentSize(
                          context, 2),
                    ),
                    ConstantWidget.getDefaultTextFiledWidget(
                      context,
                      'Full Name',
                      _fullNameController,
                    ),
                    ConstantWidget.getDefaultTextFiledWidget(
                      context,
                      'Email',
                      _emailController,
                    ),
                    ConstantWidget.getDefaultTextFiledWidget(
                      context,
                      'Phone Number',
                      _phoneController,
                    ),
                    ConstantWidget.getPasswordTextFiled(
                      context,
                      'Password',
                      _passwordController,
                    ),
                    ConstantWidget.getPasswordTextFiled(
                      context,
                      'Confirm Password',
                      _confirmPasswordController,
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
                            'Sign Up',
                            kSfWarmGold,
                            () {
                              _register();
                            },
                          ),
                    SizedBox(
                      height: ConstantWidget.getScreenPercentSize(
                          context, 1),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ConstantWidget.getTextWidget(
                          'Already have an account? ',
                          subTextColor,
                          TextAlign.center,
                          FontWeight.w400,
                          ConstantWidget.getScreenPercentSize(
                              context, 1.7),
                        ),
                        InkWell(
                          onTap: () => context.pop(),
                          child: ConstantWidget.getTextWidget(
                            'Login',
                            textColor,
                            TextAlign.center,
                            FontWeight.w600,
                            ConstantWidget.getScreenPercentSize(
                                context, 1.7),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: ConstantWidget.getScreenPercentSize(
                          context, 3),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
