import 'package:flutter/foundation.dart';
import '../../../core/backend/supabase_client.dart';
import '../../../shared/models/collection_model.dart';

class CollectionRepository {
  String? get _userId => supabase.auth.currentUser?.id;

  Future<List<LinkCollection>> fetchCollections() async {
    final uid = _userId;
    if (uid == null) return [];
    try {
      final rows = await supabase
          .from('collections')
          .select()
          .eq('user_id', uid)
          .order('created_at');
      return [for (final row in rows) LinkCollection.fromMap(Map<String, dynamic>.from(row))];
    } catch (e) {
      debugPrint('Supabase fetchCollections error: $e');
      return [];
    }
  }

  Future<void> upsert(LinkCollection collection) async {
    final uid = _userId;
    if (uid == null) return;
    try {
      await supabase.from('collections').upsert(collection.toMap(uid), onConflict: 'id, user_id');
    } catch (e) {
      debugPrint('Supabase upsert collection error: $e');
    }
  }

  Future<void> delete(String id) async {
    final uid = _userId;
    if (uid == null) return;
    try {
      await supabase.from('collections').delete().eq('id', id).eq('user_id', uid);
    } catch (e) {
      debugPrint('Supabase delete collection error: $e');
    }
  }
}
