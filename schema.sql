-- ============================================================
-- OMOP Concept Mapping Tool — Supabase Schema
-- Run this in your Supabase SQL editor (Dashboard > SQL Editor)
-- ============================================================

-- 1. Source fields table (populated by admin CSV upload)
create table if not exists source_fields (
  id serial primary key,
  source_field text not null,
  details text,
  created_at timestamptz default now()
);

-- 2. Mappings table — one row per (user, source_field)
create table if not exists mappings (
  id serial primary key,
  username text not null,
  source_field_id integer references source_fields(id) on delete cascade,
  domain_id text,
  name text,
  concept_id text,
  vocab text,
  updated_at timestamptz default now(),
  unique(username, source_field_id)
);

-- ============================================================
-- Row Level Security
-- Allow all reads and writes (no auth — username-based only)
-- ============================================================
alter table source_fields enable row level security;
alter table mappings enable row level security;

create policy "Allow all reads on source_fields"
  on source_fields for select using (true);

create policy "Allow all reads on mappings"
  on mappings for select using (true);

create policy "Allow all inserts on mappings"
  on mappings for insert with check (true);

create policy "Allow all updates on mappings"
  on mappings for update using (true);

-- ============================================================
-- Admin: CSV Upload helper view
-- After uploading CSV via Supabase Table Editor or SQL,
-- your source_fields rows will appear here.
-- ============================================================

-- Optional: view showing all fields + how many users have mapped them
create or replace view mapping_progress as
  select
    sf.id,
    sf.source_field,
    sf.details,
    count(distinct m.username) as users_who_mapped
  from source_fields sf
  left join mappings m on m.source_field_id = sf.id
  group by sf.id, sf.source_field, sf.details
  order by sf.id;
