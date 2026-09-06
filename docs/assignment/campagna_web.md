# Campagna Web — fondamenta (content spec, Capitolo 1 completo)

Principio: zero sintassi, solo modelli mentali (perché/come/cosa-succede-se). Quiz in italiano, semplici, 5 per topic (80% = 4/5).

## Mappa ID (stabili, snake_case)

| Capitolo | Root id | Subtopic id | Quiz id (= `quiz_<topic>`) |
|---|---|---|---|
| 1 La Rete | `web_network` | `net_client_server`, `net_dns_url`, `net_http_https` | quiz_web_network, quiz_net_client_server, ... |
| 2 Dati e Stato | `web_data` | `data_represent`, `data_where`, `data_state` | ... |
| 3 Costruire sul Web | `web_building` | `build_browser`, `build_framework`, `build_ship` | ... |

Boss (id rinominati, display tematici): `man_in_the_middle` (cap1), `the_amnesiac` (cap2), `spaghetti_colossus` (cap3). Prereq catena: cap2 richiede `man_in_the_middle`, cap3 richiede `the_amnesiac`. Badge Hub dinamici (nessun cambio Hub). Save vecchi: chiavi boss datate innocue; consigliato New Run.

## Root (inquadramento, 1 detail + 1 quiz da 5 ciascuno)

### Root `web_network` — La rete in un quadro
Detail: Il web è una rete di computer che si parlano a strati: ogni strato risolve un problema diverso — trovare l'altro (nomi e indirizzi), mettersi d'accordo su come parlare (protocolli), scambiarsi contenuti. Separare i ruoli significa poter rompere e riparare un pezzo senza buttare tutto: se cambia il Wi-Fi, i nomi restano; se cambia un server, il browser resta. Studiare prima la rete ha senso perché ogni scelta dopo (dati, pagine, app) deve fare i conti con come viaggiano le informazioni.
Link: MDN https://developer.mozilla.org/en-US/docs/Learn_web_development/Howto/Web_mechanics/How_does_the_Internet_work · Cloudflare https://www.cloudflare.com/learning/network-layer/how-does-the-internet-work/

Quiz:
1. Perché la rete è organizzata a strati invece che in un unico blocco? A) Per consumare più energia B) Ogni strato risolve un problema diverso e si può cambiare senza rompere gli altri ✓ C) Perché è più lenta e sicura D) Perché lo impone la legge — Expl: separare i problemi rende la rete riparabile ed evolvibile.
2. Cosa significa che client, DNS e HTTP sono "fondamenta"? A) Sono tecnologie vecchie e superate B) Tutto ciò che costruirai dopo (dati, pagine, app) si appoggia su di essi ✓ C) Vanno imparati a memoria D) Funzionano solo con un unico fornitore — Expl: le fondamenta non si vedono ma reggono i piani alti.
3. Il sito non si apre: perché il modello a ruoli aiuta a capire il guasto? A) Non aiuta, bisogna reinstallare tutto B) Permette di isolare il colpevole: il nome? l'indirizzo? il server? la risposta? ✓ C) Dice sempre di cambiare browser D) Rende tutto più veloce — Expl: ruoli separati = colpevoli separati.
4. Perché ogni attore fa solo il suo mestiere (il DNS traduce, HTTP conversa, il browser mostra)? A) Per pigrizia B) Specializzazione: se uno cambia tecnologia, gli altri non si rompono ✓ C) Per risparmiare elettricità D) Per caso storico — Expl: interfacce stabili tra ruoli permettono innovazione indipendente.
5. Perché studiare la rete prima dei dati e della costruzione? A) Ordine alfabetico B) Prima capisci come viaggiano le informazioni, poi cosa sono e come impacchettarle ✓ C) Perché la rete è più facile D) È indifferente, l'ordine è casuale — Expl: il viaggio spiega i vincoli di tutto il resto.

