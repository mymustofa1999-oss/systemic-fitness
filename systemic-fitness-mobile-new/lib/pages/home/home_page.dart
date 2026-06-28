import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:workout/ColorCategory.dart';
import 'package:workout/ConstantWidget.dart';
import 'package:workout/Widgets.dart';
import 'package:workout/util/CustomAnimatedBottomBar.dart';
import 'package:workout/router/app_router.dart';
import 'package:workout/data/api_service.dart';
import 'package:workout/data/api_config.dart';
import 'package:workout/models/payment_model.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:workout/Constants.dart';
import 'package:workout/data/pref_data.dart';
import 'package:workout/models/user_model.dart';
import 'package:workout/widgets/custom_button.dart';
import 'package:workout/widgets/custom_text_field.dart';
import 'package:workout/widgets/loading_widget.dart';

class HomePage extends StatefulWidget {
  final Widget child;

  const HomePage({super.key, required this.child});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  bool _isFree = true;
  bool _isLoadingSub = true;

  bool _isProfileIncomplete = false;
  bool _isLoadingProfile = true;
  UserModel? _user;

  final _formKey = GlobalKey<FormState>();
  final _dobController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  String? _selectedGender;
  bool _isSavingProfile = false;

  final List<String> _genders = ['male', 'female'];

  List<String> get _tabRoutes {
    if (_isFree) {
      return const [
        AppRoutes.dashboard,
        AppRoutes.profile,
      ];
    }
    return const [
      AppRoutes.dashboard,
      AppRoutes.messages,
      AppRoutes.profile,
    ];
  }

  List<String> get _tabToolbarTitles {
    if (_isFree) {
      return const [
        'Home',
        'Profile',
      ];
    }
    return const [
      'Home',
      'Messages',
      'Profile',
    ];
  }

  @override
  void initState() {
    super.initState();
    _loadSubscription();
    _checkProfile();
  }

  @override
  void dispose() {
    _dobController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _checkProfile() async {
    try {
      final user = await PrefData.getUser();
      if (user != null) {
        setState(() {
          _user = user;
          _isProfileIncomplete = _isIncomplete(user);
          if (_isProfileIncomplete) {
            _prefillFields(user);
          }
        });
      }

      // Fetch fresh details from API to double check
      final res = await ApiService.get(ApiConfig.me);
      final data = res['data'];
      if (data != null && data['user'] != null) {
        final freshUser = UserModel.fromJson(data['user']);
        await PrefData.setUser(freshUser.toJson());
        if (mounted) {
          setState(() {
            _user = freshUser;
            _isProfileIncomplete = _isIncomplete(freshUser);
            if (_isProfileIncomplete) {
              _prefillFields(freshUser);
            }
            _isLoadingProfile = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoadingProfile = false;
          });
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoadingProfile = false;
        });
      }
    }
  }

  bool _isIncomplete(UserModel user) {
    if (user.role != 'client') return false;
    final p = user.profile;
    return p == null ||
        p.dateOfBirth == null || p.dateOfBirth!.isEmpty ||
        p.gender == null || p.gender!.isEmpty ||
        p.weightKg == null || p.weightKg! <= 0 ||
        p.heightCm == null || p.heightCm! <= 0;
  }

