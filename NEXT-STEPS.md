# Where WINter Fantasy stands (Nov 10, 2026)

## Done

- **App** (`index.html`): Google sign-in → "Create your team" (team name, manager name, favourite WINter team) → squad builder, matches, league table, rules.
- **GitHub**: all code is on `main` at https://github.com/diegogragut/WINtergames-Fantasy. This Mac can push: `gh` is installed in `~/.local/gh-cli` and logged in as diegogragut.
- **Supabase**: project **winter-fantasy** (`https://pkftgdviovllansnswah.supabase.co`), organization "WINter Fantasy", free plan. `supabase/schema.sql` has been run: 5 tables, row security, the 2-per-team and lock rules. `config.js` holds the URL and the public anon key.
- **Google sign-in**: Google Cloud project **WINter Games Fantasy** has an OAuth web client "WINter Fantasy" whose redirect is the Supabase callback. Supabase → Authentication → Providers → Google is **ENABLED** with that client.

- **Live site**: https://wintergames-fantasy.vercel.app (Vercel project `wintergames-fantasy`, "Diego" Hobby team). Every push to `main` redeploys it.
- **Supabase URL Configuration**: Site URL is the live site, and the redirect allow list holds the live site and `http://localhost:3000`.
- **Google sign-in published** ("In production"): anyone with a Google account can sign in. The branding page has the home page and privacy link (`/privacy`), and the authorised domains include `wintergames-fantasy.vercel.app`.

- **Organizer**: your team "Tres Rios FC" is an organizer. To add another organizer later, run this in Supabase → SQL Editor:
  ```sql
  insert into public.admins (user_id)
  select id from auth.users where email = 'THEIR-GOOGLE-EMAIL';
  ```

## Not done yet

1. **Optional, recommended**: rotate the Google client secret (Clients → WINter Fantasy → Add secret, paste the new one into Supabase, then disable the old one). The old one was briefly visible during setup.

Squads lock at the first kick-off: **Nov 12, 19:00 Costa Rica time**.
