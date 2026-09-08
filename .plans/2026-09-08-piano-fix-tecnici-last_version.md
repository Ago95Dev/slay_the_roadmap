# Piano fix tecnici — da `last_version` a consegna (US-01..05)

Data: 2026-09-08. Partenza: worktree `/home/omalex/projects/slay_the_roadmap-collab`, branch `last_version` (HEAD `641fed8`).
Riferimenti: `ANALISI_E_PIANO.md` (verità di partenza), `docs/assignment/` (US esatte, sola lettura), fratello `/home/omalex/projects/slay_the_roadmap` (sola lettura, 243 test, NON copiare file).
Run: `flutter run -d linux`. Obiettivo: prima rendere l'app avviabile e sicura, poi conformarla all'assignment e consegnarla.

## Vincoli (da PROMPT_NUOVO_AGENTE.md, non negoziabili)

1. Una fase alla volta, in ordine 0→5. Fase 0 prima di tutto.
2. TDD: prima test che fallisce e riproduce il bug, poi fix, poi `flutter test` verde, poi `flutter build linux --debug`.
3. Niente nuove dipendenze senza dirlo; niente refactor estetici; meccaniche e numeri semplici.
4. Ogni deviazione dall'assignment va documentata (impatto su Evaluation) o rimossa.
5. Commit in italiano formato: `[Fase N] Titolo — Contesto / Cosa implementa / Verifica (analyze+test+build) / Prossimo`. Mai push senza via esplicito utente.
6. Mai committare segreti: credenziali Hub solo `--dart-define=HUB_USER/HUB_PASS` a runtime, mai in file. `gameId` e action pubblici per design.
7. Se istruzione contraddice test verdi o assignment → stop e chiedi.
8. Hub contratto NON rompere (ANALISI §4): game `6a9dbf66cc89679981fe7893`, `POST /executions {gameId,playerId,actionId,data}` snake_case, `quiz_completed {xp_amount:100, badge:<topic>}`, `boss_defeated {badge:<boss>}`, livelli 0/100/500, classifica `overall_xp`, fallback offline-first.

## Decisioni pre-avvio (2026-09-08, risposte utente)

- Timer 25s boss: RIMUOVI (Fase 2).
- Skip-che-sblocca-senza-XP: RIMUOVI (Fase 2, sblocco solo via quiz 80%).
- Branch lavoro: NUOVO branch da `last_version` (es. `fix/last_version-stabilize`), mai commit diretti su `last_version`.
- Hub/run: credenziali HUB_USER/HUB_PASS fornite dall'utente a runtime via `--dart-define`, mai in file; via libera a `flutter run/test/build` lunghi. Fase 0-1 comunque offline-first con FakeEngineClient.

## Fase 0 — Respira (P0, prima di tutto)

Contesto: `flutter run` parte ma `No Material widget found` x5 + timeout OpenGL, app inutilizzabile. `lib/main.dart:7-24` corretto, `utils/app_theme.dart:28-161` puro ThemeData (innocente).

Ipotesi ordinate (da analisi tecnica):
- H1 (alta): `providers/game_provider.dart:200-210` ctor lancia `_loadProgress()` async + `notifyListeners:306` durante primo build; `_skillTree` vuoto + `firstWhere(id=='start')` senza `orElse :296,302` → `StateError`.
- H2 (alta): OpenGL = ambiente Linux/VM senza GPU, non Dart. I x5 sono cascata dopo primo crash.
- H3 (media): InkWell scoperti veri solo in `widgets/topic_node.dart:28`, `widgets/compact_stats_bar.dart:36,216`, `screens/path_selection_screen.dart:191`. Gli altri (`quiz_screen:206`, `reward_selection:218`, `boss_fight:1080`) sono sotto Scaffold e vanno bene a runtime, ma esplodono in test senza MaterialApp.
- H4 (bassa): `context.watch` in `showDialog(builder:)` (`main_menu_screen:280`) + `ScaffoldMessenger.of(context)` in `auth_dialogs.dart:41` (context del Dialog senza Scaffold).

