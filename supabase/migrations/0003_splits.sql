-- Split transactions: transaction id -> [[tag, percent], ...], e.g. {"<id>": [["Alkohol", 40], ["Restaurang", 60]]}.
-- Percentages add up to 100. A split wins over the place's rule and over a per-transaction tag.
alter table public.mk_settings add column if not exists splits jsonb not null default '{}'::jsonb;
