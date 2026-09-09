# Utente U1 — scheda risultati (ESEMPIO DIDATTICO — dati fittizi, in attesa sessione reale)

> ⚠️ ESEMPIO di compilazione corretta. Sostituire con dati reali a sessione svolta. File originale: `U1.md`.

- Data: 2026-09-07, ore 10:15 (~24 min totali)
- Profilo: età 23, esperienza Dart/Flutter base (1 progetto universitario Flutter, 6 mesi), mai vista l'app: sì
- Task (R = riuscito, F = fallito + tempo): T1 R (28s), T2 R (45s), T3 R (2'50", 4/5 = 80% al 1° tentativo), T4 R (55s), T5 R (4'10", sconfitta poi vittoria al retry), T6 R (50s), T7 R (40s)
- SUS (0-100): 82,5
- IMI (interesse / competenza / pressione, 1-5): 4,7 / 4,0 / 2,0
- GEQ (flow / sfida / positivo / negativo, 1-5): 4,3 / 3,7 / 4,5 / 1,7
- 3 attriti osservati:
  1. (T2, min 2') Tappa un topic locked prima di quello sbloccato — SnackBar "completa il precedente" capita subito, si autocorregge senza aiuto.
  2. (T4, min 9') Preview reward solo descrittiva ("+6 danni"): esita 15s tra 2 carte perché non vede l'effetto in azione, poi sceglie e ritrova subito in inventory.
  3. (T5, min 13') Non nota subito le soglie boss 25/50/75%: le nota solo dopo il cambio mossa ("ah, si è arrabbiato a metà vita").
- 3 citazioni testuali:
  1. "Sto cercando il topic da aprire… ok, quello col lucchetto no, vado su quello colorato."
  2. "Mi aspettavo di poter riprendere la ricompensa… ah no, dice già riscattata. Giusto, una sola."
  3. "Ho perso ma il retry è immediato, riprovo — stavolta tengo le carte forti per la fine."
- Bug visti: nessuno — nessun crash. Victory boss ha assegnato tutte le reward del nodo (comportamento noto semplificato, dichiarato in `02_stato.md` punto 2, non un crash).
