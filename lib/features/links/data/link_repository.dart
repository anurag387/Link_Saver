import 'package:flutter/foundation.dart';
import '../../../core/backend/supabase_client.dart';
import '../../../shared/models/link_model.dart';

class LinkRepository {
  String? get _userId => supabase.auth.currentUser?.id;

  Future<List<LinkItem>> fetchLinks() async {
    final uid = _userId;
    if (uid == null) return [];
    try {
      final rows = await supabase
          .from('links')
          .select()
          .eq('user_id', uid)
          .order('saved_at', ascending: false);
      return [for (final row in rows) LinkItem.fromMap(Map<String, dynamic>.from(row))];
    } catch (e) {
      debugPrint('Supabase fetchLinks error: $e');
      return [];
    }
  }

  Future<void> upsert(LinkItem item) async {
    final uid = _userId;
    if (uid == null) return;
    try {
      await supabase.from('links').upsert(item.toMap(uid), onConflict: 'id, user_id');
    } catch (e) {
      debugPrint('Supabase upsert link error: $e');
    }
  }

  Future<void> delete(String id) async {
    final uid = _userId;
    if (uid == null) return;
    try {
      await supabase.from('links').delete().eq('id', id).eq('user_id', uid);
    } catch (e) {
      debugPrint('Supabase delete link error: $e');
    }
  }
}
