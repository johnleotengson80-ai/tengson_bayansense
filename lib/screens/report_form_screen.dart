import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_strings.dart';
import '../validators.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';

enum ReportUiState { idle, loading, success, empty, error }

class ReportFormScreen extends StatefulWidget {
  const ReportFormScreen({super.key});

  @override
  State<ReportFormScreen> createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends State<ReportFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();

  ReportUiState _uiState = ReportUiState.empty;
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;
  String? _selectedCategory;
  bool _simulateFailure = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> submitReport() async {
    if (_uiState == ReportUiState.loading) return;
    if (!_formKey.currentState!.validate()) {
      setState(() => _autovalidateMode = AutovalidateMode.onUserInteraction);
      return;
    }

    setState(() => _uiState = ReportUiState.loading);
    await Future<void>.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    setState(() {
      if (_simulateFailure) {
        _uiState = ReportUiState.error;
      } else {
        _uiState = ReportUiState.success;
      }
    });
  }

  void _startReport() {
    setState(() => _uiState = ReportUiState.idle);
  }

  void _submitAnotherReport() {
    _formKey.currentState?.reset();
    _descriptionController.clear();
    _locationController.clear();
    setState(() {
      _selectedCategory = null;
      _autovalidateMode = AutovalidateMode.disabled;
      _uiState = ReportUiState.idle;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.reportFormTitle)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppSpacing.formMaxWidth),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.medium),
            child: _uiState == ReportUiState.success
                ? _buildSuccess()
                : _buildForm(),
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      autovalidateMode: _autovalidateMode,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_uiState == ReportUiState.empty) ...[
            _buildEmptyPanel(),
            const SizedBox(height: AppSpacing.large),
          ],
          const Text(AppStrings.reportSimulationNote),
          const SizedBox(height: AppSpacing.medium),
          AppTextField(
            controller: _descriptionController,
            label: AppStrings.reportDescriptionLabel,
            hint: AppStrings.reportDescriptionHelper,
            validator: validateDescription,
            keyboardType: TextInputType.multiline,
            minLines: 4,
            maxLines: 8,
          ),
          const SizedBox(height: AppSpacing.medium),
          DropdownButtonFormField<String>(
            isExpanded: true,
            initialValue: _selectedCategory,
            decoration: const InputDecoration(
              labelText: AppStrings.reportCategoryLabel,
              hintText: AppStrings.reportCategoryHint,
              border: OutlineInputBorder(),
            ),
            items: AppStrings.problemTypes
                .map(
                  (category) => DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  ),
                )
                .toList(),
            validator: (value) =>
                value == null ? AppStrings.reportCategoryRequired : null,
            onChanged: _uiState == ReportUiState.loading
                ? null
                : (value) => setState(() => _selectedCategory = value),
          ),
          const SizedBox(height: AppSpacing.medium),
          AppTextField(
            controller: _locationController,
            label: AppStrings.reportLocationPurok,
            hint: AppStrings.reportLocationHint,
            validator: validateReportLocation,
          ),
          const SizedBox(height: AppSpacing.small),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            activeTrackColor: AppColors.primary,
            title: const Text(AppStrings.simulateFailure),
            value: _simulateFailure,
            onChanged: _uiState == ReportUiState.loading
                ? null
                : (value) => setState(() => _simulateFailure = value),
          ),
          if (_uiState == ReportUiState.error) ...[
            const SizedBox(height: AppSpacing.small),
            const Text(
              AppStrings.simulatedReportError,
              style: TextStyle(color: AppColors.primary),
            ),
            const SizedBox(height: AppSpacing.small),
            AppButton(
              label: AppStrings.submitReportRetry,
              onPressed: submitReport,
            ),
            const SizedBox(height: AppSpacing.small),
          ],
          AppButton(
            label: AppStrings.submitReportAction,
            loading: _uiState == ReportUiState.loading,
            onPressed: _uiState == ReportUiState.loading ? null : submitReport,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyPanel() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.medium),
      decoration: BoxDecoration(
        color: AppColors.subtleSurface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppSpacing.cornerRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            AppStrings.reportsSentThisSession,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.small),
          const Text(AppStrings.noSessionReports),
          const SizedBox(height: AppSpacing.medium),
          AppButton(
            label: AppStrings.startReportAction,
            onPressed: _startReport,
          ),
        ],
      ),
    );
  }

  Widget _buildSuccess() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(
          Icons.check_circle_outline,
          color: AppColors.primary,
          size: AppSpacing.smallIconSize,
        ),
        const SizedBox(height: AppSpacing.medium),
        Text(
          AppStrings.simulatedReportSuccessTitle,
          style: Theme.of(context).textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.small),
        const Text(
          AppStrings.simulatedReportSuccessMessage,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.large),
        AppButton(
          label: AppStrings.submitAnotherReport,
          onPressed: _submitAnotherReport,
        ),
      ],
    );
  }
}