  void _prefillFields(UserModel user) {
    if (user.profile != null) {
      final p = user.profile!;
      _dobController.text = p.dateOfBirth ?? '';
      _selectedGender = (p.gender != null && _genders.contains(p.gender!.toLowerCase())) ? p.gender!.toLowerCase() : null;
      _heightController.text = p.heightCm != null && p.heightCm! > 0 ? p.heightCm!.toString() : '';
      _weightController.text = p.weightKg != null && p.weightKg! > 0 ? p.weightKg!.toString() : '';
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1990),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dobController.text = '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    if (_user?.id == null) return;

    setState(() => _isSavingProfile = true);

    try {
      final body = <String, dynamic>{
        'date_of_birth': _dobController.text.trim(),
        'gender': _selectedGender,
        'height_cm': double.parse(_heightController.text.trim()),
        'weight_kg': double.parse(_weightController.text.trim()),
      };

      final response = await ApiService.putWithRetry(
        ApiConfig.userById(_user!.id!),
        body: body,
      );

      final data = response['data'];
      if (data != null) {
        final userMap = data['user'] is Map<String, dynamic>
            ? Map<String, dynamic>.from(data['user'] as Map)
            : Map<String, dynamic>.from(data as Map);
        await PrefData.setUser(userMap);
        
        final freshUser = UserModel.fromJson(userMap);
        
        if (mounted) {
          Fluttertoast.showToast(
            msg: 'Profile completed successfully!',
            backgroundColor: greenButton,
            textColor: Colors.white,
          );
          setState(() {
            _user = freshUser;
            _isProfileIncomplete = false;
            _isSavingProfile = false;
          });
        }
      }
    } on ApiException catch (e) {
      Fluttertoast.showToast(
        msg: e.message,
        backgroundColor: Colors.red.shade700,
        textColor: Colors.white,
      );
      if (mounted) setState(() => _isSavingProfile = false);
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Failed to update profile.',
        backgroundColor: Colors.red.shade700,
        textColor: Colors.white,
      );
      if (mounted) setState(() => _isSavingProfile = false);
    }
  }

  Future<void> _loadSubscription() async {
    try {
      final res = await ApiService.get(ApiConfig.subscriptionMe);
      final sub = MySubscriptionResult.fromJson(
        Map<String, dynamic>.from(res['data'] ?? {}),
      );
      final s = sub.subscription;
      final isFree = !sub.hasSubscription ||
          s == null ||
          (s.status ?? '').toLowerCase() != 'active' ||
          (s.tier ?? '').toLowerCase() == 'free' ||
          (s.tier ?? '').toLowerCase() == 'sf_free';
      if (mounted) {
        setState(() {
          _isFree = isFree;
          _isLoadingSub = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoadingSub = false;
        });
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateIndex();
  }

  void _updateIndex() {
    final location = GoRouterState.of(context).matchedLocation;
    int index = _tabRoutes.indexWhere((route) => location.startsWith(route));
    if (index == -1) index = 0;
    if (_selectedIndex != index) {
      setState(() => _selectedIndex = index);
    }
  }

  void _onTabTapped(int index) {
    if (index == _selectedIndex) return;
    context.go(_tabRoutes[index]);
  }

  @override
  Widget build(BuildContext context) {
    if (_isProfileIncomplete) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Text(
            'Lengkapi Profil Anda',
            style: TextStyle(
              fontFamily: Constants.fontsFamily,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: kSfCharcoal,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sebelum melanjutkan, Anda wajib melengkapi data profil berikut sebagai acuan perhitungan beban latihan (load/weight reference) pada Training Card Anda.',
                    style: TextStyle(
                      fontFamily: Constants.fontsFamily,
                      fontSize: 13,
                      color: kSfCharcoal.withOpacity(0.7),
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Date of Birth
                  Text(
                    'Tanggal Lahir',
                    style: TextStyle(
                      fontFamily: Constants.fontsFamily,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: kSfCharcoal,
                    ),
                  ),
                  const SizedBox(height: 8),
                  CustomTextField(
                    hint: 'YYYY-MM-DD',
                    controller: _dobController,
                    readOnly: true,
                    onTap: _pickDate,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Mohon masukkan tanggal lahir'
                        : null,
                    suffixIcon: const Icon(Icons.calendar_today, size: 18, color: kSfCharcoal),
                  ),
                  const SizedBox(height: 18),

                  // Gender
                  Text(
                    'Jenis Kelamin',
                    style: TextStyle(
                      fontFamily: Constants.fontsFamily,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: kSfCharcoal,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedGender,
                        isExpanded: true,
                        hint: Text(
                          'Pilih Jenis Kelamin...',
                          style: TextStyle(
                            fontFamily: Constants.fontsFamily,
                            fontSize: 14,
                            color: subTextColor,
                          ),
                        ),
                        style: TextStyle(
                          fontFamily: Constants.fontsFamily,
                          fontSize: 14,
                          color: kSfCharcoal,
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'male',
                            child: Text('Pria'),
                          ),
                          DropdownMenuItem(
                            value: 'female',
                            child: Text('Wanita'),
                          ),
                        ],
                        onChanged: (v) => setState(() => _selectedGender = v),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Height
                  Text(
                    'Tinggi Badan (cm)',
                    style: TextStyle(
                      fontFamily: Constants.fontsFamily,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: kSfCharcoal,
                    ),
                  ),
                  const SizedBox(height: 8),
                  CustomTextField(
                    hint: 'Contoh: 170',
                    controller: _heightController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Mohon masukkan tinggi badan';
                      }
                      final parsed = double.tryParse(v.trim());
                      if (parsed == null || parsed <= 0) {
                        return 'Tinggi badan harus lebih besar dari 0';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 18),

                  // Weight
                  Text(
                    'Berat Badan (kg)',
                    style: TextStyle(
                      fontFamily: Constants.fontsFamily,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: kSfCharcoal,
                    ),
                  ),
                  const SizedBox(height: 8),
                  CustomTextField(
                    hint: 'Contoh: 70.5',
                    controller: _weightController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Mohon masukkan berat badan';
                      }
                      final parsed = double.tryParse(v.trim());
                      if (parsed == null || parsed <= 0) {
                        return 'Berat badan harus lebih besar dari 0';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),

                  // Submit Button
                  CustomButton(
                    text: 'Simpan & Lanjutkan',
                    onPressed: _saveProfile,
                    isLoading: _isSavingProfile,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      );
    }

    double height = ConstantWidget.getScreenPercentSize(context, 7.5);
    double iconHeight = ConstantWidget.getPercentSize(height, 28);

    // SF Phase 4 palette migration:
    //   bgDarkWhite (#FFFFFF) → kSfWarmWhite (#F8F6F1) — page bg
    //   accentColor (Black)    → kSfWarmGold (#B8922E) — active tab + title
    //   textColor              → kSfCharcoal (#444444) — inactive tab
    return Scaffold(
      backgroundColor: kSfWarmWhite,
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: kSfWarmWhite,
        systemOverlayStyle: const SystemUiOverlayStyle(
          systemNavigationBarColor: kSfWarmWhite,
          statusBarColor: kSfWarmWhite,
          statusBarIconBrightness: Brightness.dark,
        ),
        title: getCustomText(
          _tabToolbarTitles[_selectedIndex],
          kSfCharcoal,
          1,
          TextAlign.start,
          FontWeight.w700,
          ConstantWidget.getScreenPercentSize(context, 2.5),
        ),
        actions: [
          if (_selectedIndex == 0)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: IconButton(
                onPressed: () => context.push(AppRoutes.notifications),
                tooltip: 'Notifikasi',
                icon: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: kSfCharcoal.withOpacity(0.15)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.notifications_none_rounded,
                    color: kSfCharcoal,
                    size: 22,
                  ),
                ),
              ),
            ),
        ],
      ),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: widget.child,
      ),
      bottomNavigationBar: CustomAnimatedBottomBar(
        containerHeight: height,
        backgroundColor: kSfWarmWhite,
        selectedIndex: _selectedIndex,
        showElevation: true,
        itemCornerRadius: 24,
        curve: Curves.easeIn,
        onItemSelected: _onTabTapped,
        items: _buildNavItems(iconHeight),
      ),
    );
  }

  List<BottomNavyBarItem> _buildNavItems(double iconHeight) {
    if (_isFree) {
      return <BottomNavyBarItem>[
        BottomNavyBarItem(
          title: 'Home',
          activeColor: kSfWarmGold,
          inactiveColor: kSfCharcoal,
          textAlign: TextAlign.center,
          iconSize: iconHeight,
          imageName: "Home.svg",
        ),
        BottomNavyBarItem(
          title: 'Profile',
          activeColor: kSfWarmGold,
          inactiveColor: kSfCharcoal,
          textAlign: TextAlign.center,
          iconSize: iconHeight,
          imageName: "User.svg",
        ),
      ];
    }
    return <BottomNavyBarItem>[
      BottomNavyBarItem(
        title: 'Home',
        activeColor: kSfWarmGold,
        inactiveColor: kSfCharcoal,
        textAlign: TextAlign.center,
        iconSize: iconHeight,
        imageName: "Home.svg",
      ),
      BottomNavyBarItem(
        title: 'Messages',
        activeColor: kSfWarmGold,
        inactiveColor: kSfCharcoal,
        textAlign: TextAlign.center,
        iconSize: iconHeight,
        imageName: "Message-5.svg",
      ),
      BottomNavyBarItem(
        title: 'Profile',
        activeColor: kSfWarmGold,
        inactiveColor: kSfCharcoal,
        textAlign: TextAlign.center,
        iconSize: iconHeight,
        imageName: "User.svg",
      ),
    ];
  }
}
