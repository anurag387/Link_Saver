# Link Saver — Cloud Sync Build

This version adds **Supabase authentication + PostgreSQL cloud storage**. Links and collections are no longer only in Riverpod memory.

## What is fixed

- Add a link -> saved to Supabase
- Favorite / Archive / Read Later -> synced to Supabase
- Edit / Delete -> synced to Supabase
- Create / Delete collection -> synced to Supabase
- Refresh / restart -> data loads again from the cloud
- Another phone/PC -> sign in with the **same account** and the same links/collections load
- Supabase Row Level Security keeps each user's rows separated

## 1. Create the cloud database

Create a Supabase project, open **SQL Editor**, and run the complete `supabase_schema.sql` file.

The Flutter client uses the Supabase publishable key; never put a Supabase secret/service-role key in the app.

## 2. Configure Auth

In Supabase Authentication, enable Email/Password.

If you want users to enter the app immediately after registration, disable email confirmation. If confirmation remains enabled, the app will tell the user to verify the email first.

## 3. Get the project credentials

Copy your project URL and publishable key from the Supabase Connect/API area.

Do not commit these values into the repository. This project reads them through Dart build-time defines.

## 4. Run

```bash
flutter pub get
flutter run --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co --dart-define=SUPABASE_PUBLISHABLE_KEY=YOUR_PUBLISHABLE_KEY
```

For a web build:

```bash
flutter build web --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co --dart-define=SUPABASE_PUBLISHABLE_KEY=YOUR_PUBLISHABLE_KEY
```

For Android APK:

```bash
flutter build apk --release --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co --dart-define=SUPABASE_PUBLISHABLE_KEY=YOUR_PUBLISHABLE_KEY
```

## 5. Use on another device

Install/run the same project on the other device with the **same Supabase URL + publishable key**, then sign in using the **same email/password**. The data is in the cloud, so it does not depend on the first device's local storage.

## Important

The ZIP contains the code and database schema, but it cannot contain your personal Supabase project credentials because those are project-specific secrets/configuration. The app shows a clear configuration screen until the two build-time values are supplied.
