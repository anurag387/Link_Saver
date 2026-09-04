import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/brand_color_helper.dart';
import '../../../../shared/models/link_model.dart';
import '../../../../shared/widgets/shimmer_box.dart';
import '../../providers/links_provider.dart';
import '../edit_link_sheet.dart';

class LinkCard extends ConsumerWidget {
  final LinkItem link;
  final VoidCallback onTap;
  final VoidCallback onFavorite;
  final VoidCallback onArchive;
  final VoidCallback onDelete;
  final VoidCallback? onLongPress;
  final bool selected;

  const LinkCard({
    super.key,
    required this.link,
    required this.onTap,
    required this.onFavorite,
    required this.onArchive,
    required this.onDelete,
    this.onLongPress,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(clockTickerProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final brandInfo = BrandHelper.getBrandColor(link.domain.isNotEmpty ? link.domain : link.url);

    return Dismissible(
      key: ValueKey(link.id),
      background: _swipeBackground(
        alignment: Alignment.centerLeft,
        color: theme.colorScheme.secondary,
        icon: Icons.star_rounded,
        label: 'Favorite',
      ),
      secondaryBackground: _swipeBackground(
        alignment: Alignment.centerRight,
        color: theme.colorScheme.tertiary,
        icon: Icons.archive_rounded,
        label: 'Archive',
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          onFavorite();
        } else {
          onArchive();
        }
        return false;
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.standard),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.large),
          gradient: LinearGradient(
            colors: isDark
                ? [
                    theme.colorScheme.surface,
                    brandInfo.brandColor.withValues(alpha: 0.16),
                  ]
                : [
                    theme.colorScheme.surface,
                    brandInfo.brandColor.withValues(alpha: 0.08),
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: selected
                ? theme.colorScheme.primary
                : brandInfo.brandColor.withValues(alpha: isDark ? 0.45 : 0.35),
            width: selected ? 2 : 1.4,
          ),
          boxShadow: [
            BoxShadow(
              color: brandInfo.brandColor.withValues(alpha: isDark ? 0.14 : 0.08),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.large),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadius.large),
            onTap: onTap,
            onLongPress: onLongPress,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.standard),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Real Brand Logo / Favicon
                      BrandHelper.buildBrandLogo(
                        link.url.isNotEmpty ? link.url : link.domain,
                        size: 40,
                        fallbackEmoji: link.faviconEmoji,
                      ),
                      const SizedBox(width: AppSpacing.standard),
                      Expanded(
                        child: link.metadataPending
                            ? const ShimmerBox(height: 16)
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    link.title.isNotEmpty ? link.title : link.url,
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  // Brand Pill
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: brandInfo.brandColor.withValues(alpha: isDark ? 0.22 : 0.15),
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(
                                        color: brandInfo.brandColor.withValues(alpha: 0.3),
                                        width: 0.8,
                                      ),
                                    ),
                                    child: Text(
                                      link.domain.isNotEmpty ? link.domain : brandInfo.name,
                                      style: theme.textTheme.labelSmall?.copyWith(
                                        color: isDark
                                            ? brandInfo.brandColor.withValues(alpha: 0.95)
                                            : brandInfo.accentColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        icon: Icon(
                          link.isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
                          color: link.isFavorite
                              ? Colors.amber
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                        onPressed: onFavorite,
                      ),
                    ],
                  ),
                  if (link.description.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.small),
                    Text(
                      link.description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: AppSpacing.compact),
                  Row(
                    children: [
                      if (link.isReadLater)
                        Container(
                          margin: const EdgeInsets.only(right: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.schedule_rounded, size: 12, color: theme.colorScheme.onPrimaryContainer),
                              const SizedBox(width: 3),
                              Text(
                                'Read Later',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ],
                          ),
                        ),
                      const Spacer(),
                      Text(_relativeDate(link.savedAt), style: theme.textTheme.labelSmall),
                      const SizedBox(width: 4),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert_rounded, size: 18),
                        padding: EdgeInsets.zero,
                        onSelected: (value) {
                          if (value == 'edit') showEditLinkSheet(context, link);
                          if (value == 'archive') onArchive();
                          if (value == 'delete') onDelete();
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Text('Edit Link'),
                          ),
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
                  if (link.tags.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.compact),
                    Wrap(
                      spacing: AppSpacing.small,
                      children: link.tags
                          .map((t) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '#$t',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                    fontSize: 11,
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _swipeBackground({
    required Alignment alignment,
    required Color color,
    required IconData icon,
    required String label,
  }) {
    final isLeft = alignment == Alignment.centerLeft;
    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppRadius.large),
      ),
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.large),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: isLeft
            ? [Icon(icon, color: color), const SizedBox(width: AppSpacing.small), Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600))]
            : [Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600)), const SizedBox(width: AppSpacing.small), Icon(icon, color: color)],
      ),
    );
  }

  String _relativeDate(DateTime date) {
    final now = DateTime.now();
    var localDate = date.isUtc ? date.toLocal() : date;
    if (localDate.isAfter(now.add(const Duration(seconds: 30)))) {
      localDate = localDate.subtract(now.timeZoneOffset);
    }
    final diff = now.difference(localDate);
    if (diff.isNegative || diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1 || (diff.inHours < 48 && localDate.day != now.day)) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('d MMM yyyy').format(localDate);
  }
}
