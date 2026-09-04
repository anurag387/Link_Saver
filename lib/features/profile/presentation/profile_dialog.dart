import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_spacing.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/profile_provider.dart';

void showProfileDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => const ProfileDialog(),
  );
}

class ProfileDialog extends ConsumerStatefulWidget {
  const ProfileDialog({super.key});

  @override
  ConsumerState<ProfileDialog> createState() => _ProfileDialogState();
}

class _ProfileDialogState extends ConsumerState<ProfileDialog> {
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late TextEditingController _notesController;
  late TextEditingController _occController;

  bool _isEditing = false;
  String _selectedIcon = 'person';
  String? _avatarBase64;

  final List<String> _avatarPresets = [
    'person', 'code', 'work', 'school', 'star', 'palette', 'rocket', 'camera', 'coffee', 'security', 'terminal', 'favorite'
  ];

  @override
  void initState() {
    super.initState();
    final profile = ref.read(profileProvider);
    _selectedIcon = profile.avatarIcon;
    _avatarBase64 = profile.avatarBase64;
    _nameController = TextEditingController(text: profile.displayName);
    _bioController = TextEditingController(text: profile.bio);
    _notesController = TextEditingController(text: profile.personalNote);
    _occController = TextEditingController(text: profile.occupation);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _notesController.dispose();
    _occController.dispose();
    super.dispose();
  }

  IconData _getAvatarIconData(String key) {
    switch (key) {
      case 'code': return Icons.code_rounded;
      case 'work': return Icons.work_rounded;
      case 'school': return Icons.school_rounded;
      case 'star': return Icons.star_rounded;
      case 'palette': return Icons.palette_rounded;
      case 'rocket': return Icons.rocket_launch_rounded;
      case 'camera': return Icons.camera_alt_rounded;
      case 'coffee': return Icons.coffee_rounded;
      case 'security': return Icons.security_rounded;
      case 'terminal': return Icons.terminal_rounded;
      case 'favorite': return Icons.favorite_rounded;
      default: return Icons.person_rounded;
    }
  }

