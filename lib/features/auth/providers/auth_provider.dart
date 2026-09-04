import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/backend/supabase_client.dart';
import '../../../core/backend/supabase_config.dart';

final authStateProvider = StreamProvider<AuthState>((ref) {
  if (!SupabaseConfig.isConfigured) {
    return const Stream.empty();
  }
  return supabase.auth.onAuthStateChange;
});

final currentUserProvider = Provider<User?>((ref) {
  if (!SupabaseConfig.isConfigured) return null;
  final authState = ref.watch(authStateProvider);
  return authState.value?.session?.user ?? supabase.auth.currentUser;
});

class AuthController {
  Future<String?> signIn(String email, String password) async {
    try {
      await supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> signUp(String email, String password) async {
    try {
      final response = await supabase.auth.signUp(
        email: email.trim(),
        password: password,
      );
      if (response.session == null) {
        return 'Account created. Check your email to verify the account, then sign in.';
      }
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> signOut() => supabase.auth.signOut();
}

final authControllerProvider = Provider<AuthController>((ref) => AuthController());
