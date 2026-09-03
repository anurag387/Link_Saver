import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_spacing.dart';
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
    // Respect the "Default collection" setting instead of always defaulting
    // to Personal. Guard against the stored default pointing at a
    // collection that no longer exists.
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
    setState(() {
      _urlError = null;
      _saving = true;
    });

    // Link is stored immediately (offline-first); metadata continues
    // fetching in the background even after the sheet closes.
    unawaited(ref.read(linksProvider.notifier).saveLink(
          url: _urlController.text.trim(),
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
              DropdownButtonFormField<String>(
                value: _collectionId,
                items: collections
                    .map((c) => DropdownMenuItem(
                        value: c.id, child: Text('${c.emoji}  ${c.name}')))
                    .toList(),
                onChanged: (value) =>
                    setState(() => _collectionId = value ?? _collectionId),
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
