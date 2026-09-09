# Utente U4 — scheda risultati (ESEMPIO DIDATTICO — dati fittizi, in attesa sessione reale)

> ⚠️ ESEMPIO di compilazione corretta (mostra il caso XP stacking noto). Sostituire con dati reali. File originale: `U4.md`.

- Data: 2026-09-08, ore 15:00 (~22 min totali, la più veloce)
- Profilo: età 22, esperienza Dart/Flutter intermedia (2 app Flutter pubblicate su corso mobile), mai vista l'app: sì
- Task (R = riuscito, F = fallito + tempo): T1 R (25s), T2 R (40s), T3 R (2'20", 5/5 = 100% al 1° colpo), T4 R (42s), T5 R (3'30", vittoria diretta senza sconfitta), T6 R (45s), T7 R (1'10", nota XP doppia e la si spiega)
- SUS (0-100): 72,5
- IMI (interesse / competenza / pressione, 1-5): 4,0 / 4,3 / 1,7
- GEQ (flow / sfida / positivo / negativo, 1-5): 4,0 / 3,0 / 4,0 / 1,3
- 3 attriti osservati:
  1. (T7, min 19') Confronta XP HUD vs profilo/card Hub: si aspetta +100 XP (vittoria boss) e ne vede +200 — è lo stacking noto reward `experience` nodo + 100 XP vittoria (`02_stato.md` punto 3). Dopo spiegazione lo accetta ("numeri semplici, ok se dichiarato").
  2. (T5, min 12') Boss giudicato facile per chi sa Dart ("HP30 boss vs 50 miei, quiz giusta −6/−10: vinto senza usare le soglie"): suggerisce 1 passiva distintiva per boss.
  3. (T1, min 1') Pulsante menu in Home con rientro (nota UX U1-U3): "il menu rientra da solo? pensavo di aver sbagliato tap" — poi nessun impatto.
- 3 citazioni testuali:
  1. "Soglia 80% equa, con 5 domande devi sbagliare al massimo una — selettivo ma chiaro."
  2. "Sto cercando l'inventario… eccolo, la carta scelta c'è. Il pick-1-of-3 ha senso per il deck."
  3. "Aspetta, 200 XP e non 100? Ah, c'è anche la reward del nodo… dichiaratelo e passa."
- Bug visti: nessuno — nessun crash. Victory assegna tutte le reward del nodo invece di 1 sola (semplificazione nota `02_stato.md` punto 2). Save-per-utente e badge topic/boss verificati, badge remoti nella card Hub visibili.
