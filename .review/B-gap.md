# B) Gap per categoria

## B1. Codice (blocca build e completezza)
1. **Dipendenze mancanti (P0)**: aggiungere `shared_preferences` + `get_it` in `pubspec.yaml` oppure rimuovere `shared_preferences_service.dart` + `setup_locator.dart`. Oggi 4+4 error.
2. **Widget quiz rotto (P0)**: `ui/widgets/quiz/quiz_questions.dart:21,57` usa `selectedAnswer`/`submitQuizResults` inesistenti. O allineare `Quiz/QuizRepository` o eliminare il file e usare solo `quiz_screen.dart`.
3. **Test rotto (P0)**: `test/widget_test.dart` cerca counter `"0"/"1"` ma app monta `HomeScreen`. Riscrivere smoke su `HomeScreen` + unit `percentage/passed 80%` + boss damage + save/restore. `test/data|domain|ui|utils/` e `testing/` vuote.
4. **Dati quiz incompleti (P0)**: solo 3 quiz; roadmap ha 9 subtopics → 6 topic con `throw:159`. Servono 5 domande per topic per rendere 80% = 4/5 esatto (3 domande → 2.4 ambiguo).
5. **Reward senza UI (P1)**: implementare pick-1-of-3 con preview + `isSelected` + vincolo 1 + inventory visibile; chiudere TODO `boss_fight_active:422-423`.
6. **XP/level/badge finti (P1)**: `+100xp` in-memory, `level=1` mai incrementato, badge solo label. Cablare `PlayerProgress` ai VM e mostrare in HUD (oggi HUD incoerente tra schermate).
7. **Duplicati legacy (P1)**: rimuovere `models/roadmap_models.dart`, `services/roadmap_service.dart`, `widgets/`, `ui/view_model/` oppure documentare perché restano. Riducono `analyze` e confondono GamiDOC/architettura.
8. **Qualità (P2)**: 159 issue (`prefer_const`, `avoid_print`, `withOpacity`/`groupValue` deprecati su Flutter 3.47.2, `use_build_context_synchronously`, `library_private_types`). `_startQuiz roadmap_screen:55` inutilizzato.

## B2. Engine polyglot (assente, richiesto per gamification reale)
1. **GameId/auth non fissati**: README `695bf66160d8fa02e0c31013` + pwd `0iiOCxv14qUo` vs Postman `6930249860d8fa02e0c3100d` + pwd `RCtO867ww.d` + ID storici nel body. Verificare con `GET /gengine/state/{id}?size=100`.
2. **Nessun client HTTP**: aggiungere `http`/`dio`, `EngineClient` con `FakeEngineClient` fallback offline (aula senza rete = demo morta).
3. **Dashboard da creare**: Point `xp` (weekly+Daily obbligatori), levels `experience` (0/100/500), badge collection (almeno `variables_badge`, `mid_boss_badge`, carte se modellate come badge), 5 rule Drools minime (`quiz_pass_threshold_80`, `unlock_on_quiz_passed`, `reward_claim_once`, `boss_defeat`, `boss_damage`), `snake_case`, una-rule-per-file.
4. **Octalysis/Toda da chiudere**: CD mapping noto (US-01 CD2+CD3, US-02 CD2+CD8, US-03 CD3+CD4, US-04 CD6+CD7, US-05 CD4). Foglio Slay elenca Levels/Streaks, Leaderboards(?), Avatar, Hearts/Energy/Cards/Skills/XP, custom path, progress bar; gap dichiarati Titles, Coop/PVP, Classes, Coins/shop, External Badges, Special animations. Decidere Leaderboard sì/no e TITLE vs Level prima di GamiDOC.

## B3. Docs (tutti e 5 i deliverable sono a 0/bassa)
1. **GamiDOC**: sezioni richieste concept+obiettivi, target, meccaniche/dinamiche, architettura. Architettura deve mostrare Flutter+Provider+repo locali + (futuro) `POST /gengine/execute` + save locale; dichiarare duplicati rimossi e soglia 80% su 5 domande.
2. **User Evaluation**: metodo Bassanelli (think-aloud/observation + questionario UX usability/engagement/motivation, scale/item corretti, limiti). Task M: pick path → leggi topic → quiz → boss. Senza, deliverable 2 vuoto.
3. **Sprints/Group**: Sprint1 dichiarato US-01..03 ma codice oltre Sprint1 (boss presente) e US-05 assente → riscrivere board reale + Sprint2 (save+engine+reward UI) + ruoli D'Agostino/Di Giacomo.
4. **README**: stock generico. Servono descrizione Slay, `flutter pub get/run -d linux`, gameId canonico, credenziali demo, link video.
5. **Video 3-5min**: problema+idea / live demo / meccaniche. Oggi filmabile solo locale; senza rete mostrare fallback.

## B4. Processo
- Allineare Sprint1 backlog (US-01 M, US-02 L, US-03 M) allo stato reale: US-01 ok, US-02 dati parziali, US-03 senza UI, US-04 extra-Sprint1 già presente, US-05 da fare.
- Decision log mockup: Option2 path, TITLE vs Level, costo/energia, scudo, hint OPT, lock (quiz basta o serve boss?), `Continue` cosa ripristina, `Sign in` serve davvero.
