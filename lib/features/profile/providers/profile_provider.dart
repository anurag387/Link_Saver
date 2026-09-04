import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/backend/supabase_client.dart';
import '../../../core/backend/supabase_config.dart';
import '../../../core/storage/local_storage_provider.dart';

class UserProfile {
  final String avatarIcon;
  final String? avatarBase64;
  final String displayName;
  final String bio;
  final String personalNote;
  final String occupation;

  const UserProfile({
    this.avatarIcon = 'person',
    this.avatarBase64,
    this.displayName = '',
    this.bio = '',
    this.personalNote = '',
    this.occupation = '',
  });

  UserProfile copyWith({
    String? avatarIcon,
    String? avatarBase64,
    String? displayName,
    String? bio,
    String? personalNote,
    String? occupation,
    bool clearCustomAvatar = false,
  }) {
    return UserProfile(
      avatarIcon: avatarIcon ?? this.avatarIcon,
      avatarBase64: clearCustomAvatar ? null : (avatarBase64 ?? this.avatarBase64),
      displayName: displayName ?? this.displayName,
      bio: bio ?? this.bio,
      personalNote: personalNote ?? this.personalNote,
      occupation: occupation ?? this.occupation,
    );
  }
}

class ProfileNotifier extends StateNotifier<UserProfile> {
  final SharedPreferences _prefs;

  ProfileNotifier(this._prefs) : super(const UserProfile()) {
    if (SupabaseConfig.isConfigured) {
      supabase.auth.onAuthStateChange.listen((event) {
        if (event.session == null) {
          state = const UserProfile();
        } else {
          loadProfileForCurrentUser();
        }
      });
      loadProfileForCurrentUser();
    }
  }

  String _keyFor(String userId, String base) => 'user_${userId}_$base';

  void loadProfileForCurrentUser() {
    final user = supabase.auth.currentUser;
    if (user == null) {
      state = const UserProfile();
      return;
    }
    final userId = user.id;
    final userEmail = user.email ?? '';
    final defaultName = userEmail.contains('@') ? userEmail.split('@')[0] : 'User';

    // 1. Read from user-specific local cache
    final icon = _prefs.getString(_keyFor(userId, 'avatar_icon')) ?? 'person';
    final base64Image = _prefs.getString(_keyFor(userId, 'avatar_base64'));
    final name = _prefs.getString(_keyFor(userId, 'display_name')) ?? defaultName;
    final bio = _prefs.getString(_keyFor(userId, 'bio')) ?? '';
    final note = _prefs.getString(_keyFor(userId, 'personal_note')) ?? '';
    final occ = _prefs.getString(_keyFor(userId, 'occupation')) ?? '';

    state = UserProfile(
      avatarIcon: icon,
      avatarBase64: base64Image,
      displayName: name,
      bio: bio,
      personalNote: note,
      occupation: occ,
    );

    // 2. Sync fresh metadata from Supabase cloud
    _syncFromSupabase();
  }

  Future<void> _syncFromSupabase() async {
    if (!SupabaseConfig.isConfigured) return;
    try {
      final user = supabase.auth.currentUser;
      if (user != null) {
        final userId = user.id;
        final meta = user.userMetadata;
        final name = meta?['display_name'] as String?;
        final icon = meta?['avatar_icon'] as String? ?? meta?['avatar_emoji'] as String?;
        final base64Image = meta?['avatar_base64'] as String?;
        final bio = meta?['bio'] as String?;
        final note = meta?['personal_note'] as String?;
        final occ = meta?['occupation'] as String?;

        final userEmail = user.email ?? '';
        final defaultName = userEmail.contains('@') ? userEmail.split('@')[0] : 'User';

        state = state.copyWith(
          displayName: name ?? (state.displayName.isNotEmpty ? state.displayName : defaultName),
          avatarIcon: icon ?? state.avatarIcon,
          avatarBase64: base64Image ?? state.avatarBase64,
          bio: bio ?? state.bio,
          personalNote: note ?? state.personalNote,
          occupation: occ ?? state.occupation,
        );

        if (state.displayName.isNotEmpty) await _prefs.setString(_keyFor(userId, 'display_name'), state.displayName);
        await _prefs.setString(_keyFor(userId, 'avatar_icon'), state.avatarIcon);
        if (state.avatarBase64 != null && state.avatarBase64!.isNotEmpty) {
          await _prefs.setString(_keyFor(userId, 'avatar_base64'), state.avatarBase64!);
        }
        if (state.bio.isNotEmpty) await _prefs.setString(_keyFor(userId, 'bio'), state.bio);
        if (state.personalNote.isNotEmpty) await _prefs.setString(_keyFor(userId, 'personal_note'), state.personalNote);
        if (state.occupation.isNotEmpty) await _prefs.setString(_keyFor(userId, 'occupation'), state.occupation);
      }
    } catch (_) {}
  }

  Future<void> updateProfile({
    String? avatarIcon,
    String? avatarBase64,
    String? displayName,
    String? bio,
    String? personalNote,
    String? occupation,
    bool clearCustomAvatar = false,
  }) async {
    final user = supabase.auth.currentUser;
    final userId = user?.id ?? 'guest';

    state = state.copyWith(
      avatarIcon: avatarIcon,
      avatarBase64: avatarBase64,
      displayName: displayName,
      bio: bio,
      personalNote: personalNote,
      occupation: occupation,
      clearCustomAvatar: clearCustomAvatar,
    );

    try {
      await _prefs.setString(_keyFor(userId, 'avatar_icon'), state.avatarIcon);
      if (state.avatarBase64 != null && state.avatarBase64!.isNotEmpty) {
        await _prefs.setString(_keyFor(userId, 'avatar_base64'), state.avatarBase64!);
      } else {
        await _prefs.remove(_keyFor(userId, 'avatar_base64'));
      }
      await _prefs.setString(_keyFor(userId, 'display_name'), state.displayName);
      await _prefs.setString(_keyFor(userId, 'bio'), state.bio);
      await _prefs.setString(_keyFor(userId, 'personal_note'), state.personalNote);
      await _prefs.setString(_keyFor(userId, 'occupation'), state.occupation);

      if (SupabaseConfig.isConfigured && user != null) {
        await supabase.auth.updateUser(
          UserAttributes(
            data: {
              'display_name': state.displayName,
              'avatar_icon': state.avatarIcon,
              'avatar_base64': state.avatarBase64,
              'bio': state.bio,
              'personal_note': state.personalNote,
              'occupation': state.occupation,
            },
          ),
        );
      }
    } catch (_) {}
  }

  Future<void> deletePersonalData() async {
    final user = supabase.auth.currentUser;
    final userId = user?.id ?? 'guest';

    state = const UserProfile();
    try {
      await _prefs.remove(_keyFor(userId, 'avatar_icon'));
      await _prefs.remove(_keyFor(userId, 'avatar_base64'));
      await _prefs.remove(_keyFor(userId, 'display_name'));
      await _prefs.remove(_keyFor(userId, 'bio'));
      await _prefs.remove(_keyFor(userId, 'personal_note'));
      await _prefs.remove(_keyFor(userId, 'occupation'));

      if (SupabaseConfig.isConfigured && user != null) {
        await supabase.auth.updateUser(
          UserAttributes(
            data: {
              'display_name': null,
              'avatar_icon': null,
              'avatar_base64': null,
              'bio': null,
              'personal_note': null,
              'occupation': null,
            },
          ),
        );
      }
    } catch (_) {}
  }
}

final profileProvider = StateNotifierProvider<ProfileNotifier, UserProfile>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ProfileNotifier(prefs);
});


