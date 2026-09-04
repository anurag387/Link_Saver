import 'package:flutter/material.dart';
import '../../../core/constants/app_spacing.dart';

void showProjectOverviewDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => const ProjectOverviewDialog(),
  );
}

class ProjectOverviewDialog extends StatelessWidget {
  const ProjectOverviewDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.large)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680, maxHeight: 720),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.large),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(AppRadius.medium),
                        ),
                        child: Icon(Icons.rocket_launch_rounded, color: theme.colorScheme.primary),
                      ),
                      const SizedBox(width: AppSpacing.small),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Project Overview & Architecture',
                              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                          Text('Link Saver — Cloud Sync & Knowledge Base',
                              style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(height: 24),
              Expanded(
                child: ListView(
                  children: [
                    _buildCard(
                      theme: theme,
                      title: 'Lead Developer & Project Creator',
                      icon: Icons.person_pin_rounded,
                      color: Colors.amber,
                      content: '• Creator: Anurag Barmon\n'
                          '• GitHub: https://github.com/anurag387 (@anurag387)\n'
                          '• Role: Lead Mobile & Cloud Software Engineer\n'
                          '• Project: Link Saver Cloud Sync Suite (Flutter + Supabase)',
                    ),
                    const SizedBox(height: AppSpacing.standard),
                    _buildCard(
                      theme: theme,
                      title: 'Project Summary & Capabilities',
                      icon: Icons.auto_awesome_rounded,
                      color: Colors.teal,
                      content: 'Link Saver is a full-featured, cross-platform bookmarking and digital curation suite built with Flutter and Supabase. It enables users to instantly save web links, organize them into collections, search with live filters, and access all data seamlessly across devices.',
                    ),
                    const SizedBox(height: AppSpacing.standard),
                    _buildCard(
                      theme: theme,
                      title: 'Tech Stack & Architecture',
                      icon: Icons.layers_rounded,
                      color: Colors.blue,
                      content: '• Framework: Flutter 3.47+ (Dart 3.13)\n'
                          '• State Management: Riverpod 2.6 (Reactive StateNotifier Providers)\n'
                          '• Backend & Auth: Supabase Flutter SDK 2.17 (PostgreSQL Cloud Database)\n'
                          '• Security: Row Level Security (RLS) isolating each user\'s links & collections\n'
                          '• Favicon Engine: High-resolution Google & DuckDuckGo Favicon API\n'
                          '• Responsive Engine: Adaptive layouts for Mobile, Tablet & Desktop / Web.',
                    ),
                    const SizedBox(height: AppSpacing.standard),
                    _buildCard(
                      theme: theme,
                      title: 'Database Tables & Schema',
                      icon: Icons.table_chart_rounded,
                      color: Colors.teal,
                      content: '1. public.collections (id, user_id, name, icon, created_at)\n'
                          '2. public.links (id, user_id, url, title, description, domain, favicon_emoji, collection_id, tags, notes, is_favorite, is_archived, is_read_later, saved_at, metadata_pending)\n\n'
                          'Security: 4 RLS policies (SELECT, INSERT, UPDATE, DELETE) per table bound to auth.uid().',
                    ),
                    const SizedBox(height: AppSpacing.standard),
                    _buildCard(
                      theme: theme,
                      title: 'App Versioning & How to Upgrade',
                      icon: Icons.system_update_alt_rounded,
                      color: Colors.deepOrange,
                      content: 'Version format: MAJOR.MINOR.PATCH+BUILD_NUMBER (e.g., 1.1.0+3)\n\n'
                          '• pubspec.yaml ফাইলে version: 1.1.0+3 এডিট করে ভার্সন বাড়ানো হয়:\n'
                          '  - Major (1.x.x): বড় ধরনের নতুন ফিচার বা আর্কিটেকচার পরিবর্তনের জন্য।\n'
                          '  - Minor (x.1.x): নতুন ফিচার বা স্ক্রিন যোগ করলে।\n'
                          '  - Patch (x.x.1): বাগ ফিক্স বা ছোটখাটো উন্নতির জন্য।\n'
                          '  - Build Number (+3): প্লে স্টোর/অ্যাপ স্টোরে রিলিজ দেওয়ার প্রতিবার ১ করে বৃদ্ধি করতে হয়।',
                    ),
                    const SizedBox(height: AppSpacing.standard),
                    _buildCard(
                      theme: theme,
                      title: 'Multi-Platform Deployment',
                      icon: Icons.devices_rounded,
                      color: Colors.purple,
                      content: '• Web Build: flutter run -d chrome (ব্রাউজারে রিয়েল-টাইম ক্লাউড অ্যাপ)\n'
                          '• Android APK: build_apk.bat (ফোনে সরাসরি ইন্সটলযোগ্য রিলিজ APK)\n'
                          '• Windows Desktop: flutter run -d windows (Visual Studio C++ বিল্ডের মাধ্যমে)',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.standard),
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close Overview'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard({
    required ThemeData theme,
    required String title,
    required IconData icon,
    required Color color,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.standard),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: AppSpacing.small),
              Expanded(
                child: Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.small),
          Text(content, style: theme.textTheme.bodyMedium?.copyWith(height: 1.45)),
        ],
      ),
    );
  }
}
