import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _sent = false;

  void _handleReset() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _sent = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: _sent
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(Icons.check_circle_outline, size: 72, color: Colors.green),
                    const SizedBox(height: 24),
                    Text(
                      'Check your inbox',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.h2(isDark),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'We have sent instructions to ${_emailController.text} to reset your password.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium(isDark),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => context.pop(),
                      child: const Text('Back to Login'),
                    ),
                  ],
                )
              : Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Forgot Password',
                        style: AppTextStyles.h2(isDark),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Provide your account email to receive reset validation steps.',
                        style: AppTextStyles.bodyMedium(isDark),
                      ),
                      const SizedBox(height: 32),
                      TextFormField(
                        controller: _emailController,
                        validator: AppValidators.email,
                        decoration: InputDecoration(
                          labelText: 'Email Address',
                          prefixIcon: const Icon(Icons.email_outlined),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _handleReset,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text('Send Reset Instructions'),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
