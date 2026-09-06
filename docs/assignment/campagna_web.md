# Campagna Web — fondamenta (content spec, Capitolo 1 completo)

Principio: zero sintassi, solo modelli mentali (perché/come/cosa-succede-se). Quiz in italiano, semplici, 5 per topic (80% = 4/5).

## Mappa ID (stabili, snake_case)

| Capitolo | Root id | Subtopic id | Quiz id (= `quiz_<topic>`) |
|---|---|---|---|
| 1 La Rete | `web_network` | `net_client_server`, `net_dns_url`, `net_http_https` | quiz_web_network, quiz_net_client_server, ... |
| 2 Dati e Stato | `web_data` | `data_represent`, `data_where`, `data_state` | ... |
| 3 Costruire sul Web | `web_building` | `build_browser`, `build_framework`, `build_ship` | ... |

Boss (id rinominati, display tematici): `man_in_the_middle` (cap1), `the_amnesiac` (cap2), `spaghetti_colossus` (cap3). Prereq catena: cap2 richiede `man_in_the_middle`, cap3 richiede `the_amnesiac`. Badge Hub dinamici (nessun cambio Hub). Save vecchi: chiavi boss datate innocue; consigliato New Run.

## Capitolo 1 — La Rete 👹 Man-in-the-Middle

### T1 `net_client_server` — Client e server
Detail: Il web è una conversazione tra due ruoli. Il client (browser) chiede, il server risponde: ogni pagina è una sequenza di richieste e risposte, mai il server che "spinge" da solo. Il codice può girare sul client (interazione immediata) o sul server (dati protetti e condivisi): dove lo metti cambia velocità, sicurezza e chi paga il conto computazionale.
Link: MDN https://developer.mozilla.org/en-US/docs/Learn_web_development/Howto/Web_mechanics/What_is_a_web_server · web.dev https://web.dev/howbrowserswork/

Quiz:
1. Apri un sito: chi inizia la conversazione? A) Il server invia la pagina da solo B) Il client chiede, il server risponde ✓ C) Il DNS crea la pagina D) Il browser indovina — Expl: tutto parte da una richiesta del client.
2. Perché il codice dei pagamenti gira sul server e non nel browser? A) È più veloce B) Nel browser chiunque potrebbe leggerlo e manometterlo ✓ C) Il browser non esegue codice D) Costa meno — Expl: il client è ispezionabile, i segreti stanno sul server.
3. Il server può aggiornare la tua pagina senza che tu chieda nulla? A) Sì, quando vuole B) No: HTTP è richiesta→risposta, serve una nuova richiesta (o canali apposta) ✓ C) Solo di notte D) Solo con HTTPS — Expl: il modello base è pull, non push.
4. Cosa distingue un client da un server? A) La potenza del computer B) Il ruolo nella conversazione: chi chiede vs chi risponde ✓ C) Il sistema operativo D) Il linguaggio usato — Expl: sono ruoli, non macchine (una macchina può fare entrambi).
5. Un sito lento a mostrare i vestiti filtrati: dove conviene filtrare, client o server, se il catalogo è enorme? A) Client, è più moderno B) Server: evita di spedire tutto il catalogo nel browser ✓ C) Nel DNS D) Nel CSS — Expl: meno dati viaggiano, prima vedi risultati.

### T2 `net_dns_url` — Indirizzi e nomi
Detail: I computer si trovano con indirizzi IP numerici, impossibili da ricordare: il DNS è la rubrica che traduce nomi (es. esempio.it) in IP. L'URL è l'indirizzo completo della risorsa: protocollo, nome, porta, percorso e parametri dicono al browser dove andare e cosa chiedere. Senza DNS digiteremmo numeri; senza URL non sapremmo quale pagina di quel server vogliamo.
Link: Cloudflare https://www.cloudflare.com/learning/dns/what-is-dns/ · MDN https://developer.mozilla.org/en-US/docs/Learn_web_development/Howto/Web_mechanics/What_is_a_URL

