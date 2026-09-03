<div align="center">

# 🔗 Link Saver

**Capture instantly, organize effortlessly, find anything later.**

A cross-platform Flutter app for saving, organizing, and syncing your links across every device — powered by Supabase.

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.3%2B-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Supabase](https://img.shields.io/badge/Backend-Supabase-3ECF8E?logo=supabase&logoColor=white)](https://supabase.com)
[![State Management](https://img.shields.io/badge/State-Riverpod-6F42C1)](https://riverpod.dev)

</div>

---

## 📖 Overview

**Link Saver** is a Flutter application that lets you save links from anywhere, organize them into collections, tag and annotate them, and pick them up later — favorited, archived, or queued for reading. This build adds full **cloud sync**: every action is backed by **Supabase Authentication** and a **PostgreSQL** database, so your data follows you across devices instead of living only in local app memory.

## ✨ Features

| Feature | Description |
|---|---|
| 🔐 **Email/password auth** | Secure sign-up & sign-in via Supabase Auth |
| ☁️ **Real-time cloud sync** | Every add, edit, delete, and status change is written straight to Supabase |
| 📁 **Collections** | Group links into custom, emoji-tagged collections |
| ⭐ **Favorites, Archive & Read Later** | Organize links by status with a single tap |
| 🏷️ **Tags & notes** | Add personal notes and tags to any saved link |
| 🔍 **Search** | Instantly find links by title, domain, or tag |
| 🌗 **Light & dark themes** | Adaptive Material theming |
| 🔒 **Row Level Security (RLS)** | Each user can only ever see their own data |
| 📱 **Multi-device continuity** | Sign in on any device and your links & collections are already there |

## 🏗️ Architecture

The project follows a clean, **feature-first** structure with [Riverpod](https://riverpod.dev) for state management:

```
lib/
├── main.dart                     # App entry point & Supabase bootstrap
├── app_shell.dart                # Root navigation shell
├── core/
│   ├── backend/                  # Supabase client & configuration
│   ├── constants/                # Shared spacing/design tokens
│   └── theme/                    # App-wide light/dark theming
├── shared/
│   ├── models/                   # LinkItem & Collection data models
│   └── widgets/                  # Reusable UI components
└── features/
    ├── auth/                     # Login & authentication gate
    ├── links/                    # Home feed, link details, save sheet
    ├── collections/               # Collection list & detail views
    ├── search/                   # Search screen & provider
    └── settings/                  # App settings & theme toggle
```

**Backend:** Supabase (PostgreSQL + Auth + Row Level Security)
**State management:** Flutter Riverpod
**Data flow:** UI → Providers → Repositories → Supabase

## 🗄️ Database Schema

Two tables live in the `public` schema, both protected with Row Level Security so a user can only access their own rows:

- **`collections`** — `id`, `user_id`, `name`, `emoji`, `created_at`
- **`links`** — `id`, `user_id`, `url`, `title`, `description`, `domain`, `favicon_emoji`, `collection_id`, `tags[]`, `notes`, `is_favorite`, `is_archived`, `is_read_later`, `saved_at`, `metadata_pending`

The full schema, indexes, and RLS policies are defined in [`supabase_schema.sql`](./supabase_schema.sql).

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) `>=3.3.0 <4.0.0`
- A free [Supabase](https://supabase.com) account
- Android Studio / Xcode (for mobile builds) or Chrome (for web)

### 1. Set up the cloud database

1. Create a new project on [Supabase](https://supabase.com).
2. Open the **SQL Editor** and run the entire contents of [`supabase_schema.sql`](./supabase_schema.sql).
3. Under **Authentication → Providers**, enable **Email/Password**.
   - Disable *"Confirm email"* if you want users to be able to log in immediately after sign-up.

### 2. Get your project credentials

From your Supabase project's **Connect / API** settings, copy:
- **Project URL**
- **Publishable (anon) key**

> ⚠️ Never use the **service-role/secret key** in the Flutter app — only the publishable key is safe for client-side use. Credentials are never committed to the repo; they're passed in at build time via `--dart-define`.

### 3. Install dependencies

```bash
flutter pub get
```

### 4. Run the app

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=YOUR_PUBLISHABLE_KEY
```

**Windows shortcut:** double-click `run_cloud.bat` and paste your URL/key when prompted.

### 5. Build for release

**Web:**
```bash
flutter build web \
  --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=YOUR_PUBLISHABLE_KEY
```

**Android APK:**
```bash
flutter build apk --release \
  --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=YOUR_PUBLISHABLE_KEY
```

Or simply run `build_apk.bat` on Windows.

## 📲 Using on Multiple Devices

Install and run the app on another device using the **same Supabase URL and publishable key**, then sign in with the **same email/password**. Since all data lives in the cloud, your links and collections appear immediately — no manual transfer needed.

## 🔧 Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter |
| Language | Dart |
| State Management | flutter_riverpod |
| Backend / Auth / DB | Supabase (PostgreSQL) |
| Other packages | `uuid`, `intl`, `url_launcher` |

## 📌 Notes

- This repository ships the **code and database schema only** — it intentionally does **not** include Supabase project credentials, since these are unique and private to each deployment.
- Until `SUPABASE_URL` and `SUPABASE_PUBLISHABLE_KEY` are supplied at build/run time, the app displays a clear configuration screen instead of crashing.
- Row Level Security ensures complete data isolation between user accounts at the database level — not just in the app layer.

## 📄 License

This project is provided as-is for personal and educational use. Adapt it freely for your own projects.

---

<div align="center">
Made with Flutter & Supabase
</div>