### Root `web_data` — I dati in un quadro
Detail: Tutto ciò che vedi sul web è dati in viaggio: testi, immagini, prezzi, messaggi. Prima di mostrarli bisogna decidere come rappresentarli (in che forma), dove tenerli (chi li custodisce) e come ricordare da dove eravamo rimasti (lo stato). Queste tre domande tornano in ogni app: un social, un negozio, un gioco. Capirle a livello di idee — senza sintassi — ti permette di valutare qualsiasi tecnologia dopo.
Link: MDN https://developer.mozilla.org/en-US/docs/Learn_web_development/Core/Scripting/JSON · roadmap.sh https://roadmap.sh/databases

Quiz:
1. Perché si dice che "il web è dati in viaggio"? A) Perché i cavi si muovono B) Pagine, prezzi e messaggi sono dati spediti tra client e server e poi mostrati ✓ C) Perché tutto è video D) Perché i dati si cancellano da soli — Expl: la pagina è solo l'ultima tappa di dati in movimento.
2. Perché la rappresentazione dei dati conta più di quanto sembri? A) Non conta nulla B) La stessa informazione in forme diverse cambia peso, leggibilità e chi può capirla (persone o programmi) ✓ C) Conta solo per i colori D) Serve solo ai database — Expl: la forma decide costo di viaggio e facilità d'uso.
3. Perché non tenere tutti i dati nel browser dell'utente? A) Perché è vietato B) Il browser si chiude, si perde e non è condiviso: serve un custode stabile e comune ✓ C) Perché il browser è lento a mostrare D) Perché costa di più — Expl: ciò che deve durare e valere per tutti vive altrove.
4. Perché il problema "ricordarsi di me" esiste sul web? A) Perché gli utenti sono smemorati B) La conversazione base non ha memoria: ogni richiesta riparte da zero ✓ C) Perché i server sono spenti D) Perché i browser cancellano tutto per dispetto — Expl: senza memoria aggiuntiva, il server non riconosce nessuno.
5. Cosa accomuna un negozio, un social e un gioco online dal punto di vista dei dati? A) I colori usati B) Tutti devono rappresentare, custodire e ricordare dati ✓ C) Lo stesso fornitore D) Niente — Expl: cambia il contenuto, il trittico di problemi resta.

### Root `web_building` — Costruire in un quadro
Detail: Costruire sul web significa tre cose: trasformare dati in pagine che il browser sa mostrare, domare la complessità quando le pagine diventano app, e spedire il tutto dal proprio computer ai server degli utenti. Ogni fase ha un suo ostacolo: il browser che interpreta, il caos dell'interfaccia che cresce, il rischio di rompere tutto pubblicando. Questo capitolo ti dà i modelli mentali per non perderti: come ragiona un browser, perché nascono gli strumenti moderni, perché si versiona e si pubblica con cura.
Link: MDN https://developer.mozilla.org/en-US/docs/Learn_web_development/Getting_started/Your_first_website/What_will_your_website_look_like · roadmap.sh https://roadmap.sh/frontend

Quiz:
1. Perché "costruire sul web" non significa solo "scrivere pagine"? A) Perché le pagine non servono B) Perché bisogna anche gestire la complessità crescente e portare il lavoro sui server degli utenti ✓ C) Perché serve un server in casa D) Perché i browser scrivono da soli — Expl: mostrare, organizzare e spedire sono tre mestieri diversi.
2. Perché il browser è il primo "giudice" del tuo lavoro? A) Perché paga lo stipendio B) Qualunque cosa costruisci, è lui a interpretarla e mostrarla all'utente ✓ C) Perché scrive il codice D) Perché sceglie i colori — Expl: il traguardo è sempre ciò che il browser capisce.
3. Perché un progetto piccolo resta semplice e uno grande diventa caos? A) Per sfortuna B) Più pagine e interazioni = più pezzi che si influenzano: serve organizzazione apposta ✓ C) Perché i computer rallentano D) Perché Internet è lento — Expl: la complessità cresce con le connessioni tra pezzi.
4. Perché "spedire" (pubblicare) è parte del costruire? A) Non lo è B) Finché sta solo sul tuo computer, nessun utente può usarlo: il viaggio verso il server completa il lavoro ✓ C) Solo per fare backup D) Solo per i siti grandi — Expl: costruire include mettere il lavoro nelle mani degli utenti.
5. Perché serve tenere traccia delle versioni mentre costruisci? A) Per occupare disco B) Per poter sbagliare senza paura: tornare indietro e confrontare idee ✓ C) Perché è obbligatorio per legge D) Per andare più veloci — Expl: le versioni sono la memoria del progetto.

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

