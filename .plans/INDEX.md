# Indice piani — slay_the_roadmap-collab

Traccia tutti i piani in `.plans/`. Attivo = quello su cui si lavora. Archiviati = storico sola lettura.

| Data | File | Stato | Scope | Note |
|---|---|---|---|---|
| 2026-09-09 | `2026-09-09-piano-ux-onboarding.md` | ATTIVO | UX onboarding: U1 gate CONTINUE, U2 chip avatar, U3 ritorno al menu, U4 docs | Da test utente nuovo account (screenshot Home) |
| 2026-09-08 | `archive/2026-09-08-piano-hub-fix.md` | ARCHIVIATO | Hub fix app↔engine H1-H8 completati | Suite 78/78, analyze 0 error, pushato |
| 2026-09-08 | `archive/2026-09-08-piano-fix-tecnici-last_version.md` | ARCHIVIATO | Fix tecnici Fasi 0-5 completati | Boot, test, conformità, utenti, igiene, docs |
| 2026-09-06 | `archive/2026-09-06-plan_completamento.md` | ARCHIVIATO | Piano completamento v2 scope ridotto (storico) | Superato dal piano last_version |

## Regole

- Un solo ATTIVO alla volta. Piano finito → `git mv` in `archive/` con prefisso data `YYYY-MM-DD-`.
- Ogni piano cita: base, assignment (`docs/assignment/`), stato branch/HEAD.
- DoD ogni fase: `flutter analyze` + `flutter test` + `flutter build linux --debug` verdi.
