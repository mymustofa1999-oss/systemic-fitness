import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:workout/ColorCategory.dart';
import 'package:workout/Constants.dart';
import 'package:workout/data/api_config.dart';
import 'package:workout/data/api_service.dart';
import 'package:workout/widgets/custom_button.dart';
import 'package:workout/widgets/custom_text_field.dart';

class LogNutritionPage extends StatefulWidget {
  const LogNutritionPage({super.key});

  @override
  State<LogNutritionPage> createState() => _LogNutritionPageState();
}

class _LogNutritionPageState extends State<LogNutritionPage> {
  final _formKey = GlobalKey<FormState>();
  final _foodNameController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatController = TextEditingController();
  bool _isSaving = false;
  String _selectedMealType = 'breakfast';

  final List<String> _mealTypes = ['breakfast', 'lunch', 'dinner', 'snack'];

  @override
  void dispose() {
    _foodNameController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    super.dispose();
  }

  String _mealTypeLabel(String type) {
    switch (type) {
      case 'breakfast':
        return 'Breakfast';
      case 'lunch':
        return 'Lunch';
      case 'dinner':
        return 'Dinner';
      case 'snack':
        return 'Snack';
      default:
        return type;
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      await ApiService.postWithRetry(
        ApiConfig.nutritionLog,
        body: {
          'meal_type': _selectedMealType,
          'food_name': _foodNameController.text.trim(),
          'calories': int.tryParse(_caloriesController.text.trim()) ?? 0,
          'protein_g': double.tryParse(_proteinController.text.trim()),
          'carbs_g': double.tryParse(_carbsController.text.trim()),
          'fat_g': double.tryParse(_fatController.text.trim()),
        },
      );

      if (mounted) {
        Fluttertoast.showToast(
          msg: 'Meal logged successfully!',
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
        msg: 'Failed to save meal.',
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
          'Log Meal',
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
              // Meal type
              _buildLabel('Meal Type'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _mealTypes.map((type) {
                  final isSelected = _selectedMealType == type;
                  return ChoiceChip(
                    label: Text(
                      _mealTypeLabel(type),
                      style: TextStyle(
                        fontFamily: Constants.fontsFamily,
                        fontSize: 13,
                        color: isSelected ? Colors.white : accentColor,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: accentColor,
                    backgroundColor: primaryColor,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedMealType = type);
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Food name
              _buildLabel('Food Name'),
              const SizedBox(height: 8),
              CustomTextField(
                hint: 'e.g. Grilled Chicken Salad',
                controller: _foodNameController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Food name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Calories
              _buildLabel('Calories'),
              const SizedBox(height: 8),
              CustomTextField(
                hint: 'Enter calories',
                controller: _caloriesController,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Calories is required';
                  }
                  if (int.tryParse(value.trim()) == null) {
                    return 'Enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Macros row
              _buildLabel('Macros (optional)'),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      hint: 'Protein (g)',
                      controller: _proteinController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: CustomTextField(
                      hint: 'Carbs (g)',
                      controller: _carbsController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: CustomTextField(
                      hint: 'Fat (g)',
                      controller: _fatController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Save button
              CustomButton(
                text: 'Save Meal',
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
