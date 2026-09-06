# 03 — Piano di completamento Slay the Roadmap

Obiettivo: da P0 (build verde offline) a consegna esame. Team 2 persone. Stima totale ~10-12 giorni effettivi.

## Principi
1. Prima giocabile offline (filmabile anche senza rete), poi Hub reale con fallback.
2. Ogni fase chiude con comando verificabile. Niente fase successiva se la precedente è rossa.
3. I 5 deliverable restano coerenti allo stato finale (regola esame).
4. Tagli dichiarati subito se il tempo stringe (vedi §6), mai a sorpresa nel video.

## Fase 0 — Consolidamento (0.5g) — DoD: repo pulito
- Commit P0 + docs/ riordinata (`git add lib test docs/assignment docs/README docs/*.pdf docs/src docs/assets; commit`).
- Decidi e annota in `02_stato.md`: `shared_preferences/get_it` rientrano solo in Fase 1 (save), `go_router` NO (resta Navigator.push).
- DoD: `flutter analyze` 0 error, `flutter test` 7/7, `flutter build linux` ok, `ls docs/*.pdf` 3 file.

## Fase 1 — Giocabile offline (3-4g) — DoD: video filmabile senza rete
Obiettivo: US-01..05 dimostrabili in locale, anche se XP/level ancora finti.
1. **Reward UI (1g)** — `quiz_screen` + `boss_fight_active_screen:419`: pick-1-of-3 con preview effetti, `isSelected`, vincolo 1/topic, inventory visibile (usa `reward.dart`, `reward_repository take(3)`, `PlayerInventory maxSlots 20`). Chiude TODO victory (oggi solo `pop`).
2. **Save/restore (1g)** — `flutter pub add shared_preferences` (+ `get_it` solo se serve), `PersistenceRepository` implementato, autosave dopo quiz/boss/topic, `Continue` + `New Run` con confirm in `home_screen`, fix `player_progress fromJson` (oggi perde `adaptiveQuizzes`). Test restore.
3. **Contenuti + HUD (1g)** — `topic_detail_repository` da 5/12 a 12/12 (togli placeholder), HUD unico XP/Level/cuori/energia (oggi M3 vs M7 incoerenti), `_startQuiz` morto e `_buildQuizButton onPressed` vuoto: o collega o elimina.
4. **Bilanciamento (0.5g)** — tabella pubblica in specifica: costi 1-3, danni carta `15+damage`, danno quiz `round(%/10)`, boss 150/200/250 vs player 100, heal 15, soglie 25/50/75 solo visive + log. Verifica che nessuna carta costi 9 con energia 4/5.
- DoD: `flutter test` (aggiungi quiz/boss/save) verde, walkthrough Home→Path→Roadmap→Topic→Quiz→Reward→Boss→Win/Lose filmabile offline.

## Fase 2 — Hub reale (2-3g) — DoD: XP/badge da servizio esterno
Prerequisito: account Hub + gioco creato da console (non in app).
1. **Setup Hub (0.5g)** — console `gamification-webapp.createlab-univaq.it`: game, actions (`quiz_completed, claim_reward, play_card, boss_quiz_answer, boss_defeated, boss_lost, unlock_area`), Point `xp` + Levels `experience` (0/100/500), badge collection (almeno `variables_badge, mid_boss_badge`), 5 rule Drools minime con `/rules/validate` (snake_case, salience badge dopo punti).
2. **EngineClient (1g)** — `package:http`, `POST /auth {origin:GAME}` Bearer 24h + `POST /executions {gameId,playerId,actionId,data:{}}` (data sempre presente). `FakeEngineClient` fallback offline: HUD/XP sempre da store locale, sync best-effort. `playerId` locale (M1 sign-in = stub o rimosso).
3. **Cablaggio (1g)** — quiz pass → `quiz_completed {score,passed,xpAmount}`, reward → `claim_reward {card_id}`, boss → `play_card/boss_defeated {damage}`. Nessun setter diretto punti/badge (solo eventi → regole).
- DoD: con rete, XP/livelli/badge arrivano da Hub; senza rete, app gira uguale (dati locali). `gameId` canonico in `lib/env.dart` + README (chiude discrepanza README vs Postman).

## Fase 3 — Docs esame (3g) — DoD: 5 deliverable coerenti
1. **GamiDOC finale (1g)** — parte da `docs/gamidoc.pdf`: aggiungi Architettura reale (rimanda a `specifica.pdf`, niente duplicati), engine Hub (endpoint + mapping actionId), persistenza, KPI/analytics, limiti. Dichiara tagli (leaderboard `?`, TITLE vs Level, Coins/shop, Coop/PVP) come scelte.
2. **User Evaluation (1-1.5g)** — protocollo Bassanelli: 5 autodidatti principianti, task Path→Topic→Quiz→Boss, think-aloud + questionario (SUS + engagement/motivazione), tabella success rate/tempo/citazioni + 3 riflessioni + fix applicati. Senza questo il deliverable 2 è nullo.
3. **README + Sprint + video (0.5-1g)** — README (descrizione, `pub get/run -d linux`, gameId demo, link video), Sprint1 reale + Sprint2 + ruoli D'Agostino/Di Giacomo + retro, video 3-5min (problema 30s, demo offline 2-3min, meccaniche Octalysis/Toda/Hub 60s). Registra solo ciò che Fase 1-2 ha reso cliccabile.

## Fase 4 — Consegna (0.5g) — DoD: checklist E5 verde
- Coerenza GamiDOC ↔ codice ↔ video ↔ README (stessi numeri: 80%=4/5, HP, soglie, XP).
- Dry-run: clone fresco → `pub get` → `analyze` 0 error → `test` verde → `build` ok → demo 5 min senza rete + 5 min con Hub.
- Consegna secondo `EGS_Exam_Deliverables.pdf` + link repo/video.

## Rischi e mitigazioni
- R1 Hub irraggiungibile/credenziali → fallback locale sempre, video offline pronto.
- R2 Soglia 80% ambigua → 5 domande/topic, `pass = percentage>=80` (già così dopo P0).
- R3 Save parziale → spec `Save v1 {completedNodes, deck, xp, bossHp, energy, hearts}` + test restore.
- R4 Scope creep (Option2 path, login/settings, leaderboard) → stub `ComingSoon` esistenti: o implementi stub vero o rimuovi voce prima di valutazione/video.

## §6 — Tagli accettabili (se tempo corto, in ordine)
1. Taglia Option2/secondo path (resta solo Dart/Flutter).
2. Taglia login/signup (playerId locale fisso).
3. Taglia leaderboard/classifiche Hub (resta XP/badge/livelli).
4. Taglia animazioni/audio/custom estetici (resta dark fantasy minimale).
5. NON tagliare mai: quiz 80%, reward 1/3, boss win/lose, save, video demo reale.

## Milestone riepilogo
| Milestone | DoD | Sblocca |
|---|---|---|
| M0 repo pulito | analyze/test/build verdi | Fase 1 |
| M1 offline giocabile | demo senza rete filmabile | video bozza |
| M2 Hub reale | XP/badge da API + fallback | gamification vera |
| M3 docs | 5 deliverable coerenti | consegna |
