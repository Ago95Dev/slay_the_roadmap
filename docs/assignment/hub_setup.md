# Hub setup — Slay The Code (F7, parte console: FATTA)

- Console: https://gamification-webapp.createlab-univaq.it
- Game: **Slay The Code** — `gameId = 6a9dbf66cc89679981fe7893` — owner `slay`
- API: https://gamification-api.createlab-univaq.it/api/v1 (Swagger `/swagger-ui/index.html`)

## Risorse create (2026-09-06, via API + validate)

- Actions: `quiz_completed`, `claim_reward`, `boss_defeated`
- PointConcept: `xp` (all-time, senza periods)
- Level: `experience` su `xp` — Level 1: 0, Level 2: 100, Level 3: 500 (stesse soglie app F6)
- Badge collection: `slay_badges` (visible, creata vuota; i badge li assegnano le rule)
- Rules (validate OK, create): `quiz_xp`, `topic_badge`, `boss_badge` (salience -10 per le badge)

## Contratto eventi (l'app deve inviare ESATTAMENTE così)

```json
POST /api/v1/executions
{"gameId": "6a9dbf66cc89679981fe7893", "playerId": "<id>", "actionId": "quiz_completed",
 "data": {"xp_amount": 100, "badge": "dart_basics"}}

POST /api/v1/executions
{"gameId": "6a9dbf66cc89679981fe7893", "playerId": "<id>", "actionId": "boss_defeated",
 "data": {"badge": "syntax_guardian"}}
```

- `data` sempre presente (anche `{}`); chiavi snake_case (`xp_amount`, non `xpAmount`).
- `quiz_completed` si invia SOLO se passato (soglia 80% verificata in app).
- `boss_defeated` aggiunge +100 XP lato Hub + badge.
- Auth: `POST /api/v1/auth {username, password, origin: "GAME"}` → Bearer 24h (`Authorization: Bearer <token>`). Credenziali MAI nel repo: a runtime via `--dart-define`, con fallback offline.
```bash
flutter run -d linux --dart-define=HUB_USER=slay --dart-define=HUB_PASS='<password>'
```
Senza define, nessuna chiamata di rete (Fake/offline).
- `playerId`: id libero scelto dall'app (es. `slay_<uuid>` salvato in SharedPreferences); auto-creato al primo evento.

## Verifica E2E (player test_slay/test_slay2, poi cancellati)

- quiz `{xp_amount:100, badge:dart_basics}` → xp 100, badge `dart_basics` in `slay_badges`, level `Level 2`.
- boss `{badge:syntax_guardian}` → xp 200 (+100 bonus), level `Level 2`.
- Stato letto da `GET /games/{id}/players/{pid}` (badge in chiave `badges`).

## Classifica (voce D)

- Classification `overall_xp` (GENERAL su `xp`, cron lun 8:00): `GET /games/{id}/classifications/overall_xp/board` → `{board:{content:[{position,playerId,score}]}}` (verificata con dati reali).
- App: `EngineClient.getLeaderboard()` best-effort + schermata con stati vuota/offline.

## Resta per F7 (lato app)

`EngineClient` + `FakeEngineClient`, login a runtime, chiamate best-effort in quiz/boss viewmodel, `gameId` in config.
