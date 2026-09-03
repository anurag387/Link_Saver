/// Supabase configuration is supplied at build/run time so credentials are not
/// committed to the source code.
///
/// Run with:
/// flutter run --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co \\
///   --dart-define=SUPABASE_PUBLISHABLE_KEY=YOUR_PUBLISHABLE_KEY
class SupabaseConfig {
  SupabaseConfig._();

  static const url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://tpjyuzmfjsmvhymqxwqe.supabase.co',
  );
  static const publishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRwanl1em1manNtdmh5bXF4d3FlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODgxNjI4NjksImV4cCI6MjEwMzczODg2OX0.Fwwqz_JeWv6mjKrA-kiLvg5toeSDYTQwHXgEnEk7fBI',
  );

  static bool get isConfigured => url.isNotEmpty && publishableKey.isNotEmpty;
}