## Capitolo 2 — Dati e Stato 👹 The Amnesiac

### T1 `data_represent` — Rappresentare i dati
Detail: I computer in fondo conoscono solo numeri binari, ma noi ragioniamo in testi, immagini, elenchi: servono formati che facciano da ponte. Il testo è il ponte più universale — leggibile da persone e programmi — ed è per questo che i formati testuali leggeri dominano lo scambio web. Per organizzare le informazioni bastano poche forme mentali: liste (ordine), mappe (nome→valore), alberi (gerarchie di contenuti dentro contenuti). La pagina stessa è un albero (il DOM): nodi annidati che il browser attraversa per mostrare e aggiornare.
Link: MDN https://developer.mozilla.org/en-US/docs/Learn_web_development/Core/Scripting/JSON · MDN https://developer.mozilla.org/en-US/docs/Web/API/Document_Object_Model/Introduction

Quiz:
1. Perché i computer usano il binario ma sul web viaggia tanto testo? A) Il testo è più moderno B) Il testo è leggibile da persone e programmi diversi: fa da ponte universale ✓ C) Il binario è vietato D) Il testo pesa sempre meno — Expl: interoperabilità batte compattezza nello scambio.
2. Un catalogo deve scambiare prodotti tra negozio e fornitori con sistemi diversi: perché un formato testuale standard aiuta? A) È più colorato B) Ogni sistema lo legge e lo produce senza accordi segreti ✓ C) È più veloce del binario D) Non serve Internet — Expl: lo standard elimina il bisogno di parlare la stessa lingua madre.
3. Quando conviene pensare a "lista" e quando a "mappa"? A) Sono uguali B) Lista quando conta l'ordine (commenti in sequenza), mappa quando conta ritrovare per nome (utente→profilo) ✓ C) Lista per i numeri, mappa per le foto D) A caso — Expl: la domanda è "come lo ritroverò?".
4. Perché dire che una pagina è "un albero" (DOM)? A) È verde B) È fatta di nodi annidati (pagina→sezioni→titoli→testi) che si possono attraversare e aggiornare pezzo per pezzo ✓ C) Cresce da sola D) Ha radici nel server — Expl: la gerarchia permette di toccare un ramo senza abbattere il bosco.
5. Spedisci una foto in un formato che il destinatario non apre: dov'è il problema? A) Nella foto B) Nella rappresentazione scelta: senza formato condiviso, il dato è muto ✓ C) Nel cavo D) Nel browser — Expl: il dato esiste solo se entrambe le parti lo interpretano.

### T2 `data_where` — Dove vivono i dati
Detail: Un'app web divide il lavoro in tre case: il frontend (ciò che vedi e tocchi nel browser), il backend (la logica che decide e protegge sul server), il database (la memoria che custodisce e ritrova). Separarli non è burocrazia: ognuno scala e si rompe per conto suo — puoi cambiare i colori senza toccare i pagamenti, o spostare il database senza riscrivere le pagine. Il prezzo è il viaggio: ogni confine attraversato è una richiesta in più, quindi si mette in ogni casa solo ciò che lì ha senso.
Link: MDN https://developer.mozilla.org/en-US/docs/Learn_web_development/Extensions/Server-side/First_steps/Introduction · roadmap.sh https://roadmap.sh/backend

