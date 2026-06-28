import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:workout/ColorCategory.dart';
import 'package:workout/ConstantWidget.dart';
import 'package:workout/Constants.dart';
import 'package:workout/SizeConfig.dart';
import 'package:workout/Widgets.dart';
import 'package:workout/data/fcm_service.dart';
import 'package:workout/data/pref_data.dart';
import 'package:workout/models/user_model.dart';
import 'package:workout/router/app_router.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  UserModel? _user;
  bool _isLoading = true;
  bool _isSoundOn = true;
  bool _isTtsOn = true;
  bool _isReminderOn = true;
  String _localeStr = 'id';

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    setState(() => _isLoading = true);

    try {
      _user = await PrefData.getUser();
      _isSoundOn = await PrefData.getIsSoundOn();
      _isTtsOn = await PrefData.getIsTtsOn();
      _isReminderOn = await PrefData.getReminderOn();
      _localeStr = await PrefData.getLocale();
    } catch (_) {}

    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
                ConstantWidget.getScreenPercentSize(context, 2))),
        title: getMediumBoldTextWithMaxLine('Logout', Colors.black87, 1),
        content: getCustomText(
          'Are you sure you want to logout?',
          subTextColor,
          2,
          TextAlign.start,
          FontWeight.w400,
          ConstantWidget.getScreenPercentSize(context, 1.8),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: getCustomText('Cancel', subTextColor, 1,
                TextAlign.center, FontWeight.w500,
                ConstantWidget.getScreenPercentSize(context, 1.8)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: getCustomText('Logout', Colors.red, 1,
                TextAlign.center, FontWeight.w600,
                ConstantWidget.getScreenPercentSize(context, 1.8)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // 1. Best-effort unregister FCM token (network call, may fail offline)
    try {
      await FcmService.unregisterDeviceToken();
    } catch (_) {
      // ignore — local clear is the source of truth
    }

    // 2. Wipe all session state from local storage. clearAll() removes
    //    access/refresh tokens, user data, sign-in flag, fcm token, and
    //    assessment flags so the next session starts cold.
    await PrefData.clearAll();

    // 3. Hard navigate to splash (the root). Splash re-evaluates auth
    //    fresh in initState and auto-redirects to /login. This is more
    //    reliable than `context.go('/login')` because the GoRouter
    //    redirect callback can race with the SharedPreferences flush
    //    when navigating directly to /login from inside a ShellRoute.
    if (!mounted) return;
    context.go(AppRoutes.splash);
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    double textMargin = SizeConfig.safeBlockHorizontal! * 3.5;

    if (_isLoading) {
      return Container(
        color: bgDarkWhite,
        child: Center(child: getProgressDialog()),
      );
    }

    Widget divider = Container(
      margin: EdgeInsets.symmetric(
          vertical: ConstantWidget.getScreenPercentSize(context, 0.5)),
      color: borderColor,
      height: 0.5,
    );

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: bgDarkWhite,
      child: ListView(
        padding: EdgeInsets.symmetric(
            horizontal: textMargin, vertical: textMargin),
        children: [
          // User info header
          _buildUserHeader(),
          SizedBox(
              height: ConstantWidget.getScreenPercentSize(context, 3)),

          // Account section
          getSettingTabTitle(context, 'ACCOUNT'),
          SizedBox(
              height: ConstantWidget.getScreenPercentSize(context, 1)),
          _buildSettingItem(
            'User.svg',
            'Edit Profile',
            () => context.push(AppRoutes.editProfile),
          ),
          divider,
          _buildSettingItem(
            'CPU.svg',
            'Subscription',
            () => context.push(AppRoutes.subscription),
          ),
          divider,
          _buildSettingItem(
            'CPU.svg',
            'My Assessments',
            () => context.push(AppRoutes.assessmentHistory),
          ),
          divider,
          _buildSettingItem(
            'Chart.svg',
            'Progress',
            () => context.push(AppRoutes.progress),
          ),
          divider,
          _buildSettingItem(
            'Goal.svg',
            'Body Metrics',
            () => context.push(AppRoutes.bodyMetrics),
          ),
          divider,
          _buildSettingItem(
            'Cup.svg',
            'Nutrition',
            () => context.push(AppRoutes.nutrition),
          ),
          divider,
          _buildSettingItem(
            'Notification.svg',
            'Announcements',
            () => context.push(AppRoutes.announcements),
          ),
          divider,
          _buildSettingItem(
            'Clock.svg',
            'Schedule',
            () => context.push(AppRoutes.scheduling),
          ),
          divider,
          _buildSettingItem(
            'Cup.svg',
            'Foods',
            () => context.push(AppRoutes.foods),
          ),
          divider,
          _buildSettingItem(
            'Setting.svg',
            'Forms',
            () => context.push(AppRoutes.forms),
          ),

          SizedBox(
              height: ConstantWidget.getScreenPercentSize(context, 3)),

          // Settings section
          getSettingTabTitle(context, 'SETTINGS'),
          SizedBox(
              height: ConstantWidget.getScreenPercentSize(context, 1)),
          _buildToggleItem(
            'Sound',
            _isSoundOn,
            (val) async {
              setState(() => _isSoundOn = val);
              await PrefData.setIsSoundOn(val);
            },
          ),
          divider,
          _buildToggleItem(
            'Text to Speech',
            _isTtsOn,
            (val) async {
              setState(() => _isTtsOn = val);
              await PrefData.setIsTtsOn(val);
            },
          ),
          divider,
          _buildToggleItem(
            'Reminders',
            _isReminderOn,
            (val) async {
              setState(() => _isReminderOn = val);
              await PrefData.setReminderOn(val);
            },
          ),
          divider,
          _buildToggleItem(
            'English Language (Bahasa Inggris)',
            _localeStr == 'en',
            (val) async {
              final next = val ? 'en' : 'id';
              setState(() => _localeStr = next);
              await PrefData.setLocale(next);
            },
          ),

          SizedBox(
              height: ConstantWidget.getScreenPercentSize(context, 3)),

          // Logout button
          ConstantWidget.getBorderButtonWidget(
            context,
            'Logout',
            _logout,
            borderColor: Colors.red,
          ),

          SizedBox(
              height: ConstantWidget.getScreenPercentSize(context, 2)),
        ],
      ),
    );
  }

  Widget _buildUserHeader() {
    double avatarSize = ConstantWidget.getScreenPercentSize(context, 10);
    return Column(
      children: [
        SizedBox(
            height: ConstantWidget.getScreenPercentSize(context, 1)),
        Container(
          height: avatarSize,
          width: avatarSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: cellColor,
            image: _user?.avatarUrl != null &&
                    _user!.avatarUrl!.isNotEmpty
                ? DecorationImage(
                    image: NetworkImage(_user!.avatarUrl!),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child:
              _user?.avatarUrl == null || _user!.avatarUrl!.isEmpty
                  ? Center(
                      child: Icon(Icons.person,
                          color: subTextColor,
                          size: ConstantWidget.getPercentSize(
                              avatarSize, 50)),
                    )
                  : null,
        ),
        SizedBox(
            height: ConstantWidget.getScreenPercentSize(context, 2)),
        ConstantWidget.getCustomText(
          _user?.fullName ?? 'User',
          textColor,
          1,
          TextAlign.center,
          FontWeight.w700,
          ConstantWidget.getScreenPercentSize(context, 2.5),
        ),
        SizedBox(
            height: ConstantWidget.getScreenPercentSize(context, 0.5)),
        ConstantWidget.getTextWidget(
          _user?.email ?? '',
          subTextColor,
          TextAlign.center,
          FontWeight.w400,
          ConstantWidget.getScreenPercentSize(context, 1.7),
        ),
        if (_user?.role != null) ...[
          SizedBox(
              height: ConstantWidget.getScreenPercentSize(context, 1)),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal:
                  ConstantWidget.getWidthPercentSize(context, 3),
              vertical:
                  ConstantWidget.getScreenPercentSize(context, 0.5),
            ),
            decoration: getDefaultDecoration(
              bgColor: cellColor,
              radius:
                  ConstantWidget.getScreenPercentSize(context, 1.5),
            ),
            child: ConstantWidget.getTextWidget(
              _user!.role!.toUpperCase(),
              blueButton,
              TextAlign.center,
              FontWeight.w600,
              ConstantWidget.getScreenPercentSize(context, 1.3),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSettingItem(
      String svgIcon, String title, VoidCallback onTap) {
    double size = ConstantWidget.getScreenPercentSize(context, 5.5);
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: ConstantWidget.getScreenPercentSize(context, 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: size,
              width: size,
              decoration: getDefaultDecoration(
                bgColor: cellColor,
                radius: ConstantWidget.getPercentSize(size, 25),
              ),
              child: Center(
                child: SvgPicture.asset(
                  Constants.assetsImagePath + svgIcon,
                  height: ConstantWidget.getPercentSize(size, 50),
                  color: textColor,
                ),
              ),
            ),
            SizedBox(
                width: ConstantWidget.getWidthPercentSize(context, 2)),
            Expanded(
              child: ConstantWidget.getCustomText(
                title,
                textColor,
                1,
                TextAlign.start,
                FontWeight.w500,
                ConstantWidget.getScreenPercentSize(context, 1.8),
              ),
            ),
            Icon(
              Icons.navigate_next,
              color: textColor,
              size: ConstantWidget.getScreenPercentSize(context, 3),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleItem(
      String title, bool value, ValueChanged<bool> onChanged) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: ConstantWidget.getScreenPercentSize(context, 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: ConstantWidget.getCustomText(
              title,
              textColor,
              1,
              TextAlign.start,
              FontWeight.w500,
              ConstantWidget.getScreenPercentSize(context, 1.8),
            ),
          ),
          CupertinoSwitch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: greenButton,
          ),
        ],
      ),
    );
  }
}
