# Slay the Roadmap / Slay the Code

Dungeon crawler didattico in Flutter che gamifica lo studio delle tecnologie Web: la roadmap è il dungeon, i topic sono le stanze, le carte-ricompensa il bottino. Progetto del corso EGS (A.A. 2025/2026); game Hub condiviso "Slay The Code".

## Come si gioca

Studio di un topic → quiz da 5 domande (soglia 80%) → scelta 1 carta su 3 → sblocco del nodo successivo → boss di capitolo (10 HP vs 3 HP, turni di carte e quiz, soglie 25/50/75). XP e livelli con soglie 0/100/500, identiche all'Hub. Vittoria boss: badge + 100 XP + capitolo successivo; sconfitta: retry senza XP.

## Stato e numeri reali

- Roadmap 3 capitoli (root + 3 topic + boss), 12 quiz, 21 carte in 4 rarità, 3 boss con passive uniche
- Save per utente con auth locale (hash salato), login/logout, New Run con conferma e wipe
- Hub best-effort offline-first: eventi `quiz_completed` / `claim_reward` / `boss_defeated`, classifica e card profilo; senza credenziali l'app è identica
- Suite: `flutter analyze` 0 error, `flutter test` 86/86

## Run

```bash
git checkout fix/last_version-stabilize
flutter pub get
flutter analyze
flutter test
flutter run -d linux
```

Con Hub (credenziali solo a runtime, mai nel repo):

```bash
flutter run -d linux \
  --dart-define=HUB_USER=<user> \
  --dart-define=HUB_PASS=<pw>
```

## Struttura

```
lib/
├── main.dart                 # entry point + bootstrap
├── providers/game_provider.dart  # stato globale (progress, deck, Hub)
├── services/                 # storage (save per utente, auth), engine Hub
├── data/                     # roadmap, topic, quiz, carte, boss, repository
├── domain/models/            # PlayerProgress (livelli 0/100/500), boss, quiz
├── screens/                  # menu, home, roadmap, quiz, reward, boss, profilo
└── widgets/                  # HUD, classifica Hub, card profilo, compendio
test/                         # smoke + US-01..05 + Hub mock + UX (86 test)
docs/
├── gamidoc.pdf               # GamiDOC (sorgenti in src/gamidoc, pdflatex)
├── specifica.pdf / aspetti_teorici.pdf
└── assignment/               # user stories, stato, evaluation, video, sprint
```

Dipendenze principali: `provider`, `shared_preferences`, `http`, `crypto`, `uuid`, `intl`, `url_launcher`, `webview_flutter`.

## Documenti

- `docs/gamidoc.pdf`: concept, meccaniche con numeri reali, Octalysis/Toda, architettura Hub, stato onesto, valutazione
- `docs/assignment/`: US-01..US-05, Sprint 1, stato fatto/manca, protocollo evaluation 5 utenti, scaletta video, proposta engine futura
