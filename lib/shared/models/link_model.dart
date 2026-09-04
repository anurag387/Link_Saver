class LinkItem {
  final String id;
  final String url;
  final String title;
  final String description;
  final String domain;
  final String? faviconEmoji;
  final String collectionId;
  final List<String> tags;
  final String notes;
  final bool isFavorite;
  final bool isArchived;
  final bool isReadLater;
  final DateTime savedAt;
  final bool metadataPending;

  const LinkItem({
    required this.id,
    required this.url,
    required this.title,
    required this.description,
    required this.domain,
    this.faviconEmoji = '',
    required this.collectionId,
    this.tags = const [],
    this.notes = '',
    this.isFavorite = false,
    this.isArchived = false,
    this.isReadLater = false,
    required this.savedAt,
    this.metadataPending = false,
  });

  Map<String, dynamic> toMap(String userId) => {
        'id': id,
        'user_id': userId,
        'url': url,
        'title': title,
        'description': description,
        'domain': domain,
        'favicon_emoji': faviconEmoji,
        'collection_id': collectionId,
        'tags': tags,
        'notes': notes,
        'is_favorite': isFavorite,
        'is_archived': isArchived,
        'is_read_later': isReadLater,
        'saved_at': savedAt.toUtc().toIso8601String(),
        'metadata_pending': metadataPending,
      };

  static DateTime _parseSavedAt(dynamic value) {
    if (value == null) return DateTime.now();
    try {
      final str = value.toString();
      final dt = DateTime.parse(str);
      return dt.isUtc ? dt.toLocal() : dt;
    } catch (_) {
      return DateTime.now();
    }
  }

  factory LinkItem.fromMap(Map<String, dynamic> map) => LinkItem(
        id: (map['id'] as String?) ?? '',
        url: (map['url'] as String?) ?? '',
        title: (map['title'] as String?) ?? '',
        description: (map['description'] as String?) ?? '',
        domain: (map['domain'] as String?) ?? '',
        faviconEmoji: (map['favicon_emoji'] as String?) ?? (map['faviconEmoji'] as String?),
        collectionId: (map['collection_id'] as String?) ??
            (map['collectionId'] as String?) ??
            'personal',
        tags: List<String>.from(map['tags'] ?? const <String>[]),
        notes: (map['notes'] as String?) ?? '',
        isFavorite: (map['is_favorite'] as bool?) ?? (map['isFavorite'] as bool?) ?? false,
        isArchived: (map['is_archived'] as bool?) ?? (map['isArchived'] as bool?) ?? false,
        isReadLater: (map['is_read_later'] as bool?) ?? (map['isReadLater'] as bool?) ?? false,
        savedAt: _parseSavedAt(map['saved_at'] ?? map['savedAt']),
        metadataPending: (map['metadata_pending'] as bool?) ??
            (map['metadataPending'] as bool?) ??
            false,
      );

  LinkItem copyWith({
    String? url,
    String? title,
    String? description,
    String? domain,
    String? faviconEmoji,
    String? collectionId,
    List<String>? tags,
    String? notes,
    bool? isFavorite,
    bool? isArchived,
    bool? isReadLater,
    bool? metadataPending,
  }) {
    return LinkItem(
      id: id,
      url: url ?? this.url,
      title: title ?? this.title,
      description: description ?? this.description,
      domain: domain ?? this.domain,
      faviconEmoji: faviconEmoji ?? this.faviconEmoji,
      collectionId: collectionId ?? this.collectionId,
      tags: tags ?? this.tags,
      notes: notes ?? this.notes,
      isFavorite: isFavorite ?? this.isFavorite,
      isArchived: isArchived ?? this.isArchived,
      isReadLater: isReadLater ?? this.isReadLater,
      savedAt: savedAt,
      metadataPending: metadataPending ?? this.metadataPending,
    );
  }
}
