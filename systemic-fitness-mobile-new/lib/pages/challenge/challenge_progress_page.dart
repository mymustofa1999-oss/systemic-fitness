import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:workout/Constants.dart';
import 'package:workout/ColorCategory.dart';
import 'package:workout/data/api_config.dart';
import 'package:workout/data/api_service.dart';
import 'package:workout/data/pref_data.dart';
import 'package:workout/models/challenge_model.dart';
import 'package:workout/widgets/custom_button.dart';
import 'package:workout/widgets/loading_widget.dart';

class ChallengeProgressPage extends StatefulWidget {
  final String challengeId;

  const ChallengeProgressPage({super.key, required this.challengeId});

  @override
  State<ChallengeProgressPage> createState() => _ChallengeProgressPageState();
}

class _ChallengeProgressPageState extends State<ChallengeProgressPage> {
  final _formKey = GlobalKey<FormState>();
  final _valueController = TextEditingController();
  bool _isLoading = true;
  bool _isSaving = false;
  String? _error;
  ChallengeModel? _challenge;
  double? _currentProgress;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _valueController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final user = await PrefData.getUser();
      final results = await Future.wait([
        ApiService.getWithRetry(
            ApiConfig.challengeById(widget.challengeId)),
        ApiService.getWithRetry(
            ApiConfig.challengeParticipants(widget.challengeId)),
      ]);

      final challengeData = results[0]['data'];
      final participantsData = results[1]['data'] as List? ?? [];

      final participants = participantsData
          .map((e) => ChallengeParticipant.fromJson(e))
          .toList();
      final myParticipant = participants
          .where((p) => p.userId == user?.id)
          .firstOrNull;

      setState(() {
        _challenge = challengeData != null
            ? ChallengeModel.fromJson(challengeData)
            : null;
        _currentProgress = myParticipant?.progressValue ?? 0;
        _valueController.text =
            _currentProgress?.toStringAsFixed(0) ?? '0';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _submitProgress() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final value = double.parse(_valueController.text.trim());
      await ApiService.postWithRetry(
        ApiConfig.challengeProgress(widget.challengeId),
        body: {'value': value},
      );

      if (mounted) {
        Fluttertoast.showToast(
          msg: 'Progress updated!',
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
    } catch (_) {
      Fluttertoast.showToast(
        msg: 'Failed to update progress.',
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
          'Update Progress',
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
          ? const LoadingWidget()
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error!,
                          style: TextStyle(
                              fontFamily: Constants.fontsFamily,
                              color: subTextColor)),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: _loadData,
                        child: Text('Retry',
                            style: TextStyle(
                                fontFamily: Constants.fontsFamily,
                                color: blueButton)),
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
                        // Challenge info
                        Text(
                          _challenge?.name ?? '',
                          style: TextStyle(
                            fontFamily: Constants.fontsFamily,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: accentColor,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Goal info card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Goal',
                                    style: TextStyle(
                                      fontFamily: Constants.fontsFamily,
                                      fontSize: 13,
                                      color: subTextColor,
                                    ),
                                  ),
                                  Text(
                                    '${_challenge?.goalValue?.toStringAsFixed(0) ?? '—'} ${_challenge?.goalType ?? ''}',
                                    style: TextStyle(
                                      fontFamily: Constants.fontsFamily,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: accentColor,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Current Progress',
                                    style: TextStyle(
                                      fontFamily: Constants.fontsFamily,
                                      fontSize: 13,
                                      color: subTextColor,
                                    ),
                                  ),
                                  Text(
                                    '${_currentProgress?.toStringAsFixed(0) ?? '0'} ${_challenge?.goalType ?? ''}',
                                    style: TextStyle(
                                      fontFamily: Constants.fontsFamily,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: greenButton,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Input
                        Text(
                          'New Progress Value (cumulative total)',
                          style: TextStyle(
                            fontFamily: Constants.fontsFamily,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: accentColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _valueController,
                          keyboardType: const TextInputType
                              .numberWithOptions(decimal: true),
                          style: TextStyle(
                            fontFamily: Constants.fontsFamily,
                            fontSize: 16,
                            color: accentColor,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Enter total progress value',
                            hintStyle: TextStyle(
                              fontFamily: Constants.fontsFamily,
                              color: subTextColor,
                            ),
                            filled: true,
                            fillColor: primaryColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                          ),
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty) {
                              return 'Please enter a value';
                            }
                            if (double.tryParse(value.trim()) ==
                                null) {
                              return 'Enter a valid number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Enter your cumulative total, not just today\'s increment.',
                          style: TextStyle(
                            fontFamily: Constants.fontsFamily,
                            fontSize: 12,
                            color: subTextColor,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Submit button
                        CustomButton(
                          text: 'Submit Progress',
                          onPressed: _submitProgress,
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
}
