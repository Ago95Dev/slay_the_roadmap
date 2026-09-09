# Stato — FATTO / MANCA (aggiornato 2026-09-09, branch `fix/last_version-stabilize`)

## FATTO (Fasi 0-4 + Hub H1-H8 + UX U1-U3, branch `fix/last_version-stabilize`)

- Boot pulito `flutter run -d linux`; `flutter analyze` 0 error; test **123/123**; `flutter build linux --debug` ok.
- Numeri ALLINEATI app=Hub: quiz pass → +100 XP, vittoria boss → +100 XP; 10 livelli 0/100/500/1000/1600/2300/3100/4000/5000/6100.
- US-01 roadmap ad albero con gate reale (sequenziale per capitolo); US-02 quiz 2-5 domande soglia 80%, submit bloccato senza risposta, sblocco auto; US-03 reward pick-1-of-3 con guard 1/topic + inventory; US-04 boss HP30/player HP50, quiz giusta −6 (soglia −10), errata = danno mossa, soglie per-boss live, victory (badge+100XP+sblocco) / defeat (retry senza XP); US-05 autosave per utente + restore + wipe con confirm.
- Rimosse deviazioni: timer 25s boss, skip-che-sblocca-senza-XP. Livelli a 10 soglie (`levelThresholds`, L1-L3 invariati) + HUD/profilo sui nuovi helper. Badge locali topic/boss + sezione profilo.
- Auth v2 `salt$sha256` con migrazione v1 e cancellazione chiare; save per utente (`dart_quest_progress_<u>` / `slay_save_v1_<u>`); playerId Hub `slay_<uuid>` stabile (mai username in chiaro). Hub best-effort offline-first (`FakeEngineClient`), credenziali solo `--dart-define`, mai nel repo. Eventi attivi (scelta B, specchio totale): `quiz_completed`/`claim_reward`/`boss_defeated` + `topic_completed`/`resource_viewed`/`dungeon_cleared`/`daily_login` con `xp_amount` (extra skill/relic restano locali, vedi `06_proposta_engine.md`); `claim_reward` anche dal pick-1-of-3; `boss_defeated` sempre; badge remoti nella card Hub; log successi + stato online reale.
- Igiene: 139 artifact unstagati (`src/build/`, `src/*/ephemeral`), `pubspec.yaml.backup` rimosso, `.gitignore` esteso. Contratto Hub intatto (game `6a9dbf…`, snake_case, `quiz_completed`/`boss_defeated`, `overall_xp`).
- Docs: GamiDOC/specifica/teoria in `docs/*.pdf` (sorgenti `docs/src/`); Octalysis radar `docs/assets/Octa_Analysis.jpg`.

## MANCA / NOTE PER LA VALUTAZIONE (dichiarare, non nascondere)

1. Preview reward solo descrittiva (accettata come "preview effetto" minimale).
2. Victory boss assegna tutte le reward del nodo (semplificazione, non esattamente 1).
3. Reward `experience` del nodo boss si somma ai 100 XP vittoria (numeri semplici).
4. Dropdown "Done" in topic_detail = override manuale con XP (lasciato, da dichiarare o rimuovere in review).
5. UX onboarding: CONTINUE solo a campagna iniziata, chip classe con icona fallback, pulsante menu in Home con rientro (U1-U3), NEW RUN con conferma e wipe per-utente (U5).
5. GamiDOC PDF: riallineare i numeri e le note prima della consegna (`pdflatex` due passate, vedi `docs/README.md`).
6. Evaluation 5 utenti da eseguire (protocollo in `04_evaluation.md`); video 3-5min da girare (scaletta in `05_video_e_sprint.md`).
