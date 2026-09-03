import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/backend/supabase_client.dart';
import '../../../shared/models/link_model.dart';

class LinkRepository {
  String get _userId => supabase.auth.currentUser!.id;

  Future<List<LinkItem>> fetchLinks() async {
    final rows = await supabase
        .from('links')
        .select()
        .eq('user_id', _userId)
        .order('saved_at', ascending: false);
    return [for (final row in rows) LinkItem.fromMap(Map<String, dynamic>.from(row))];
  }

  Future<void> upsert(LinkItem item) async {
    await supabase.from('links').upsert(item.toMap(_userId));
  }

  Future<void> delete(String id) async {
    await supabase.from('links').delete().eq('id', id).eq('user_id', _userId);
  }
}
