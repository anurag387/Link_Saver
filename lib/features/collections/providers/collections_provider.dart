import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/backend/supabase_config.dart';
import '../../../core/backend/supabase_client.dart';
import '../../../shared/models/collection_model.dart';
import '../../links/data/seed_data.dart';
import '../../links/providers/links_provider.dart';
import '../../settings/providers/settings_provider.dart';
import '../data/collection_repository.dart';

const kFallbackCollectionId = 'personal';

class CollectionsNotifier extends StateNotifier<List<LinkCollection>> {
  CollectionsNotifier(this._ref) : super(const []) {
    if (SupabaseConfig.isConfigured) {
      supabase.auth.onAuthStateChange.listen((event) {
        if (event.session == null) {
          state = const [];
        } else {
          load();
        }
      });
      load();
    } else {
      state = seedCollections;
    }
  }

  final Ref _ref;
  final _uuid = const Uuid();
  final _repository = CollectionRepository();

  Future<void> load() async {
    try {
      var result = await _repository.fetchCollections();
      if (result.isEmpty) {
        for (final collection in seedCollections) {
          await _repository.upsert(collection);
        }
        result = await _repository.fetchCollections();
      }
      state = result;
      final currentDefault = _ref.read(defaultCollectionProvider);
      if (!result.any((c) => c.id == currentDefault)) {
        _ref.read(defaultCollectionProvider.notifier).state = result.first.id;
      }
    } catch (_) {}
  }

  Future<void> addCollection(String name, {String emoji = '📁'}) async {
    final collection = LinkCollection(id: _uuid.v4(), name: name, emoji: emoji);
    state = [...state, collection];
    if (SupabaseConfig.isConfigured) await _repository.upsert(collection);
  }

  Future<void> removeCollection(String id) async {
    if (id == kFallbackCollectionId) return;
    state = state.where((c) => c.id != id).toList();
    await _ref.read(linksProvider.notifier).reassignCollection(
          fromCollectionId: id,
          toCollectionId: kFallbackCollectionId,
        );
    if (SupabaseConfig.isConfigured) await _repository.delete(id);
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
