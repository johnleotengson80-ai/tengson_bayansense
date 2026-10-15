import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../error_messages.dart';
import '../services/api_exception.dart';
import '../state/reports_state.dart';
import '../validators.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';
import '../widgets/centered_content.dart';
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

  bool _submitting = false;
  String? _error;
  AutovalidateMode _autovalidate = AutovalidateMode.disabled;

  @override
  void dispose() {
    _descriptionController.dispose();
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
    });
    final reports = context.read<ReportsState>();
    final navigator = Navigator.of(context);
    try {
      final result = await reports.submit(_descriptionController.text);
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
      setState(() => _error = messageForSubmit(e));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Submit a report')),
      body: CenteredContent(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            autovalidateMode: _autovalidate,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Describe what is happening and where (purok, street, or landmark). '
                  'You can write in Bisaya, Tagalog, or English.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _descriptionController,
                  label: 'Describe the problem',
                  hint: 'Example: Barado ang kanal sa atbang sa eskwelahan, Purok 3',
                  validator: validateDescription,
                  keyboardType: TextInputType.multiline,
                  minLines: 5,
                  maxLines: 10,
                ),
                const SizedBox(height: 16),
                if (_error != null) ...[
                  StatusMessage(text: _error!, kind: MessageKind.error),
                  const SizedBox(height: 16),
                ],
                AppButton(label: 'Submit report', loading: _submitting, onPressed: _submit),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
