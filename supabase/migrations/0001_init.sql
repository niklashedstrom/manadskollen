-- Månadskollen: one row per bank transaction, one settings row per user.
-- Every row belongs to the signed-in user; RLS makes other users' rows invisible.

create table public.mk_transactions (
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  id      text not null,             -- source|date|amount|text|n, stable across re-uploads (dedup key)
  src     text not null,             -- account label, e.g. "Lönekonto", "Kreditkort"
  date    date not null,
  amount  numeric(14,2) not null,    -- negative = money out
  text    text not null,
  key     text not null,             -- normalized merchant, what tag rules match on
  created_at timestamptz not null default now(),
  primary key (user_id, id)
);
create index mk_transactions_user_date on public.mk_transactions (user_id, date desc);

create table public.mk_settings (
  user_id   uuid primary key default auth.uid() references auth.users (id) on delete cascade,
  rules     jsonb not null default '{}'::jsonb,   -- merchant key -> tag
  overrides jsonb not null default '{}'::jsonb,   -- transaction id -> tag
  tags      jsonb not null default '[]'::jsonb,
  flips     jsonb not null default '{}'::jsonb,   -- account -> flip sign
  own       jsonb not null default '[]'::jsonb,   -- your own account numbers
  updated_at timestamptz not null default now()
);

alter table public.mk_transactions enable row level security;
alter table public.mk_settings     enable row level security;

create policy "mk own transactions" on public.mk_transactions
  for all to authenticated
  using (user_id = (select auth.uid()))
  with check (user_id = (select auth.uid()));

create policy "mk own settings" on public.mk_settings
  for all to authenticated
  using (user_id = (select auth.uid()))
  with check (user_id = (select auth.uid()));

revoke all on public.mk_transactions, public.mk_settings from anon;