Quiz:
1. Perché dividere frontend, backend e database invece di fare tutto in un unico posto? A) Per usare più computer B) Ogni parte evolve e si rompe per conto suo: si cambia un pezzo senza riscrivere tutto ✓ C) Perché è più veloce sempre D) Perché lo chiede il browser — Expl: separare permette di riparare e far crescere pezzo per pezzo.
2. Dove terresti il saldo del conto corrente: nel browser o nel backend col database? A) Nel browser, è più comodo B) Nel backend: è condiviso, protetto e sopravvive alla chiusura del browser ✓ C) Nel DNS D) Nel CSS — Expl: ciò che deve essere vero per tutti vive sotto custodia.
3. Perché il frontend chiede i dati invece di possederli? A) Pigrizia B) Mostra una copia fresca al momento del bisogno, senza portarsi dietro tutto il mondo ✓ C) Non sa contare D) Costa meno il server — Expl: chiedere all'occorrenza evita copie vecchie e pesanti.
4. Il sito mostra prezzi vecchi dopo un cambio: quale confine sospetti? A) I colori B) La copia tra database, backend e frontend non si è aggiornata lungo il viaggio ✓ C) Il DNS D) La tastiera — Expl: più case = più copie: bisogna capire quale è rimasta indietro.
5. Cosa succede se il database cade ma frontend e backend sono accesi? A) Nulla B) Le pagine si aprono ma i dati veri (prodotti, profili, ordini) mancano ✓ C) Il browser si chiude D) Il DNS smette — Expl: ogni casa è un singolo punto di rottura per il suo mestiere.

### T3 `data_state` — Ricordare (stato, sessioni, cache)
Detail: HTTP è smemorato per disegno: ogni richiesta è nuova, il server non ti riconosce tra una pagina e l'altra. Per questo il web ha inventato memorie aggiuntive: i cookie (bigliettini che il browser ripresenta), le sessioni (il server lega quei bigliettini a un utente collegato), la cache (copie di risposte riusate per non richiederle). Ogni memoria ha un prezzo: i cookie viaggiano sempre, le sessioni vanno protette, le cache possono mostrare copie vecchie. Il mestiere è scegliere cosa ricordare, dove, e per quanto.
Link: MDN https://developer.mozilla.org/en-US/docs/Web/HTTP/Cookies · MDN https://developer.mozilla.org/en-US/docs/Web/HTTP/Caching

Quiz:
1. Perché HTTP è "smemorato" e perché è un problema? A) È rotto B) Ogni richiesta riparte da zero: senza aiuti il server non sa chi sei né a che punto eri ✓ C) Dimentica le password apposta D) Solo di notte — Expl: la semplicità del protocollo scarica la memoria su altri meccanismi.
2. Come fa un sito a ricordarti il login da una pagina all'altra? A) Indovina B) Il browser ripresenta un bigliettino (cookie) e il server lo lega alla tua sessione ✓ C) Lo scrive nell'URL in chiaro D) Lo chiede ogni volta — Expl: riconoscimento = gettone ripresentato + registro lato server.
3. Perché il carrello sopravvive se ricarichi ma sparisce in un altro browser? A) Magia B) La memoria vive in quel browser (cookie/spazio locale), non legata al tuo account server ✓ C) Il server è pieno D) Il DNS filtra — Expl: conta DOVE vive la memoria: dispositivo o account.
4. A cosa serve la cache e qual è il suo rischio? A) A nulla B) Riusa copie per velocità e risparmio, ma rischia di mostrare contenuti vecchi ✓ C) Cifra i dati D) Sostituisce il database — Expl: velocità contro freschezza, sempre.
5. Un sito bancario su PC condiviso: perché il logout conta? A) Spegne il PC B) Invalida la sessione: il bigliettino da solo non basta più a entrare ✓ C) Cancella Internet D) Cambia password — Expl: chiudere la sessione brucia il gettone agli occhi del server.

### Boss cap2 👹 The Amnesiac
Quiz adattivi dai 3 topic sopra (pesca esistente). Lore una riga: "ha cancellato la memoria del web: ti costringe a ricordare tutto da solo, tra bigliettini, sessioni e copie stantie".

## Capitolo 3 — Costruire sul Web 👹 Spaghetti Colossus

