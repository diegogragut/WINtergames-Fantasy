# Where WINter Fantasy stands (Nov 10, 2026)

## Done

- **App** (`index.html`): Google sign-in → "Create your team" (team name, manager name, favourite WINter team) → squad builder, matches, league table, rules.
- **GitHub**: all code is on `main` at https://github.com/diegogragut/WINtergames-Fantasy. This Mac can push: `gh` is installed in `~/.local/gh-cli` and logged in as diegogragut.
- **Supabase**: project **winter-fantasy** (`https://pkftgdviovllansnswah.supabase.co`), organization "WINter Fantasy", free plan. `supabase/schema.sql` has been run: 5 tables, row security, the 2-per-team and lock rules. `config.js` holds the URL and the public anon key.
- **Google sign-in**: Google Cloud project **WINter Games Fantasy** has an OAuth web client "WINter Fantasy" whose redirect is the Supabase callback. Supabase → Authentication → Providers → Google is **ENABLED** with that client.
  - The Google app is still in **Testing**: only test users can sign in. Test user added: your own Google account.

## Not done yet

1. **Deploy on Vercel.** You're signed in to Vercel (personal "Diego" Hobby team). The import page for `diegogragut/WINtergames-Fantasy` (project name `wintergames-fantasy`, preset **Other**, root `./`) was open, but the deploy hadn't finished. Open https://vercel.com/new, import the repo with those settings, and click **Deploy**. The site should end up at `https://wintergames-fantasy.vercel.app` (Vercel may pick a slightly different name).
2. **Point Supabase at the live site.** Supabase → Authentication → URL Configuration:
   - Site URL = the Vercel address
   - Redirect URLs: add the Vercel address (and `http://localhost:3000` for local testing)
3. **Let everyone sign in with Google.** Google Cloud → Google Auth Platform:
   - **Branding**: add the Vercel address as the home page, and a privacy policy link (a `privacy.html` page still needs to be added to the site).
   - **Audience**: click **Publish app**.
   - Until then, add each friend's Gmail under **Audience → Test users** (up to 100).
4. **Make yourself organizer** after you sign in on the live site, in Supabase → SQL Editor:
   ```sql
   insert into public.admins (user_id)
   select id from auth.users where email = 'YOUR-GOOGLE-EMAIL';
   ```
5. **Optional, recommended**: rotate the Google client secret (Clients → WINter Fantasy → Add secret, paste the new one into Supabase, then disable the old one). The old one was briefly visible during setup.

Squads lock at the first kick-off: **Nov 12, 19:00 Costa Rica time**.
