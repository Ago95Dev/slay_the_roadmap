# Analisi branch `last_version` — stato, errori tecnici, gamification, piano consegna

Data: 2026-09-08. Branch: `origin/last_version` (HEAD `641fed8`), worktree: `/home/omalex/projects/slay_the_roadmap-collab`.
Obiettivo: consegnare il progetto secondo l'assignment EGS_assignment2 (US-01..05, Sprint 1 = US-01/02/03).
Riferimento assignment: `/home/omalex/projects/slay_the_roadmap/docs/assignment/` (US esatte) — il main lì ha già copertura completa e testata, utile come confronto.

## 1. Errori tecnici (bloccanti prima)

1. **Crash all'avvio `No Material widget found` ×5 + timeout OpenGL** (log `flutter run -d linux`, build `641fed8`). App non utilizzabile. Entry `lib/main.dart` ha MaterialApp corretto → sospetti: dialog/widget con InkWell fuori da Material nel boot (menu/gothic), init del `GameProvider`, tema custom `utils/app_theme.dart`. Da riprodurre con log completo e stack della PRIMA eccezione.
2. **Suite test cancellata**: `test/` contiene solo cartelle vuote; cancellati ~14 file (~8.600 righe) + `widget_test.dart` era già rotto (template counter su `MyApp` inesistente). Zero rete di sicurezza: ripristinare smoke + regression per US prima di toccare logica.
3. **Auth insicura**: `lib/services/storage_service.dart` — SHA-256 senza salt + fallback che accetta le vecchie password in chiaro (`savedPwd == password`). Entrambe da rimuovere: solo hash+salt, migrazione che invalida le chiare.
4. **Save unico globale** (`dart_quest_progress`): cambio utente non cambia progressi. Serve save per utente (minimo) prima di parlare di profili.
5. **Duplicati residui da verificare**: `config/hub.dart` vs `hub_config.dart`, `services/` vs `data/services/`, `screens/` vs `ui/` morta, file orfani in root (`engine_client_main.dart`, `topic_node.dart`), `pubspec.yaml.backup`, downgrade `shared_preferences`/`http` da riconciliare.
6. **Build artifact committati** (~138 path: `.so` 40MB, `ephemeral/`, `src/build/`): `git rm` + `.gitignore`, MAI più in repo.

## 2. Gamification: cosa c'è e come (lenti Octalysis/Toda/GamiDOC)

| Elemento (corso) | Stato nel branch | Come / nota |
|---|---|---|
| CD2 Accomplishment (XP/livelli/sblocchi) | ~ parziale | XP e sblocco nodi ci sono; soglie livelli da verificare; skill-tree con skip-che-sblocca-senza-XP devia dall'US |
| CD3 Empowerment (deck/strategie) | ~ parziale | Carte + reward selection presenti; limiti/preview da confermare su device |
| CD4 Ownership (inventory/save) | ✗ debole | Inventory sì, ma save unico vanifica il possesso per-utente |
| CD8 Loss (tensione quiz, penalità) | ✗ debole | **Timer 25s** non richiesto (rischio usabilità/valutazione); penalità retry non trovate |
| CD6 Scarcity (boss-gate) | ~ | Boss finali presenti nei dati (10HP); gate da verificare |
| CD7 Unpredictability | ~ | Mosse random + enrage a soglie (superset interessante, tenere) |
| CD1 Meaning (lore/narrativa) | ~ | Dialoghi presenti (punto di forza relativo); manca arco intro→finale |
| CD5 Social | ✗ | Widget classifica Hub senza hint offline; niente altro |
| Toda Levels/Streaks/Avatar | ~ | Costanti presenti, daily ok; streak/avatar wiring da verificare |
| Toda Leaderboards/Coins/Classi | ✗ | Solo widget classifica; resto assente (ok se dichiarato) |
| Quiz 80% + badge + soglie boss 25/50/75 | ✗ da provare | Soglia nei dati; badge completamento e soglie HP non trovati nel path live |

## 3. Piano per la consegna (ordine)

1. **Fase 0 — Respira**: fix crash avvio (root cause, non pezze) + `flutter analyze` 0 error + smoke test che apre menu senza eccezioni.
2. **Fase 1 — Rete di sicurezza**: ripristina test minimi per US-01..05 (threshold 80, unlock, reward limite, boss win/lose, save/restore) prima di ogni refactor.
3. **Fase 2 — Conformità assignment**: rimuovi/giustifica deviazioni (timer, skip-senza-XP) OPPURE documentale come scelte con impatto su Evaluation; implementa badge, soglie, reset mancanti.
4. **Fase 3 — Utenti**: hash+salt (via chiare), save per utente, login richiesto.
5. **Fase 4 — Igiene**: duplicati, artifact, pubspec; cherry-pick dal main solo se serve.
6. **Fase 5 — Docs esame**: GamiDOC sezioni (concept/target/meccaniche/architettura), Evaluation 5 utenti, README run, video 3-5min, sprint+ruoli.

## 4. Contratto Hub (NON rompere)

Game condiviso `6a9dbf66cc89679981fe7893` ("Slay The Code"). Eventi snake_case via `POST /executions {gameId,playerId,actionId,data}`; `quiz_completed {xp_amount:100, badge:<topic>}`, `boss_defeated {badge:<boss>}`; livelli 0/100/500; classifica `overall_xp`. Credenziali MAI nel repo (`--dart-define=HUB_USER/HUB_PASS`); playerId stabile per utente (l'username in chiaro inquina la classifica condivisa).
