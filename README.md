# WINter Fantasy

Fantasy league for the Winter Games 2026 tournament (Nov 12 – Nov 23).

Each manager builds one 7-player squad (5 starters + 2 bench), with at most 2 players from any WINter team. Only starters score.

| Event | Points |
|---|---|
| Goal | +5 |
| Assist | +2 |
| Match win (every player on the winning team) | +1 |
| Goalkeeper clean sheet | +3 |
| Yellow card | −2 |
| Red card | −5 |

Squads lock at the first kick-off: **Nov 12, 19:00 (Costa Rica time)**.

## Where it runs

Live app: https://claude.ai/artifact/Djiazk4jVJBtsrnDebkwZJ

`index.html` is a single self-contained page. Accounts, saved squads, match results and the league table use the claude.ai artifact runtime (`window.claude.use("db")` and `window.claude.use("user")`). That runtime only exists when the page is opened on claude.ai.

Opened anywhere else (for example GitHub Pages or a local file), the page still renders and you can build a squad, but picks are kept only in that browser. Nothing is saved to an account and there's no shared league table. Running it standalone would need a real backend (for example Firebase or Supabase) in place of the `db` and `user` calls.

## Data model (claude.ai database)

- `squads/<userId>`: `{ name, slots: [7 player ids], locked, updatedAt }`. Slots 0–4 are GK, DEF, DEF, MID, FWD; slots 5–6 are the bench. Everyone can read; each user writes only their own.
- `stats/<matchId>`: `{ played, hs, as, gk: { home, away }, ev: { <playerId>: { g, a, y, r } } }`. Owner only.
- `config/positions`: `{ map: { <playerId>: "GK" | "DEF" | "MID" | "FWD" } }`. Owner only.

Player ids are `<team-slug>--<name-slug>`, for example `sin-pulmon--diego-granados`.
