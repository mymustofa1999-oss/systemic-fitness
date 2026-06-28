import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:workout/data/api_service.dart';
import 'package:workout/data/nutrition_guidance_repository.dart';
import 'package:workout/models/nutrition_guidance_model.dart';
import 'package:workout/router/app_router.dart';

class HealthProfileFormPage extends StatefulWidget {
  const HealthProfileFormPage({super.key});

  @override
  State<HealthProfileFormPage> createState() => _HealthProfileFormPageState();
}

class _HealthProfileFormPageState extends State<HealthProfileFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _weightCtrl = TextEditingController();
  final _allergyCtrl = TextEditingController();

  String _gender = 'male';
  String _ageGroup = '18_40';
  String? _femaleCondition;
  String _goal = 'maintenance';
  final Set<String> _conditions = {};
  final List<String> _allergies = [];
  bool _saving = false;

  @override
  void dispose() {
    _weightCtrl.dispose();
    _allergyCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final profile = NutritionHealthProfile(
        gender: _gender,
        ageGroup: _ageGroup,
        femaleCondition: _gender == 'female' ? _femaleCondition : null,
        goal: _goal,
        weightKg: double.tryParse(_weightCtrl.text.trim()) ?? 0,
        allergies: List.of(_allergies),
        conditions: _conditions.toList(),
      );
      await NutritionGuidanceRepository.upsertProfile(profile);
      if (!mounted) return;
      context.go(AppRoutes.nutritionGuidancePlan);
    } on PaidSubscriptionRequiredException {
      if (!mounted) return;
      context.go(AppRoutes.nutritionGuidanceUpgrade);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Gagal menyimpan: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _addAllergy() {
    final v = _allergyCtrl.text.trim();
    if (v.isEmpty) return;
    setState(() {
      _allergies.add(v);
      _allergyCtrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil Kesehatan')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Jenis Kelamin', style: TextStyle(fontWeight: FontWeight.bold)),
              DropdownButtonFormField<String>(
                value: _gender,
                items: const [
                  DropdownMenuItem(value: 'male', child: Text('Laki-laki')),
                  DropdownMenuItem(value: 'female', child: Text('Perempuan')),
                ],
                onChanged: (v) => setState(() => _gender = v ?? 'male'),
              ),
              const SizedBox(height: 16),

              const Text('Kelompok Usia', style: TextStyle(fontWeight: FontWeight.bold)),
              DropdownButtonFormField<String>(
                value: _ageGroup,
                items: const [
                  DropdownMenuItem(value: 'under_18', child: Text('< 18 tahun')),
                  DropdownMenuItem(value: '18_40', child: Text('18 - 40 tahun')),
                  DropdownMenuItem(value: '41_60', child: Text('41 - 60 tahun')),
                  DropdownMenuItem(value: 'over_60', child: Text('> 60 tahun')),
                ],
                onChanged: (v) => setState(() => _ageGroup = v ?? '18_40'),
              ),
              const SizedBox(height: 16),

              if (_gender == 'female') ...[
                const Text('Kondisi Khusus', style: TextStyle(fontWeight: FontWeight.bold)),
                DropdownButtonFormField<String>(
                  value: _femaleCondition,
                  hint: const Text('Pilih (opsional)'),
                  items: const [
                    DropdownMenuItem(value: 'normal', child: Text('Normal')),
                    DropdownMenuItem(value: 'pregnant', child: Text('Hamil')),
                    DropdownMenuItem(value: 'menopause', child: Text('Menopause')),
                  ],
                  onChanged: (v) => setState(() => _femaleCondition = v),
                ),
                const SizedBox(height: 16),
              ],

              const Text('Tujuan', style: TextStyle(fontWeight: FontWeight.bold)),
              DropdownButtonFormField<String>(
                value: _goal,
                items: const [
                  DropdownMenuItem(value: 'maintenance', child: Text('Maintenance')),
                  DropdownMenuItem(value: 'fat_loss', child: Text('Fat Loss')),
                  DropdownMenuItem(value: 'recovery', child: Text('Recovery')),
                ],
                onChanged: (v) => setState(() => _goal = v ?? 'maintenance'),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _weightCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Berat Badan (kg)',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  final d = double.tryParse((v ?? '').trim());
                  if (d == null || d <= 0) return 'Masukkan berat badan yang valid';
                  return null;
                },
              ),
              const SizedBox(height: 24),

              const Text('Kondisi Kesehatan', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: HealthConditions.all.map((c) {
                  final selected = _conditions.contains(c);
                  return FilterChip(
                    label: Text(HealthConditions.labels[c] ?? c),
                    selected: selected,
                    onSelected: (val) => setState(() {
                      if (val) {
                        _conditions.add(c);
                      } else {
                        _conditions.remove(c);
                      }
                    }),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              const Text('Alergi Makanan', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _allergyCtrl,
                      decoration: const InputDecoration(
                        hintText: 'Mis: kacang, susu',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      onSubmitted: (_) => _addAllergy(),
                    ),
                  ),
                  IconButton(onPressed: _addAllergy, icon: const Icon(Icons.add_circle, color: Colors.green)),
                ],
              ),
              if (_allergies.isNotEmpty)
                Wrap(
                  spacing: 8,
                  children: _allergies
                      .map((a) => Chip(
                            label: Text(a),
                            onDeleted: () => setState(() => _allergies.remove(a)),
                          ))
                      .toList(),
                ),
              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                child: _saving
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Simpan & Lihat Rencana'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
