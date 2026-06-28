import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:workout/ColorCategory.dart';
import 'package:workout/Constants.dart';
import 'package:workout/data/api_config.dart';
import 'package:workout/data/api_service.dart';
import 'package:workout/data/pref_data.dart';
import 'package:workout/models/user_model.dart';
import 'package:workout/widgets/custom_button.dart';
import 'package:workout/widgets/custom_text_field.dart';
import 'package:workout/widgets/loading_widget.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dobController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  String? _error;
  UserModel? _user;
  String? _selectedGender;
  String? _selectedFitnessGoal;
  String? _selectedExperienceLevel;
  File? _selectedAvatar;
  final ImagePicker _picker = ImagePicker();

  final List<String> _genders = ['male', 'female', 'other'];
  final List<String> _fitnessGoals = ['lose_weight', 'gain_muscle', 'maintain', 'improve_endurance', 'flexibility'];
  final List<String> _experienceLevels = ['beginner', 'intermediate', 'advanced'];

  @override
  void initState() {
    super.initState();
    _fetchUser();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _fetchUser() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final response = await ApiService.getWithRetry(ApiConfig.me);
      final data = response['data'];
      if (data != null && mounted) {
        final merged = <String, dynamic>{
          ...?(data['user'] as Map<String, dynamic>?),
          'profile': data['profile'],
          'stats': data['stats'],
        };
        final user = UserModel.fromJson(merged);
        setState(() {
          _user = user;
          _fullNameController.text = user.fullName ?? '';
          _phoneController.text = user.phone ?? '';
          _dobController.text = user.profile?.dateOfBirth ?? '';
          _heightController.text = user.profile?.heightCm?.toString() ?? '';
          _weightController.text = user.profile?.weightKg?.toString() ?? '';
          _selectedGender = user.profile?.gender;
          _selectedFitnessGoal = user.profile?.fitnessGoal;
          _selectedExperienceLevel = user.profile?.experienceLevel;
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
          _error = 'Failed to load profile.';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _pickAvatar() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery, maxWidth: 512);
    if (picked != null) {
      setState(() => _selectedAvatar = File(picked.path));
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

  String _formatLabel(String s) {
    return s.replaceAll('_', ' ').split(' ').map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}').join(' ');
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_user?.id == null) return;

    setState(() => _isSaving = true);

    try {
      // Upload avatar first if selected
      if (_selectedAvatar != null) {
        try {
          await ApiService.uploadImageWithRetry(
            _selectedAvatar!.path,
            entityType: 'user',
            entityId: _user!.id!,
          );
        } catch (e) {
          // Continue with profile save even if avatar upload fails
          Fluttertoast.showToast(
            msg: 'Avatar upload failed, but profile will be saved.',
            backgroundColor: Colors.orange.shade700,
            textColor: Colors.white,
          );
        }
      }

      final body = <String, dynamic>{
        'full_name': _fullNameController.text.trim(),
        'phone': _phoneController.text.trim(),
        if (_dobController.text.trim().isNotEmpty)
          'date_of_birth': _dobController.text.trim(),
        if (_selectedGender != null) 'gender': _selectedGender,
        if (double.tryParse(_heightController.text.trim()) != null)
          'height_cm': double.parse(_heightController.text.trim()),
        if (double.tryParse(_weightController.text.trim()) != null)
          'weight_kg': double.parse(_weightController.text.trim()),
        if (_selectedFitnessGoal != null) 'fitness_goal': _selectedFitnessGoal,
        if (_selectedExperienceLevel != null)
          'experience_level': _selectedExperienceLevel,
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
      }

      if (mounted) {
        Fluttertoast.showToast(
          msg: 'Profile updated successfully!',
          backgroundColor: greenButton,
          textColor: Colors.white,
        );
        context.pop();
      }
    } on ApiException catch (e) {
      Fluttertoast.showToast(
        msg: e.message,
        backgroundColor: Colors.red.shade700,
        textColor: Colors.white,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Failed to update profile.',
        backgroundColor: Colors.red.shade700,
        textColor: Colors.white,
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
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
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Edit Profile',
          style: TextStyle(
            fontFamily: Constants.fontsFamily,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: accentColor,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: LoadingWidget())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_error!, style: TextStyle(fontFamily: Constants.fontsFamily, color: subTextColor)),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: _fetchUser,
                        child: Text('Retry', style: TextStyle(fontFamily: Constants.fontsFamily, color: blueButton, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Avatar
                        Center(
                          child: GestureDetector(
                            onTap: _pickAvatar,
                            child: Stack(
                              children: [
                                CircleAvatar(
                                  radius: 50,
                                  backgroundColor: primaryColor,
                                  backgroundImage: _selectedAvatar != null
                                      ? FileImage(_selectedAvatar!)
                                      : (_user?.avatarUrl != null && _user!.avatarUrl!.isNotEmpty
                                          ? NetworkImage(_user!.avatarUrl!) as ImageProvider
                                          : null),
                                  child: (_selectedAvatar == null && (_user?.avatarUrl == null || _user!.avatarUrl!.isEmpty))
                                      ? Icon(Icons.person, size: 50, color: subTextColor)
                                      : null,
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: accentColor,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(Icons.camera_alt, size: 16, color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Full Name
                        _buildLabel('Full Name'),
                        const SizedBox(height: 8),
                        CustomTextField(
                          hint: 'Enter full name',
                          controller: _fullNameController,
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null,
                        ),
                        const SizedBox(height: 16),

                        // Phone
                        _buildLabel('Phone'),
                        const SizedBox(height: 8),
                        CustomTextField(
                          hint: 'Enter phone number',
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 16),

                        // Date of Birth
                        _buildLabel('Date of Birth'),
                        const SizedBox(height: 8),
                        CustomTextField(
                          hint: 'YYYY-MM-DD',
                          controller: _dobController,
                          readOnly: true,
                          onTap: _pickDate,
                          suffixIcon: Icon(Icons.calendar_today, size: 18, color: subTextColor),
                        ),
                        const SizedBox(height: 16),

                        // Gender
                        _buildLabel('Gender'),
                        const SizedBox(height: 8),
                        _buildDropdown(_genders, _selectedGender, (v) => setState(() => _selectedGender = v)),
                        const SizedBox(height: 16),

                        // Height & Weight
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel('Height (cm)'),
                                  const SizedBox(height: 8),
                                  CustomTextField(
                                    hint: 'cm',
                                    controller: _heightController,
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel('Weight (kg)'),
                                  const SizedBox(height: 8),
                                  CustomTextField(
                                    hint: 'kg',
                                    controller: _weightController,
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Fitness Goal
                        _buildLabel('Fitness Goal'),
                        const SizedBox(height: 8),
                        _buildDropdown(_fitnessGoals, _selectedFitnessGoal, (v) => setState(() => _selectedFitnessGoal = v)),
                        const SizedBox(height: 16),

                        // Experience Level
                        _buildLabel('Experience Level'),
                        const SizedBox(height: 8),
                        _buildDropdown(_experienceLevels, _selectedExperienceLevel, (v) => setState(() => _selectedExperienceLevel = v)),
                        const SizedBox(height: 32),

                        // Save button
                        CustomButton(
                          text: 'Save Changes',
                          onPressed: _save,
                          isLoading: _isSaving,
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: Constants.fontsFamily,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: accentColor,
      ),
    );
  }

  Widget _buildDropdown(List<String> items, String? value, ValueChanged<String?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          hint: Text(
            'Select',
            style: TextStyle(
              fontFamily: Constants.fontsFamily,
              fontSize: 15,
              color: subTextColor,
            ),
          ),
          style: TextStyle(
            fontFamily: Constants.fontsFamily,
            fontSize: 15,
            color: accentColor,
          ),
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(_formatLabel(item)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
