import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/nav_index_provider.dart';
import '../../collections/providers/collections_provider.dart';
import '../../profile/presentation/profile_dialog.dart';
import '../../profile/providers/profile_provider.dart';
import '../../settings/providers/settings_provider.dart';
import '../providers/links_provider.dart';
import 'link_detail_screen.dart';
import 'save_link_sheet.dart';
import 'widgets/link_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final themeMode = ref.watch(themeModeProvider);
    final profile = ref.watch(profileProvider);
    final allLinks = ref.watch(linksProvider).where((l) => !l.isArchived).toList();
    final links = ref.watch(filteredLinksProvider);
    final filter = ref.watch(homeFilterProvider);
    final isOnline = ref.watch(isOnlineProvider);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await Future.wait<void>([
              ref.read(linksProvider.notifier).load(),
              ref.read(collectionsProvider.notifier).load(),
            ]);
            ref.read(profileProvider.notifier).loadProfileForCurrentUser();
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.large,
                    AppSpacing.standard, AppSpacing.large, 0),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Header Row with Profile & Quick Theme Switcher
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  profile.displayName.isNotEmpty
                                      ? profile.displayName
                                      : 'My Library',
                                  style: theme.textTheme.headlineSmall
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: AppSpacing.micro),
                                Text(
                                  profile.bio.isNotEmpty
                                      ? profile.bio
                                      : 'Your saved web, organized.',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant),
                                ),
                              ],
                            ),
                          ),
                          // Quick Light/Dark Mode Switcher
                          Container(
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest
                                  .withValues(alpha: 0.5),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              tooltip: 'Toggle Dark / Light theme',
                              icon: Icon(
                                themeMode == ThemeMode.dark
                                    ? Icons.dark_mode_rounded
                                    : (themeMode == ThemeMode.light
                                        ? Icons.light_mode_rounded
                                        : Icons.brightness_auto_rounded),
                                color: themeMode == ThemeMode.dark
                                    ? Colors.amber
                                    : theme.colorScheme.primary,
                              ),
                              onPressed: () {
                                final nextMode = themeMode == ThemeMode.dark
                                    ? ThemeMode.light
                                    : ThemeMode.dark;
                                ref.read(themeModeProvider.notifier).setMode(nextMode);
                              },
                            ),
                          ),
                          // Profile Avatar Button
                          InkWell(
                            borderRadius: BorderRadius.circular(24),
                            onTap: () => showProfileDialog(context),
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    theme.colorScheme.primary,
                                    theme.colorScheme.tertiary
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: theme.colorScheme.primary
                                        .withValues(alpha: 0.25),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: profile.avatarBase64 != null &&
                                        profile.avatarBase64!.isNotEmpty
                                    ? ClipOval(
                                        child: Image.memory(
                                          base64Decode(profile.avatarBase64!),
                                          width: 42,
                                          height: 42,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => const Icon(
                                              Icons.person_rounded,
                                              color: Colors.white,
                                              size: 24),
                                        ),
                                      )
                                    : const Icon(Icons.person_rounded,
                                        color: Colors.white, size: 24),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (!isOnline) ...[
                        const SizedBox(height: AppSpacing.standard),
                        _OfflineBanner(theme: theme),
                      ],
                      const SizedBox(height: AppSpacing.standard),
                      _SearchEntry(
                        theme: theme,
                        onTap: () =>
                            ref.read(navIndexProvider.notifier).state = 2,
                      ),
                      const SizedBox(height: AppSpacing.standard),
                      SizedBox(
                        height: 40,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            _FilterChip(
                              label: 'All (${allLinks.length})',
                              icon: Icons.all_inbox_rounded,
                              selected: filter == HomeFilter.all,
                              onSelected: () => ref
                                  .read(homeFilterProvider.notifier)
                                  .state = HomeFilter.all,
                            ),
                            _FilterChip(
                              label: 'Recent',
                              icon: Icons.history_rounded,
                              selected: filter == HomeFilter.recent,
                              onSelected: () => ref
                                  .read(homeFilterProvider.notifier)
                                  .state = HomeFilter.recent,
                            ),
                            _FilterChip(
                              label: 'Favorites',
                              icon: Icons.star_rounded,
                              selected: filter == HomeFilter.favorites,
                              onSelected: () => ref
                                  .read(homeFilterProvider.notifier)
                                  .state = HomeFilter.favorites,
                            ),
                            _FilterChip(
                              label: 'Later',
                              icon: Icons.schedule_rounded,
                              selected: filter == HomeFilter.later,
                              onSelected: () => ref
                                  .read(homeFilterProvider.notifier)
                                  .state = HomeFilter.later,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.standard),
                    ],
                  ),
                ),
              ),
              if (links.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyState(
                    icon: Icons.link_off_rounded,
                    title: 'Nothing saved yet',
                    message:
                        'Save interesting links and find them\nwhenever you need them.',
                    actionLabel: 'Save Your First Link',
                    onAction: () => showSaveLinkSheet(context),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.large, 0,
                      AppSpacing.large, AppSpacing.major),
                  sliver: SliverList.builder(
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
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showSaveLinkSheet(context),
        icon: const Icon(Icons.add_link_rounded),
        label: const Text('Save Link'),
      ),
    );
  }
}

class _SearchEntry extends StatelessWidget {
  final ThemeData theme;
  final VoidCallback onTap;
  const _SearchEntry({required this.theme, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.medium),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.standard, vertical: AppSpacing.compact),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(AppRadius.medium),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Row(
          children: [
            Icon(Icons.search_rounded, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: AppSpacing.small),
            Text('Search your links by title, url, tag...', style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool selected;
  final VoidCallback onSelected;

  const _FilterChip({
    required this.label,
    this.icon,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.small),
      child: ChoiceChip(
        avatar: icon != null ? Icon(icon, size: 16) : null,
        label: Text(label),
        selected: selected,
        onSelected: (_) => onSelected(),
      ),
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  final ThemeData theme;
  const _OfflineBanner({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.compact),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(AppRadius.medium),
      ),
      child: Row(
        children: [
          Icon(Icons.cloud_off_rounded, size: 18, color: theme.colorScheme.error),
          const SizedBox(width: AppSpacing.small),
          Expanded(
            child: Text(
              "You're offline — your links are still available. Changes will sync when you're connected.",
              style: theme.textTheme.labelSmall,
            ),
          ),
        ],
      ),
    );
  }
}
