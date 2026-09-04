import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/utils/icon_helper.dart';
import '../../collections/providers/collections_provider.dart';
import '../../settings/providers/settings_provider.dart';
import '../providers/links_provider.dart';

Future<void> showSaveLinkSheet(BuildContext context, {String? prefillUrl}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => SaveLinkSheet(prefillUrl: prefillUrl),
  );
}

class SaveLinkSheet extends ConsumerStatefulWidget {
  final String? prefillUrl;
  const SaveLinkSheet({super.key, this.prefillUrl});

  @override
  ConsumerState<SaveLinkSheet> createState() => _SaveLinkSheetState();
}

class _SaveLinkSheetState extends ConsumerState<SaveLinkSheet> {
  late final TextEditingController _urlController =
      TextEditingController(text: widget.prefillUrl ?? '');
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final List<String> _tags = [];
  final TextEditingController _tagController = TextEditingController();
  late String _collectionId;
  String? _urlError;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final collections = ref.read(collectionsProvider);
    final defaultCollection = ref.read(defaultCollectionProvider);
    _collectionId = collections.any((c) => c.id == defaultCollection)
        ? defaultCollection
        : (collections.isNotEmpty
            ? collections.first.id
            : kFallbackCollectionId);
  }

  bool get _isValidUrl {
    final value = _urlController.text.trim();
    if (value.isEmpty) return false;
    final uri = Uri.tryParse(value.startsWith('http') ? value : 'https://$value');
    return uri != null && uri.host.contains('.');
  }

  @override
  void dispose() {
    _urlController.dispose();
    _titleController.dispose();
    _notesController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_isValidUrl) {
      setState(() => _urlError = 'Please enter a valid URL.');
      return;
    }

    final rawUrl = _urlController.text.trim();
    final cleanUrl = rawUrl.startsWith('http') ? rawUrl : 'https://$rawUrl';
    final existing = ref.read(linksProvider).where((l) => l.url.toLowerCase() == cleanUrl.toLowerCase()).firstOrNull;

    if (existing != null) {
      final proceed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Duplicate Link Detected'),
          content: Text('You already saved this link ("${existing.title.isNotEmpty ? existing.title : existing.domain}"). Do you want to save it again?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Save Again')),
          ],
        ),
      );
      if (proceed != true) return;
    }

    setState(() {
      _urlError = null;
      _saving = true;
    });

    unawaited(ref.read(linksProvider.notifier).saveLink(
          url: cleanUrl,
          title: _titleController.text.trim(),
          collectionId: _collectionId,
          tags: _tags,
          notes: _notesController.text.trim(),
        ));

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final collections = ref.watch(collectionsProvider);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    final selectedCollectionId = collections.any((c) => c.id == _collectionId)
        ? _collectionId
        : (collections.isNotEmpty ? collections.first.id : kFallbackCollectionId);

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppRadius.xLarge)),
        ),
        padding: const EdgeInsets.fromLTRB(AppSpacing.large, AppSpacing.small,
            AppSpacing.large, AppSpacing.large),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: AppSpacing.small),
                  decoration: BoxDecoration(
                    color: theme.dividerColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.small),
              Text('Save Link',
                  textAlign: TextAlign.center, style: theme.textTheme.titleLarge),
              const SizedBox(height: AppSpacing.large),
              Text('URL', style: theme.textTheme.bodyMedium),
              const SizedBox(height: AppSpacing.small),
              TextField(
                controller: _urlController,
                keyboardType: TextInputType.url,
                autofocus: widget.prefillUrl == null,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.link_rounded),
                  hintText: 'https://example.com',
                  errorText: _urlError,
                ),
                onChanged: (_) {
                  if (_urlError != null) setState(() => _urlError = null);
                },
              ),
              const SizedBox(height: AppSpacing.standard),
              Text('Title (optional)', style: theme.textTheme.bodyMedium),
              const SizedBox(height: AppSpacing.small),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(hintText: 'Auto-filled once fetched'),
              ),
              const SizedBox(height: AppSpacing.standard),
              Text('Collection', style: theme.textTheme.bodyMedium),
              const SizedBox(height: AppSpacing.small),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: selectedCollectionId,
                      items: collections
                          .map((c) {
                            final iconData = IconHelper.getCollectionIcon(c.emoji);
                            return DropdownMenuItem(
                              value: c.id,
                              child: Row(
                                children: [
                                  Icon(iconData, size: 18),
                                  const SizedBox(width: 8),
                                  Text(c.name),
                                ],
                              ),
                            );
                          })
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _collectionId = value ?? _collectionId),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.small),
                  IconButton.filledTonal(
                    tooltip: 'Create New Collection',
                    icon: const Icon(Icons.create_new_folder_outlined),
                    onPressed: () {
                      final nameCtrl = TextEditingController();
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('New Collection'),
                          content: TextField(
                            controller: nameCtrl,
                            autofocus: true,
                            decoration: const InputDecoration(
                              labelText: 'Collection Name',
                              hintText: 'e.g. Work, Research, Dev',
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('Cancel'),
                            ),
                            FilledButton(
                              onPressed: () async {
                                final name = nameCtrl.text.trim();
                                if (name.isNotEmpty) {
                                  await ref.read(collectionsProvider.notifier).addCollection(name);
                                  final updated = ref.read(collectionsProvider);
                                  if (updated.isNotEmpty) {
                                    setState(() {
                                      _collectionId = updated.last.id;
                                    });
                                  }
                                }
                                if (ctx.mounted) Navigator.pop(ctx);
                              },
                              child: const Text('Create'),
                            ),
                          ],
                        ),
                      ).then((_) => nameCtrl.dispose());
                    },
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.standard),
              Text('Tags', style: theme.textTheme.bodyMedium),
              const SizedBox(height: AppSpacing.small),
              Wrap(
                spacing: AppSpacing.small,
                runSpacing: AppSpacing.small,
                children: [
                  ..._tags.map((t) => Chip(
                        label: Text('#$t'),
                        onDeleted: () => setState(() => _tags.remove(t)),
                      )),
                  SizedBox(
                    width: 140,
                    child: TextField(
                      controller: _tagController,
                      decoration: const InputDecoration(
                        hintText: '+ Add tag',
                        isDense: true,
                      ),
                      onSubmitted: (value) {
                        final tag = value.trim();
                        if (tag.isNotEmpty && !_tags.contains(tag)) {
                          setState(() {
                            _tags.add(tag);
                            _tagController.clear();
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.standard),
              Text('Notes', style: theme.textTheme.bodyMedium),
              const SizedBox(height: AppSpacing.small),
              TextField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(hintText: 'Why is this useful?'),
              ),
              const SizedBox(height: AppSpacing.large),
              FilledButton(
                onPressed: _saving ? null : _save,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.standard),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.medium)),
                ),
                child: const Text('Save Link'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
