-- Notes on single transactions: transaction id -> free text, e.g. {"<id>": "byxor John Henrik"}.
alter table public.mk_settings add column if not exists notes jsonb not null default '{}'::jsonb;
