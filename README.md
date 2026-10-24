# Månadskollen

Personal income/expense overview from Nordea exports (account PDFs, card CSV). Static site on Vercel, data in Supabase.

## How it fits together

- `index.html` – the whole app. Parses CSV and PDF in the browser (pdf.js, loaded on first PDF), so bank files never leave the device as files; only the parsed rows go to the database.
- `config.js` – Supabase URL and anon key. Public by design; row-level security restricts each signed-in user to their own rows.
- `supabase/migrations/0001_init.sql` – `transactions` (one row per bank transaction, primary key `(user_id, id)` so re-uploads dedupe) and `settings` (tag rules, per-transaction tags, own account numbers).
- Sign-in is email + password (`signInWithPassword`). Anyone can create an account with "Skapa konto" (`signUp`); with email confirmation on, the account works once the link in the confirmation email is opened. A magic link is the fallback for a forgotten password; once signed in, "Sätt lösenord" in the footer sets a new one (`updateUser`). Email templates cannot be edited on the free plan without custom SMTP, so a code-based login is not used.
- The `training` project's auth users are shared with the training app. That is safe to open for sign-up because every training table has RLS with no policies, the views are `security_invoker`, and the edge functions authenticate with their own tokens, not user JWTs. Keep it that way: a new training table needs RLS, and a new function must not trust any signed-in user.

## Setup

1. Supabase: tables live in the `training` project with an `mk_` prefix; `supabase/migrations/0001_init.sql` is already applied there.
2. Supabase → Authentication → URL Configuration: set Site URL to the Vercel URL and add it under Redirect URLs.
3. Fill in `config.js` with the project URL and anon (publishable) key.
4. Vercel → Add New Project → import this repo. Framework preset: Other. No build command, output directory `.`.
5. Supabase → Authentication → Sign In / Providers: "Allow new users to sign up" and "Confirm email" both on, so others can create their own accounts. Turn sign-up off again to close registration; existing accounts keep working.

## Data notes

- Transfers between your own accounts are matched (same amount, opposite sign, different account, ≤3 days apart) and tagged `Överföring`, which is excluded from totals. `Överföring <your own account number>` is always a transfer.
- Card bill payments (`Betalning PG 4173300-7`) are tagged `Kortfaktura` and count as spending until the card's own purchases for that period are loaded; then the payment pairs with the card's `INBETALNING` and drops out.
- The running month is labelled "pågår"; the overview opens on the last complete month.
- `./release.sh` before each commit stamps a build id; open Home Screen apps compare it with `/version.txt` and reload when it changes.
