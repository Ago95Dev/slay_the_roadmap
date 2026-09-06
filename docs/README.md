# docs — Slay the Roadmap / Slay the Code

Documentazione del progetto EGS (Esempi di Gamification e Sistemi Intelligenti, A.A. 2025/2026).

## Documenti finali

| PDF | Descrizione | Pagine |
|-----|-------------|--------|
| [specifica.pdf](specifica.pdf) | Specifiche tecniche del prototipo (contesto, architettura, dominio, dati, flussi, Hub, verifica, debiti) | 13 |
| [gamidoc.pdf](gamidoc.pdf) | GamiDOC di progetto (contesto, game behavior, gamification, aesthetics, architettura, stato, valutazione) | 10 |
| [aspetti_teorici.pdf](aspetti_teorici.pdf) | Aspetti teorici della gamification (Octalysis, Toda, GamiDOC, user research, Hub, intelligent systems, sintesi) | 10 |

## Struttura cartelle

```text
docs/
├── README.md               # questo indice
├── specifica.pdf           # finali (rigenerati dai sorgenti, non editare a mano)
├── gamidoc.pdf
├── aspetti_teorici.pdf
├── src/                    # sorgenti LaTeX (solo .tex)
│   ├── specifica/          # main.tex + cap1..cap8 → specifica.pdf
│   ├── gamidoc/            # main.tex + cap1..cap7 → gamidoc.pdf
│   └── teoria/             # main.tex + cap1..cap7 → aspetti_teorici.pdf
├── assignment/             # cartella esame: user stories, Sprint 1, fatto/manca
├── assets/                 # immagini centralizzate usate dai .tex
└── legacy/                 # PDF storici + originali (byte preservati, non rinominati)
```

- **Sorgenti `.tex`**: `src/specifica/`, `src/gamidoc/`, `src/teoria/` (solo `.tex`, niente artefatti build).
- **Legacy**: `legacy/` — 6 PDF storici (mockup M1–M7, assignment 2, gamidoc_5, bozza GamiDOC, slide framing, Molina) + originale `Octa_Analysis.jpg` + file originale `user_stories`. I riferimenti nei `.tex` puntano a `docs/legacy/…`.
- **Immagini di lavoro**: `assets/Octa_Analysis.jpg` (copia di lavoro del radar Octalysis, score 169; referenziato dai `.tex` come `docs/assets/Octa_Analysis.jpg`).
  Nota: i mockup M1–M7 sono referenziati come PDF (`legacy/3_Mockups.pdf`) — nessuna immagine estratta dai PDF.
- **Esame**: `assignment/` — `01_user_stories.md` (US-01…US-05 + acceptance + Sprint 1), `02_stato.md` (FATTO/MANCA).

## Come ricompilare

Serve `pdflatex` (TeX Live). Da repo root, per ciascun documento due passate (la seconda risolve TOC e riferimenti):

```bash
cd docs/src/specifica && pdflatex main.tex && pdflatex main.tex
cp main.pdf ../../specifica.pdf && rm -f main.aux main.log main.out main.toc main.pdf

cd ../gamidoc && pdflatex main.tex && pdflatex main.tex
cp main.pdf ../../gamidoc.pdf && rm -f main.aux main.log main.out main.toc main.pdf

cd ../teoria && pdflatex main.tex && pdflatex main.tex
cp main.pdf ../../aspetti_teorici.pdf && rm -f main.aux main.log main.out main.toc main.pdf
```

(`latexmk -pdf main.tex` non è installato su questa macchina; con `latexmk` basterebbe una sola invocazione per documento.)
Regole: compilazione a **0 error** (`grep -c "^! " main.log` deve dare 0); gli artefatti `main.aux/.log/.out/.toc/main.pdf` **non** vanno lasciati in `src/`; i PDF top-level devono chiamarsi esattamente `specifica.pdf`, `gamidoc.pdf`, `aspetti_teorici.pdf`.
