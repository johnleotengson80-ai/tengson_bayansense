import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_spacing.dart';
import '../../constants/app_strings.dart';
import '../../routing/routes.dart';
import '../../services/api_exception.dart';
import '../../services/bayan_sense_service.dart';
import '../../services/mock_bayan_sense_service.dart';
import '../../validators.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/responsive_scaffold.dart';
import '../../widgets/status_message.dart';
import 'admin_home_screen.dart';

class CreateStaffScreen extends StatefulWidget {
  const CreateStaffScreen({super.key});

  @override
  State<CreateStaffScreen> createState() => _CreateStaffScreenState();
}

class _CreateStaffScreenState extends State<CreateStaffScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _department;
  bool _saving = false;
  String? _error;
  String? _success;
  Map<String, dynamic>? _fieldErrors;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_saving) return;
    if (!_formKey.currentState!.validate()) return;
    final matchingDepartments = AppStrings.departmentNames
        .where((department) => department.name == _department)
        .toList();
    final departmentId =
        matchingDepartments.isEmpty ? null : matchingDepartments.first.id;
    if (departmentId == null) {
      setState(() => _error = AppStrings.departmentRequired);
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
      _success = null;
      _fieldErrors = null;
    });
    try {
      await context.read<BayanSenseService>().createPersonnel(
            fullName: _nameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
            departmentId: departmentId,
          );
      if (!mounted) return;
      setState(() {
        _nameController.clear();
        _emailController.clear();
        _passwordController.clear();
        _department = null;
        _success = AppStrings.staffAccountCreated;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _error =
            error.statusCode == 403 ? AppStrings.accessDenied : error.message;
        _fieldErrors = error.details;
      });
    } on MockServiceException catch (error) {
      if (!mounted) return;
      setState(() => _error = error.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => ResponsiveScaffold(
        title: AppStrings.staffAccounts,
        role: 'admin',
        selectedRoute: Routes.adminStaff,
        items: AdminHomeScreen.navigationItems,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.medium),
          children: [
            Text(AppStrings.createStaffTitle,
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: AppSpacing.large),
            if (_success != null) ...[
              StatusMessage(text: _success!, kind: MessageKind.success),
              const SizedBox(height: AppSpacing.medium),
            ],
            if (_error != null) ...[
              StatusMessage(
                text: _error!,
                kind: MessageKind.error,
                onRetry: _submit,
              ),
              const SizedBox(height: AppSpacing.medium),
            ],
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppTextField(
                    controller: _nameController,
                    label: AppStrings.fullName,
                    validator: validateFullName,
                    serverError: _fieldErrors?['full_name']?.toString(),
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: AppSpacing.medium),
                  AppTextField(
                    controller: _emailController,
                    label: AppStrings.emailLabel,
                    keyboardType: TextInputType.emailAddress,
                    validator: validateEmail,
                    serverError: _fieldErrors?['email']?.toString(),
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: AppSpacing.medium),
                  AppTextField(
                    controller: _passwordController,
                    label: AppStrings.password,
                    obscureText: true,
                    validator: validateNewPassword,
                    serverError: _fieldErrors?['password']?.toString(),
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: AppSpacing.small),
                  const Text(AppStrings.passwordRule),
                  const SizedBox(height: AppSpacing.medium),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final itemWidth =
                          (constraints.maxWidth - AppSpacing.xxLarge * 3)
                              .clamp(0.0, 600.0);
                      return DropdownButtonFormField<String>(
                        initialValue: _department,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: AppStrings.department,
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          for (final department in AppStrings.departmentNames)
                            DropdownMenuItem(
                              value: department.name,
                              child: SizedBox(
                                width: itemWidth,
                                child: Text(
                                  department.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                        ],
                        validator: (value) => value == null
                            ? AppStrings.departmentRequired
                            : null,
                        onChanged: _saving
                            ? null
                            : (value) => setState(() => _department = value),
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.large),
                  AppButton(
                    label: AppStrings.createStaffAccount,
                    loading: _saving,
                    onPressed: _submit,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}
