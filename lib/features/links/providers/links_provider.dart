import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/backend/supabase_config.dart';
import '../../../core/backend/supabase_client.dart';
import '../../../core/storage/local_storage_provider.dart';
import '../../../core/utils/metadata_helper.dart';
import '../../../shared/models/link_model.dart';
import '../../settings/providers/settings_provider.dart';
import '../data/link_repository.dart';
import '../data/seed_data.dart';

class LinksNotifier extends StateNotifier<List<LinkItem>> {
  LinksNotifier(this._ref) : super(const []) {
    // 1. Immediately load local / persistent links at startup
    load();

    // 2. React to auth state changes (sign in, sign out, token refresh)
    if (SupabaseConfig.isConfigured) {
      supabase.auth.onAuthStateChange.listen((event) {
        load();
      });
    }
  }

  final Ref _ref;
  final _uuid = const Uuid();
  final _repository = LinkRepository();

  String get _userId {
    if (SupabaseConfig.isConfigured) {
      final uid = supabase.auth.currentUser?.id;
      if (uid != null && uid.isNotEmpty) return uid;
    }
    return 'local_user';
  }

  void _saveToLocalCache(List<LinkItem> links) {
    try {
      final uid = _userId;
      final prefs = _ref.read(sharedPreferencesProvider);
      final list = links.map((l) => l.toMap(uid)).toList();
      final jsonStr = jsonEncode(list);
      prefs.setString('user_${uid}_cached_links', jsonStr);
      if (links.isNotEmpty) {
        prefs.setString('global_links_backup_v1', jsonStr);
      }
    } catch (_) {}
  }

  List<LinkItem> _loadFromLocalCache() {
    try {
      final uid = _userId;
      final prefs = _ref.read(sharedPreferencesProvider);
      var raw = prefs.getString('user_${uid}_cached_links');
      if (raw == null || raw.isEmpty || raw == '[]') {
        raw = prefs.getString('global_links_backup_v1');
      }
      if (raw != null && raw.isNotEmpty && raw != '[]') {
        final decoded = jsonDecode(raw) as List<dynamic>;
        return [
          for (final item in decoded)
            LinkItem.fromMap(Map<String, dynamic>.from(item as Map))
        ];
      }
    } catch (_) {}
    return const [];
  }

  Future<void> load() async {
    // 1. Immediately load from persistent local cache for instant 0ms UI
    final localLinks = _loadFromLocalCache();
    if (localLinks.isNotEmpty) {
      state = localLinks;
    }

    // 2. If authenticated with Supabase, fetch and sync with cloud
    if (SupabaseConfig.isConfigured && supabase.auth.currentUser != null) {
      try {
        final cloudLinks = await _repository.fetchLinks();
        if (cloudLinks.isNotEmpty) {
          state = cloudLinks;
          _saveToLocalCache(cloudLinks);
        } else if (state.isNotEmpty || localLinks.isNotEmpty) {
          // If cloud table is empty, sync existing local links to Supabase Cloud
          final toSync = state.isNotEmpty ? state : localLinks;
          for (final link in toSync) {
            await _repository.upsert(link);
          }
          _saveToLocalCache(toSync);
        }
      } catch (_) {
        // Keep using existing state or localLinks if network/cloud temporarily fails
      }
    } else if (state.isEmpty && localLinks.isEmpty) {
      state = seedLinks;
      _saveToLocalCache(seedLinks);
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
    final domain = MetadataHelper.extractDomain(url);
    final hasTitle = title != null && title.trim().isNotEmpty;
    final item = LinkItem(
      id: _uuid.v4(),
      url: url,
      title: hasTitle ? title.trim() : domain,
      description: '',
      domain: domain,
      collectionId: collectionId,
      tags: tags,
      notes: notes,
      savedAt: DateTime.now(),
      metadataPending: autoFetch && !hasTitle,
    );
    state = [item, ...state];
    _saveToLocalCache(state);

    if (SupabaseConfig.isConfigured) {
      try {
        await _repository.upsert(item);
      } catch (_) {}
    }

    if (item.metadataPending) {
      try {
        final meta = await MetadataHelper.fetchMetadata(url);
        final updated = item.copyWith(
          title: hasTitle ? title : (meta.title.isNotEmpty ? meta.title : domain),
          description: meta.description,
          domain: meta.domain,
          metadataPending: false,
        );
        state = [for (final link in state) link.id == item.id ? updated : link];
        _saveToLocalCache(state);
        if (SupabaseConfig.isConfigured) await _repository.upsert(updated);
      } catch (_) {
        final fallback = item.copyWith(metadataPending: false);
        state = [for (final link in state) link.id == item.id ? fallback : link];
        _saveToLocalCache(state);
      }
    }
  }

  Future<void> importLinkItem(LinkItem item) async {
    final exists = state.any((l) => l.id == item.id);
    if (!exists) {
      state = [item, ...state];
      _saveToLocalCache(state);
      if (SupabaseConfig.isConfigured) {
        try {
          await _repository.upsert(item);
        } catch (_) {}
      }
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
    _saveToLocalCache(state);
    if (SupabaseConfig.isConfigured) {
      for (final link in changed) {
        try {
          await _repository.upsert(link);
        } catch (_) {}
      }
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
    _saveToLocalCache(state);
    if (SupabaseConfig.isConfigured) {
      try {
        await _repository.delete(id);
      } catch (_) {}
    }
  }

  Future<void> updateLink(
    String id, {
    String? url,
    String? title,
    String? description,
    String? notes,
    String? collectionId,
    List<String>? tags,
    bool? isFavorite,
    bool? isReadLater,
  }) async {
    await _update(id, (l) {
      final newUrl = (url != null && url.trim().isNotEmpty) ? url.trim() : l.url;
      final newDomain = (url != null && url.trim().isNotEmpty) ? MetadataHelper.extractDomain(newUrl) : l.domain;
      return l.copyWith(
        url: newUrl,
        domain: newDomain,
        title: title,
        description: description,
        notes: notes,
        collectionId: collectionId,
        tags: tags,
        isFavorite: isFavorite,
        isReadLater: isReadLater,
      );
    });
  }

  Future<void> _update(String id, LinkItem Function(LinkItem) update) async {
    LinkItem? updated;
    state = [
      for (final link in state)
        if (link.id == id) (updated = update(link)) else link,
    ];
    _saveToLocalCache(state);
    if (SupabaseConfig.isConfigured && updated != null) {
      try {
        await _repository.upsert(updated);
      } catch (_) {}
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

