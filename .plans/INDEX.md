# Indice piani — slay_the_roadmap-collab

Traccia tutti i piani in `.plans/`. Attivo = quello su cui si lavora. Archiviati = storico sola lettura.

| Data | File | Stato | Scope | Note |
|---|---|---|---|---|
| 2026-09-08 | `2026-09-08-piano-fix-tecnici-last_version.md` | ATTIVO | Fix tecnici da `last_version` (HEAD `641fed8`) a consegna US-01..05: Fasi 0 respira → 1 test → 2 conformità → 3 utenti → 4 igiene → 5 docs | Parte da ANALISI_E_PIANO.md + 2 analisi oracle (tecnica + gamification). Vincoli: TDD, commit `[Fase N]`, mai push senza via, mai segreti in repo, Hub non rompere |
| 2026-09-06 | `archive/2026-09-06-plan_completamento.md` | ARCHIVIATO | Piano completamento v2 scope ridotto (F1..F8 + Fase 1B A-E), riferito al fratello / storia precedente | Archiviato 2026-09-08: superato dal piano last_version; tenuto per storico F1..F7/rischi R1-R5 |

## Regole

- Un solo ATTIVO alla volta. Nuovo piano → archivia il precedente in `archive/` con prefisso data `YYYY-MM-DD-`.
- Ogni piano cita: base (`ANALISI_E_PIANO.md`), assignment (`docs/assignment/`), stato branch/HEAD.
- DoD ogni fase: `flutter analyze` + `flutter test` + `flutter build linux --debug` verdi.
