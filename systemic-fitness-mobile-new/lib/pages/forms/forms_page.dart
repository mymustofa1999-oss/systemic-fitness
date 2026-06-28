import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:workout/Constants.dart';
import 'package:workout/ColorCategory.dart';
import 'package:workout/data/api_config.dart';
import 'package:workout/data/api_service.dart';
import 'package:workout/widgets/loading_widget.dart';
import 'package:workout/widgets/empty_state_widget.dart';

class FormsPage extends StatefulWidget {
  const FormsPage({super.key});

  @override
  State<FormsPage> createState() => _FormsPageState();
}

class _FormsPageState extends State<FormsPage> {
  List<Map<String, dynamic>> _forms = [];
  bool _isLoading = true;
  String? _error;

  // Form detail state
  Map<String, dynamic>? _selectedForm;
  List<Map<String, dynamic>> _formFields = [];
  bool _isLoadingDetail = false;
  String? _detailError;

  // Response submission
  final Map<String, dynamic> _responses = {};
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadForms();
  }

  Future<void> _loadForms() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await ApiService.getWithRetry(ApiConfig.forms);
      final List<dynamic> data = response['data'] ?? [];

      setState(() {
        _forms = data.cast<Map<String, dynamic>>();
        _isLoading = false;
      });
    } on ApiException catch (e) {
      setState(() {
        _error = e.message;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Gagal memuat data formulir';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadFormDetail(String formId) async {
    setState(() {
      _isLoadingDetail = true;
      _detailError = null;
      _responses.clear();
    });

    try {
      final response = await ApiService.getWithRetry(
        ApiConfig.formById(formId),
      );
      final data = response['data'] as Map<String, dynamic>? ?? response;

      setState(() {
        _selectedForm = data;
        final fields = data['fields'] ?? data['questions'] ?? [];
        _formFields = (fields as List).cast<Map<String, dynamic>>();
        _isLoadingDetail = false;
      });
    } on ApiException catch (e) {
      setState(() {
        _detailError = e.message;
        _isLoadingDetail = false;
      });
    } catch (e) {
      setState(() {
        _detailError = 'Gagal memuat detail formulir';
        _isLoadingDetail = false;
      });
    }
  }

  Future<void> _submitResponse() async {
    if (_selectedForm == null) return;

    final formId = (_selectedForm!['id'] ?? '').toString();
    setState(() => _isSubmitting = true);

    try {
      await ApiService.postWithRetry(
        ApiConfig.formResponses(formId),
        body: {'answers': _responses},
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Jawaban berhasil dikirim!'),
          backgroundColor: Colors.green,
        ),
      );
      _onBackToList();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal mengirim jawaban'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _onFormTap(Map<String, dynamic> form) {
    final formId = (form['id'] ?? '').toString();
    setState(() {
      _selectedForm = form;
      _formFields = [];
    });
    _loadFormDetail(formId);
  }

  void _onBackToList() {
    setState(() {
      _selectedForm = null;
      _formFields = [];
      _detailError = null;
      _responses.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final showDetail = _selectedForm != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: accentColor),
          onPressed: () {
            if (showDetail) {
              _onBackToList();
            } else {
              context.pop();
            }
          },
        ),
        title: Text(
          showDetail
              ? (_selectedForm?['title'] ?? 'Detail Formulir').toString()
              : 'Formulir',
          style: TextStyle(
            fontFamily: Constants.fontsFamily,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: accentColor,
          ),
        ),
        centerTitle: true,
      ),
      body: showDetail ? _buildFormDetail() : _buildFormList(),
    );
  }

  Widget _buildFormList() {
    if (_isLoading) return const LoadingWidget();

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 56, color: subTextColor),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: TextStyle(
                fontFamily: Constants.fontsFamily,
                fontSize: 14,
                color: subTextColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _loadForms,
              child: Text(
                'Coba Lagi',
                style: TextStyle(
                  fontFamily: Constants.fontsFamily,
                  color: blueButton,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_forms.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.assignment_outlined,
        title: 'Belum Ada Formulir',
        subtitle: 'Belum ada formulir yang tersedia.',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadForms,
      color: accentColor,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _forms.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final form = _forms[index];
          final title = (form['title'] ?? form['name'] ?? '-').toString();
          final description =
              (form['description'] ?? '').toString();
          final status = (form['status'] ?? '').toString();

          return Material(
            color: getCellColor(index),
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => _onFormTap(form),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.description_outlined,
                        color: accentColor,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontFamily: Constants.fontsFamily,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: accentColor,
                            ),
                          ),
                          if (description.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily:
                                    Constants.fontsFamily,
                                fontSize: 12,
                                color: subTextColor,
                              ),
                            ),
                          ],
                          if (status.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: status == 'active'
                                    ? greenButton
                                        .withOpacity(0.15)
                                    : subTextColor
                                        .withOpacity(0.1),
                                borderRadius:
                                    BorderRadius.circular(8),
                              ),
                              child: Text(
                                status.toUpperCase(),
                                style: TextStyle(
                                  fontFamily:
                                      Constants.fontsFamily,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: status == 'active'
                                      ? greenButton
                                      : subTextColor,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right,
                        color: subTextColor),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFormDetail() {
    if (_isLoadingDetail) return const LoadingWidget();

    if (_detailError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline,
                size: 56, color: subTextColor),
            const SizedBox(height: 16),
            Text(
              _detailError!,
              style: TextStyle(
                fontFamily: Constants.fontsFamily,
                fontSize: 14,
                color: subTextColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => _loadFormDetail(
                  (_selectedForm?['id'] ?? '').toString()),
              child: Text(
                'Coba Lagi',
                style: TextStyle(
                  fontFamily: Constants.fontsFamily,
                  color: blueButton,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_formFields.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.assignment_outlined,
        title: 'Formulir Kosong',
        subtitle:
            'Formulir ini belum memiliki pertanyaan.',
      );
    }

    return Column(
      children: [
        // Description
        if ((_selectedForm?['description'] ?? '').toString().isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 12),
            color: primaryColor,
            child: Text(
              (_selectedForm!['description']).toString(),
              style: TextStyle(
                fontFamily: Constants.fontsFamily,
                fontSize: 13,
                color: subTextColor,
              ),
            ),
          ),

        // Form fields
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: _formFields.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final field = _formFields[index];
              final fieldId =
                  (field['id'] ?? field['key'] ?? '$index')
                      .toString();
              final label =
                  (field['label'] ?? field['question'] ?? '')
                      .toString();
              final fieldType =
                  (field['type'] ?? 'text').toString();
              final required =
                  field['required'] == true;
              final rawOptions = field['options'];
              final List? options = rawOptions is List
                  ? rawOptions
                  : rawOptions is Map
                      ? rawOptions.values.toList()
                      : null;

              return Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          label,
                          style: TextStyle(
                            fontFamily:
                                Constants.fontsFamily,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: accentColor,
                          ),
                        ),
                      ),
                      if (required)
                        Text(
                          '*',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.red,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (fieldType == 'select' ||
                      fieldType == 'dropdown' ||
                      fieldType == 'radio')
                    _buildSelectField(
                        fieldId, options)
                  else if (fieldType == 'textarea' ||
                      fieldType == 'long_text')
                    _buildTextAreaField(fieldId)
                  else
                    _buildTextField(fieldId),
                ],
              );
            },
          ),
        ),

        // Submit button
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _isSubmitting
                  ? null
                  : _submitResponse,
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(12),
                ),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'Kirim Jawaban',
                      style: TextStyle(
                        fontFamily:
                            Constants.fontsFamily,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String fieldId) {
    return TextField(
      onChanged: (val) => _responses[fieldId] = val,
      style: TextStyle(
        fontFamily: Constants.fontsFamily,
        fontSize: 14,
        color: accentColor,
      ),
      decoration: InputDecoration(
        hintText: 'Ketik jawaban...',
        hintStyle: TextStyle(
          fontFamily: Constants.fontsFamily,
          fontSize: 14,
          color: subTextColor,
        ),
        filled: true,
        fillColor: primaryColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 12),
      ),
    );
  }

  Widget _buildTextAreaField(String fieldId) {
    return TextField(
      onChanged: (val) => _responses[fieldId] = val,
      maxLines: 4,
      style: TextStyle(
        fontFamily: Constants.fontsFamily,
        fontSize: 14,
        color: accentColor,
      ),
      decoration: InputDecoration(
        hintText: 'Ketik jawaban...',
        hintStyle: TextStyle(
          fontFamily: Constants.fontsFamily,
          fontSize: 14,
          color: subTextColor,
        ),
        filled: true,
        fillColor: primaryColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 12),
      ),
    );
  }

  Widget _buildSelectField(
      String fieldId, List? options) {
    if (options == null || options.isEmpty) {
      return _buildTextField(fieldId);
    }

    final stringOptions =
        options.map((e) => e.toString()).toList();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: stringOptions.map((option) {
        final isSelected = _responses[fieldId] == option;
        return GestureDetector(
          onTap: () {
            setState(() => _responses[fieldId] = option);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color:
                  isSelected ? accentColor : primaryColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? accentColor
                    : subTextColor.withOpacity(0.3),
              ),
            ),
            child: Text(
              option,
              style: TextStyle(
                fontFamily: Constants.fontsFamily,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : accentColor,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
