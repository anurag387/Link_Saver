import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_config.dart';

SupabaseClient get supabase => Supabase.instance.client;

Future<void> initializeSupabase() async {
  if (!SupabaseConfig.isConfigured) return;

  await Supabase.initialize(
    url: SupabaseConfig.url,
    publishableKey: SupabaseConfig.publishableKey,
  );
}