Passi:
1. `flutter run -d linux -v 2>&1 | tee /tmp/opencode/boot.log` → isolare PRIMA eccezione + stack (ignorare le altre 4, cascata).
2. `flutter doctor -v`; se VM riprovare `--enable-software-rendering`.
3. `flutter analyze` → 0 error (info tollerati, error no).
4. Fix: ctor solo sincrono (`_initializeRoadmap`), load async da `main()`/`FutureBuilder`/`addPostFrameCallback` con splash; `firstWhere(..., orElse:)` + guard; mai `notifyListeners` durante build; `WidgetsFlutterBinding.ensureInitialized()` in `main()`; wrap `Material` sui 4 InkWell scoperti.
5. Smoke test: `pumpWidget(MaterialApp(home: MainMenuScreen))` senza eccezioni (va in Fase 1 ma sblocca Fase 0).

DoD: boot pulito su linux, `analyze` 0 error, smoke verde. Commit `[Fase 0]`.

## Fase 1 — Rete di sicurezza (P0 processuale)

Contesto: `test/` = 4 dir con solo `.gitkeep`, zero `.dart`. Nessun gate su refactor. Seam già testabile: `lib/data/services/shared_preferences_persistence.dart:17` accetta overrides senza platform channel.

Test minimi prima di toccare logica (uno per US):
- US-01 gate roadmap: tap locked → SnackBar, no navigazione; unlock dopo prereq.
- US-02 quiz: soglia 80 (`domain/models/quiz.dart:7`, `models/types:654`, `constants:3`, uso live `quiz_screen:277`), submit bloccato senza risposta, sblocco auto dopo pass.
- US-03 reward: pick-1-of-3 (`reward_selection:74,106`), `claimedRewardTopics` (`shared_preferences_persistence:58-81`) impedisce re-claim, inventory cresce di 1.
- US-04 boss: HP10/player HP3 (`boss_repository:98-99,163-164`), turno quiz ±1 (enraged -2), soglie 75/50/25 (`constants:29-31`, `boss_fight.dart:52-73`), win/lose.
- US-05 save: roundtrip save/restore autosave + wipe con confirm (`shared_preferences_persistence:12-13,120-131`, `PlayerProgress.fromJson:408-410`).

DoD: `flutter test` verde, ogni fix futuro parte da test rosso. Commit `[Fase 1]`.

## Fase 2 — Conformità assignment (deviazioni + mancanti)

Contesto: meccaniche presenti ma con deviazioni non richieste e mancanti US. Sprint 1 = US-01/02/03 dentro, US-04/05 fuori-prototipo — il branch è già oltre Sprint 1, dichiararlo senza retrocedere.

Deviazioni (rimuovi o giustifica con impatto Evaluation):
- Timer 25s `boss_fight_screen:42-43,337,342` — non in US-04 né in piano F4. Togli o giustifica con dati usabilità/accessibilità.
- Skip-che-sblocca-senza-XP `game_provider:361-367` — aggira US-02 (sblocco via quiz 80%). Rimuovi o dichiara + misura uso skip.
- Doppio leveling: `player_progress:8-26 levelForXp` 0/100/500 (=Hub, tenere) vs legacy `skill_tree_data:570-572 100+level*100` + `_awardExperience:655-665`. Unifica su `levelForXp`. Numeri locali vs Hub `quizXpAmount:100 hub_config:22` → dichiara quale vede l'utente.
- Doppio modello Boss: `constants` + `boss_fight.dart` enrage vs `roadmap_data:44-46 thresholdPowers` — chiarisci path live, esponi HUD soglie.

Mancanti:
- US-02 badge locale: oggi solo eventi Hub (`game_provider:408-411,712-714`). Aggiungi collection locale o dichiara Hub-only.
- US-03 enforce 1/topic in UI: contratto `persistence_repository:14-16` ok ma `quiz_screen:292-296,376-388` non controlla il set → guard + test. Preview oltre descrittiva o marca mancante in GamiDOC.
- US-04 victory: `boss_fight:1290-1309` solo Continue, retry `576-582` full-heal gratis `1311-1340`. Aggiungi claim 1 reward + sblocco capitolo + badge in vittoria; retry con conseguenze (senza XP) in sconfitta.
- US-01 highlight opz/obbl + click-expand da provare su device.
- Streak bonus (`player_progress:16-18,40-44`) verificare cablaggio prima di citarlo.

