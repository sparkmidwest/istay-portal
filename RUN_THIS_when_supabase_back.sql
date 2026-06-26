-- RUN THIS when Supabase connection is back (driver upload + AI features)
create table if not exists istay.upload_queue (
  id uuid primary key default gen_random_uuid(),
  driver text,
  file_name text,
  file_data text,                 -- base64 data URL of the rate con (image/PDF)
  status text not null default 'pending' check (status in ('pending','extracted','posted','rejected')),
  extracted jsonb,                -- AI-extracted load fields
  raw_note text,
  week_id uuid references istay.weeks(id) on delete set null,
  created_at timestamptz default now()
);
alter table istay.loads add column if not exists source text default 'manual';
alter table istay.loads add column if not exists upload_id uuid references istay.upload_queue(id) on delete set null;
alter table istay.loads add column if not exists needs_review boolean default false;

alter table istay.upload_queue enable row level security;
create policy "auth full uploads" on istay.upload_queue for all to authenticated using (true) with check (true);
create policy "anon insert uploads" on istay.upload_queue for insert to anon with check (true);
grant insert (driver,file_name,file_data,status,extracted) on istay.upload_queue to anon;
grant all on istay.upload_queue to authenticated;
