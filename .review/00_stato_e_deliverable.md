# Review — Slay the Roadmap (stato al 2026-09-05)

> Stato: **BOZZA PROVVISORIA** — in attesa di integrazione concept Slay (task di analisi GDD/User Stories ancora in corso).
> Questa cartella `.review/` contiene la valutazione del progetto rispetto al materiale in `material_4_exam/`.

## Evidenze confermate

### 1. Codice attuale = template Flutter intatto
- `lib/main.dart` (122 righe): `MyApp` + `MyHomePage` counter demo, `seedColor deepPurple`. Nessuna feature d'esame.
- `test/widget_test.dart`: solo smoke test counter 0→1.
- `testing/fakes/`, `testing/models/`: vuote (solo `.gitkeep`).
- `pubspec.yaml`: solo `flutter` + `cupertino_icons`; mancano `http/dio`, `riverpod/bloc`, `go_router`, `shared_preferences`, ecc.
- `README.md`: stock "A new Flutter project", senza descrizione né istruzioni di run.
- Giudizio: prototipo zero, lavoro esame tutto da fare.

### 2. Deliverable ufficiali (da `OneDrive_2_9-5-2026/EGS_Exam_Deliverables.pdf`, 1 pagina)
1. **GamiDOC (PDF)**: concept+obiettivi, target users, meccaniche/dinamiche, architettura/scelte tecniche.
2. **User Evaluation Document (PDF)**: metodo, profilo utenti, risultati, riflessioni critiche.
3. **GitHub Repository**: codice + README con descrizione + istruzioni run.
4. **Demo Video 3–5 min**: problema+idea, live demo, spiegazione meccaniche gameful.
5. **Sprints Description + Group Management (PDF)**: sprint, ruoli, workplan.
- Nota: tutti i deliverable devono essere coerenti e rappresentare lo stato finale.
- Assenti nel PDF: rubric/pesi, scadenze, template pagine, piattaforma di consegna.

### 3. Gamification Engine (da `OneDrive_2_9-5-2026/README.md` + Postman + `test2.json`)
- Base URL: `https://gamification-api.polyglot-edu.com/gamification` + dashboard `https://gamification.polyglot-edu.com/gamification`, Swagger disponibile.
- Auth: Basic `sco_master` / password (ATTENZIONE: discrepanza `0iiOCxv14qUo` nel README vs `RCtO867ww.d` nella Postman collection; gameId `695bf66160d8fa02e0c31013` nel README vs `6930249860d8fa02e0c3100d` nella collection — da verificare).
- Concetti: PointConcept `xp` con periodi daily+weekly, Badge = collection, Levels = singolo oggetto `experience` con thresholds, level-up automatico.
- Azioni/regole: snake_case obbligatorio, una sola rule per file, Drools con `salience -1000`, `BadgeNotification`/`BadgeUpdate`.
- Endpoint chiave: `POST /gengine/execute`, `POST /data/game/{id}/player/{name}`, `GET /gengine/state/{id}?size=100`, `POST /model/game/{id}/badges`, `POST /model/game/{id}/rule`.

### 4. Materiale corso (da `OneDrive_1_9-5-2026/`, inventario)
- Riferimento diretto Slay: `PROJECTS/Slay the Roadmap/` (assignment2 user stories + Octalysis + short description) + foglio Toda `Slay the Roadmap` + `Element, Actions, Mockups/` (formato assignment1).
- PENDING: dettaglio concept (user stories, meccaniche, mockup) — task in corso, verrà integrato in `02_concept_e_gap.md`.
- Altro: GDD esemplificativi, slide teoria, tutorial OSM POI (non pertinente a Slay), paper GamiDOC, feedback GamiDOC altri team (criteri impliciti: target preciso, aim non generico).
- `Challenge EGS2025-2026.pdf` = solo certificati eccellenza (Ungrowth, Readi, Re:Discover), NON un brief.
- `Programma Pomeridiano_COTB.pdf` = programma Cartoons on the Bay, non pertinente.
- Seminari Bassanelli (User Research, 1–2 Dec 2025): richiesti metodo + questionario UX + think-aloud per valutazione.

## Prossimo passo
Completare `02_concept_e_gap.md`, `03_checklist_deliverable.md`, `04_piano_azione.md` dopo l'analisi concept.
Vedi `INDICE.md` per la struttura.
