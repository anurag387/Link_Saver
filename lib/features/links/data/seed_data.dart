import '../../../shared/models/collection_model.dart';
import '../../../shared/models/link_model.dart';

final List<LinkCollection> seedCollections = [
  const LinkCollection(id: 'personal', name: 'Personal', emoji: '⭐'),
  const LinkCollection(id: 'development', name: 'Development', emoji: '💻'),
  const LinkCollection(id: 'learning', name: 'Learning', emoji: '📚'),
  const LinkCollection(id: 'design', name: 'Design', emoji: '🎨'),
  const LinkCollection(id: 'shopping', name: 'Shopping', emoji: '🛒'),
];

final List<LinkItem> seedLinks = [
  LinkItem(
    id: '1',
    url: 'https://flutter.dev',
    title: 'Flutter Documentation',
    description:
        'Build beautiful, natively compiled applications for mobile, web, and desktop from a single codebase.',
    domain: 'flutter.dev',
    collectionId: 'development',
    tags: const ['flutter', 'development'],
    notes: 'Useful documentation for Flutter.',
    isFavorite: true,
    savedAt: DateTime.now().subtract(const Duration(hours: 2)),
  ),
  LinkItem(
    id: '2',
    url: 'https://material.io',
    title: 'Material Design',
    description: 'Design systems and components for building great products.',
    domain: 'material.io',
    collectionId: 'design',
    tags: const ['design', 'material3'],
    savedAt: DateTime.now().subtract(const Duration(hours: 5)),
  ),
  LinkItem(
    id: '3',
    url: 'https://riverpod.dev',
    title: 'Riverpod — State Management',
    description:
        'A reactive caching and data-binding framework for Flutter and Dart apps.',
    domain: 'riverpod.dev',
    collectionId: 'development',
    tags: const ['flutter', 'state-management'],
    isReadLater: true,
    savedAt: DateTime.now().subtract(const Duration(days: 1)),
  ),
  LinkItem(
    id: '4',
    url: 'https://dart.dev',
    title: 'Dart Language Tour',
    description: 'A tour of all the major Dart language features.',
    domain: 'dart.dev',
    collectionId: 'learning',
    tags: const ['dart', 'basics'],
    savedAt: DateTime.now().subtract(const Duration(days: 2)),
  ),
  LinkItem(
    id: '5',
    url: 'https://example-shop.com/desk-lamp',
    title: 'Minimalist Desk Lamp',
    description: 'A soft-light desk lamp with adjustable warmth.',
    domain: 'example-shop.com',
    collectionId: 'shopping',
    tags: const ['home'],
    isArchived: true,
    savedAt: DateTime.now().subtract(const Duration(days: 6)),
  ),
];
