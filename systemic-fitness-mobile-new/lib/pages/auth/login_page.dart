import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:workout/ColorCategory.dart';
import 'package:workout/ConstantWidget.dart';
import 'package:workout/Constants.dart';
import 'package:workout/SizeConfig.dart';
import 'package:workout/data/api_config.dart';
import 'package:workout/data/api_service.dart';
import 'package:workout/data/pref_data.dart';
import 'package:workout/models/auth_model.dart';
import 'package:workout/data/fcm_service.dart';
import 'package:workout/router/app_router.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_emailController.text.trim().isEmpty ||
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

    setState(() => _isLoading = true);

    try {
      final response = await ApiService.post(
        ApiConfig.login,
        body: {
          'email': _emailController.text.trim(),
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

        if (mounted) context.go(AppRoutes.dashboard);
      }
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

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.translucent,
      child: Scaffold(
        backgroundColor: kSfWarmWhite,
        appBar: getNoneAppBar(context),
        body: Container(
          child: Column(
            children: [
              ConstantWidget.getLoginAppBar(context, function: () {
                exitApp();
              }),
              Expanded(
                flex: 1,
                child: ListView(
                  padding: EdgeInsets.symmetric(
                    horizontal:
                        Constants.getDefaultHorizontalMargin(context),
                  ),
                  children: [
                    SizedBox(
                      height: ConstantWidget.getScreenPercentSize(
                          context, 2.5),
                    ),
                    ConstantWidget.getTextWidget(
                      "Login",
                      textColor,
                      TextAlign.left,
                      FontWeight.w700,
                      ConstantWidget.getScreenPercentSize(context, 3),
                    ),
                    SizedBox(
                      height: ConstantWidget.getScreenPercentSize(
                          context, 1.4),
                    ),
                    ConstantWidget.getTextWidget(
                      "Welcome back! Sign in to continue your fitness journey.",
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
                      'Email',
                      _emailController,
                    ),
                    ConstantWidget.getPasswordTextFiled(
                      context,
                      'Password',
                      _passwordController,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            child: ConstantWidget.getTextWidget(
                              'Forgot Password?',
                              textColor,
                              TextAlign.end,
                              FontWeight.w600,
                              ConstantWidget.getScreenPercentSize(
                                  context, 1.8),
                            ),
                            onTap: () {
                              context.push(AppRoutes.forgotPassword);
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: ConstantWidget.getScreenPercentSize(
                          context, 4),
                    ),
                    _isLoading
                        ? Center(
                            child: CircularProgressIndicator(
                              color: kSfWarmGold,
                            ),
                          )
                        : ConstantWidget.getButtonWidget(
                            context,
                            'Login',
                            kSfWarmGold,
                            () {
                              _login();
                            },
                          ),
                    ConstantWidget.getTextWidget(
                      'OR',
                      textColor,
                      TextAlign.center,
                      FontWeight.w600,
                      ConstantWidget.getScreenPercentSize(
                          context, 1.8),
                    ),
                    ConstantWidget.getButtonWidget(
                      context,
                      'Create New Account',
                      kSfWarmGold,
                      () {
                        FocusScopeNode currentFocus =
                            FocusScope.of(context);
                        if (!currentFocus.hasPrimaryFocus) {
                          currentFocus.unfocus();
                        }
                        context.push(AppRoutes.register);
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(
                height:
                    ConstantWidget.getScreenPercentSize(context, 2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
