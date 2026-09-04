import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_spacing.dart';
import 'settings_screen.dart';

// Latest available remote version (can be configured or fetched from cloud/GitHub)
const String kLatestAppVersion = '1.1.0'; 
const String kAppDownloadUrl = 'https://github.com/anurag387/Link_Saver_Cloud_Sync/releases';

Future<void> checkAppUpdate(BuildContext context, WidgetRef ref, {bool showIfUpToDate = true}) async {
  final currentVersion = ref.read(appVersionProvider);

  // Show quick check loading dialog if requested
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => const Center(
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.large),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: AppSpacing.standard),
              Text('Checking for updates...', style: TextStyle(fontSize: 14)),
            ],
          ),
        ),
      ),
    ),
  );

  await Future.delayed(const Duration(milliseconds: 700));

  if (!context.mounted) return;
  Navigator.of(context, rootNavigator: true).pop(); // Close loading

  final hasUpdate = _isNewerVersion(currentVersion, kLatestAppVersion);

  if (hasUpdate) {
    _showUpdateAvailableDialog(context, currentVersion, kLatestAppVersion);
  } else if (showIfUpToDate) {
    _showUpToDateDialog(context, currentVersion);
  }
}

bool _isNewerVersion(String current, String latest) {
  try {
    final currentClean = current.split('+')[0];
    final latestClean = latest.split('+')[0];
    final currParts = currentClean.split('.').map(int.parse).toList();
    final latestParts = latestClean.split('.').map(int.parse).toList();

    for (var i = 0; i < 3; i++) {
      final c = i < currParts.length ? currParts[i] : 0;
      final l = i < latestParts.length ? latestParts[i] : 0;
      if (l > c) return true;
      if (l < c) return false;
    }

    // Check build number if main version is same
    final currBuild = current.contains('+') ? int.tryParse(current.split('+')[1]) ?? 0 : 0;
    final latestBuild = latest.contains('+') ? int.tryParse(latest.split('+')[1]) ?? 0 : 0;
    return latestBuild > currBuild;
  } catch (_) {
    return false;
  }
}

void _showUpToDateDialog(BuildContext context, String currentVersion) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.check_circle_outline_rounded, color: Colors.green, size: 24),
          SizedBox(width: 8),
          Text('App Version'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Current Version: v$currentVersion',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          const Text(
            'Your app is up to date! You already have the latest features and bug fixes.',
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
        ],
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}

void _showUpdateAvailableDialog(BuildContext context, String currentVersion, String newVersion) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.system_update_rounded, color: Colors.blueAccent, size: 24),
          SizedBox(width: 8),
          Text('New Update Available!'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Current Version: v$currentVersion',
              style: const TextStyle(fontSize: 13, color: Colors.grey)),
          const SizedBox(height: 4),
          Text('New Version: v$newVersion',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blueAccent)),
          const SizedBox(height: 12),
          const Text(
            'A new version of Link Saver is available with improvements and fixes. Please update to continue enjoying the best experience.',
            style: TextStyle(fontSize: 13),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Later'),
        ),
        FilledButton.icon(
          icon: const Icon(Icons.download_rounded, size: 18),
          label: const Text('Update Now'),
          onPressed: () async {
            Navigator.pop(ctx);
            final uri = Uri.parse(kAppDownloadUrl);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            }
          },
        ),
      ],
    ),
  );
}
