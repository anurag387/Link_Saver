import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/utils/icon_helper.dart';
import '../../../shared/models/collection_model.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../links/presentation/link_detail_screen.dart';
import '../../links/presentation/widgets/link_card.dart';
import '../../links/providers/links_provider.dart';
import '../providers/collections_provider.dart';

/// Shows the links that belong to a single collection. Reached by tapping
/// a collection card in [CollectionsScreen] — previously that tap did
/// nothing at all.
class CollectionDetailScreen extends ConsumerWidget {
  final String collectionId;
  const CollectionDetailScreen({super.key, required this.collectionId});

  LinkCollection? _findCollection(List<LinkCollection> collections) {
    for (final c in collections) {
      if (c.id == collectionId) return c;
    }
    return null;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collections = ref.watch(collectionsProvider);
    final collection = _findCollection(collections);

    // The collection could have been deleted (e.g. from another surface)
    // while this screen was open — back out gracefully instead of crashing.
    if (collection == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Navigator.of(context).canPop()) Navigator.of(context).pop();
      });
      return const Scaffold(body: SizedBox.shrink());
    }

    final links = ref
        .watch(linksProvider)
        .where((l) => l.collectionId == collectionId && !l.isArchived)
        .toList()
      ..sort((a, b) => b.savedAt.compareTo(a.savedAt));

    final canDelete = collectionId != kFallbackCollectionId;

    final iconData = IconHelper.getCollectionIcon(collection.emoji);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(iconData, size: 20),
            const SizedBox(width: 8),
            Text(collection.name),
          ],
        ),
        actions: [
          if (canDelete)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded),
              tooltip: 'Delete collection',
              onPressed: () => _confirmDelete(context, ref, collection),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(linksProvider.notifier).load();
        },
        child: links.isEmpty
            ? SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: EmptyState(
                    icon: iconData,
                    title: 'No links yet',
                    message: 'Links you save into "${collection.name}" will show up here.',
                  ),
                ),
              )
            : ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.large),
                itemCount: links.length,
                itemBuilder: (context, index) {
                  final link = links[index];
                  return LinkCard(
                    link: link,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => LinkDetailScreen(linkId: link.id),
                      ),
                    ),
                    onFavorite: () =>
                        ref.read(linksProvider.notifier).toggleFavorite(link.id),
                    onArchive: () =>
                        ref.read(linksProvider.notifier).toggleArchive(link.id),
                    onDelete: () =>
                        ref.read(linksProvider.notifier).deleteLink(link.id),
                  );
                },
              ),
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, LinkCollection collection) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete collection?'),
        content: Text(
          'Links in "${collection.name}" will be moved to Personal instead '
          'of being deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      ref.read(collectionsProvider.notifier).removeCollection(collection.id);
      if (context.mounted) Navigator.of(context).pop();
    }
  }
}
