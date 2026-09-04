import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/utils/icon_helper.dart';
import '../../../shared/widgets/empty_state.dart';
import '../providers/collections_provider.dart';
import 'collection_detail_screen.dart';

class CollectionsScreen extends ConsumerWidget {
  const CollectionsScreen({super.key});

  int _columnsFor(double width) {
    if (AppBreakpoints.isDesktop(width)) return 5;
    if (AppBreakpoints.isTablet(width)) return 3;
    return 2;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final collections = ref.watch(collectionsProvider);
    final counts = ref.watch(collectionLinkCountsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Collections'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Add Collection',
            onPressed: () => _showCreateDialog(context, ref),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(collectionsProvider.notifier).load();
        },
        child: collections.isEmpty
            ? SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: EmptyState(
                    icon: Icons.folder_open_rounded,
                    title: 'Organize your links',
                    message: 'Create collections for your favorite topics.',
                    actionLabel: 'Create Collection',
                    onAction: () => _showCreateDialog(context, ref),
                  ),
                ),
              )
            : LayoutBuilder(
                builder: (context, constraints) {
                  final columns = _columnsFor(constraints.maxWidth);
                  return GridView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(AppSpacing.large),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      crossAxisSpacing: AppSpacing.standard,
                      mainAxisSpacing: AppSpacing.standard,
                      childAspectRatio: 1.15,
                    ),
                    itemCount: collections.length,
                    itemBuilder: (context, index) {
                      final c = collections[index];
                      final count = counts[c.id] ?? 0;
                      final iconData = IconHelper.getCollectionIcon(c.emoji);

                      return Card(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(AppRadius.large),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  CollectionDetailScreen(collectionId: c.id),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.standard),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primaryContainer.withValues(alpha: 0.6),
                                    borderRadius: BorderRadius.circular(AppRadius.medium),
                                  ),
                                  child: Icon(iconData, size: 24, color: theme.colorScheme.primary),
                                ),
                                const SizedBox(height: AppSpacing.small),
                                Text(
                                  c.name,
                                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: AppSpacing.micro),
                                Text('$count links', style: theme.textTheme.bodyMedium),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
      ),
    );
  }

  void _showCreateDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    String selectedIcon = 'folder';

    final availableIcons = [
      'folder', 'star', 'code', 'book', 'palette', 'shopping',
      'work', 'school', 'favorite', 'article', 'music', 'game'
    ];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('New Collection'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: controller,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Collection Name',
                  hintText: 'e.g. Flutter Dev, Design Inspos',
                ),
              ),
              const SizedBox(height: AppSpacing.standard),
              const Text('Choose Icon:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: AppSpacing.small),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: availableIcons.map((iconKey) {
                  final iconData = IconHelper.getCollectionIcon(iconKey);
                  final isSelected = selectedIcon == iconKey;
                  return InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => setState(() => selectedIcon = iconKey),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        iconData,
                        size: 20,
                        color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final name = controller.text.trim();
                if (name.isNotEmpty) {
                  ref.read(collectionsProvider.notifier).addCollection(
                        name,
                        emoji: selectedIcon,
                      );
                }
                Navigator.of(context).pop();
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    ).then((_) => controller.dispose());
  }
}
