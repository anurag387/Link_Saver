import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/brand_color_helper.dart';
import '../../../core/utils/icon_helper.dart';
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

    final collection =
        collections.where((c) => c.id == link.collectionId).firstOrNull;
    final collectionIcon = collection != null
        ? IconHelper.getCollectionIcon(collection.emoji)
        : Icons.folder_rounded;
    final openExternally = ref.watch(openLinksExternallyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Link Details'),
        actions: [
          IconButton(
            tooltip: 'Copy Link',
            icon: const Icon(Icons.copy_rounded),
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: link.url));
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Link copied to clipboard!')),
                );
              }
            },
          ),
          IconButton(
            tooltip: 'Show QR Code',
            icon: const Icon(Icons.qr_code_2_rounded),
            onPressed: () => _showQrCodeDialog(context, link.url, link.title),
          ),
          IconButton(
            tooltip: 'Share',
            icon: const Icon(Icons.share_rounded),
            onPressed: () => _shareLink(link.url, link.title),
          ),
          IconButton(
            icon: Icon(
                link.isFavorite ? Icons.star_rounded : Icons.star_border_rounded),
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
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'edit', child: Text('Edit Link')),
              PopupMenuItem(
                value: 'archive',
                child: Text(link.isArchived ? 'Unarchive' : 'Archive'),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.large),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              BrandHelper.buildBrandLogo(
                link.url.isNotEmpty ? link.url : link.domain,
                size: 44,
                fallbackEmoji: link.faviconEmoji,
              ),
              const SizedBox(width: AppSpacing.standard),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      link.domain,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      link.url,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.large),
          Text(link.title, style: theme.textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.small),
          if (link.description.isNotEmpty)
            Text(link.description, style: theme.textTheme.bodyLarge),
          const SizedBox(height: AppSpacing.large),
          Divider(color: theme.dividerColor),
          const SizedBox(height: AppSpacing.large),
          _DetailRow(
            icon: collectionIcon,
            text: collection != null ? collection.name : 'Personal',
          ),
          const SizedBox(height: AppSpacing.compact),
          _DetailRow(
            icon: Icons.sell_rounded,
            text: link.tags.isEmpty ? 'No tags' : link.tags.map((t) => '#$t').join('  '),
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

  void _shareLink(String url, String title) {
    Share.share(
      title.isNotEmpty ? '$title - $url' : url,
      subject: title.isNotEmpty ? title : 'Shared Link',
    );
  }

  void _showQrCodeDialog(BuildContext context, String url, String title) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.qr_code_2_rounded, size: 24),
            SizedBox(width: 8),
            Text('Link QR Code'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: SizedBox(
                width: 200,
                height: 200,
                child: QrImageView(
                  data: url.isNotEmpty ? url : 'https://example.com',
                  version: QrVersions.auto,
                  size: 200.0,
                  backgroundColor: Colors.white,
                  gapless: false,
                  errorStateBuilder: (cxt, err) {
                    return const Center(
                      child: Text(
                        'QR code error',
                        textAlign: TextAlign.center,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              url,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  Future<void> _openLink(
      BuildContext context, String url, bool openExternally) async {
    final uri = Uri.tryParse(url.startsWith('http') ? url : 'https://$url');
    if (uri == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("That link doesn't look valid.")));
      return;
    }

    final launched = await launchUrl(
      uri,
      mode: openExternally
          ? LaunchMode.externalApplication
          : LaunchMode.inAppBrowserView,
    );

    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Could not open $url')));
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
