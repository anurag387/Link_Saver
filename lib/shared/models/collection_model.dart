class LinkCollection {
  final String id;
  final String name;
  final String emoji; // Stores icon key e.g. 'folder', 'code', 'book'

  const LinkCollection({
    required this.id,
    required this.name,
    this.emoji = 'folder',
  });

  String get icon => emoji;

  Map<String, dynamic> toMap(String userId) => {
        'id': id,
        'user_id': userId,
        'name': name,
        'emoji': emoji,
      };

  factory LinkCollection.fromMap(Map<String, dynamic> map) => LinkCollection(
        id: (map['id'] as String?) ?? '',
        name: (map['name'] as String?) ?? 'Untitled',
        emoji: (map['emoji'] as String?) ?? (map['icon'] as String?) ?? 'folder',
      );
}
