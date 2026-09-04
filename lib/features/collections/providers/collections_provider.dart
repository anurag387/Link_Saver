import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/backend/supabase_config.dart';
import '../../../core/backend/supabase_client.dart';
import '../../../core/storage/local_storage_provider.dart';
import '../../../shared/models/collection_model.dart';
import '../../links/data/seed_data.dart';
import '../../links/providers/links_provider.dart';
import '../../settings/providers/settings_provider.dart';
import '../data/collection_repository.dart';

const kFallbackCollectionId = 'personal';

class CollectionsNotifier extends StateNotifier<List<LinkCollection>> {
  CollectionsNotifier(this._ref) : super(const []) {
    // 1. Immediately load local / persistent collections
    load();

    // 2. React to auth state changes
    if (SupabaseConfig.isConfigured) {
      supabase.auth.onAuthStateChange.listen((event) {
        load();
      });
    }
  }

  final Ref _ref;
  final _uuid = const Uuid();
  final _repository = CollectionRepository();

  String get _userId {
    if (SupabaseConfig.isConfigured) {
      final uid = supabase.auth.currentUser?.id;
      if (uid != null && uid.isNotEmpty) return uid;
    }
    return 'local_user';
  }

  void _saveToLocalCache(List<LinkCollection> collections) {
    try {
      final uid = _userId;
      final prefs = _ref.read(sharedPreferencesProvider);
      final list = collections.map((c) => c.toMap(uid)).toList();
      final jsonStr = jsonEncode(list);
      prefs.setString('user_${uid}_cached_collections', jsonStr);
      if (collections.isNotEmpty) {
        prefs.setString('global_collections_backup_v1', jsonStr);
      }
    } catch (_) {}
  }

  List<LinkCollection> _loadFromLocalCache() {
    try {
      final uid = _userId;
      final prefs = _ref.read(sharedPreferencesProvider);
      var raw = prefs.getString('user_${uid}_cached_collections');
      if (raw == null || raw.isEmpty || raw == '[]') {
        raw = prefs.getString('global_collections_backup_v1');
      }
      if (raw != null && raw.isNotEmpty && raw != '[]') {
        final decoded = jsonDecode(raw) as List<dynamic>;
        return [
          for (final item in decoded)
            LinkCollection.fromMap(Map<String, dynamic>.from(item as Map))
        ];
      }
    } catch (_) {}
    return const [];
  }

  Future<void> load() async {
    // 1. Immediately load local collections for instant UI
    final localCollections = _loadFromLocalCache();
    if (localCollections.isNotEmpty) {
      state = localCollections;
    }

    // 2. Fetch fresh collections from Supabase
    if (SupabaseConfig.isConfigured && supabase.auth.currentUser != null) {
      try {
        var result = await _repository.fetchCollections();
        if (result.isNotEmpty) {
          state = result;
          _saveToLocalCache(result);
        } else {
          final toSeed = state.isNotEmpty
              ? state
              : (localCollections.isNotEmpty ? localCollections : seedCollections);
          for (final collection in toSeed) {
            await _repository.upsert(collection);
          }
          state = toSeed;
          _saveToLocalCache(toSeed);
        }
      } catch (_) {}
    } else if (state.isEmpty && localCollections.isEmpty) {
      state = seedCollections;
      _saveToLocalCache(seedCollections);
    }

    final currentDefault = _ref.read(defaultCollectionProvider);
    if (state.isNotEmpty && !state.any((c) => c.id == currentDefault)) {
      _ref.read(defaultCollectionProvider.notifier).state = state.first.id;
    }
  }

  Future<void> addCollection(String name, {String emoji = 'folder'}) async {
    final collection = LinkCollection(id: _uuid.v4(), name: name, emoji: emoji);
    state = [...state, collection];
    _saveToLocalCache(state);
    if (SupabaseConfig.isConfigured) {
      try {
        await _repository.upsert(collection);
      } catch (_) {}
    }
  }

  Future<void> importCollection(LinkCollection collection) async {
    final exists = state.any((c) => c.id == collection.id);
    if (!exists) {
      state = [...state, collection];
      _saveToLocalCache(state);
      if (SupabaseConfig.isConfigured) {
        try {
          await _repository.upsert(collection);
        } catch (_) {}
      }
    }
  }

  Future<void> removeCollection(String id) async {
    if (id == kFallbackCollectionId) return;
    state = state.where((c) => c.id != id).toList();
    _saveToLocalCache(state);
    await _ref.read(linksProvider.notifier).reassignCollection(
          fromCollectionId: id,
          toCollectionId: kFallbackCollectionId,
        );
    if (SupabaseConfig.isConfigured) {
      try {
        await _repository.delete(id);
      } catch (_) {}
    }
    if (_ref.read(defaultCollectionProvider) == id) {
      _ref.read(defaultCollectionProvider.notifier).state = kFallbackCollectionId;
    }
  }
}

final collectionsProvider = StateNotifierProvider<CollectionsNotifier, List<LinkCollection>>((ref) => CollectionsNotifier(ref));

final collectionLinkCountsProvider = Provider<Map<String, int>>((ref) {
  final links = ref.watch(linksProvider);
  final counts = <String, int>{};
  for (final link in links.where((l) => !l.isArchived)) {
    counts[link.collectionId] = (counts[link.collectionId] ?? 0) + 1;
  }
  return counts;
});
