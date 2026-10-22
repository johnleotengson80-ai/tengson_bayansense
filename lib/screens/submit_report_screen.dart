import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_spacing.dart';
import '../constants/app_strings.dart';
import '../error_messages.dart';
import '../routing/routes.dart';
import 'resident/resident_home_screen.dart';
import '../services/api_exception.dart';
import '../services/mock_bayan_sense_service.dart';
import '../state/reports_state.dart';
import '../validators.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';
import '../widgets/responsive_scaffold.dart';
import '../widgets/status_message.dart';
import 'out_of_scope_screen.dart';
import 'report_confirmation_screen.dart';

/// S03 - Submit Report. The server classifies and routes the report in the same request, so the
/// result screen can show the category and department immediately.
/// Photo and location are not here yet: the API has no upload endpoint and takes no address field.
class SubmitReportScreen extends StatefulWidget {
  const SubmitReportScreen({super.key});

  @override
  State<SubmitReportScreen> createState() => _SubmitReportScreenState();
}

class _SubmitReportScreenState extends State<SubmitReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();

  bool _submitting = false;
  String? _error;
  Map<String, dynamic>? _fieldErrors;
  AutovalidateMode _autovalidate = AutovalidateMode.disabled;

  @override
  void dispose() {
    _descriptionController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) return;
    if (!_formKey.currentState!.validate()) {
      setState(() => _autovalidate = AutovalidateMode.onUserInteraction);
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
      _fieldErrors = null;
    });
    final reports = context.read<ReportsState>();
    final navigator = Navigator.of(context);
    try {
      final result = await reports.submit(
        _descriptionController.text,
        latitude: double.tryParse(_latitudeController.text.trim()),
        longitude: double.tryParse(_longitudeController.text.trim()),
      );
      if (!mounted) return;
      navigator.pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => result.isOutOfScope
              ? OutOfScopeNoticeScreen(result: result)
              : ReportConfirmationScreen(result: result),
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = messageForSubmit(e);
        _fieldErrors = e.details;
      });
    } on MockServiceException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      title: AppStrings.submitReport,
      role: 'resident',
      selectedRoute: Routes.submitReport,
      items: ResidentHomeScreen.navigationItems,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Form(
          key: _formKey,
          autovalidateMode: _autovalidate,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(AppStrings.reportDescriptionHelper),
              const SizedBox(height: AppSpacing.medium),
              AppTextField(
                controller: _descriptionController,
                label: AppStrings.reportDescriptionLabel,
                hint: AppStrings.reportDescriptionHelper,
                validator: validateDescription,
                serverError: _fieldErrors?['description']?.toString(),
                keyboardType: TextInputType.multiline,
                minLines: 5,
                maxLines: 10,
              ),
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: _descriptionController,
                builder: (context, value, _) => Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '${value.text.runes.length} ${AppStrings.characterCount}',
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.large),
              Text(AppStrings.reportLocation,
                  style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: AppSpacing.small),
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      controller: _latitudeController,
                      label: AppStrings.latitude,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                      validator: validateLatitude,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.medium),
                  Expanded(
                    child: AppTextField(
                      controller: _longitudeController,
                      label: AppStrings.longitude,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                      validator: validateLongitude,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.medium),
              const StatusMessage(
                text: AppStrings.photoUploadUnavailable,
              ),
              const SizedBox(height: AppSpacing.medium),
              if (_error != null) ...[
                StatusMessage(
                  text: _error!,
                  kind: MessageKind.error,
                  onRetry: _submit,
                ),
                const SizedBox(height: AppSpacing.medium),
              ],
              AppButton(
                label: AppStrings.submitReportAction,
                loading: _submitting,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
