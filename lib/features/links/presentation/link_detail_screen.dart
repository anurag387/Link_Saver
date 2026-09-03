import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_spacing.dart';
import '../../collections/providers/collections_provider.dart';
import '../../settings/providers/settings_provider.dart';
import '../providers/links_provider.dart';
import 'edit_link_sheet.dart';

class LinkDetailScreen extends ConsumerWidget {
  final String linkId;
  const LinkDetailScreen({super.key, required this.linkId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final links = ref.watch(linksProvider);
    final collections = ref.watch(collectionsProvider);
    final link = links.where((l) => l.id == linkId).firstOrNull;

    if (link == null) {
      return const Scaffold(body: Center(child: Text('Link not found')));
    }

    final collection = collections.where((c) => c.id == link.collectionId).firstOrNull;
    final openExternally = ref.watch(openLinksExternallyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Link Details'),
        actions: [
          IconButton(
            icon: Icon(link.isFavorite ? Icons.star_rounded : Icons.star_border_rounded),
            onPressed: () =>
                ref.read(linksProvider.notifier).toggleFavorite(link.id),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') {
                showEditLinkSheet(context, link);
              } else if (value == 'archive') {
                ref.read(linksProvider.notifier).toggleArchive(link.id);
              } else if (value == 'delete') {
                ref.read(linksProvider.notifier).deleteLink(link.id);
                Navigator.of(context).pop();
              } else if (value == 'share') {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Share sheet would open here.')));
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'edit', child: Text('Edit Link')),
              PopupMenuItem(
                value: 'archive',
                child: Text(link.isArchived ? 'Unarchive' : 'Archive'),
              ),
              const PopupMenuItem(value: 'share', child: Text('Share')),
              const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.large),
        children: [
          Row(
            children: [
              Text(link.faviconEmoji ?? '🌐', style: const TextStyle(fontSize: 22)),
              const SizedBox(width: AppSpacing.small),
              Expanded(
                child: Text(link.domain,
                    style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.standard),
          Text(link.title, style: theme.textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.small),
          if (link.description.isNotEmpty)
            Text(link.description, style: theme.textTheme.bodyLarge),
          const SizedBox(height: AppSpacing.large),
          Divider(color: theme.dividerColor),
          const SizedBox(height: AppSpacing.large),
          _DetailRow(
            icon: Icons.folder_rounded,
            text: collection != null
                ? '${collection.emoji} ${collection.name}'
                : 'Uncategorized',
          ),
          const SizedBox(height: AppSpacing.compact),
          _DetailRow(
            icon: Icons.sell_rounded,
            text: link.tags.isEmpty ? 'No tags' : link.tags.join(', '),
          ),
          const SizedBox(height: AppSpacing.compact),
          _DetailRow(
            icon: Icons.calendar_today_rounded,
            text: 'Saved ${DateFormat.yMMMd().format(link.savedAt)}',
          ),
          if (link.notes.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.large),
            Divider(color: theme.dividerColor),
            const SizedBox(height: AppSpacing.large),
            Text('Notes', style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.small),
            Text('"${link.notes}"', style: theme.textTheme.bodyMedium),
          ],
          const SizedBox(height: AppSpacing.section),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _openLink(context, link.url, openExternally),
                  icon: const Icon(Icons.open_in_new_rounded),
                  label: const Text('Open Link'),
                ),
              ),
              const SizedBox(width: AppSpacing.standard),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => showEditLinkSheet(context, link),
                  icon: const Icon(Icons.edit_rounded),
                  label: const Text('Edit'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _openLink(
      BuildContext context, String url, bool openExternally) async {
    final uri = Uri.tryParse(url.startsWith('http') ? url : 'https://$url');
    if (uri == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("That link doesn't look valid.")));
      return;
    }

    final launched = await launchUrl(
      uri,
      mode: openExternally
          ? LaunchMode.externalApplication
          : LaunchMode.inAppBrowserView,
    );

    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open $url')));
    }
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _DetailRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: AppSpacing.small),
        Expanded(child: Text(text, style: theme.textTheme.bodyMedium)),
      ],
    );
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
