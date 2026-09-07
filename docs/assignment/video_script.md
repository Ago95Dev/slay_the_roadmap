# Video script — Slay the Roadmap (3–5 min)

Nota regia: girare la **demo offline** (senza `--dart-define`, fallback Fake) così non dipende
dalla rete; mostrare l'**Hub** solo nella parte meccaniche (screenshot console o run con credenziali).

## 1. Problema + idea (30s)

- Studiare le fondamenta del Web (HTML/CSS/JS) è dispersivo: tutorial passivi, nessun feedback.
- Idea: un dungeon-crawler deck-building dove ogni topic è un nodo da conquistare —
  quiz per avanzare, carte reward per potenziarsi, boss di fine capitolo per certificare.
- [B-roll: roadmap con gate locked]

## 2. Demo click-per-click (M1–M5, ~2:30)

- **M1 Home (15s):** fresh install → premi **New Run** (spiegare: al primo giro azzera il save).
- **M2 Roadmap → Topic (30s):** tap su nodo locked = SnackBar bloccato (gate); apri un topic,
  mostra detail + vite/streak.
- **M3 Quiz → Reward (45s):** rispondi a 1 domanda (submit bloccato senza risposta),
  completa il quiz → schermata **pick-1-of-3** con preview effetti → carta in inventario.
- **M4 Boss (45s):** entra nel boss di capitolo (lore pre-fight) → gioca 1 turno
  (energia 3, 1 per carta) → quiz di fine turno (giusta = danno, errata = danno al player) →
  mostra vittoria (reward + sblocco capitolo + badge) *oppure* sconfitta (retry full HP, senza XP).
- **M5 Continue (15s):** chiudi e riapri → **Continue** ripristina il save.

## 3. Meccaniche (60s)

- **Octalysis:** CD1 narrativa (intro/lore/finale), CD4 titoli+avatar, CD5 leaderboard,
  CD6 daily reward, CD7 passive uniche boss.
- **Toda:** titoli come collection, classifica come competizione, Da-ripassare come feedback.
- **Hub:** Point `xp`, badge `topic_badge`/`boss_badge`, 3 rule (`quiz_pass`, `unlock`,
  `boss_defeat`) — best-effort: con rete sincronizza, senza rete l'app è identica.

## 4. Chiusura (15s)

- Stato: 215/215 test verdi; repo + README con run; future work: shop, classi, multiplayer.
- Link repo + gameId Hub in descrizione.
