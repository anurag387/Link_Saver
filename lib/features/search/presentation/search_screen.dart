import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/utils/icon_helper.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../collections/providers/collections_provider.dart';
import '../../links/presentation/link_detail_screen.dart';
import '../../links/presentation/widgets/link_card.dart';
import '../../links/providers/links_provider.dart';
import '../providers/search_provider.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      ref.read(searchQueryProvider.notifier).state = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final results = ref.watch(searchResultsProvider);
    final collections = ref.watch(collectionsProvider);
    final collectionFilter = ref.watch(searchCollectionFilterProvider);
    final favoritesOnly = ref.watch(searchFavoritesOnlyProvider);
    final sort = ref.watch(sortOptionProvider);
    final query = ref.watch(searchQueryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.large,
                AppSpacing.small, AppSpacing.large, AppSpacing.small),
            child: TextField(
              controller: _controller,
              onChanged: _onChanged,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search_rounded),
                hintText: 'Search links, tags, notes...',
                suffixIcon: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _controller,
                  builder: (context, value, _) {
                    if (value.text.isEmpty) return const SizedBox.shrink();
                    return IconButton(
                      icon: const Icon(Icons.clear_rounded),
                      onPressed: () {
                        _debounce?.cancel();
                        _controller.clear();
                        ref.read(searchQueryProvider.notifier).state = '';
                      },
                    );
                  },
                ),
              ),
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.large),
              children: [
                FilterChip(
                  avatar: const Icon(Icons.star_rounded, size: 16),
                  label: const Text('Favorites'),
                  selected: favoritesOnly,
                  onSelected: (v) =>
                      ref.read(searchFavoritesOnlyProvider.notifier).state = v,
                ),
                const SizedBox(width: AppSpacing.small),
                ...collections.map((c) {
                  final iconData = IconHelper.getCollectionIcon(c.emoji);
                  return Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.small),
                    child: FilterChip(
                      avatar: Icon(iconData, size: 16),
                      label: Text(c.name),
                      selected: collectionFilter == c.id,
                      onSelected: (selected) => ref
                          .read(searchCollectionFilterProvider.notifier)
                          .state = selected ? c.id : null,
                    ),
                  );
                }),
                const SizedBox(width: AppSpacing.small),
                DropdownButtonHideUnderline(
                  child: DropdownButton<SortOption>(
                    value: sort,
                    icon: const Icon(Icons.sort_rounded, size: 18),
                    items: const [
                      DropdownMenuItem(
                          value: SortOption.recent, child: Text('Recently saved')),
                      DropdownMenuItem(value: SortOption.oldest, child: Text('Oldest')),
                      DropdownMenuItem(
                          value: SortOption.alphabetical,
                          child: Text('Alphabetical')),
                      DropdownMenuItem(
                          value: SortOption.favorites, child: Text('Favorites')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        ref.read(sortOptionProvider.notifier).state = value;
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.small),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await ref.read(linksProvider.notifier).load();
              },
              child: results.isEmpty
                  ? SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.6,
                        child: EmptyState(
                          icon: Icons.search_rounded,
                          title: query.isEmpty ? 'Search your links' : 'No links found',
                          message: query.isEmpty
                              ? 'Try a title, tag, domain, or note.'
                              : 'Try another keyword or remove filters.',
                        ),
                      ),
                    )
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(AppSpacing.large, 0,
                          AppSpacing.large, AppSpacing.large),
                      itemCount: results.length,
                      itemBuilder: (context, index) {
                        final link = results[index];
                        return LinkCard(
                          link: link,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => LinkDetailScreen(linkId: link.id),
                            ),
                          ),
                          onFavorite: () => ref
                              .read(linksProvider.notifier)
                              .toggleFavorite(link.id),
                          onArchive: () => ref
                              .read(linksProvider.notifier)
                              .toggleArchive(link.id),
                          onDelete: () =>
                              ref.read(linksProvider.notifier).deleteLink(link.id),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
