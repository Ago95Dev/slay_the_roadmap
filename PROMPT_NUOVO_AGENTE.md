# PROMPT — nuovo agente sul branch last_version (contesto azzerato, copia/incolla)

Sei un Flutter engineer che prende in mano un progetto esistente. Leggi TUTTO prima di toccare codice.

## Dove sei
- Repo/worktree: `/home/omalex/projects/slay_the_roadmap-collab` (branch `last_version`, Flutter stable, run: `flutter run -d linux`).
- Analisi e piano già pronti: leggi `ANALISI_E_PIANO.md` (stesso percorso) — è la verità di partenza: errori tecnici, tabella gamification, fasi 0-5.
- Assignment (obiettivo finale = consegna secondo assignment): US-01 roadmap ad albero con stati/prereq, US-02 quiz 3-5 domande soglia 80% + badge + sblocco, US-03 reward 1-di-3 con preview/inventory/limite-1, US-04 boss HP/turni carte-quiz/soglie 25-50-75/win-lose, US-05 autosave topic-deck-boss + restore + reset. Sprint 1 = US-01/02/03. Dettagli US: `/home/omalex/projects/slay_the_roadmap/docs/assignment/` (sola lettura).
- Progetto fratello di riferimento (sola lettura, NON copiare file): `/home/omalex/projects/slay_the_roadmap` — stesso assignment, copertura US-01..05 testata (243 test). Usalo per capire il comportamento atteso, poi implementa sui file di QUESTO worktree.

## Stato noto (verificato 2026-09-08)
- `flutter run` parte ma lancia `No Material widget found` ×5 + timeout OpenGL: app inutilizzabile, causa ignota (sospetti in ANALISI §1.1).
- `test/` quasi vuota (suite cancellata); auth SHA-256 senza salt + fallback plaintext; save unico globale; duplicati e build artifact committati; Hub condiviso funzionante (vedi contratto in ANALISI §4).
- MAI committare segreti: credenziali Hub solo via `--dart-define=HUB_USER/HUB_PASS` (chiedile all'utente a runtime, non scriverle in file). gameId e action sono pubblici per design.

## Regole di lavoro
1. Una fase alla volta, nell'ordine di ANALISI §3. Fase 0 prima di tutto: root cause del crash, `flutter analyze` 0 error, smoke test verde.
2. Ogni fix: prima un test che fallisce e lo riproduce, poi il fix, poi suite verde (`flutter test`), poi `flutter build linux --debug`.
3. Niente nuove dipendenze senza dirlo; niente refactor estetici; meccaniche e numeri semplici; ogni deviazione dall'assignment va documentata (impatto su Evaluation) o rimossa.
4. Commit in italiano col formato: `[Fase N] Titolo — Contesto / Cosa implementa / Verifica (analyze+test+build) / Prossimo`. Non pushare senza esplicito via dell'utente.
5. Se un'istruzione qui contraddice i test verdi o l'assignment, fermati e chiedi.

## Prima risposta attesa
Riepilogo in 10 righe: cosa hai capito (goal, stato, prime 3 azioni) + eventuale domanda bloccante. Poi esegui la Fase 0.
