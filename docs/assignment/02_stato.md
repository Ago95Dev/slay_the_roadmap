# Stato — FATTO / MANCA (aggiornato 2026-09-08, branch `fix/last_version-stabilize`)

## FATTO (Fasi 0-4 + Hub H1-H6, branch `fix/last_version-stabilize`)

- Boot pulito `flutter run -d linux`; `flutter analyze` 0 error; test **62/62**; `flutter build linux --debug` ok.
- Numeri ALLINEATI app=Hub: quiz pass → +100 XP, vittoria boss → +100 XP; livelli 0/100/500.
- US-01 roadmap ad albero con gate reale (sequenziale per capitolo); US-02 quiz 5 domande soglia 80% (=4/5), submit bloccato senza risposta, sblocco auto; US-03 reward pick-1-of-3 con guard 1/topic + inventory; US-04 boss HP10/player HP3, turni quiz ±1 (enraged -2), soglie 75/50/25 live, victory (badge+150XP+sblocco) / defeat (retry senza XP); US-05 autosave per utente + restore + wipe con confirm.
- Rimosse deviazioni: timer 25s boss, skip-che-sblocca-senza-XP. Livelli unificati su `levelForXp` 0/100/500 (=Hub). Badge locali topic/boss + sezione profilo.
- Auth v2 `salt$sha256` con migrazione v1 e cancellazione chiare; save per utente (`dart_quest_progress_<u>` / `slay_save_v1_<u>`); playerId Hub `slay_<uuid>` stabile (mai username in chiaro). Hub best-effort offline-first (`FakeEngineClient`), credenziali solo `--dart-define`, mai nel repo. Eventi attivi: solo `quiz_completed`/`claim_reward`/`boss_defeated` (extra disattivati, vedi `06_proposta_engine.md`); `claim_reward` anche dal pick-1-of-3; `boss_defeated` sempre; badge remoti nella card Hub; log successi + stato online reale.
- Igiene: 139 artifact unstagati (`src/build/`, `src/*/ephemeral`), `pubspec.yaml.backup` rimosso, `.gitignore` esteso. Contratto Hub intatto (game `6a9dbf…`, snake_case, `quiz_completed`/`boss_defeated`, `overall_xp`).
- Docs: GamiDOC/specifica/teoria in `docs/*.pdf` (sorgenti `docs/src/`); Octalysis radar `docs/assets/Octa_Analysis.jpg`.

## MANCA / NOTE PER LA VALUTAZIONE (dichiarare, non nascondere)

1. Preview reward solo descrittiva (accettata come "preview effetto" minimale).
2. Victory boss assegna tutte le reward del nodo (semplificazione, non esattamente 1).
3. Reward `experience` del nodo boss si somma ai 150 XP vittoria (numeri semplici).
4. Dropdown "Done" in topic_detail = override manuale con XP (lasciato, da dichiarare o rimuovere in review).
5. GamiDOC PDF: riallineare i numeri (80%=4/5, HP10/3, 0/100/500) e le 4 note sopra prima della consegna (`pdflatex` due passate, vedi `docs/README.md`).
6. Evaluation 5 utenti da eseguire (protocollo in `04_evaluation.md`); video 3-5min da girare (scaletta in `05_video_e_sprint.md`).
