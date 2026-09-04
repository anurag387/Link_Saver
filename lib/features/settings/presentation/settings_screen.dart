import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/backend/supabase_config.dart';
import '../../../core/utils/icon_helper.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../shared/models/collection_model.dart';
import '../../../shared/models/link_model.dart';
import '../../collections/providers/collections_provider.dart';
import '../../links/providers/links_provider.dart';
import '../../profile/presentation/profile_dialog.dart';
import '../providers/settings_provider.dart';
import 'app_version_dialog.dart';
import 'project_overview_dialog.dart';

final appVersionProvider = Provider<String>((ref) => '1.1.0');

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appVersion = ref.watch(appVersionProvider);
    final themeMode = ref.watch(themeModeProvider);
    final autoFetch = ref.watch(autoFetchMetadataProvider);
    final openExternally = ref.watch(openLinksExternallyProvider);
    final isOnline = ref.watch(isOnlineProvider);
    final defaultCollection = ref.watch(defaultCollectionProvider);
    final collections = ref.watch(collectionsProvider);
    final links = ref.watch(linksProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings & Preferences'),
        actions: [
          IconButton(
            tooltip: 'Project Overview',
            icon: const Icon(Icons.rocket_launch_rounded),
            onPressed: () => showProjectOverviewDialog(context),
          ),
        ],
      ),
      body: ListView(
        children: [
          const _SectionHeader('Appearance & Theme'),
          RadioListTile<ThemeMode>(
            title: const Text('Light Theme'),
            secondary: const Icon(Icons.light_mode_rounded),
            value: ThemeMode.light,
            groupValue: themeMode,
            onChanged: (v) => ref.read(themeModeProvider.notifier).setMode(v!),
          ),
          RadioListTile<ThemeMode>(
            title: const Text('Dark Theme'),
            secondary: const Icon(Icons.dark_mode_rounded),
            value: ThemeMode.dark,
            groupValue: themeMode,
            onChanged: (v) => ref.read(themeModeProvider.notifier).setMode(v!),
          ),
          RadioListTile<ThemeMode>(
            title: const Text('System Default'),
            secondary: const Icon(Icons.brightness_auto_rounded),
            value: ThemeMode.system,
            groupValue: themeMode,
            onChanged: (v) => ref.read(themeModeProvider.notifier).setMode(v!),
          ),
          const Divider(),
          const _SectionHeader('Cloud Account & Sync'),
          ListTile(
            leading: const Icon(Icons.cloud_done_rounded, color: Colors.green),
            title: const Text('Account Status'),
            subtitle: Text(SupabaseConfig.isConfigured
                ? (ref.watch(currentUserProvider)?.email ?? 'Signed in to Supabase Cloud')
                : 'Cloud is not configured'),
            trailing: FilledButton.tonal(
              onPressed: () => showProfileDialog(context),
              child: const Text('Profile'),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            title: const Text('Sign out'),
            onTap: SupabaseConfig.isConfigured ? () => _signOut(context, ref) : null,
          ),
          const Divider(),
          const _SectionHeader('Data Management & Cloud Storage'),
          ListTile(
            leading: const Icon(Icons.storage_rounded, color: Colors.blue),
            title: const Text('Storage & Sync Analytics'),
            subtitle: Text('${links.length} links • ${collections.length} collections synced to cloud'),
            onTap: () => _showStorageAnalytics(context, links, collections),
            trailing: const Icon(Icons.chevron_right_rounded),
          ),
          ListTile(
            leading: const Icon(Icons.cleaning_services_rounded, color: Colors.orange),
            title: const Text('Cache Management'),
            subtitle: const Text('Clear local session cache & refresh from Supabase'),
            onTap: () => _showCacheManagement(context, ref, links.length),
            trailing: const Icon(Icons.chevron_right_rounded),
          ),
          ListTile(
            leading: const Icon(Icons.cloud_sync_rounded, color: Colors.teal),
            title: const Text('Cloud Backup & Manual Re-sync'),
            subtitle: const Text('Instant cloud synchronization across all devices'),
            onTap: () async {
              await ref.read(linksProvider.notifier).load();
              await ref.read(collectionsProvider.notifier).load();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cloud data synced successfully with Supabase!')),
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.file_download_rounded, color: Colors.indigo),
            title: const Text('Export Data (JSON / CSV)'),
            subtitle: const Text('Download or copy your complete link database'),
            onTap: () => _showExportDialog(context, links, collections),
            trailing: const Icon(Icons.chevron_right_rounded),
          ),
          ListTile(
            leading: const Icon(Icons.file_upload_rounded, color: Colors.deepPurple),
            title: const Text('Import Backup Data'),
            subtitle: const Text('Restore links and collections from JSON'),
            onTap: () => _showImportDialog(context, ref),
            trailing: const Icon(Icons.chevron_right_rounded),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.wifi_rounded),
            title: const Text('Simulate Online / Offline'),
            subtitle: const Text('Demo toggle for offline handling preview'),
            value: isOnline,
            onChanged: (v) => ref.read(isOnlineProvider.notifier).state = v,
          ),
          const Divider(),
          const _SectionHeader('Preferences'),
          ListTile(
            leading: const Icon(Icons.folder_rounded),
            title: const Text('Default collection'),
            trailing: DropdownButton<String>(
              value: collections.any((c) => c.id == defaultCollection)
                  ? defaultCollection
                  : (collections.isNotEmpty ? collections.first.id : null),
              underline: const SizedBox.shrink(),
              items: collections
                  .map((c) => DropdownMenuItem(
                      value: c.id,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(IconHelper.getCollectionIcon(c.icon), size: 18),
                          const SizedBox(width: 8),
                          Text(c.name),
                        ],
                      )))
                  .toList(),
              onChanged: (v) {
                if (v != null) {
                  ref.read(defaultCollectionProvider.notifier).setCollection(v);
                }
              },
            ),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.sync_rounded),
            title: const Text('Auto-fetch metadata'),
            subtitle: const Text('Extract website title, description & icon'),
            value: autoFetch,
            onChanged: (v) =>
                ref.read(autoFetchMetadataProvider.notifier).setAutoFetch(v),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.open_in_browser_rounded),
            title: const Text('Open links externally'),
            subtitle: const Text('Launch in system default web browser'),
            value: openExternally,
            onChanged: (v) =>
                ref.read(openLinksExternallyProvider.notifier).setOpenExternally(v),
          ),
          const Divider(),
          const _SectionHeader('System & Developer Credits'),
          ListTile(
            leading: const Icon(Icons.info_outline_rounded, color: Colors.blueAccent),
            title: const Text('App Version'),
            subtitle: Text('v$appVersion • Tap to check for update'),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(AppRadius.medium),
              ),
              child: Text('v$appVersion', style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            onTap: () => checkAppUpdate(context, ref),
          ),
          ListTile(
            leading: const Icon(Icons.military_tech_rounded, color: Colors.amber),
            title: const Text('Developer & Project Credits'),
            subtitle: const Text('Created by Anurag Barmon • Lead Engineer (GitHub: @anurag387)'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => _showDeveloperCreditDialog(context),
          ),
          ListTile(
            leading: const Icon(Icons.rocket_launch_rounded, color: Colors.purple),
            title: const Text('Project Overview & Architecture'),
            subtitle: const Text('Complete system summary, tech stack & database guide'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => showProjectOverviewDialog(context),
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Privacy Policy & Cloud Security'),
            onTap: () => showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Privacy & Cloud Security'),
                content: const Text(
                  'Link Saver isolates all data with PostgreSQL Row Level Security (RLS). Only your authenticated session can access your saved links and collections.',
                ),
                actions: [
                  FilledButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.large),
        ],
      ),
    );
  }

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text('Your cloud data is securely stored in Supabase and can be loaded again upon login.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(authControllerProvider).signOut();
    }
  }

  void _showStorageAnalytics(
      BuildContext context, List<LinkItem> links, List<LinkCollection> collections) {
    final favoritesCount = links.where((l) => l.isFavorite).length;
    final readLaterCount = links.where((l) => l.isReadLater).length;
    final archivedCount = links.where((l) => l.isArchived).length;
    final approxSizeKb = (links.length * 0.45 + collections.length * 0.15).toStringAsFixed(2);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Storage & Cloud Sync Analytics'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _statRow('Total Links Saved:', '${links.length} links'),
            _statRow('Favorites:', '$favoritesCount links'),
            _statRow('Read Later:', '$readLaterCount links'),
            _statRow('Collections:', '${collections.length} collections'),
            _statRow('Archived:', '$archivedCount links'),
            const Divider(height: 20),
            _statRow('Estimated Payload Size:', '~$approxSizeKb KB'),
            _statRow('Sync State:', 'Cloud Real-time (Supabase)'),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _statRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _showCacheManagement(BuildContext context, WidgetRef ref, int linkCount) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cache Management'),
        content: Text(
          'Currently caching $linkCount in-memory link models and Supabase JWT auth token.\n\n'
          'Clearing cache refreshes the state and pulls fresh data directly from Supabase Cloud.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton.icon(
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Clear Cache & Refresh'),
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(linksProvider.notifier).load();
              await ref.read(collectionsProvider.notifier).load();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cache cleared and fresh data loaded from Cloud!')),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  void _showExportDialog(
      BuildContext context, List<LinkItem> links, List<LinkCollection> collections) {
    final data = {
      'exportedAt': DateTime.now().toIso8601String(),
      'version': '1.1.0',
      'collections': [
        for (final c in collections) {'id': c.id, 'name': c.name, 'icon': c.icon},
      ],
      'links': [
        for (final l in links)
          {
            'id': l.id,
            'url': l.url,
            'title': l.title,
            'description': l.description,
            'domain': l.domain,
            'collectionId': l.collectionId,
            'tags': l.tags,
            'notes': l.notes,
            'isFavorite': l.isFavorite,
            'isArchived': l.isArchived,
            'isReadLater': l.isReadLater,
            'savedAt': l.savedAt.toIso8601String(),
          },
      ],
    };
    final json = const JsonEncoder.withIndent('  ').convert(data);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Complete Database'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: SelectableText(json, style: const TextStyle(fontFamily: 'monospace', fontSize: 11)),
          ),
        ),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.copy_rounded),
            label: const Text('Copy JSON'),
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: json));
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Complete database JSON copied to clipboard!')));
              }
            },
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _showImportDialog(BuildContext context, WidgetRef ref) {
    final textController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Import JSON Backup'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Paste your exported JSON database below:'),
            const SizedBox(height: AppSpacing.small),
            TextField(
              controller: textController,
              maxLines: 8,
              decoration: const InputDecoration(
                hintText: '{\n  "collections": [...],\n  "links": [...]\n}',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton.icon(
            icon: const Icon(Icons.file_upload_rounded),
            label: const Text('Import & Sync'),
            onPressed: () async {
              try {
                final raw = textController.text.trim();
                final map = jsonDecode(raw) as Map<String, dynamic>;
                
                final importedCollections = (map['collections'] as List<dynamic>? ?? []);
                for (final item in importedCollections) {
                  final colMap = Map<String, dynamic>.from(item as Map);
                  final col = LinkCollection.fromMap(colMap);
                  await ref.read(collectionsProvider.notifier).importCollection(col);
                }

                final importedLinks = (map['links'] as List<dynamic>? ?? []);
                for (final item in importedLinks) {
                  final linkMap = Map<String, dynamic>.from(item as Map);
                  final link = LinkItem.fromMap(linkMap);
                  await ref.read(linksProvider.notifier).importLinkItem(link);
                }

                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Successfully imported ${importedLinks.length} links and ${importedCollections.length} collections!',
                      ),
                    ),
                  );
                }
              } catch (e) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Import failed: Invalid JSON format ($e)')),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  void _showDeveloperCreditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.military_tech_rounded, color: Colors.amber, size: 28),
            SizedBox(width: 8),
            Text('Developer & Project Credits'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.standard),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(AppRadius.medium),
                border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
              ),
              child: const Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.black87,
                    child: Icon(Icons.code_rounded, color: Colors.white, size: 28),
                  ),
                  SizedBox(width: AppSpacing.standard),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Anurag Barmon', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                        Text('Lead Mobile & Cloud Developer', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        SizedBox(height: 2),
                        Text('GitHub: @anurag387', style: TextStyle(fontSize: 12, color: Colors.blueAccent, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.standard),
            const Text(
              '• Project: Link Saver — Cloud Sync & Digital Knowledge Base\n'
              '• Built with: Flutter 3.47, Dart, Riverpod & Supabase Cloud\n'
              '• Security: PostgreSQL Row Level Security (RLS)\n'
              '• Platform: Web, Android APK & Desktop Suite',
              style: TextStyle(fontSize: 13, height: 1.45),
            ),
            const SizedBox(height: AppSpacing.standard),
            OutlinedButton.icon(
              icon: const Icon(Icons.open_in_new_rounded, size: 18),
              label: const Text('View GitHub Profile (@anurag387)'),
              onPressed: () async {
                final uri = Uri.parse('https://github.com/anurag387');
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.large, AppSpacing.standard, AppSpacing.large, AppSpacing.small),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold),
      ),
    );
  }
}
