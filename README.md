# Slay the Roadmap

Dungeon-crawler deck-building per imparare le **fondamenta del Web** (HTML, CSS, JavaScript):
una **campagna** di 3 capitoli con nodi topic → quiz → **reward pick-1-of-3** → **boss di fine capitolo**
con meccaniche passive uniche. XP e livelli (L1 0 / L2 100 / L3 500) coincidono tra app e Hub;
autosave locale, profili multipli, leaderboard Hub e daily reward completano il quadro.

Team: D'Agostino (matr. 303226) + Di Giacomo (matr. 303377). Corso EGS, A.A. 2025/26.

## Requisiti

- Flutter SDK (stable) + backend Linux desktop abilitato
- Rete **opzionale**: senza credenziali Hub l'app gira identica in offline-first

## Run

```bash
flutter pub get
flutter run -d linux
```

Con Hub (XP/badge/leaderboard remoti):

```bash
flutter run -d linux \
  --dart-define=HUB_USER=<user> \
  --dart-define=HUB_PASS=<password>
```

Al primo giro premi **New Run** (azzera il save e parte la campagna dall'inizio);
ai giri successivi **Continue** ripristina il save (`Save v1` in SharedPreferences).

Test:

```bash
flutter test   # 215/215 verdi (2026-09-07)
```

## Hub (Gamification Hub)

- `gameId`: `6a9dbf66cc89679981fe7893` (pubblico per design, vedi `lib/config/hub.dart`)
- Point `xp`, badge `topic_badge` / `boss_badge`, 3 rule (`quiz_pass`, `unlock`, `boss_defeat`),
  classifica `overall_xp`. Credenziali solo via `--dart-define`, mai nel repo.

## Struttura repo (breve)

| Path | Cosa contiene |
|---|---|
| `lib/` | app Flutter (screens, view model, data, contenuti campagna Web) |
| `test/` | 215 test (unit + widget + regressione per F1–F12) |
| `docs/assignment/` | sprint, video script, protocollo valutazione, user stories |
| `docs/gamidoc.pdf` | GamiDOC di progetto (design gamification) |
| `docs/specifica.pdf`, `docs/aspetti_teorici.pdf` | specifica e aspetti teorici (sorgenti LaTeX in `docs/src/`) |
| `.plans/plan_completamento.md` | piano di completamento F1–F12 (storia del lavoro) |

## Video demo (3–5 min)

Link: [placeholder — caricare su YouTube/unlisted e incollare qui]
Scaletta click-per-click in [`docs/assignment/video_script.md`](docs/assignment/video_script.md).
