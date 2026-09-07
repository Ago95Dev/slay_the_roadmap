# Sprint report — Slay the Roadmap

Team: D'Agostino (303226) + Di Giacomo (303377). Corso EGS, A.A. 2025/26.
Storia verificabile via `git log --oneline` (hash citati sotto).

## Sprint 1 — Core offline (F1–F6)

Obiettivo: walkthrough completo filmabile **senza rete**
(Home → Roadmap → Topic → Quiz → Reward → Boss win/lose → Continue).

| Lavoro | Commit |
|---|---|
| F1 gate topic locked + single path | `de79b19` |
| F2 detail 12/12, risposta obbligatoria, hint dopo 2 errori | `51c2cc8` |
| Fix completamento topic al rientro dal quiz | `62f1b9a` |
| F3 reward pick-1-of-3 | `accc0a3` |
| F4 boss fight (energia, deck vero, win/lose) | `7ed1402` |
| F5 autosave SharedPreferences (Continue / New Run / Reset) | `3472763` |
| F6 HUD unico + livelli L1 0 / L2 100 / L3 500 | `699df15` |
| Fix battle-log dark mode | `0cf083a` |

DoD raggiunta: demo offline + `flutter analyze` 0 error + test verdi + `build linux` ok.

## Sprint 2 — Hub + campagna Web + boss credibili

| Lavoro | Commit |
|---|---|
| F7 Hub: gioco configurato su console, verificato E2E | `3163d84` |
| F7 EngineClient Hub offline-first (`--dart-define=HUB_USER/HUB_PASS`, fallback Fake) | `5cd5369` |
| Chiusi buchi reward-tipi, vite e streak | `31f0853` |
| Boss 10HP/3HP, domande dal capitolo, carte web | `ac1b106` |
| Boss come finali di capitolo nella roadmap | `ad5dff5` |
| Campagna Web fondamenta: spec + cap. 1, poi cap. 2–3 + root, poi swap contenuti (9 detail, 45 quiz) | `dba0d8c`, `a0b57fd`, `8797a34` |

DoD raggiunta: con rete XP/badge/leaderboard da Hub, senza rete app identica (fallback Fake).

## Sprint 3 — Gap Octalysis/Toda (1B) + profili/campagne/personalizzazione (F10–F12)

| Lavoro | Commit |
|---|---|
| Piano architettura utenti/campagne/Hub + scope F10–F12 | `9677b19` |
| 1B/A narrativa CD1 + fix vittoria finale persa | `d22fc88` |
| 1B/B titoli per capitolo + avatar persistito | `7da814f` |
| 1B/C passive uniche per boss | `c274b45` |
| 1B/D classifica XP Hub con stati vuoto/offline | `11f8d7f` |
| 1B/E daily reward +25 XP una-tantum | `5acf3b8` |
| F10 profili locali multipli (auth FNV+salt, migrazione save v1) | `d921365` |
| F11 N campagne (1 attiva + 2 coming soon, progress isolati) | `8036bcf` |
| F12 Da-ripassare (da failCount) + analytics locali | `9a97886` |

DoD raggiunta: `flutter test` 215/215 verdi (2026-09-07).

## Sprint 4 — Hub personale + fix login/classifica/reset/quiz-provider + replay

| Lavoro | Commit |
|---|---|
| Fix login all'avvio, crash classifica, reset con race | `d25c5d0` |
| Docs esame (README, sprint, video script, protocollo valutazione) | `5374d92` |
| GamiDOC finalizzato senza placeholder (resta solo Evaluation) | `e3ae4ea` |
| Hub personale post-login come centro (profilo/HUD/daily/CONTINUA/CAMPAGNE/CLASSIFICA/NUMERI/IMPOSTAZIONI) | `38f3546` |
| Fix voci hub/home morte e hint offline classifica | `1d8ff34` |
| Replay quiz dei topic completati a 0 XP (streak/vite/fail ok, niente doppi premi) | `ce646ba` |
| Provider sopra MaterialApp: tutte le route ereditano i ViewModel (addio ProviderNotFound) | `d2ca75b` |

Campagna Web già live dagli sprint precedenti (1 attiva ``Fondamenta Web'' + 2 coming soon).

DoD raggiunta: `flutter test` 243/243 verdi (2026-09-07).

## Stato F8 (docs esame)

Resta da fare: **User Evaluation** (5 utenti, protocollo pronto in
`docs/assignment/`, capitolo GamiDOC ``Valutazione'' DA COMPLETARE con le sessioni)
e **video demo** (scaletta pronta in `docs/assignment/video_script.md`,
link YouTube da caricare nel README). Completato: GamiDOC senza placeholder
(tranne Evaluation), README con numeri veri, sprint report reale, protocollo valutazione.

## Ruoli

- D'Agostino (303226): [DA CONFERMARE — divisione da concordare, es. core gameplay F1–F4]
- Di Giacomo (303377): [DA CONFERMARE — divisione da concordare, es. persistenza/HUD/Hub F5–F7]

## Retrospettiva (onesta, 3 righe)

Abbiamo tenuto lo scope stretto (US-01..05 + gap misurati) rinviando shop, classi e
multiplayer a future work: questo ci ha fatto chiudere ma ha lasciato il debito noto
(bilanciamento boss rinviato, 1 flake widget in suite parallela). Il fallback
offline-first si è rivelato la scelta giusta: demo e valutazione non dipendono dalla rete.
