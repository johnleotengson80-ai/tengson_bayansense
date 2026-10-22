import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_strings.dart';
import '../constants/app_text_styles.dart';
import '../routing/routes.dart';
import '../state/auth_state.dart';
import '../validators.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.initialRegisterMode = false});

  final bool initialRegisterMode;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  late bool _registerMode = widget.initialRegisterMode;
  bool _hidePassword = true;
  AutovalidateMode _autovalidate = AutovalidateMode.disabled;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _toggleMode() {
    context.read<AuthState>().clearMessages();
    setState(() {
      _registerMode = !_registerMode;
      _autovalidate = AutovalidateMode.disabled;
    });
  }

  Future<void> _submit() async {
    final auth = context.read<AuthState>();
    if (auth.busy) return;
    if (!_formKey.currentState!.validate()) {
      setState(() => _autovalidate = AutovalidateMode.onUserInteraction);
      return;
    }
    if (_registerMode) {
      await auth.register(
        fullName: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
      );
    } else {
      await auth.login(_emailController.text, _passwordController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthState>();
    final mobile = MediaQuery.sizeOf(context).width < AppSpacing.compactBreakpoint;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: AppStrings.publicHome,
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
            Routes.root,
            (route) => false,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.large),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: AppSpacing.formMaxWidth),
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(
                    mobile ? AppSpacing.medium : AppSpacing.xLarge,
                  ),
                  child: Form(
                    key: _formKey,
                    autovalidateMode: _autovalidate,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Icon(
                          Icons.account_balance_outlined,
                          size: AppSpacing.smallIconSize,
                          color: AppColors.primary,
                        ),
                        const SizedBox(height: AppSpacing.small),
                        const Text(
                          AppStrings.appName,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.pageTitle,
                        ),
                        const SizedBox(height: AppSpacing.small),
                        Text(
                          _registerMode
                              ? AppStrings.registerTitle
                              : AppStrings.loginTitle,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.body,
                        ),
                        const SizedBox(height: AppSpacing.large),
                        if (_registerMode) ...[
                          AppTextField(
                            controller: _nameController,
                            label: AppStrings.fullName,
                            validator: validateFullName,
                            serverError:
                                auth.errorDetails?['full_name']?.toString(),
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: AppSpacing.medium),
                        ],
                        AppTextField(
                          controller: _emailController,
                          label: AppStrings.emailLabel,
                          validator: validateEmail,
                          serverError:
                              auth.errorDetails?['email']?.toString(),
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: AppSpacing.medium),
                        AppTextField(
                          controller: _passwordController,
                          label: AppStrings.password,
                          validator: _registerMode
                              ? validateNewPassword
                              : validateLoginPassword,
                          serverError:
                              auth.errorDetails?['password']?.toString(),
                          obscureText: _hidePassword,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _submit(),
                          suffixIcon: IconButton(
                            tooltip: _hidePassword
                                ? AppStrings.showPassword
                                : AppStrings.hidePassword,
                            icon: Icon(
                              _hidePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            onPressed: () =>
                                setState(() => _hidePassword = !_hidePassword),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.medium),
                        if (auth.errorMessage != null) ...[
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.medium),
                            decoration: BoxDecoration(
                              color: AppColors.primaryTint,
                              borderRadius: BorderRadius.circular(
                                AppSpacing.cornerRadius,
                              ),
                            ),
                            child: Text(
                              auth.errorMessage!,
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.medium),
                        ],
                        AppButton(
                          label: _registerMode
                              ? AppStrings.createAccount
                              : AppStrings.login,
                          loading: auth.busy,
                          onPressed: _submit,
                        ),
                        const SizedBox(height: AppSpacing.small),
                        TextButton(
                          onPressed: auth.busy ? null : _toggleMode,
                          child: Text(
                            _registerMode
                                ? '${AppStrings.existingAccountPrompt} ${AppStrings.signInAction}'
                                : '${AppStrings.accountPrompt} ${AppStrings.createAccountLink}',
                          ),
                        ),
                        if (!_registerMode) ...[
                          const SizedBox(height: AppSpacing.small),
                          const Text(
                            AppStrings.staffAccountNote,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.secondary,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
