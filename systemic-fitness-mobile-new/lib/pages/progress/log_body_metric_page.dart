import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:workout/ColorCategory.dart';
import 'package:workout/Constants.dart';
import 'package:workout/data/api_config.dart';
import 'package:workout/data/api_service.dart';
import 'package:workout/widgets/custom_button.dart';
import 'package:workout/widgets/custom_text_field.dart';

class LogBodyMetricPage extends StatefulWidget {
  const LogBodyMetricPage({super.key});

  @override
  State<LogBodyMetricPage> createState() => _LogBodyMetricPageState();
}

class _LogBodyMetricPageState extends State<LogBodyMetricPage> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  final _bodyFatController = TextEditingController();
  final _muscleMassController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isSaving = false;
  File? _selectedPhoto;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _weightController.dispose();
    _bodyFatController.dispose();
    _muscleMassController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery, maxWidth: 1024);
    if (picked != null) {
      setState(() => _selectedPhoto = File(picked.path));
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final body = <String, dynamic>{};

      final weight = double.tryParse(_weightController.text.trim());
      if (weight != null) body['weight_kg'] = weight;

      final bodyFat = double.tryParse(_bodyFatController.text.trim());
      if (bodyFat != null) body['body_fat_pct'] = bodyFat;

      final muscleMass = double.tryParse(_muscleMassController.text.trim());
      if (muscleMass != null) body['muscle_mass_kg'] = muscleMass;

      final notes = _notesController.text.trim();
      if (notes.isNotEmpty) body['notes'] = notes;

      // Photo upload would typically use multipart, simplified here
      await ApiService.postWithRetry(ApiConfig.bodyMetric, body: body);

      if (mounted) {
        Fluttertoast.showToast(
          msg: 'Body metric logged successfully!',
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
        msg: 'Failed to save body metric.',
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
          'Log Body Metric',
          style: TextStyle(
            fontFamily: Constants.fontsFamily,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: accentColor,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Weight
              _buildLabel('Weight (kg)'),
              const SizedBox(height: 8),
              CustomTextField(
                hint: 'Enter weight in kg',
                controller: _weightController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Weight is required';
                  }
                  if (double.tryParse(value.trim()) == null) {
                    return 'Enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Body Fat
              _buildLabel('Body Fat % (optional)'),
              const SizedBox(height: 8),
              CustomTextField(
                hint: 'Enter body fat percentage (0-100)',
                controller: _bodyFatController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value != null && value.trim().isNotEmpty) {
                    final v = double.tryParse(value.trim());
                    if (v == null || v < 0 || v > 100) {
                      return 'Enter a value between 0 and 100';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Muscle Mass
              _buildLabel('Muscle Mass (kg, optional)'),
              const SizedBox(height: 8),
              CustomTextField(
                hint: 'Enter muscle mass in kg',
                controller: _muscleMassController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 20),

              // Notes
              _buildLabel('Notes (optional)'),
              const SizedBox(height: 8),
              CustomTextField(
                hint: 'Any additional notes...',
                controller: _notesController,
                maxLines: 3,
              ),
              const SizedBox(height: 20),

              // Photo
              _buildLabel('Photo (optional)'),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickPhoto,
                child: Container(
                  width: double.infinity,
                  height: 150,
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor),
                  ),
                  child: _selectedPhoto != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            _selectedPhoto!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt_outlined, size: 40, color: subTextColor),
                            const SizedBox(height: 8),
                            Text(
                              'Tap to add photo',
                              style: TextStyle(
                                fontFamily: Constants.fontsFamily,
                                fontSize: 14,
                                color: subTextColor,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 32),

              // Save button
              CustomButton(
                text: 'Save Metric',
                onPressed: _save,
                isLoading: _isSaving,
                color: greenButton,
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
}
