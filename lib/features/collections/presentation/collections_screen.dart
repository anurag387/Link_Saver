import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_spacing.dart';
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
            onPressed: () => _showCreateDialog(context, ref),
          ),
        ],
      ),
      body: collections.isEmpty
          ? EmptyState(
              emoji: '📁',
              title: 'Organize your links',
              message: 'Create collections for your favorite topics.',
              actionLabel: 'Create Collection',
              onAction: () => _showCreateDialog(context, ref),
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                final columns = _columnsFor(constraints.maxWidth);
                return GridView.builder(
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
                              Text(c.emoji, style: const TextStyle(fontSize: 28)),
                              const SizedBox(height: AppSpacing.small),
                              Text(c.name, style: theme.textTheme.titleMedium),
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
    );
  }

  void _showCreateDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Collection'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Collection name'),
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
                ref.read(collectionsProvider.notifier).addCollection(name);
              }
              Navigator.of(context).pop();
            },
            child: const Text('Create'),
          ),
        ],
      ),
      // The dialog's Future completes once it's dismissed either way
      // (Cancel or Create both call Navigator.pop above), so this is a
      // safe place to dispose the controller and avoid leaking it.
    ).then((_) => controller.dispose());
  }
}