DoD: walkthrough offline filmabile Home→Roadmap→Topic→Quiz→Reward→Boss win/lose→Continue; `analyze`+`test`+`build` verdi. Commit `[Fase 2]`.

## Fase 3 — Utenti (auth + save per utente)

Contesto: auth e save vanificano ownership (CD4) e inquinano classifica.

- Auth `storage_service:46-59`: SHA-256 senza salt + fallback `savedPwd==password :58`. Fix: salt random 16B per utente (`salt$sha256(salt+pwd)`, chiave `user_pwd_v2_`), al login se match v1-plaintext → re-hash v2 + cancella v1; mai fallback permanente; valutare `flutter_secure_storage`. Test login/migrazione.
- Save: `dart_quest_progress storage:6 + constants:64` e `slay_save_v1 persistence:13` entrambi globali; `logoutUser` rimuove solo `current_user`. Fix: chiave per utente (`dart_quest_progress_<username>`), reload+notify a login, clear in-memory a logout. Test 2 utenti isolati.
- `playerId` Hub: oggi username in chiaro `game_provider:982-986,1003` → usa `slay_<uuid>` stabile (cfr `hub_setup.md:17-35`).

DoD: 2 utenti non si sovrascrivono, login richiesto, chiare invalidate. Commit `[Fase 3]`.

## Fase 4 — Igiene (duplicati, artifact, pubspec)

Verificato: risolti `config/hub.dart`, `lib/ui/`, orfani root. Restano:
- `git rm --cached` 138 path artifact (`src/build/`, `.so`, `linux/flutter/ephemeral/`, `.cache.dill.track.dill`) + estendi `.gitignore` (`src/build/`, `ephemeral/`, `*.backup`).
- `git rm pubspec.yaml.backup` (staled: `get_it`, `flutter_lints ^2.0.0` vs `^3.0.0`; `shared_preferences ^2.2.2` uguale → nessun downgrade da riconciliare).
- Decidi se tenere `data/services/shared_preferences_persistence.dart` come seam testabile o consolidare in `services/` (un solo file, non duplicato top-level).
- Cherry-pick dal fratello solo se serve, mai copia file interi.

DoD: `git ls-files` pulito, `analyze`+`test`+`build` verdi da clone fresco (`pub get`→...). Commit `[Fase 4]`. NON toccare `hub_config.dart`, `engine_client.dart`.

## Fase 5 — Docs esame

- GamiDOC (concept/target/meccaniche/architettura; oggi solo bozza legacy `docs/legacy/Gamidoc*` + Octalysis 169): numeri reali (80%=4/5, HP10/3, soglie, livelli 0/100/500), deviazioni dichiarate, future-work (shop/coins, classi).
- Evaluation 5 utenti (think-aloud + SUS/IMI/GEQ), README run, video 3-5min, Sprint 1 reale + Sprint 2 + ruoli.
- Dry-run consegna E5 da clone fresco.

## Rischi

- R1 Hub down/credenziali → fallback locale + `FakeEngineClient`, video girabile offline.
- R2 Save parziale → spec Save v1 + test restore.
- R3 Scope creep → ogni proposta fuori US va in future-work, mai nel codice.
- R4 HUD incoerente → unica fonte `PlayerProgress.levelForXp`.
- R5 Flake widget paralleli → stabilizzare con delay virtuali.

## Milestone

| M | DoD | Sblocca |
|---|---|---|
| M0 boot | run pulito + analyze 0 + smoke | fix logici |
| M1 rete | test US verdi | conformità |
| M2 conforme | walkthrough offline filmabile | utenti/igiene |
| M3 utenti+igiene | 2 utenti isolati + repo pulito | docs |
| M4 docs | 5 deliverable coerenti | consegna |
