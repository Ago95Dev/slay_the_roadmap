# Utenti, campagne e Hub — disegno architettura (v1)

Risponde a: salvataggio per-utente su DB caricabile, multi-utenza con login, esperienza personalizzata, N campagne, ruolo del gamification engine.

## 1. Dove siamo oggi (limiti onesti)

- Un solo save locale (`slay_save_v1` in SharedPreferences): un utente, una campagna, un device.
- Nessun login: `playerId` Hub generato (`slay_<timestamp>`), anonimo.
- Campagna hardcoded nei repository (una sola).
- Conseguenze: niente profili caricabili, niente cross-device, niente dati remoti per-utente oltre l'XP/badge anonimo su Hub.

## 2. Modello proposto (semplice, da esame)

```
UserProfile { userId, displayName, avatarIcon, avatarFrame, createdAt, campaigns: {campaignId: CampaignProgress} }
CampaignProgress { completedTopicIds, claimedRewardTopics, bossFights, xp, streak, maxStreak, lives, titles, seenIntros, lastPlayed }
Campaign { id, title, subtitle, intro, chapterIds }   // i contenuti restano nei repository
```

- Store locale multi-profilo: indice `slay_users_index` + un record `slay_profile_<userId>` per utente. Il vecchio `slay_save_v1` si importa una volta in un utente "Giocatore" e poi si archivia (migrazione senza perdite).
- Login/registrazione **locale**: username + password (hash SHA-256 con salt, solo verifica in locale). Dichiarato nel GamiDOC come prototype-grade: niente recupero password, niente ruoli. Niente auth remota: gli account Hub sono per-developer, non per-giocatori.
- Hub resta la controparte remota: un player Hub per coppia (utente, campagna) → `slay_<userId>_<campaignId>`. Così XP/badge/leaderboard remoti sono già per-utente e per-campagna senza cambi Hub.

## 3. Personalizzazione per utente (tracciamento progressi)

- Ogni utente riprende dove era (continue per campagna, `lastPlayed`).
- Storico per topic: conta i quiz falliti → sezione "Da ripassare" con i topic deboli (piccola aggiunta: `failCount` per topic).
- Titoli, avatar, streak, vite: già per-profilo, da spostare dentro CampaignProgress.
- Analytics per Evaluation: eventi locali (quiz pass/fail, tempo boss, retry) + specchio Hub = dati utente reali per il documento di valutazione.

## 4. N campagne (progettare per N, spedirne 1)

- `CampaignRepository.list()` → oggi 1 attiva (Fondamenta Web) + N in `comingSoon` (titolo + "Prossimamente"), riusando il pattern già usato per le roadmap.
- Roadmap/quiz/detail/boss parametrizzati su `campaignId`; la selezione campagna sostituisce lo "single path" attuale.
- Nuova campagna = nuovo seed contenuti + nuovi badge Hub (nomi dinamici, zero cambi Hub) + voce in lista. Nessun cambio a meccaniche, save formato, engine.

## 5. Ruolo del gamification engine (Hub) nella nostra app

**A cosa serve.** L'Hub è il registro esterno autorevole di XP, livelli, badge e classifiche: rende i progressi verificabili da fuori (docente che apre la console), persistenti oltre il device e confrontabili (leaderboard). La logica di gioco (quiz, boss, sblocchi) resta in app.

**Come lo utilizziamo.** Solo eventi best-effort (`quiz_completed`, `boss_defeated`) con fallback offline: l'app funziona identica senza rete; quando c'è rete, lo stato remoto converge. Mai chiamate bloccanti, mai segreti nel repo (`--dart-define`), un player per (utente, campagna).

**Se non ci fosse.** L'app resta completamente giocabile (tutto il game loop è locale); si perdono: persistenza remota/cross-device, leaderboard, badge verificabili, metriche indipendenti per l'Evaluation. In demo offline non cambia nulla — è il disegno voluto.

## 6. Impatto sul piano (scope aggiornato)

Escono dai tagli e entrano in piano (dopo Fase 1B, prima di F8): F10 profili locali + login/registrazione + migrazione save; F11 modello N-campagne + selezione + coming soon; F12 "da ripassare" + analytics locali per Evaluation. Stima +2-3g. Resta tagliato: auth remota/recupero password, shop, classi, coop/PVP.
