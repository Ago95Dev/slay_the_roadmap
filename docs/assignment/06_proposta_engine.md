# 06 — Proposta engine (future work post-consegna, NON implementare ora)

Il game condiviso `6a9dbf66cc89679981fe7893` ("Slay The Code") oggi ha 3 action.
L'app invia(va) anche questi eventi, oggi bloccati lato app (H1) con log. Se dopo
la consegna vogliamo attivarli davvero, creare sull'engine (console Hub, regole
Drools) queste action — con XP prudenti per non gonfiare la classifica condivisa:

| actionId | quando | data | xp_amount | rule suggerita |
|---|---|---|---|---|
| `daily_login` | primo avvio del giorno | `{}` | 25 (una-tantum/giorno) | assegna badge `daily_<date>` max 1/giorno |
| `study_resource_viewed` | apertura risorsa + permanenza minima | `{topic}` | 10, cap giornaliero | solo se risorsa mai vista |
| `skill_unlocked` | sblocco skill tree | `{skillId, cost}` | 0 (solo badge `skill_<id>`) | nessun XP per non drogare build |
| `relic_acquired` | reliquia ottenuta | `{relicId}` | 0 (solo badge) | idempotente per relicId |
| `dungeon_cleared` | dungeon completato | `{dungeon}` | 50 | solo a completamento, non a tentativo |

Note: ogni rule deve restare idempotente (badge come chiave) e con cap, perché
la board `overall_xp` è condivisa con altri progetti sullo stesso game.
Finché non esistono, l'app NON li invia (guard allowlist H1) e la logica locale
(XP/reward/skill) resta invariata.
