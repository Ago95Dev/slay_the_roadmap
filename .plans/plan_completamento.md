# Piano di completamento — Slay the Roadmap (v2, scope ridotto)

Obiettivo: da P0 a consegna esame implementando **solo** US-01..05 dell'assignment e le meccaniche del nostro GamiDOC (dungeon-crawler deck-building). Niente feature extra. Team 2 persone, stima ~8-10 giorni effettivi.

## Stato avanzamento (aggiornato 2026-09-06)

- [x] F1 gate roadmap + single path Dart (`fa540af`) — gate locked con SnackBar, morti rimossi, test 11/11
- [x] F2 detail 12/12 + risposta obbligatoria + hint (`47d9575`) — test 19/19
- [x] Fix completamento quiz→topic (`2423c38`) — bug critico: QuizResult scartato, nessun topic si completava; regression test, 20/20
- [ ] F3 reward pick-1-of-3 ← PROSSIMO
- [ ] F4 boss fight completo
- [ ] F5 autosave
- [ ] F6 HUD + livelli
- [ ] F7 Hub minimo
- [ ] F8 docs esame

## §0 — Convenzione commit (obbligatoria a fine fase/sottofase)

Ogni commit in italiano, esplicativo anche di cosa verrà dopo:

```
[Fase N] Titolo breve in italiano

Contesto: perché questo lavoro (US-XX / GamiDOC § / debito noto)
Cosa implementa: file toccati + comportamento ottenuto
Verifica: comandi lanciati ed esito (analyze / test / build)
Prossimo: cosa resta fuori e quale fase/sottofase lo copre
```

## §1 — Scope IN: solo queste 8 feature

| ID | Feature (US / GamiDOC §) | Acceptance | File coinvolti |
|---|---|---|---|
| F1 | Roadmap con gate (US-01) | Tap su topic `locked` bloccato con messaggio; rimosso `_startQuiz` morto e bottone quiz morto; via Option2 (single path Dart) | `roadmap_screen`, `roadmap_view_model`, `roadmap_selection_screen` |
| F2 | Topic + quiz completi (US-02) | Detail reali 12/12 (via placeholder); unico ingresso quiz (AppBar); submit bloccato senza risposta (mai più `null→0`); feedback immediato (già ok); dopo 2 errori sulla stessa domanda mostra `explanation` (campo già esistente = hint) | `topic_detail_repository`, `topic_detail_screen`, `quiz_screen`, `quiz_view_model` |
| F3 | Reward pick-1-of-3 (US-03) | Schermata scelta 1 su 3 con preview effetti; limite 1/topic; inventory visibile (`maxSlots 20` già); `isSelected` cablato | `quiz_screen`/`boss_fight_active_screen`, `reward_repository` (oggi mai chiamato), `reward.dart` |
| F4 | Boss fight (US-04) | Energia 3/turno (1 per carta); HP 100 vs boss 150/200/250; quiz obbligatorio a fine turno (giusta = danno `round(%/10)`, errata = danno player); soglie 25/50/75 cambiano mosse boss (già); schermata vittoria (claim 1 reward + sblocco capitolo + badge) / sconfitta (retry full HP, **senza XP** = tentativi illimitati ma penalizzati); deck = reward guadagnate (oggi `[]`) | `boss_fight_view_model`, `boss_fight_active_screen`, `boss_fight.dart` |
| F5 | Autosave (US-05) | `Save v1 {completedNodes, deck, xp, level, bossUnlocks}`; `Continue` ripristina, `New Run` wipe+confirm, Reset in Settings minima; fix `fromJson` (oggi perde `adaptiveQuizzes`) | `persistence_repository` (+ implementazione `shared_preferences`), `player_progress`, `home_screen` |
| F6 | HUD unico + livelli | XP bar + Level con soglie **L1 0 / L2 100 / L3 500** (stesse dell'Hub, così locale e remoto coincidono); vite/energia visibili nel boss | `player_progress` (level-up oggi assente), `home/roadmap/boss` HUD |
| F7 | Hub minimo | Game su console + Point `xp` + badge collection (`topic_badge`, `boss_badge`) + 3 rule (`quiz_pass`, `unlock`, `boss_defeat`); `EngineClient` (`POST /auth` + `POST /executions`) con `FakeEngineClient` offline; `gameId` canonico in `env` + README | nuovo `data/services/engine_client.dart`, `quiz/boss_view_model` (chiamate best-effort) |
| F8 | Docs esame | GamiDOC finale, User Evaluation 5 utenti, README run, video 3-5min, Sprint1 reale + Sprint2 + ruoli | `docs/` |

## §2 — Scope OUT: tagliati (dichiarati nel GamiDOC come future work)

Leaderboard/social/share/deck-code, shop/coins, classi, coop/PVP, login/signup (playerId locale fisso), roadmap extra, profilo/achievements avanzati, eventi testuali random, branching campagna, difficoltà adattiva oltre le soglie, monthly quest/login reward, animazioni extra. Voci mockup M1 Sign-in e M2 Option2: rimosse o disattivate prima di valutazione e video.

## §3 — Fasi e DoD

- **Fase 1 — Core offline (~4g)**: F1→F6 in ordine. DoD: walkthrough completo filmabile **senza rete** (Home→Roadmap→Topic→Quiz→Reward→Boss win/lose→Continue); `analyze` 0 error, `test` verdi (nuovi test reward/save/boss/livelli), `build linux` ok. Commit a ogni sottofase F1..F6.
- **Fase 2 — Hub (~1.5g)**: F7. DoD: con rete XP/badge da Hub, senza rete app identica (fallback); `gameId` unico documentato.
- **Fase 3 — Docs (~2.5g)**: F8. DoD: 5 deliverable coerenti con numeri reali (80%=4/5, HP, soglie, soglie livello).
- **Fase 4 — Consegna (0.5g)**: dry-run da clone fresco (`pub get`→`analyze`→`test`→`build`→demo) + checklist E5.

## §4 — Rischi

- R1 Hub down/credenziali → fallback locale già in Fase 1, video girabile offline.
- R2 Save parziale → spec `Save v1` + test restore in F5.
- R3 Scope creep → ogni proposta fuori §1 va in §2 (future work), mai nel codice.
- R4 HUD incoerente → F6 unica fonte `PlayerProgress`.
- R5 Test widget flaky in suite parallela (osservato 1 flake su regressione quiz) → se ricapita, stabilizzare con delay virtuali prima della consegna.

## §5 — Milestone

| Milestone | DoD | Sblocca |
|---|---|---|
| M1 offline | demo senza rete + test verdi | video bozza, valutazione |
| M2 hub | XP/badge remoti + fallback | gamification esterna |
| M3 docs | 5 deliverable coerenti | consegna |
