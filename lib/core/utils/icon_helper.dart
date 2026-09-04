import 'package:flutter/material.dart';

class IconHelper {
  IconHelper._();

  static const Map<String, IconData> collectionIcons = {
    'folder': Icons.folder_rounded,
    'star': Icons.star_rounded,
    'code': Icons.code_rounded,
    'book': Icons.menu_book_rounded,
    'palette': Icons.palette_rounded,
    'shopping': Icons.shopping_bag_rounded,
    'work': Icons.work_rounded,
    'school': Icons.school_rounded,
    'favorite': Icons.favorite_rounded,
    'bookmark': Icons.bookmark_rounded,
    'article': Icons.article_rounded,
    'music': Icons.music_note_rounded,
    'movie': Icons.movie_rounded,
    'game': Icons.sports_esports_rounded,
    'science': Icons.science_rounded,
    'travel': Icons.flight_rounded,
  };

  static IconData getCollectionIcon(String? iconName) {
    if (iconName == null || iconName.isEmpty) {
      return Icons.folder_rounded;
    }
    // Backward compatibility for emoji or old names
    if (iconName == '⭐' || iconName == 'star') return Icons.star_rounded;
    if (iconName == '💻' || iconName == 'code' || iconName == 'development') {
      return Icons.code_rounded;
    }
    if (iconName == '📚' || iconName == 'book' || iconName == 'learning') {
      return Icons.menu_book_rounded;
    }
    if (iconName == '🎨' || iconName == 'palette' || iconName == 'design') {
      return Icons.palette_rounded;
    }
    if (iconName == '🛒' || iconName == 'shopping') {
      return Icons.shopping_bag_rounded;
    }
    if (iconName == '📁' || iconName == 'folder' || iconName == 'personal') {
      return Icons.folder_rounded;
    }

    return collectionIcons[iconName] ?? Icons.folder_rounded;
  }
}
