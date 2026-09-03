import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../app_shell.dart';
import '../../../core/backend/supabase_config.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!SupabaseConfig.isConfigured) {
      return const _ConfigurationScreen();
    }

    final auth = ref.watch(authStateProvider);
    return auth.when(
      loading: () => const _LoadingScreen(),
      error: (error, _) => _ErrorScreen(error: error.toString()),
      data: (state) {
        final session = state.session ?? Supabase.instance.client.auth.currentSession;
        return session == null ? const LoginScreen() : const AppShell();
      },
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();
  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
}

class _ErrorScreen extends StatelessWidget {
  final String error;
  const _ErrorScreen({required this.error});
  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Authentication error:\n$error', textAlign: TextAlign.center),
          ),
        ),
      );
}

class _ConfigurationScreen extends StatelessWidget {
  const _ConfigurationScreen();
  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.cloud_off_rounded, size: 56),
                      SizedBox(height: 16),
                      Text('Cloud database is not configured', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                      SizedBox(height: 12),
                      Text('Create a Supabase project, run supabase_schema.sql, then start the app with SUPABASE_URL and SUPABASE_PUBLISHABLE_KEY.', textAlign: TextAlign.center),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}