### T1 `build_browser` — Come ragiona il browser
Detail: Il browser non "apre file", interpreta: legge il testo della pagina, lo trasforma in albero di nodi (parsing→DOM), poi decide aspetto e posizione di ogni nodo (render) e lo dipinge. Struttura, presentazione e comportamento sono tre mestieri separati: cosa c'è (contenuti e gerarchia), come appare (stili e layout), cosa fa quando interagisci (reazioni). Mescolarli sembra veloce all'inizio, ma ogni modifica tocca tutto: separarli significa cambiare i colori senza rompere i contenuti, o rifare un'interazione senza riscrivere la pagina.
Link: web.dev https://web.dev/howbrowserswork/ · MDN https://developer.mozilla.org/en-US/docs/Web/Performance/How_browsers_work

Quiz:
1. Cosa fa il browser quando "apre" una pagina? A) Mostra il file così com'è B) Legge il testo, costruisce l'albero dei nodi e poi calcola aspetto, posizioni e pittura ✓ C) Chiede all'utente D) Lancia il server — Expl: interpretare, non fotocopiare.
2. Perché separare cosa c'è, come appare e cosa fa? A) Moda B) Per cambiare un aspetto senza rompere gli altri: nuovi colori, stessi contenuti ✓ C) Per andare offline D) Per usare più file — Expl: separazione = modifiche indipendenti.
3. Cambi i colori e sparisce un paragrafo: cosa sospetti? A) Il server B) Presentazione e struttura erano mescolate: toccando l'aspetto hai rotto il contenuto ✓ C) Il DNS D) Il Wi-Fi — Expl: l'intreccio trasforma ogni ritocco in rischio.
4. Perché un errore in un punto può lasciare mezza pagina visibile? A) Fortuna B) Il browser costruisce e mostra pezzo per pezzo: ciò che ha capito lo dipinge ✓ C) Il server aiuta D) La cache nasconde — Expl: il render è progressivo, non tutto-o-niente.
5. Due siti con stessi contenuti ma aspetto ed extra diversi: cosa condividono? A) Niente B) La struttura di base: stessi nodi, diversa veste e diverso comportamento ✓ C) Il server D) Il database — Expl: una struttura, molte presentazioni.

### T2 `build_framework` — Domare la complessità
Detail: Quando le pagine diventano app — decine di schermate che si aggiornano da sole — tenere tutto a mano diventa caos: ogni pezzo tocca gli altri. Gli strumenti moderni rispondono con due idee: i componenti (pezzi riusabili con un mestiere chiaro: pulsante, scheda prodotto, carrello) e lo stato dell'interfaccia (una fonte di verità da cui la vista discende). Il problema vero non è il colore del pulsante, è "quando i dati cambiano, cosa si aggiorna e perché quella cosa lì". Capire il problema vale più di qualsiasi nome di strumento.
Link: MDN https://developer.mozilla.org/en-US/docs/Learn_web_development/Core/Frameworks/Introduction · roadmap.sh https://roadmap.sh/frontend

Quiz:
1. Quando una pagina diventa "app" e perché tutto si complica? A) Quando è lunga B) Quando molti pezzi si aggiornano da soli e si influenzano: ogni cambio ne tocca altri ✓ C) Quando ha immagini D) Quando è online — Expl: la complessità è nelle connessioni tra pezzi.
2. A cosa serve l'idea di componente (pulsante, scheda, carrello)? A) A scrivere di più B) A impacchettare un pezzo con un mestiere chiaro e riusarlo senza ricopiare ✓ C) A colorare D) A velocizzare Internet — Expl: un pezzo, un mestiere, riuso invece di copia-incolla.
3. Cos'è lo "stato dell'interfaccia" in una riga? A) La nazione dell'utente B) La fonte di verità del momento (cosa selezionato, cosa nel carrello) da cui la vista discende ✓ C) La velocità D) Il server — Expl: prima i fatti, poi ciò che si vede li riflette.
4. Il contatore del carrello dice 3 ma dentro ci sono 2 oggetti: dov'è il problema? A) Nei colori B) Vista e stato si sono disallineati: la vista non riflette più la verità ✓ C) Nel DNS D) Nel Wi-Fi — Expl: il bug classico è la doppia verità.
5. Perché "copiare e adattare" lo stesso pezzo in 10 punti diventa un incubo? A) Occupa disco B) Ogni correzione va rifatta 10 volte e una verrà dimenticata ✓ C) È vietato D) Rallenta il browser — Expl: la duplicazione moltiplica il futuro lavoro di riparazione.

