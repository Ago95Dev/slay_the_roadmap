# D) Piano d'azione P0 / P1 / P2

Ordine: build verde → dati completi → reward/save → engine → docs/video.

## P0 — Build verde + US-02 reale (~2-3g)
1. **P0-1 Dipendenze o potatura (0.5g).** `flutter pub add shared_preferences get_it` + `setupLocator()` in `main()` + save/load cablati, oppure elimina `shared_preferences_service` + `setup_locator`. Output: `analyze` senza error.
2. **P0-2 Quiz widget unico (0.5g).** Elimina o ripara `quiz_questions.dart`; tieni `quiz_screen.dart`. Rimuovi duplicati legacy (`models/`, `services/`, `widgets/`, `ui/view_model/`).
3. **P0-3 Test verdi (0.5g).** Riscrivi `widget_test` su `HomeScreen`; aggiungi unit soglia 80%, boss damage, save/restore.
4. **P0-4 Quiz 5×9 topic (1g).** Porta ogni subtopic a 5 domande (80% = 4/5). Elimina `throw:159`.
5. **P0-5 gameId canonico (0.5g).** `GET state` con entrambe le credenziali, fissa una coppia in `lib/env.dart` + README.

## P1 — Prodotto finale (~3-4g)
6. **P1-1 Reward UI (1g).** Pick-1-of-3 con preview + inventory + limite 1; chiudi TODO victory.
7. **P1-2 Save/restore (0.5-1g).** Autosave dopo quiz/boss/topic, `Continue`, `New Run` con confirm. Fix `adaptiveQuizzes` in `fromJson`.
8. **P1-3 Engine minimo (1g).** `xp` + `experience` + 2 badge + 2 rule + `EngineClient` con fallback locale. `http` in pubspec.
9. **P1-4 Bilanciamento (0.5g).** Tabella costi/danni/HP, soglie 25/50/75 con effetto visivo, HUD unico XP/Level.

## P2 — Docs + valutazione (~3g)
10. **P2-1 GamiDOC + Toda (1g).** Architettura reale (senza duplicati), meccaniche mappate, gap dichiarati come scelte.
11. **P2-2 User Evaluation (1-1.5g).** 5 utenti autodidatti, think-aloud + SUS, risultati + limiti.
12. **P2-3 README + video + Sprint (0.5-1g).** README run, board Sprint1 reale + Sprint2, video 3-5min solo su ciò che è cliccabile offline.
