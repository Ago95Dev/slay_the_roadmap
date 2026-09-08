# Piano Hub fix — allineamento app↔engine (US-02/03/04 + classifica)

Data: 2026-09-08. Branch: `fix/last_version-stabilize` (già pushato, restarci; mai commit su `last_version`, mai push senza via).
Base: gap analysis Hub 2026-09-08 (contratto `docs/assignment/hub_setup.md`, game `6a9dbf66cc89679981fe7893`, 3 action + livelli 0/100/500 + board `overall_xp`).
App collegata: bundle locale rebuildato con `--dart-define=HUB_USER/HUB_PASS` (solo runtime, mai nel repo).

## Parere motore (domanda utente: creare le action extra nell'engine?)

Ha senso come idea (daily_login, skill_unlocked, relic_acquired, dungeon_cleared, study_resource_viewed arricchirebbero davvero la gamification), ma **non ora**: il game è condiviso ("Slay The Code") — nuove rule con XP gonfierebbero la classifica solo per i nostri utenti e toccherebbero un backend condiviso in fase di stabilize. Decisione: lato app **disattivo gli invii extra** (codice resta, un guard li blocca + log), e documento la proposta engine (actionId, xp, rule Drools) come appendice future-work nel GamiDOC. Se dopo la consegna vuoi, la implementiamo sul engine in un secondo momento.

## Decisioni utente (2026-09-08)

- Numeri XP: ALLINEA (quiz 100 = `quizXpAmount`, boss 100; HUD e Hub coincidono).
- Eventi extra: disattiva invio + proposta engine documentata (vedi sopra).
- Badge remoti in card Hub: MOSTRA.
- Test: COMPLETI con mock HTTP (shape payload, board parse, 401/retry, claim/boss wiring).

## Vincoli (dagli altri piani)

TDD (rosso→fix→verde), `flutter analyze` 0 error, `flutter test` tutto verde, `flutter build linux --debug` ok, commit `[Hub N]` in italiano, niente nuove dipendenze, niente refactor estetici, contratto esistente non rompere (snake_case, `xp_amount`, `data:{}` default, best-effort mai throw).

## Fasi

### H1 — Eventi extra disattivati (non rotti, non rumorosi)
Dove: `game_provider.dart` invii `daily_login:174`, `study_resource_viewed:603`, `dungeon_cleared:771`, `skill_unlocked:665`, `relic_acquired:908` (e simili fuori contratto).
Cosa: singolo guard `_isHubActionAllowed` (allowlist = 3 action da `hub_config.dart`) in `_hubEvent`; extra bloccati con `debugPrint` esplicito (non errore). Reward/skill/relic locali invariati.
Test: invio extra → nessun HTTP (mock), log atteso; 3 action passano.
Verifica: analyze+test+build. Commit `[Hub 1]`.

### H2 — `claim_reward` dal pick-1-of-3
Dove: `claimRewardTopic:86-92` + `reward_selection_screen.dart:156`.
Cosa: invia `claim_reward` con `{badge/topic, rewardId}` come `_processReward:893-897`; idempotente (guard 1/topic già esistente).
Test: claim → payload shape corretta; re-claim → nessun secondo invio.
Commit `[Hub 2]`.

### H3 — Numeri allineati (decisione: allinea)
Dove: quiz `game_provider:529` (`50+score*10`), boss `constants.dart:21` + `game_provider:875` (150).
Cosa: locale = Hub: quiz pass → +100 XP (`hub_config quizXpAmount`), vittoria boss → +100 XP. Aggiorna costanti/commenti, HUD invariata (già su `levelForXp`).
Test: valori attesi 100/100; livelli 0/100/500 invariati.
Docs: `02_stato.md` nota allineamento. Commit `[Hub 3]`.

### H4 — `boss_defeated` anche senza nodo
Dove: `defeatBoss:864-888` ramo else.
Cosa: invia sempre `boss_defeated {badge:<bossId>}`; badge/sblocco locali solo se nodo presente.
Test: boss senza nodo → evento inviato, nessun crash, nessun unlock fantasma.
Commit `[Hub 4]`.

### H5 — Badge remoti nella card Hub
Dove: `hub_profile_card.dart:105-111` (oggi solo LIVELLO+PUNTEGGIO; chiave `badges` da `hub_setup:41`).
Cosa: legge `badges` da `getPlayerState`, mostra chip (empty-state se assenti); offline → `SizedBox.shrink` invariato; GET fallita → "Dati non disponibili" invariato.
Test widget: state con badge → chip visibili; senza → empty.
Commit `[Hub 5]`.

### H6 — Osservabilità (stato reale + log successi)
Dove: `engine_client.dart` (login/execute/board/player), `game_provider.dart:24 isHubOnline`.
Cosa: `debugPrint` su successo (action + HTTP 200) come già sui fallimenti; `isHubOnline` diventa reale dopo primo contatto riuscito (stato interno, default falso→ come oggi finché non prova).
Test: mock 200 → flag true + log; 401/rete → false + fallback.
Commit `[Hub 6]`.

### H7 — Test Hub completi (mock HTTP)
Dove: `test/hub_engine_test.dart` nuovo (riferimento fratello `f7_hub_test.dart`, sola lettura, non copiare).
Cosa: login shape (gameId/Bearer), payload shape `gameId/actionId/data` + `data:{}` default, parse board/entries, offline (no HTTP), 401 → re-login/retry, wiring quiz+boss+claim.
Commit `[Hub 7]`.

### H8 — Docs
`02_stato.md` (numeri finali + divergenze residue zero), GamiDOC note (eventi attivi, proposta engine appendice: actionId/xp/rule per daily/skill/relic/dungeon/resource), `04_evaluation.md` +1 KPI (coerenza XP HUD vs Hub percepita).
Commit `[Hub 8]`.

## Rischi

- R1 Engine condiviso: nessuna modifica server in questo piano (solo app) → classifica altrui intatta.
- R2 Allineamento XP cambia bilanciamento locale (quiz 100 vs prima 90 ca.): livelli 0/100/500 invariati, progressione leggermente più veloce — accettato con decisione Allinea.
- R3 Credenziali solo runtime: ogni rebuild/run con Hub richiede i `--dart-define`; senza, Fake offline (video-safe).

## Milestone

| M | DoD |
|---|---|
| MH1 silenzioso | zero 404 extra, 3 action invariate |
| MH2 eventi completi | claim/boss sempre inviati, shape ok |
| MH3 numeri veri | HUD = Hub (100/100) |
| MH4 osservabile | log successi + stato reale + badge visibili + test mock verdi |
