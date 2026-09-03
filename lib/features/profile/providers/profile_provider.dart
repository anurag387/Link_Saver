import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/backend/supabase_client.dart';
import '../../../core/backend/supabase_config.dart';
import '../../../core/storage/local_storage_provider.dart';

class UserProfile {
  final String avatarEmoji;
  final String? avatarBase64;
  final String displayName;
  final String bio;
  final String personalNote;
  final String occupation;

  const UserProfile({
    this.avatarEmoji = '😎',
    this.avatarBase64,
    this.displayName = 'Anurag Barmon',
    this.bio = 'Curating knowledge and web links.',
    this.personalNote = '',
    this.occupation = 'Lead Software Engineer',
  });

  UserProfile copyWith({
    String? avatarEmoji,
    String? avatarBase64,
    String? displayName,
    String? bio,
    String? personalNote,
    String? occupation,
    bool clearCustomAvatar = false,
  }) {
    return UserProfile(
      avatarEmoji: avatarEmoji ?? this.avatarEmoji,
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

  ProfileNotifier(this._prefs) : super(_loadInitialProfile(_prefs)) {
    _syncFromSupabase();
  }

  static UserProfile _loadInitialProfile(SharedPreferences prefs) {
    try {
      final emoji = prefs.getString('user_avatar_emoji') ?? '😎';
      final base64Image = prefs.getString('user_avatar_base64');
      final name = prefs.getString('user_display_name') ?? 'Anurag Barmon';
      final bio = prefs.getString('user_bio') ?? 'Curating knowledge and web links.';
      final note = prefs.getString('user_personal_note') ?? '';
      final occ = prefs.getString('user_occupation') ?? 'Lead Software Engineer';

      return UserProfile(
        avatarEmoji: emoji,
        avatarBase64: base64Image,
        displayName: name,
        bio: bio,
        personalNote: note,
        occupation: occ,
      );
    } catch (_) {
      return const UserProfile();
    }
  }

  Future<void> _syncFromSupabase() async {
    if (!SupabaseConfig.isConfigured) return;
    try {
      final user = supabase.auth.currentUser;
      if (user != null && user.userMetadata != null) {
        final meta = user.userMetadata!;
        final name = meta['display_name'] as String?;
        final emoji = meta['avatar_emoji'] as String?;
        final base64Image = meta['avatar_base64'] as String?;
        final bio = meta['bio'] as String?;
        final note = meta['personal_note'] as String?;
        final occ = meta['occupation'] as String?;

        if (name != null || emoji != null || base64Image != null || bio != null || occ != null) {
          state = state.copyWith(
            displayName: name ?? state.displayName,
            avatarEmoji: emoji ?? state.avatarEmoji,
            avatarBase64: base64Image ?? state.avatarBase64,
            bio: bio ?? state.bio,
            personalNote: note ?? state.personalNote,
            occupation: occ ?? state.occupation,
          );
          if (name != null) await _prefs.setString('user_display_name', name);
          if (emoji != null) await _prefs.setString('user_avatar_emoji', emoji);
          if (base64Image != null) await _prefs.setString('user_avatar_base64', base64Image);
          if (bio != null) await _prefs.setString('user_bio', bio);
          if (note != null) await _prefs.setString('user_personal_note', note);
          if (occ != null) await _prefs.setString('user_occupation', occ);
        }
      }
    } catch (_) {}
  }

  Future<void> updateProfile({
    String? avatarEmoji,
    String? avatarBase64,
    String? displayName,
    String? bio,
    String? personalNote,
    String? occupation,
    bool clearCustomAvatar = false,
  }) async {
    state = state.copyWith(
      avatarEmoji: avatarEmoji,
      avatarBase64: avatarBase64,
      displayName: displayName,
      bio: bio,
      personalNote: personalNote,
      occupation: occupation,
      clearCustomAvatar: clearCustomAvatar,
    );

    try {
      await _prefs.setString('user_avatar_emoji', state.avatarEmoji);
      if (state.avatarBase64 != null && state.avatarBase64!.isNotEmpty) {
        await _prefs.setString('user_avatar_base64', state.avatarBase64!);
      } else {
        await _prefs.remove('user_avatar_base64');
      }
      await _prefs.setString('user_display_name', state.displayName);
      await _prefs.setString('user_bio', state.bio);
      await _prefs.setString('user_personal_note', state.personalNote);
      await _prefs.setString('user_occupation', state.occupation);

      // Cloud Database Sync: persist to Supabase Auth User Metadata
      if (SupabaseConfig.isConfigured && supabase.auth.currentUser != null) {
        await supabase.auth.updateUser(
          UserAttributes(
            data: {
              'display_name': state.displayName,
              'avatar_emoji': state.avatarEmoji,
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
    state = const UserProfile();
    try {
      await _prefs.remove('user_avatar_emoji');
      await _prefs.remove('user_avatar_base64');
      await _prefs.remove('user_display_name');
      await _prefs.remove('user_bio');
      await _prefs.remove('user_personal_note');
      await _prefs.remove('user_occupation');

      if (SupabaseConfig.isConfigured && supabase.auth.currentUser != null) {
        await supabase.auth.updateUser(
          UserAttributes(
            data: {
              'display_name': null,
              'avatar_emoji': null,
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

