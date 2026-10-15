# Månadskollen

Personal income/expense overview from Nordea exports (account PDFs, card CSV). Static site on Vercel, data in Supabase.

## How it fits together

- `index.html` – the whole app. Parses CSV and PDF in the browser (pdf.js, loaded on first PDF), so bank files never leave the device as files; only the parsed rows go to the database.
- `config.js` – Supabase URL and anon key. Public by design; row-level security restricts each signed-in user to their own rows.
- `supabase/migrations/0001_init.sql` – `transactions` (one row per bank transaction, primary key `(user_id, id)` so re-uploads dedupe) and `settings` (tag rules, per-transaction tags, own account numbers).
- Sign-in is a magic link by email (Supabase Auth).

## Setup

1. Supabase: run `supabase/migrations/0001_init.sql` in the project.
2. Supabase → Authentication → URL Configuration: set Site URL to the Vercel URL and add it under Redirect URLs.
3. Fill in `config.js` with the project URL and anon (publishable) key.
4. Vercel → Add New Project → import this repo. Framework preset: Other. No build command, output directory `.`.
5. Sign in once, then Supabase → Authentication → Sign In / Providers: turn off "Allow new users to sign up" so nobody else can create an account.

## Data notes

- Transfers between your own accounts are matched (same amount, opposite sign, different account, ≤3 days apart) and tagged `Överföring`, which is excluded from totals. `Överföring <your own account number>` is always a transfer.
- Card bill payments (`Betalning PG 4173300-7`) are tagged `Kortfaktura` and count as spending until the card's own purchases for that period are loaded; then the payment pairs with the card's `INBETALNING` and drops out.
- The running month is labelled "pågår"; the overview opens on the last complete month.
