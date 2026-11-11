# WINter Fantasy

Fantasy league for the Winter Games 2026 tournament (Nov 12 – Nov 23).

1. Players **sign in with Google**.
2. The first time, they **create their team**: team name, manager name and (optionally) a favourite WINter team.
3. They **pick a 7-player squad** (5 starters + 2 bench, max 2 per WINter team). It saves to their account and follows them to any device.

| Event | Points |
|---|---|
| Goal | +5 |
| Assist | +2 |
| Match win (every player on the winning team) | +1 |
| Goalkeeper clean sheet | +3 |
| Each goal conceded (CBs and goalkeeper) | −1 |
| Yellow card | −2 |
| Red card | −5 |

Only starters score. Each manager picks a **captain (C)** by tapping a player's shirt; his points count double, and a squad can't be saved without one. Squads lock at the first kick-off: **Nov 12, 12:30 (Costa Rica time)**. Every match runs 12:30–13:10. The database enforces that, the 2-per-team rule, and "a locked squad can't change", so nobody can get around them.

## Files

| File | What it is |
|---|---|
| `index.html` | The whole app: sign-in, team creation, squad builder, matches, table, rules |
| `config.js` | Your Supabase URL and anon key |
| `supabase/schema.sql` | Database tables and security rules. Run once in Supabase |
| `vercel.json` | Vercel settings (static site, no build step) |

## Setup (about 15 minutes, once)

### 1. Create the Supabase project

1. Go to https://supabase.com, sign in, and click **New project**. Any name works (for example `winter-fantasy`). Pick a region close to Costa Rica (for example *East US*).
2. When it's ready, open **SQL Editor → New query**, paste everything from `supabase/schema.sql`, and click **Run**. It should say "Success".
3. Open **Project Settings → API**. Copy the **Project URL** and the **anon public** key into `config.js`.

### 2. Turn on Google sign-in

1. Go to https://console.cloud.google.com, create a project (or use one you have).
2. **APIs & Services → OAuth consent screen**: choose **External**, fill in the app name (`WINter Fantasy`) and your email, and save. Under **Audience/Publishing status**, click **Publish app** so anyone with a Google account can sign in (otherwise only test users you list can).
3. **APIs & Services → Credentials → Create credentials → OAuth client ID**:
   - Application type: **Web application**
   - Authorized redirect URI: `https://YOUR-PROJECT.supabase.co/auth/v1/callback` (your Supabase Project URL + `/auth/v1/callback`)
4. Copy the **Client ID** and **Client secret**.
5. In Supabase: **Authentication → Sign In / Providers → Google**, switch it on, paste the Client ID and secret, and save.

### 3. Deploy on Vercel

1. Push this folder to GitHub (with `config.js` filled in).
2. Go to https://vercel.com, sign in with GitHub, click **Add New → Project**, and import `WINtergames-Fantasy`.
3. Framework preset: **Other**. Leave the build command and output directory empty. Click **Deploy**.
4. Copy your site address (for example `https://wintergames-fantasy.vercel.app`).
5. In Supabase: **Authentication → URL Configuration**:
   - **Site URL**: your Vercel address
   - **Redirect URLs**: add your Vercel address, plus `http://localhost:3000` if you want to test on your computer

From now on, every push to GitHub redeploys the site automatically.

### 4. Make yourself the organizer

1. Open the site, sign in with Google and create your team.
2. In Supabase: **SQL Editor → New query**, run:

   ```sql
   insert into public.admins (user_id)
   select id from auth.users where email = 'you@example.com';
   ```

   (use the Google email you signed in with)
3. Reload the site. You'll see **Organizer** next to your name, **Enter result** on each match, and a position picker in the transfer market.

## Running it on your computer

Any static server works, for example:

```bash
npx serve -l 3000 .
```

Then open http://localhost:3000 (it must be in Supabase's Redirect URLs for Google sign-in to come back).

## Data model

- `profiles`: one row per manager: `team_name`, `manager_name`, `favorite_team`.
- `squads`: one row per manager: `slots` (7 player ids: 0 GK, 1–2 DEF, 3 MID, 4 FWD, 5–6 bench) and `locked`.
- `match_stats`: one row per played match: scores, goalkeepers and each player's goals, assists and cards.
- `positions`: optional position per player, set by the organizer.
- `admins`: who can enter results.

Player ids are `<team-slug>--<name-slug>`, for example `sin-pulmon--diego-granados`.
