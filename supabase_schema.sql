-- Link Saver cloud database
-- Run this entire file in Supabase Dashboard -> SQL Editor.

create extension if not exists pgcrypto;

create table if not exists public.collections (
  id text not null,
  user_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  emoji text not null default 'folder',
  created_at timestamptz not null default now(),
  primary key (id, user_id)
);

create table if not exists public.links (
  id text not null,
  user_id uuid not null references auth.users(id) on delete cascade,
  url text not null,
  title text not null default '',
  description text not null default '',
  domain text not null default '',
  favicon_emoji text default '',
  collection_id text not null,
  tags text[] not null default '{}',
  notes text not null default '',
  is_favorite boolean not null default false,
  is_archived boolean not null default false,
  is_read_later boolean not null default false,
  saved_at timestamptz not null default now(),
  metadata_pending boolean not null default false,
  primary key (id, user_id)
);

create index if not exists collections_user_id_idx on public.collections(user_id);
create index if not exists links_user_id_idx on public.links(user_id);
create index if not exists links_user_saved_at_idx on public.links(user_id, saved_at desc);

alter table public.collections enable row level security;
alter table public.links enable row level security;

drop policy if exists "users can view own collections" on public.collections;
drop policy if exists "users can insert own collections" on public.collections;
drop policy if exists "users can update own collections" on public.collections;
drop policy if exists "users can delete own collections" on public.collections;

create policy "users can view own collections" on public.collections for select to authenticated using (auth.uid() = user_id);
create policy "users can insert own collections" on public.collections for insert to authenticated with check (auth.uid() = user_id);
create policy "users can update own collections" on public.collections for update to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "users can delete own collections" on public.collections for delete to authenticated using (auth.uid() = user_id);

drop policy if exists "users can view own links" on public.links;
drop policy if exists "users can insert own links" on public.links;
drop policy if exists "users can update own links" on public.links;
drop policy if exists "users can delete own links" on public.links;

create policy "users can view own links" on public.links for select to authenticated using (auth.uid() = user_id);
create policy "users can insert own links" on public.links for insert to authenticated with check (auth.uid() = user_id);
create policy "users can update own links" on public.links for update to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "users can delete own links" on public.links for delete to authenticated using (auth.uid() = user_id);

grant select, insert, update, delete on public.collections to authenticated;
grant select, insert, update, delete on public.links to authenticated;
