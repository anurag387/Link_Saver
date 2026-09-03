import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/link_model.dart';
import '../../links/providers/links_provider.dart';

enum SortOption { recent, oldest, alphabetical, favorites }

final searchQueryProvider = StateProvider<String>((ref) => '');
final searchCollectionFilterProvider = StateProvider<String?>((ref) => null);
final searchFavoritesOnlyProvider = StateProvider<bool>((ref) => false);
final sortOptionProvider = StateProvider<SortOption>((ref) => SortOption.recent);

/// Debounced-in-UI search query, filtered by collection/favorites and sorted.
/// (Debouncing itself happens in the search field's controller — see
/// SearchScreen — so this provider can stay a simple synchronous derivation.)
final searchResultsProvider = Provider<List<LinkItem>>((ref) {
  final links = ref.watch(linksProvider);
  final query = ref.watch(searchQueryProvider).trim().toLowerCase();
  final collectionFilter = ref.watch(searchCollectionFilterProvider);
  final favoritesOnly = ref.watch(searchFavoritesOnlyProvider);
  final sort = ref.watch(sortOptionProvider);

  // Nothing searched or filtered yet — stay in the "prompt" state instead
  // of dumping every saved link here (that's what Home is for). This also
  // makes the "Search your links" empty-state copy actually reachable.
  if (query.isEmpty && collectionFilter == null && !favoritesOnly) {
    return const [];
  }

  var results = links.where((l) => !l.isArchived).toList();

  if (query.isNotEmpty) {
    results = results.where((l) {
      return l.title.toLowerCase().contains(query) ||
          l.url.toLowerCase().contains(query) ||
          l.domain.toLowerCase().contains(query) ||
          l.notes.toLowerCase().contains(query) ||
          l.tags.any((t) => t.toLowerCase().contains(query));
    }).toList();
  }

  if (collectionFilter != null) {
    results = results.where((l) => l.collectionId == collectionFilter).toList();
  }

  if (favoritesOnly) {
    results = results.where((l) => l.isFavorite).toList();
  }

  switch (sort) {
    case SortOption.recent:
      results.sort((a, b) => b.savedAt.compareTo(a.savedAt));
      break;
    case SortOption.oldest:
      results.sort((a, b) => a.savedAt.compareTo(b.savedAt));
      break;
    case SortOption.alphabetical:
      results.sort(
          (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
      break;
    case SortOption.favorites:
      results.sort((a, b) => (b.isFavorite ? 1 : 0) - (a.isFavorite ? 1 : 0));
      break;
  }

  return results;
});
