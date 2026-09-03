import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_spacing.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _register = false;
  bool _loading = false;
  String? _message;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_email.text.trim().isEmpty || _password.text.length < 6) {
      setState(() => _message = 'Enter a valid email and a password with at least 6 characters.');
      return;
    }
    setState(() {
      _loading = true;
      _message = null;
    });
    final controller = ref.read(authControllerProvider);
    final result = _register
        ? await controller.signUp(_email.text, _password.text)
        : await controller.signIn(_email.text, _password.text);
    if (!mounted) return;
    setState(() {
      _loading = false;
      _message = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.large),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.large),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('🔗', textAlign: TextAlign.center, style: theme.textTheme.displaySmall),
                    const SizedBox(height: 8),
                    Text('Link Saver', textAlign: TextAlign.center, style: theme.textTheme.headlineSmall),
                    const SizedBox(height: 8),
                    Text(_register ? 'Create an account to sync your links.' : 'Sign in to access your cloud-synced links.', textAlign: TextAlign.center, style: theme.textTheme.bodyMedium),
                    const SizedBox(height: AppSpacing.large),
                    TextField(controller: _email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email')),
                    const SizedBox(height: AppSpacing.standard),
                    TextField(controller: _password, obscureText: true, decoration: const InputDecoration(labelText: 'Password')),
                    if (_message != null) ...[
                      const SizedBox(height: AppSpacing.standard),
                      Text(_message!, style: TextStyle(color: theme.colorScheme.primary)),
                    ],
                    const SizedBox(height: AppSpacing.large),
                    FilledButton(
                      onPressed: _loading ? null : _submit,
                      child: Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Text(_loading ? 'Please wait…' : (_register ? 'Create account' : 'Sign in'))),
                    ),
                    const SizedBox(height: AppSpacing.small),
                    TextButton(
                      onPressed: _loading ? null : () => setState(() { _register = !_register; _message = null; }),
                      child: Text(_register ? 'Already have an account? Sign in' : 'New here? Create an account'),
                    ),
                    const SizedBox(height: AppSpacing.standard),
                    Text(
                      'Created with ❤️ by Anurag Barmon',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
