import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../shared/models/link_model.dart';
import '../../collections/providers/collections_provider.dart';
import '../providers/links_provider.dart';

Future<void> showEditLinkSheet(BuildContext context, LinkItem link) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => EditLinkSheet(link: link),
  );
}

class EditLinkSheet extends ConsumerStatefulWidget {
  final LinkItem link;
  const EditLinkSheet({super.key, required this.link});

  @override
  ConsumerState<EditLinkSheet> createState() => _EditLinkSheetState();
}

class _EditLinkSheetState extends ConsumerState<EditLinkSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _descController;
  late final TextEditingController _notesController;
  late final TextEditingController _tagController;
  late List<String> _tags;
  late String _collectionId;
  late bool _isFavorite;
  late bool _isReadLater;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.link.title);
    _descController = TextEditingController(text: widget.link.description);
    _notesController = TextEditingController(text: widget.link.notes);
    _tagController = TextEditingController();
    _tags = List<String>.from(widget.link.tags);
    _collectionId = widget.link.collectionId;
    _isFavorite = widget.link.isFavorite;
    _isReadLater = widget.link.isReadLater;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _notesController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  void _addTag() {
    final raw = _tagController.text.trim().replaceAll('#', '');
    if (raw.isNotEmpty && !_tags.contains(raw)) {
      setState(() {
        _tags.add(raw);
        _tagController.clear();
      });
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    await ref.read(linksProvider.notifier).updateLink(
      widget.link.id,
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      notes: _notesController.text.trim(),
      collectionId: _collectionId,
      tags: _tags,
      isFavorite: _isFavorite,
      isReadLater: _isReadLater,
    );
    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Link updated successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final collections = ref.watch(collectionsProvider);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.large)),
      ),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.large,
        AppSpacing.standard,
        AppSpacing.large,
        MediaQuery.of(context).viewInsets.bottom + AppSpacing.large,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.standard),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Edit Link', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const Divider(height: 20),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                prefixIcon: Icon(Icons.title_rounded),
              ),
            ),
            const SizedBox(height: AppSpacing.standard),
            TextField(
              controller: _descController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Description',
                prefixIcon: Icon(Icons.description_outlined),
              ),
            ),
            const SizedBox(height: AppSpacing.standard),
            DropdownButtonFormField<String>(
              value: collections.any((c) => c.id == _collectionId)
                  ? _collectionId
                  : (collections.isNotEmpty ? collections.first.id : null),
              decoration: const InputDecoration(
                labelText: 'Collection',
                prefixIcon: Icon(Icons.folder_outlined),
              ),
              items: collections
                  .map((c) => DropdownMenuItem(
                        value: c.id,
                        child: Text('${c.emoji} ${c.name}'),
                      ))
                  .toList(),
              onChanged: (val) {
                if (val != null) setState(() => _collectionId = val);
              },
            ),
            const SizedBox(height: AppSpacing.standard),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Personal Notes',
                hintText: 'Add personal reminders or insights...',
                prefixIcon: Icon(Icons.note_alt_outlined),
              ),
            ),
            const SizedBox(height: AppSpacing.standard),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _tagController,
                    decoration: const InputDecoration(
                      labelText: 'Add Tag',
                      hintText: 'e.g. flutter, design',
                      prefixIcon: Icon(Icons.sell_outlined),
                    ),
                    onSubmitted: (_) => _addTag(),
                  ),
                ),
                const SizedBox(width: AppSpacing.small),
                IconButton.filledTonal(
                  onPressed: _addTag,
                  icon: const Icon(Icons.add_rounded),
                ),
              ],
            ),
            if (_tags.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.small),
              Wrap(
                spacing: AppSpacing.small,
                runSpacing: AppSpacing.compact,
                children: _tags
                    .map((t) => Chip(
                          label: Text('#$t'),
                          onDeleted: () => setState(() => _tags.remove(t)),
                        ))
                    .toList(),
              ),
            ],
            const SizedBox(height: AppSpacing.standard),
            Row(
              children: [
                FilterChip(
                  label: const Text('⭐ Favorite'),
                  selected: _isFavorite,
                  onSelected: (val) => setState(() => _isFavorite = val),
                ),
                const SizedBox(width: AppSpacing.small),
                FilterChip(
                  label: const Text('⏳ Read Later'),
                  selected: _isReadLater,
                  onSelected: (val) => setState(() => _isReadLater = val),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.large),
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.check_rounded),
              label: Text(_saving ? 'Saving...' : 'Update Link'),
            ),
          ],
        ),
      ),
    );
  }
}
