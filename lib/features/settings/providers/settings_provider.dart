import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/storage/local_storage_provider.dart';

/// Persistent Theme Mode
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final SharedPreferences _prefs;
  ThemeModeNotifier(this._prefs) : super(_loadInitial(_prefs));

  static ThemeMode _loadInitial(SharedPreferences prefs) {
    final mode = prefs.getString('app_theme_mode');
    if (mode == 'light') return ThemeMode.light;
    if (mode == 'dark') return ThemeMode.dark;
    return ThemeMode.system;
  }

  void setMode(ThemeMode mode) {
    state = mode;
    final str = mode == ThemeMode.light ? 'light' : (mode == ThemeMode.dark ? 'dark' : 'system');
    _prefs.setString('app_theme_mode', str);
  }
}

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ThemeModeNotifier(prefs);
});

/// Persistent Default Collection
class DefaultCollectionNotifier extends StateNotifier<String> {
  final SharedPreferences _prefs;
  DefaultCollectionNotifier(this._prefs) : super(_prefs.getString('default_collection_id') ?? 'personal');

  void setCollection(String collectionId) {
    state = collectionId;
    _prefs.setString('default_collection_id', collectionId);
  }
}

final defaultCollectionProvider = StateNotifierProvider<DefaultCollectionNotifier, String>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return DefaultCollectionNotifier(prefs);
});

/// Persistent Auto Fetch Metadata
class AutoFetchMetadataNotifier extends StateNotifier<bool> {
  final SharedPreferences _prefs;
  AutoFetchMetadataNotifier(this._prefs) : super(_prefs.getBool('auto_fetch_metadata') ?? true);

  void setAutoFetch(bool value) {
    state = value;
    _prefs.setBool('auto_fetch_metadata', value);
  }
}

final autoFetchMetadataProvider = StateNotifierProvider<AutoFetchMetadataNotifier, bool>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return AutoFetchMetadataNotifier(prefs);
});

/// Persistent Open Links Externally
class OpenLinksExternallyNotifier extends StateNotifier<bool> {
  final SharedPreferences _prefs;
  OpenLinksExternallyNotifier(this._prefs) : super(_prefs.getBool('open_links_externally') ?? true);

  void setOpenExternally(bool value) {
    state = value;
    _prefs.setBool('open_links_externally', value);
  }
}

final openLinksExternallyProvider = StateNotifierProvider<OpenLinksExternallyNotifier, bool>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return OpenLinksExternallyNotifier(prefs);
});

/// In-memory simulated connectivity flag
final isOnlineProvider = StateProvider<bool>((ref) => true);
