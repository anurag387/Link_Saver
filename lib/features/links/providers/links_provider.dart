import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/backend/supabase_config.dart';
import '../../../core/backend/supabase_client.dart';
import '../../../shared/models/link_model.dart';
import '../../settings/providers/settings_provider.dart';
import '../data/link_repository.dart';
import '../data/seed_data.dart';

class LinksNotifier extends StateNotifier<List<LinkItem>> {
  LinksNotifier(this._ref) : super(const []) {
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
      state = seedLinks;
    }
  }

  final Ref _ref;
  final _uuid = const Uuid();
  final _repository = LinkRepository();

  Future<void> load() async {
    try {
      state = await _repository.fetchLinks();
    } catch (_) {
      // Keep the UI usable if the network is temporarily unavailable.
    }
  }

  Future<void> saveLink({
    required String url,
    String? title,
    required String collectionId,
    List<String> tags = const [],
    String notes = '',
  }) async {
    final autoFetch = _ref.read(autoFetchMetadataProvider);
    final domain = _extractDomain(url);
    final hasTitle = title != null && title.isNotEmpty;
    final item = LinkItem(
      id: _uuid.v4(),
      url: url,
      title: hasTitle ? title : domain,
      description: '',
      domain: domain,
      collectionId: collectionId,
      tags: tags,
      notes: notes,
      savedAt: DateTime.now(),
      metadataPending: autoFetch && !hasTitle,
    );
    state = [item, ...state];
    if (SupabaseConfig.isConfigured) await _repository.upsert(item);

    if (item.metadataPending) {
      await Future.delayed(const Duration(milliseconds: 900));
      final updated = item.copyWith(
        title: item.title == domain ? 'Untitled — $domain' : item.title,
        description: 'Fetched preview description will appear here.',
        metadataPending: false,
      );
      state = [for (final link in state) link.id == item.id ? updated : link];
      if (SupabaseConfig.isConfigured) await _repository.upsert(updated);
    }
  }

  Future<void> importLinkItem(LinkItem item) async {
    final exists = state.any((l) => l.id == item.id);
    if (!exists) {
      state = [item, ...state];
      if (SupabaseConfig.isConfigured) await _repository.upsert(item);
    }
  }

  Future<void> reassignCollection({
    required String fromCollectionId,
    required String toCollectionId,
  }) async {
    final changed = state
        .where((link) => link.collectionId == fromCollectionId)
        .map((link) => link.copyWith(collectionId: toCollectionId))
        .toList();
    state = [
      for (final link in state)
        link.collectionId == fromCollectionId ? changed.firstWhere((x) => x.id == link.id) : link,
    ];
    if (SupabaseConfig.isConfigured) {
      for (final link in changed) await _repository.upsert(link);
    }
  }

  Future<void> toggleFavorite(String id) async {
    await _update(id, (l) => l.copyWith(isFavorite: !l.isFavorite));
  }

  Future<void> toggleArchive(String id) async {
    await _update(id, (l) => l.copyWith(isArchived: !l.isArchived));
  }

  Future<void> toggleReadLater(String id) async {
    await _update(id, (l) => l.copyWith(isReadLater: !l.isReadLater));
  }

  Future<void> deleteLink(String id) async {
    state = state.where((l) => l.id != id).toList();
    if (SupabaseConfig.isConfigured) await _repository.delete(id);
  }

  Future<void> updateLink(
    String id, {
    String? title,
    String? description,
    String? notes,
    String? collectionId,
    List<String>? tags,
    bool? isFavorite,
    bool? isReadLater,
  }) async {
    await _update(id, (l) => l.copyWith(
          title: title,
          description: description,
          notes: notes,
          collectionId: collectionId,
          tags: tags,
          isFavorite: isFavorite,
          isReadLater: isReadLater,
        ));
  }

  Future<void> _update(String id, LinkItem Function(LinkItem) update) async {
    LinkItem? updated;
    state = [
      for (final link in state)
        if (link.id == id) (updated = update(link))! else link,
    ];
    if (SupabaseConfig.isConfigured && updated != null) {
      await _repository.upsert(updated!);
    }
  }

  String _extractDomain(String url) {
    try {
      final uri = Uri.parse(url.startsWith('http') ? url : 'https://$url');
      return uri.host.replaceFirst('www.', '');
    } catch (_) {
      return url;
    }
  }
}

final linksProvider = StateNotifierProvider<LinksNotifier, List<LinkItem>>((ref) => LinksNotifier(ref));

enum HomeFilter { all, recent, favorites, later }
final homeFilterProvider = StateProvider<HomeFilter>((ref) => HomeFilter.all);

final filteredLinksProvider = Provider<List<LinkItem>>((ref) {
  final links = ref.watch(linksProvider);
  final filter = ref.watch(homeFilterProvider);
  final visible = links.where((l) => !l.isArchived).toList()..sort((a, b) => b.savedAt.compareTo(a.savedAt));
  switch (filter) {
    case HomeFilter.all: return visible;
    case HomeFilter.recent: return visible.where((l) => DateTime.now().difference(l.savedAt).inDays < 3).toList();
    case HomeFilter.favorites: return visible.where((l) => l.isFavorite).toList();
    case HomeFilter.later: return visible.where((l) => l.isReadLater).toList();
  }
});

final clockTickerProvider = StreamProvider<DateTime>((ref) {
  return Stream.periodic(const Duration(seconds: 15), (_) => DateTime.now());
});

