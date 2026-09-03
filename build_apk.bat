@echo off
set SUPABASE_URL=https://tpjyuzmfjsmvhymqxwqe.supabase.co
set SUPABASE_PUBLISHABLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRwanl1em1manNtdmh5bXF4d3FlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODgxNjI4NjksImV4cCI6MjEwMzczODg2OX0.Fwwqz_JeWv6mjKrA-kiLvg5toeSDYTQwHXgEnEk7fBI

echo Building Link Saver Release APK...
flutter pub get
flutter build apk --release --dart-define=SUPABASE_URL=%SUPABASE_URL% --dart-define=SUPABASE_PUBLISHABLE_KEY=%SUPABASE_PUBLISHABLE_KEY%
pause

