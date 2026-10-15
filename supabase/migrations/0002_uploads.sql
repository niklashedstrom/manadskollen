-- Upload history shown on the Filer tab: one entry per uploaded file (name, account, period, rows added).
alter table public.mk_settings add column if not exists uploads jsonb not null default '[]'::jsonb;
