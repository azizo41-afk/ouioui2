-- Run this file in the Supabase SQL editor.
create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  name text not null default '',
  email text,
  created_at timestamptz not null default now()
);

create table if not exists public.invitations (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  sender_name text not null,
  recipient_name text not null,
  title text not null,
  message text not null,
  activity text not null,
  location text,
  theme text not null default 'romantique',
  unique_slug text not null unique,
  expiration_date timestamptz,
  created_at timestamptz not null default now()
);

create table if not exists public.available_slots (
  id uuid primary key default gen_random_uuid(),
  invitation_id uuid not null references public.invitations(id) on delete cascade,
  date date not null,
  start_time time not null,
  end_time time
);

create table if not exists public.responses (
  id uuid primary key default gen_random_uuid(),
  invitation_id uuid not null references public.invitations(id) on delete cascade,
  status text not null check (status in ('accepted','declined')),
  selected_slot_id uuid references public.available_slots(id) on delete set null,
  recipient_message text default '',
  created_at timestamptz not null default now()
);

alter table public.profiles enable row level security;
alter table public.invitations enable row level security;
alter table public.available_slots enable row level security;
alter table public.responses enable row level security;

create policy "profile owner reads own profile" on public.profiles for select using (auth.uid() = id);
create policy "profile owner updates own profile" on public.profiles for update using (auth.uid() = id);
create policy "profile owner inserts own profile" on public.profiles for insert with check (auth.uid() = id);
create policy "owners manage invitations" on public.invitations for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "public can read invitation by slug" on public.invitations for select using (true);
create policy "owners manage slots" on public.available_slots for all using (exists(select 1 from public.invitations i where i.id = invitation_id and i.user_id = auth.uid())) with check (exists(select 1 from public.invitations i where i.id = invitation_id and i.user_id = auth.uid()));
create policy "public reads slots for invitation" on public.available_slots for select using (true);
create policy "owners read responses" on public.responses for select using (exists(select 1 from public.invitations i where i.id = invitation_id and i.user_id = auth.uid()));
-- Public response insertion is intentionally disabled here. Use the Edge Function below
-- (or a dedicated server endpoint with validation/rate limiting) to accept recipient replies.
