# Piano UX onboarding — 3 problemi segnalati su schermata Home

Data: 2026-09-09. Branch: `fix/last_version-stabilize` (restarci; mai commit su `last_version`, mai push senza via).
Origine: test utente con nuovo account (screenshot Home: chip NOVICE vuota, tab senza via al menu).
Piani precedenti archiviati in `.plans/archive/` (tecnici F0-5 + Hub H1-H8, entrambi completati e pushati).

## Vincoli

TDD (rosso→fix→verde), `flutter analyze` 0 error, `flutter test` tutto verde (base 78/78), `flutter build linux --debug` ok, commit `[UX N]` in italiano, niente nuove dipendenze, niente restyle (solo fix mirati), niente segreti in file.

## U1 — CONTINUE solo a campagna iniziata (priorità alta)

Causa: `main_menu_screen.dart:213-222` naviga sempre alla Home; flag `hasStartedJourney` (`game_provider.dart:144`, persistito) mai letto nel menu.
Cosa: CONTINUE visibile/abilitato solo se `hasStartedJourney == true`, altrimenti solo NEW RUN (+ hint "inizia una run"). `pushReplacement` invariato per ora (vedi U3).
Test widget: account nuovo (flag false) → CONTINUE assente/disabilitato, tap NEW RUN → PathSelection; con save avviato → CONTINUE → Home.
File: `lib/screens/main_menu_screen.dart`, test `test/ux_onboarding_test.dart`.
Commit `[UX 1]`.

## U2 — Chip classe/avatar mai vuota (priorità media)

Cause: `playerClass` default `'Novice'` (`game_provider.dart:643`, scelta solo nel flusso NEW RUN) + `compact_stats_bar.dart:79` carica `assets/novice.png` che non esiste (asset reali: hunter/mage/warrior/utility) → cerchio vuoto.
Cosa: fallback esplicito — se l'asset della classe manca, mostra icona `Icons.person` nel cerchio (nessun nuovo asset); testo resta la classe (dichiarato in GamiDOC come titolo iniziale). Niente default forzato di classe (evita side-effect su save vecchi).
Test widget: classe `Novice` → icona fallback, nessun errore immagine; classe `Mage` → asset reale.
File: `lib/widgets/compact_stats_bar.dart`, stesso test file.
Commit `[UX 2]`.

## U3 — Ritorno al menu dalla Home (priorità alta)

Causa: CONTINUE usa `pushReplacement` (`main_menu_screen.dart:216`) che distrugge la route menu; `home_screen.dart` non ha alcun pulsante menu/home (solo tab + ingranaggio); il logout pulisce lo stato ma non naviga.
Cosa: pulsante menu (icona `home`/`menu` nell'AppBar della Home) → `Navigator.push` di `MainMenuScreen` (non replacement: la Home resta sotto, nessun dato perso); dal menu, CONTINUE rientra (U1 lo permette: journey iniziata). Logout invariato.
Test widget: tap menu → MainMenuScreen visibile; back → Home con stato intatto.
File: `lib/screens/home_screen.dart`, stesso test file.
Commit `[UX 3]`.

## U4 — Docs e chiusura

`docs/assignment/02_stato.md` (+3 righe esiti), INDEX → COMPLETATO. Nessun cambio numeri/Editoriale GamiDOC (fix solo UX).
Commit `[UX 4]` (solo docs) oppure squash in U3 se banale — default commit separato.

## Rischi

- R1 U1 cambia il primo impatto: account esistenti con save avviato vedono tutto come prima (flag true) — coperto da test con save popolato.
- R2 U3 aggiunge una route sopra la Home: nessun reset stato (push, non replacement) — verificato dal test back-con-stato.

## Milestone

| M | DoD |
|---|---|
| MU1 | account nuovo non può finire in Home vuota |
| MU2 | chip sempre con icona/immagine valida |
| MU3 | menu raggiungibile e rientrabile senza perdite |
