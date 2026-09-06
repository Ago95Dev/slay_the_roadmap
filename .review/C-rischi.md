# C) Rischi critici

1. **R1 — Build rotta (P0).** `shared_preferences`/`get_it` assenti + `quiz_questions.dart` con API inesistenti → 9 error. Nessun run/test verde possibile finché resta così. Fix: dipendenze o rimozione file morti.
2. **R2 — Test rosso (P0).** `widget_test` cerca counter `"0"` su `HomeScreen` → FAIL garantito in CI/valutazione. Riscrivere subito.
3. **R3 — gameId/password divergenti (P0).** Due coppie diverse README vs Postman. Ogni `execute` 401/404 finché non fissato. Non codificare engine prima di `GET state` di prova.
4. **R4 — Soglia 80% ambigua (P0).** 3 domande → 2.4. Con 6 topic senza quiz (`throw`) e scoring `null→0`, la valutazione utenti misura bug non apprendimento. Fissare 5 domande/topic + `pass = percentage>=80`.
5. **R5 — Save mai chiamato + fromJson lossy (P1).** `adaptiveQuizzes` azzerati al restore, nessun save dopo quiz/boss. `Continue` ripristinerebbe stato parziale. Specificare `Save v1 {completedNodes, deck, xp, bossHp, energy, hearts}`.
6. **R6 — Reward promessa ma non assegnata (P1).** TODO victory + `isSelected` mai settato → al think-aloud l'utente chiede "dov'è la mia carta?". Chiudere UI pick-1-of-3 prima di valutazione/video.
7. **R7 — Bilanciamento boss non validato (P1).** Danno `percentage/10`, heal 15 random, HP 150/200/250 vs player 100. Senza tabella costi/danni, boss o one-shot o infinito. Definire costi 1-3, danni 1-3 prima del video.
8. **R8 — Single-point engine futuro (P1).** Se XP/badge solo remoti, demo offline muore. Prevedere `FakeEngineClient` fin da ora.
