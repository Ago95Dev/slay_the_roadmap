# Protocollo di valutazione — Slay the Roadmap

Metodo: seminari Bassanelli — **think-aloud** durante i task + **questionario UX** (SUS) finale.
Stato: protocollo **pronto da eseguire, risultati non ancora raccolti** (tabella vuota sotto).

## Partecipanti

- 5 utenti **autodidatti** di HTML/CSS/JS (profilo target: principianti che studiano da soli).
- Reclutamento: [placeholder — canale e criteri di screening da definire].
- Consenso: [placeholder — modulo informato + liberatoria registrazione].

## Setup

- Build Linux fresca da clone (`flutter pub get` → `flutter run -d linux`), **offline**
  (senza `--dart-define`) così la rete non è una variabile.
- Profilo pulito per ogni utente (New Run all'inizio); osservatore prende note, registra audio.

## Task (con think-aloud: "pensa ad alta voce mentre lo fai")

| # | Task | Successo se |
|---|---|---|
| T1 | Avvia una New Run e apri il primo topic | arriva al detail senza aiuto |
| T2 | Completa un quiz e scegli 1 reward su 3 | sceglie motivando la carta |
| T3 | Prova ad aprire un topic locked, poi sbloccalo | descrive il gate correttamente |
| T4 | Gioca 1 turno di boss + quiz di fine turno | spiega energia e danno quiz |
| T5 | Chiudi, riapri, premi Continue | ritrova progress e deck |

## Questionario

- SUS (10 item standard, scala 1–5) + 3 domande aperte:
  1. Cosa ti ha motivato di più? 2. Cosa ti ha confuso? 3. Cosa cambieresti nel boss?

## Metriche

- **Success rate** per task (% utenti che completano senza aiuto).
- **Tempo** mediano per task (mm:ss da cronometro osservatore).
- **SUS** medio (0–100) + deviazione.
- Note qualitative think-aloud codificate in temi.

## Risultati (VUOTO — da riempire dopo le sessioni)

| Utente | T1 ok/tempo | T2 ok/tempo | T3 ok/tempo | T4 ok/tempo | T5 ok/tempo | SUS | Note |
|---|---|---|---|---|---|---|---|
| U1 | / | / | / | / | / | / | |
| U2 | / | / | / | / | / | / | |
| U3 | / | / | / | / | / | / | |
| U4 | / | / | / | / | / | / | |
| U5 | / | / | / | / | / | / | |

## Riflessioni (placeholder — da scrivere dopo le sessioni)

- [placeholder — 2-3 fix concreti emersi dai test, con riferimento a task/utente]
- [placeholder — cosa NON cambiamo e perché]