  Future<void> _pickImageFromDevice() async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      if (image != null) {
        final bytes = await image.readAsBytes();
        final base64String = base64Encode(bytes);
        setState(() {
          _avatarBase64 = base64String;
        });
        await ref.read(profileProvider.notifier).updateProfile(
          avatarBase64: base64String,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not pick image: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = ref.watch(currentUserProvider);
    final profile = ref.watch(profileProvider);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.large)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 680),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.large),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.account_circle_rounded, size: 24),
                      const SizedBox(width: AppSpacing.small),
                      Text('User Profile & Personal Data', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Avatar display & Selector
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          InkWell(
                            borderRadius: BorderRadius.circular(50),
                            onTap: _pickImageFromDevice,
                            child: Container(
                              width: 96,
                              height: 96,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [theme.colorScheme.primary, theme.colorScheme.tertiary],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                border: Border.all(color: theme.colorScheme.surface, width: 3),
                                boxShadow: [
                                  BoxShadow(
                                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: _avatarBase64 != null && _avatarBase64!.isNotEmpty
                                    ? ClipOval(
                                        child: Image.memory(
                                          base64Decode(_avatarBase64!),
                                          width: 90,
                                          height: 90,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => Icon(_getAvatarIconData(_selectedIcon), size: 42, color: Colors.white),
                                        ),
                                      )
                                    : Icon(_getAvatarIconData(_selectedIcon), size: 42, color: Colors.white),
                              ),
                            ),
                          ),
                          // Camera Icon Badge
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Material(
                              color: theme.colorScheme.primary,
                              shape: const CircleBorder(),
                              elevation: 4,
                              child: InkWell(
                                customBorder: const CircleBorder(),
                                onTap: _pickImageFromDevice,
                                child: const Padding(
                                  padding: EdgeInsets.all(7),
                                  child: Icon(Icons.camera_alt_rounded, size: 18, color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                          // Delete photo button if custom photo exists
                          if (_avatarBase64 != null && _avatarBase64!.isNotEmpty)
                            Positioned(
                              top: 0,
                              right: 0,
                              child: Material(
                                color: Colors.red,
                                shape: const CircleBorder(),
                                elevation: 4,
                                child: InkWell(
                                  customBorder: const CircleBorder(),
                                  onTap: () {
                                    setState(() {
                                      _avatarBase64 = null;
                                      _selectedIcon = 'person';
                                      _isEditing = true;
                                    });
                                  },
                                  child: const Padding(
                                    padding: EdgeInsets.all(4),
                                    child: Icon(Icons.close_rounded, size: 14, color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.standard),
                      Text(user?.email ?? 'signed-in-user@cloud.com',
                          style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                      const SizedBox(height: AppSpacing.standard),

                      // Avatar icon picker when in edit mode
                      if (_isEditing) ...[
                        Text('Or Choose Avatar Icon:', style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: AppSpacing.small),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _avatarPresets.map((iconKey) {
                            final isSelected = _selectedIcon == iconKey && _avatarBase64 == null;
                            return InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () {
                                setState(() {
                                  _selectedIcon = iconKey;
                                  _avatarBase64 = null;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected ? theme.colorScheme.primary : theme.colorScheme.surfaceContainerHighest,
                                  border: isSelected ? Border.all(color: theme.colorScheme.primary, width: 2) : null,
                                ),
                                child: Icon(
                                  _getAvatarIconData(iconKey),
                                  size: 20,
                                  color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const Divider(height: 24),
                      ],

                      // Personal Data Section
                      if (!_isEditing) ...[
                        _buildInfoTile(theme, Icons.badge_outlined, 'Display Name', profile.displayName.isNotEmpty ? profile.displayName : 'Not set'),
                        _buildInfoTile(theme, Icons.work_outline_rounded, 'Occupation / Title', profile.occupation.isEmpty ? 'Not set' : profile.occupation),
                        _buildInfoTile(theme, Icons.info_outline_rounded, 'Bio / About', profile.bio.isNotEmpty ? profile.bio : 'Not set'),
                        _buildInfoTile(theme, Icons.note_alt_outlined, 'Personal Note / Scratchpad', profile.personalNote.isEmpty ? 'No private notes yet.' : profile.personalNote),
                      ] else ...[
                        TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Display Name',
                            prefixIcon: Icon(Icons.badge_outlined),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.small),
                        TextField(
                          controller: _occController,
                          decoration: const InputDecoration(
                            labelText: 'Occupation / Role',
                            prefixIcon: Icon(Icons.work_outline_rounded),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.small),
                        TextField(
                          controller: _bioController,
                          maxLines: 2,
                          decoration: const InputDecoration(
                            labelText: 'Bio / About Me',
                            prefixIcon: Icon(Icons.info_outline_rounded),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.small),
                        TextField(
                          controller: _notesController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'Personal Private Note',
                            hintText: 'Save passwords hints, ideas, or personal reminders...',
                            prefixIcon: Icon(Icons.note_alt_outlined),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.standard),
              Row(
                children: [
                  if (!_isEditing) ...[
                    OutlinedButton.icon(
                      icon: const Icon(Icons.delete_forever_rounded, color: Colors.red),
                      label: const Text('Clear Data', style: TextStyle(color: Colors.red)),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Delete Personal Data?'),
                            content: const Text('This will reset your avatar, bio, and personal private notes.'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                              FilledButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          await ref.read(profileProvider.notifier).deletePersonalData();
                          setState(() {
                            _avatarBase64 = null;
                            _selectedIcon = 'person';
                          });
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Personal data cleared.')));
                          }
                        }
                      },
                    ),
                    const Spacer(),
                    FilledButton.icon(
                      icon: const Icon(Icons.edit_rounded),
                      label: const Text('Edit Profile'),
                      onPressed: () => setState(() => _isEditing = true),
                    ),
                  ] else ...[
                    TextButton(
                      onPressed: () => setState(() => _isEditing = false),
                      child: const Text('Cancel'),
                    ),
                    const Spacer(),
                    FilledButton.icon(
                      icon: const Icon(Icons.check_rounded),
                      label: const Text('Save Changes'),
                      onPressed: () async {
                        await ref.read(profileProvider.notifier).updateProfile(
                          avatarIcon: _selectedIcon,
                          avatarBase64: _avatarBase64,
                          displayName: _nameController.text.trim(),
                          occupation: _occController.text.trim(),
                          bio: _bioController.text.trim(),
                          personalNote: _notesController.text.trim(),
                        );
                        if (context.mounted) {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Profile saved permanently!')),
                          );
                        }
                      },
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile(ThemeData theme, IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.small),
      padding: const EdgeInsets.all(AppSpacing.compact),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: AppSpacing.small),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                const SizedBox(height: 2),
                Text(value, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
