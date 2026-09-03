import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/app_spacing.dart';
import 'features/collections/presentation/collections_screen.dart';
import 'features/links/presentation/home_screen.dart';
import 'features/links/presentation/save_link_sheet.dart';
import 'features/search/presentation/search_screen.dart';
import 'features/settings/presentation/settings_screen.dart';
import 'shared/widgets/nav_index_provider.dart';

const _destinations = [
  _Destination('Home', Icons.home_rounded, Icons.home_outlined),
  _Destination('Collections', Icons.folder_rounded, Icons.folder_outlined),
  _Destination('Search', Icons.search_rounded, Icons.search_outlined),
  _Destination('Settings', Icons.settings_rounded, Icons.settings_outlined),
];

const _screens = [
  HomeScreen(),
  CollectionsScreen(),
  SearchScreen(),
  SettingsScreen(),
];

class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(navIndexProvider);
    final width = MediaQuery.of(context).size.width;

    if (AppBreakpoints.isMobile(width)) {
      return _MobileShell(index: index);
    } else if (AppBreakpoints.isTablet(width)) {
      return _TabletShell(index: index);
    }
    return _DesktopShell(index: index);
  }
}

class _MobileShell extends ConsumerWidget {
  final int index;
  const _MobileShell({required this.index});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: IndexedStack(index: index, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) =>
            ref.read(navIndexProvider.notifier).state = i,
        destinations: [
          for (final d in _destinations)
            NavigationDestination(
              icon: Icon(d.outlineIcon),
              selectedIcon: Icon(d.filledIcon),
              label: d.label,
            ),
        ],
      ),
    );
  }
}

class _TabletShell extends ConsumerWidget {
  final int index;
  const _TabletShell({required this.index});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: index,
            onDestinationSelected: (i) =>
                ref.read(navIndexProvider.notifier).state = i,
            labelType: NavigationRailLabelType.all,
            leading: const SizedBox(height: AppSpacing.standard),
            trailing: Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.large),
                  child: FloatingActionButton(
                    heroTag: 'tablet-fab',
                    onPressed: () => showSaveLinkSheet(context),
                    child: const Icon(Icons.add_link_rounded),
                  ),
                ),
              ),
            ),
            destinations: [
              for (final d in _destinations)
                NavigationRailDestination(
                  icon: Icon(d.outlineIcon),
                  selectedIcon: Icon(d.filledIcon),
                  label: Text(d.label),
                ),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(child: IndexedStack(index: index, children: _screens)),
        ],
      ),
    );
  }
}

class _DesktopShell extends ConsumerWidget {
  final int index;
  const _DesktopShell({required this.index});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Row(
        children: [
          SizedBox(
            width: 240,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacing.large),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.large),
                  child: Row(
                    children: [
                      Text('🔗', style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(width: AppSpacing.small),
                      Text('Link Saver',
                          style: Theme.of(context).textTheme.titleLarge),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.section),
                for (var i = 0; i < _destinations.length; i++)
                  ListTile(
                    leading: Icon(i == index
                        ? _destinations[i].filledIcon
                        : _destinations[i].outlineIcon),
                    title: Text(_destinations[i].label),
                    selected: i == index,
                    selectedTileColor:
                        Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.medium)),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.large),
                    onTap: () => ref.read(navIndexProvider.notifier).state = i,
                  ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.large),
                  child: FilledButton.icon(
                    onPressed: () => showSaveLinkSheet(context),
                    icon: const Icon(Icons.add_link_rounded),
                    label: const Text('Save Link'),
                  ),
                ),
              ],
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            flex: 2,
            child: IndexedStack(index: index, children: _screens),
          ),
        ],
      ),
    );
  }
}

class _Destination {
  final String label;
  final IconData filledIcon;
  final IconData outlineIcon;
  const _Destination(this.label, this.filledIcon, this.outlineIcon);
}