### T3 `build_ship` — Versionare e spedire
Detail: Costruire da soli senza rete di sicurezza significa aver paura di ogni modifica: per questo si versiona — ogni tappa salvata è un punto a cui tornare e confrontare. I rami (branch) sono idee parallele che vivono senza disturbarsi, la fusione (merge) è il momento in cui si decide cosa entra nella storia principale. Spedire (dal repo al server) è l'ultimo miglio: impacchettare il lavoro e consegnarlo dove gli utenti lo useranno, con lo stesso risultato ogni volta. Chi versiona e spedisce con cura può osare di più, perché sbagliare costa poco.
Link: git-scm https://git-scm.com/book/en/v2/Getting-Started-About-Version-Control · roadmap.sh https://roadmap.sh/git-github

Quiz:
1. Perché salvare tappe (versioni) invece del solo file finale? A) Per nostalgia B) Per tornare indietro, confrontare idee e capire quando si è rotto cosa ✓ C) Per occupare spazio D) Per legge — Expl: la storia rende gli errori economici.
2. A cosa serve un ramo (branch) come idea, senza tecnicismi? A) A decorare B) A provare un'idea in parallelo senza disturbare il lavoro che funziona ✓ C) A duplicare il server D) A cancellare — Expl: sperimentare al sicuro.
3. Due persone cambiano la stessa parte e poi fondono (merge): cosa può succedere? A) Nulla mai B) Le idee cozzano (conflitto): bisogna decidere a mano cosa tenere ✓ C) Il server esplode D) Il DNS cambia — Expl: il merge unisce, ma le contraddizioni si risolvono a mano.
4. Perché "sul mio computer funziona" non basta? A) Perché mente B) Il tuo computer non è quello degli utenti: manca la consegna uguale-per-tutti dal server ✓ C) Perché è lento D) Perché manca il DNS — Expl: finché non è impacchettato e consegnato, non esiste per gli altri.
5. Perché spedire spesso piccoli passi è più sicuro di un unico grande lancio? A) Non lo è B) Se qualcosa si rompe, sai quale passo è colpevole e torni indietro di poco ✓ C) Costa meno D) È più emozionante — Expl: piccoli passi = colpevoli piccoli e vicini.

### Boss cap3 👹 Spaghetti Colossus
Quiz adattivi dai 3 topic sopra (pesca esistente). Lore una riga: "un ammasso di pagine copiate e mai versionate: ogni modifica spezza qualcos'altro".

## Lore boss (una riga ciascuno)

- 👹 Man-in-the-Middle (cap1): "vive nei Wi-Fi aperti e legge ciò che non è cifrato".
- 👹 The Amnesiac (cap2): "ha cancellato la memoria del web: ti costringe a ricordare tutto da solo, tra bigliettini, sessioni e copie stantie".
- 👹 Spaghetti Colossus (cap3): "un ammasso di pagine copiate e mai versionate: ogni modifica spezza qualcos'altro".

## Checklist implementazione (dopo ok)

1. `roadmap_repository.dart`: nuovo seed 3 root + 9 sub (id sopra), prereq catena, `bossId`/`requiredBossId` nuovi boss-id.
2. `topic_detail_repository.dart`: 12 detail nuovi (testi sopra per cap1).
3. `quiz_repository.dart`: 12 quiz nuovi (domande sopra per cap1; formato esistente 5×4 opzioni+explanation).
4. `boss_repository.dart`: nomi/lore nuovi boss, chapterId capitoli, adaptiveQuizzes dai topic del capitolo.
5. Carte: per ora generiche (flavor web rinviato). Hub: nessun cambio (badge dinamici). Test: aggiornare id attesi. Consigliato New Run (save con vecchi id).
