# Indice piani — slay_the_roadmap-collab

Traccia tutti i piani in `.plans/`. Attivo = quello su cui si lavora. Archiviati = storico sola lettura.

| Data | File | Stato | Scope | Note |
|---|---|---|---|---|
| 2026-09-08 | `2026-09-08-piano-fix-tecnici-last_version.md` | COMPLETATO Fasi 0-5 | Fix tecnici da `last_version` (HEAD `641fed8`) a consegna US-01..05: Fasi 0 respira → 1 test → 2 conformità → 3 utenti → 4 igiene → 5 docs | F0 2be1de7, F1 fab2666, F2 6e4feda, F3 5888a02, F4 1260089, F5 questo commit. Decisioni: timer/skip RIMOSSI, nuovo branch, Hub offline-first |
| 2026-09-08 | `2026-09-08-piano-hub-fix.md` | ATTIVO | Hub fix app↔engine: H1 extra off + H2 claim + H3 numeri 100/100 + H4 boss nodeless + H5 badge card + H6 osservabilità + H7 mock test + H8 docs | Decisioni: allinea XP, disattiva extra (proposta engine in GamiDOC, non ora), mostra badge, test completi |
| 2026-09-06 | `archive/2026-09-06-plan_completamento.md` | ARCHIVIATO | Piano completamento v2 scope ridotto (F1..F8 + Fase 1B A-E), riferito al fratello / storia precedente | Archiviato 2026-09-08: superato dal piano last_version; tenuto per storico F1..F7/rischi R1-R5 |

## Regole

- Un solo ATTIVO alla volta. Nuovo piano → archivia il precedente in `archive/` con prefisso data `YYYY-MM-DD-`.
- Ogni piano cita: base (`ANALISI_E_PIANO.md`), assignment (`docs/assignment/`), stato branch/HEAD.
- DoD ogni fase: `flutter analyze` + `flutter test` + `flutter build linux --debug` verdi.