Quiz:
1. A cosa serve il DNS? A) Cifrare i dati B) Tradurre nomi di dominio in indirizzi IP ✓ C) Creare pagine web D) Velocizzare il CSS — Expl: è la rubrica di Internet.
2. In `https://shop.it:443/scarpe?taglia=42`, cosa dice DOVE si trova la risorsa? A) Solo `https` B) Nome + percorso (`shop.it/scarpe`) ✓ C) Solo `?taglia=42` D) Niente, è casuale — Expl: nome e path localizzano, i parametri filtrano.
3. Se il DNS non risponde, cosa succede? A) Navigo più lento B) Il browser non sa che IP contattare: il sito non si apre ✓ C) Si apre in HTTP D) Vedo il sito di ieri — Expl: senza traduzione nome→IP non si parte.
4. Perché esistono le porte (es. :443)? A) Decorazione B) Distinguono i servizi sulla stessa macchina (web, mail...) ✓ C) Cifrano D) Comprimono — Expl: un IP, tanti servizi: la porta sceglie quale.
5. `HTTP` vs `HTTPS` nell'URL: cosa cambia per l'utente? A) Niente B) La connessione è cifrata: dati illeggibili a chi intercetta ✓ C) Il sito è più bello D) Serve password — Expl: la S = trasporto cifrato.

### T3 `net_http_https` — HTTP e HTTPS
Detail: HTTP è il linguaggio della conversazione web: metodi (GET per leggere, POST per inviare...), status code (200 ok, 404 non trovato, 500 errore server) e header (metadati). Viaggia in chiaro: chi intercetta legge tutto — per questo esiste HTTPS, che cifra il canale con TLS. Il lucchetto non dice "sito onesto", dice "nessuno in mezzo può leggere".
Link: MDN https://developer.mozilla.org/en-US/docs/Web/HTTP/Overview · Cloudflare https://www.cloudflare.com/learning/ssl/what-is-https/

Quiz:
1. Compili un form con la carta: perché serve HTTPS? A) Il sito carica prima B) In HTTP chi intercetta legge tutto in chiaro ✓ C) Evita i 404 D) Il browser lo richiede per i colori — Expl: cifratura del trasporto, non del sito.
2. Il sito risponde 404: di chi è "colpa"? A) Del server rotto B) Della risorsa chiesta: non esiste a quell'indirizzo ✓ C) Del DNS D) Di HTTPS — Expl: 4xx = errore del client/richiesta, 5xx = server.
3. GET vs POST: differenza di idea? A) Nessuna B) GET legge (ripetibile, nei log/URL), POST invia dati che cambiano stato ✓ C) POST è più veloce D) GET cifra — Expl: semantica, non velocità.
4. Il lucchetto del browser garantisce che il negozio è onesto? A) Sì B) No: garantisce solo canale cifrato e identità verificata del dominio ✓ C) Sì se verde D) Solo per le banche — Expl: cifratura ≠ affidabilità.
5. Un Wi-Fi pubblico con Man-in-the-Middle: cosa rischia chi usa HTTP? A) Nulla B) Lettura e modifica del traffico in chiaro ✓ C) Solo lentezza D) Virus nel DNS — Expl: il mostro del capitolo esiste davvero.

### Boss cap1 👹 Man-in-the-Middle
Quiz adattivi dai 3 topic sopra (pesca esistente). Lore una riga: "vive nei Wi-Fi aperti e legge ciò che non è cifrato".

## Capitoli 2-3 (scheletro, da dettagliare dopo ok cap1)

- Cap2 Dati e Stato 👹 The Amnesiac: `data_represent` (testo/binario, JSON, liste/mappe/alberi), `data_where` (frontend/backend/database: perché separare), `data_state` (stateless, cookie/sessioni, cache).
- Cap3 Costruire sul Web 👹 Spaghetti Colossus: `build_browser` (parsing→DOM→render, separazione struttura/presentazione/comportamento), `build_framework` (complessità, componenti, stato UI), `build_ship` (perché versionare, dal repo al server).

## Checklist implementazione (dopo ok)

1. `roadmap_repository.dart`: nuovo seed 3 root + 9 sub (id sopra), prereq catena, `bossId`/`requiredBossId` nuovi boss-id.
2. `topic_detail_repository.dart`: 12 detail nuovi (testi sopra per cap1).
3. `quiz_repository.dart`: 12 quiz nuovi (domande sopra per cap1; formato esistente 5×4 opzioni+explanation).
4. `boss_repository.dart`: nomi/lore nuovi boss, chapterId capitoli, adaptiveQuizzes dai topic del capitolo.
5. Carte: per ora generiche (flavor web rinviato). Hub: nessun cambio (badge dinamici). Test: aggiornare id attesi. Consigliato New Run (save con vecchi id).
