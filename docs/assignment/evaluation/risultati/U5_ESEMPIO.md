# Utente U5 — scheda risultati (ESEMPIO DIDATTICO — dati fittizi, in attesa sessione reale)

> ⚠️ ESEMPIO di compilazione corretta (mostra esplorazione libera + T7 offline). Sostituire con dati reali. File originale: `U5.md`.

- Data: 2026-09-08, ore 16:20 (~30 min totali, sessione offline senza rete)
- Profilo: età 20, esperienza Dart/Flutter nulla (primo anno triennale, solo C/Python), mai vista l'app: sì
- Task (R = riuscito, F = fallito + tempo): T1 R (40s), T2 R (1'25", prima tappa un locked poi trova lo sbloccato), T3 R (3'50", 4/5 = 80% al 2° tentativo), T4 R (1'20", prova re-claim correttamente bloccato), T5 R (5'50", 2 sconfitte poi vittoria), T6 R (1'30", NEW RUN con conferma capita), T7 F (1'20", non trova classifica offline — abbandona)
- SUS (0-100): 70,0
- IMI (interesse / competenza / pressione, 1-5): 4,5 / 3,3 / 2,3
- GEQ (flow / sfida / positivo / negativo, 1-5): 4,5 / 3,7 / 4,3 / 2,3
- 3 attriti osservati:
  1. (T2, min 3') Tap su topic locked → SnackBar gate reale capita ("ah, devo finire quello prima"): gate compreso senza aiuto.
  2. (T4, min 11') Prova a riscattare una seconda reward dello stesso topic: guard 1/topic blocca correttamente (KPI re-claim 0 errati ✓). Utente: "ok, una sola, ha senso".
  3. (T7, min 26') Sessione offline (FakeEngineClient): classifica Hub vuota, stato offline non evidente → non confronta XP e abbandona. Conferma DoD fallback locale (app identica) ma suggerisce empty-state più esplicito.
- 3 citazioni testuali:
  1. "Sto cliccando un po' tutto… questo ha il lucchetto, questo no — vado qui."
  2. "Ho scoperto per caso il menu 'Done' nel topic — figo, ma sembra un trucco, dà XP gratis?"
  3. "Il boss è divertentissimo, anche se ho perso due volte non mi sono frustrato — la terza l'ho battuto!"
- Bug visti: nessuno — nessun crash (KPI crash 0/5 tenuto). Dropdown "Done" = override manuale con XP (noto `02_stato.md` punto 4). CONTINUE appare solo a campagna iniziata (UX nota): prima del primo save l'utente cerca Continue e trova solo New Run — compreso dopo 20s.
