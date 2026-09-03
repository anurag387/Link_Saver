import '../../../core/backend/supabase_client.dart';
import '../../../shared/models/collection_model.dart';

class CollectionRepository {
  String get _userId => supabase.auth.currentUser!.id;

  Future<List<LinkCollection>> fetchCollections() async {
    final rows = await supabase
        .from('collections')
        .select()
        .eq('user_id', _userId)
        .order('created_at');
    return [for (final row in rows) LinkCollection.fromMap(Map<String, dynamic>.from(row))];
  }

  Future<void> upsert(LinkCollection collection) async {
    await supabase.from('collections').upsert(collection.toMap(_userId));
  }

  Future<void> delete(String id) async {
    await supabase.from('collections').delete().eq('id', id).eq('user_id', _userId);
  }
}
