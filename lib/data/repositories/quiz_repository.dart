import '../../domain/models/quiz.dart';

abstract class QuizRepository {
  Future<Quiz> getQuizForTopic(String topicId);
  Future<QuizResult> submitQuizAnswers(String quizId, List<int> selectedAnswers);
}

class LocalQuizRepository implements QuizRepository {
  final Map<String, Quiz> _quizzes = {
    'quiz_web_network': const Quiz(
      id: 'quiz_web_network',
      topicId: 'web_network',
      passingThreshold: 80,
      questions: [
        const Question(
          text: 'Perché la rete è organizzata a strati invece che in un unico blocco?',
          options: [
            'Per consumare più energia',
            'Ogni strato risolve un problema diverso e si può cambiare senza rompere gli altri',
            'Perché è più lenta e sicura',
            'Perché lo impone la legge',
          ],
          correctAnswerIndex: 1,
          explanation: 'Separare i problemi rende la rete riparabile ed evolvibile.',
        ),
        const Question(
          text: 'Cosa significa che client, DNS e HTTP sono "fondamenta"?',
          options: [
            'Sono tecnologie vecchie e superate',
            'Tutto ciò che costruirai dopo (dati, pagine, app) si appoggia su di essi',
            'Vanno imparati a memoria',
            'Funzionano solo con un unico fornitore',
          ],
          correctAnswerIndex: 1,
          explanation: 'Le fondamenta non si vedono ma reggono i piani alti.',
        ),
        const Question(
          text: 'Il sito non si apre: perché il modello a ruoli aiuta a capire il guasto?',
          options: [
            'Non aiuta, bisogna reinstallare tutto',
            'Permette di isolare il colpevole: il nome? l\u2019indirizzo? il server? la risposta?',
            'Dice sempre di cambiare browser',
            'Rende tutto più veloce',
          ],
          correctAnswerIndex: 1,
          explanation: 'Ruoli separati = colpevoli separati.',
        ),
        const Question(
          text: 'Perché ogni attore fa solo il suo mestiere (il DNS traduce, HTTP conversa, il browser mostra)?',
          options: [
            'Per pigrizia',
            'Specializzazione: se uno cambia tecnologia, gli altri non si rompono',
            'Per risparmiare elettricità',
            'Per caso storico',
          ],
          correctAnswerIndex: 1,
          explanation: 'Interfacce stabili tra ruoli permettono innovazione indipendente.',
        ),
        const Question(
          text: 'Perché studiare la rete prima dei dati e della costruzione?',
          options: [
            'Ordine alfabetico',
            'Prima capisci come viaggiano le informazioni, poi cosa sono e come impacchettarle',
            'Perché la rete è più facile',
            'È indifferente, l\u2019ordine è casuale',
          ],
          correctAnswerIndex: 1,
          explanation: 'Il viaggio spiega i vincoli di tutto il resto.',
        ),
      ],
    ),
    'quiz_net_client_server': const Quiz(
      id: 'quiz_net_client_server',
      topicId: 'net_client_server',
      passingThreshold: 80,
      questions: [
        const Question(
          text: 'Apri un sito: chi inizia la conversazione?',
          options: [
            'Il server invia la pagina da solo',
            'Il client chiede, il server risponde',
            'Il DNS crea la pagina',
            'Il browser indovina',
          ],
          correctAnswerIndex: 1,
          explanation: 'Tutto parte da una richiesta del client.',
        ),
        const Question(
          text: 'Perché il codice dei pagamenti gira sul server e non nel browser?',
          options: [
            'È più veloce',
            'Nel browser chiunque potrebbe leggerlo e manometterlo',
            'Il browser non esegue codice',
            'Costa meno',
          ],
          correctAnswerIndex: 1,
          explanation: 'Il client è ispezionabile, i segreti stanno sul server.',
        ),
        const Question(
          text: 'Il server può aggiornare la tua pagina senza che tu chieda nulla?',
          options: [
            'Sì, quando vuole',
            'No: HTTP è richiesta→risposta, serve una nuova richiesta (o canali apposta)',
            'Solo di notte',
            'Solo con HTTPS',
          ],
          correctAnswerIndex: 1,
          explanation: 'Il modello base è pull, non push.',
        ),
        const Question(
          text: 'Cosa distingue un client da un server?',
          options: [
            'La potenza del computer',
            'Il ruolo nella conversazione: chi chiede vs chi risponde',
            'Il sistema operativo',
            'Il linguaggio usato',
          ],
          correctAnswerIndex: 1,
          explanation: 'Sono ruoli, non macchine (una macchina può fare entrambi).',
        ),
        const Question(
          text: 'Un sito lento a mostrare i vestiti filtrati: dove conviene filtrare, client o server, se il catalogo è enorme?',
          options: [
            'Client, è più moderno',
            'Server: evita di spedire tutto il catalogo nel browser',
            'Nel DNS',
            'Nel CSS',
          ],
          correctAnswerIndex: 1,
          explanation: 'Meno dati viaggiano, prima vedi risultati.',
        ),
      ],
    ),
    'quiz_net_dns_url': const Quiz(
      id: 'quiz_net_dns_url',
      topicId: 'net_dns_url',
      passingThreshold: 80,
      questions: [
        const Question(
          text: 'A cosa serve il DNS?',
          options: [
            'Cifrare i dati',
            'Tradurre nomi di dominio in indirizzi IP',
            'Creare pagine web',
            'Velocizzare il CSS',
          ],
          correctAnswerIndex: 1,
          explanation: 'È la rubrica di Internet.',
        ),
        const Question(
          text: 'In `https://shop.it:443/scarpe?taglia=42`, cosa dice DOVE si trova la risorsa?',
          options: [
            'Solo `https`',
            'Nome + percorso (`shop.it/scarpe`)',
            'Solo `?taglia=42`',
            'Niente, è casuale',
          ],
          correctAnswerIndex: 1,
          explanation: 'Nome e path localizzano, i parametri filtrano.',
        ),
        const Question(
          text: 'Se il DNS non risponde, cosa succede?',
          options: [
            'Navigo più lento',
            'Il browser non sa che IP contattare: il sito non si apre',
            'Si apre in HTTP',
            'Vedo il sito di ieri',
          ],
          correctAnswerIndex: 1,
          explanation: 'Senza traduzione nome→IP non si parte.',
        ),
        const Question(
          text: 'Perché esistono le porte (es. :443)?',
          options: [
            'Decorazione',
            'Distinguono i servizi sulla stessa macchina (web, mail...)',
            'Cifrano',
            'Comprimono',
          ],
          correctAnswerIndex: 1,
          explanation: 'Un IP, tanti servizi: la porta sceglie quale.',
        ),
        const Question(
          text: 'HTTP vs HTTPS nell\u2019URL: cosa cambia per l\u2019utente?',
          options: [
            'Niente',
            'La connessione è cifrata: dati illeggibili a chi intercetta',
            'Il sito è più bello',
            'Serve password',
          ],
          correctAnswerIndex: 1,
          explanation: 'La S = trasporto cifrato.',
        ),
      ],
    ),
    'quiz_net_http_https': const Quiz(
      id: 'quiz_net_http_https',
      topicId: 'net_http_https',
      passingThreshold: 80,
      questions: [
        const Question(
          text: 'Compili un form con la carta: perché serve HTTPS?',
          options: [
            'Il sito carica prima',
            'In HTTP chi intercetta legge tutto in chiaro',
            'Evita i 404',
            'Il browser lo richiede per i colori',
          ],
          correctAnswerIndex: 1,
          explanation: 'Cifratura del trasporto, non del sito.',
        ),
        const Question(
          text: 'Il sito risponde 404: di chi è "colpa"?',
          options: [
            'Del server rotto',
            'Della risorsa chiesta: non esiste a quell\u2019indirizzo',
            'Del DNS',
            'Di HTTPS',
          ],
          correctAnswerIndex: 1,
          explanation: '4xx = errore del client/richiesta, 5xx = server.',
        ),
        const Question(
          text: 'GET vs POST: differenza di idea?',
          options: [
            'Nessuna',
            'GET legge (ripetibile, nei log/URL), POST invia dati che cambiano stato',
            'POST è più veloce',
            'GET cifra',
          ],
          correctAnswerIndex: 1,
          explanation: 'Semantica, non velocità.',
        ),
        const Question(
          text: 'Il lucchetto del browser garantisce che il negozio è onesto?',
          options: [
            'Sì',
            'No: garantisce solo canale cifrato e identità verificata del dominio',
            'Sì se verde',
            'Solo per le banche',
          ],
          correctAnswerIndex: 1,
          explanation: 'Cifratura ≠ affidabilità.',
        ),
        const Question(
          text: 'Un Wi-Fi pubblico con Man-in-the-Middle: cosa rischia chi usa HTTP?',
          options: [
            'Nulla',
            'Lettura e modifica del traffico in chiaro',
            'Solo lentezza',
            'Virus nel DNS',
          ],
          correctAnswerIndex: 1,
          explanation: 'Il mostro del capitolo esiste davvero.',
        ),
      ],
    ),
    'quiz_web_data': const Quiz(
      id: 'quiz_web_data',
      topicId: 'web_data',
      passingThreshold: 80,
      questions: [
        const Question(
          text: 'Perché si dice che "il web è dati in viaggio"?',
          options: [
            'Perché i cavi si muovono',
            'Pagine, prezzi e messaggi sono dati spediti tra client e server e poi mostrati',
            'Perché tutto è video',
            'Perché i dati si cancellano da soli',
          ],
          correctAnswerIndex: 1,
          explanation: 'La pagina è solo l\u2019ultima tappa di dati in movimento.',
        ),
        const Question(
          text: 'Perché la rappresentazione dei dati conta più di quanto sembri?',
          options: [
            'Non conta nulla',
            'La stessa informazione in forme diverse cambia peso, leggibilità e chi può capirla (persone o programmi)',
            'Conta solo per i colori',
            'Serve solo ai database',
          ],
          correctAnswerIndex: 1,
          explanation: 'La forma decide costo di viaggio e facilità d\u2019uso.',
        ),
        const Question(
          text: 'Perché non tenere tutti i dati nel browser dell\u2019utente?',
          options: [
            'Perché è vietato',
            'Il browser si chiude, si perde e non è condiviso: serve un custode stabile e comune',
            'Perché il browser è lento a mostrare',
            'Perché costa di più',
          ],
          correctAnswerIndex: 1,
          explanation: 'Ciò che deve durare e valere per tutti vive altrove.',
        ),
        const Question(
          text: 'Perché il problema "ricordarsi di me" esiste sul web?',
          options: [
            'Perché gli utenti sono smemorati',
            'La conversazione base non ha memoria: ogni richiesta riparte da zero',
            'Perché i server sono spenti',
            'Perché i browser cancellano tutto per dispetto',
          ],
          correctAnswerIndex: 1,
          explanation: 'Senza memoria aggiuntiva, il server non riconosce nessuno.',
        ),
        const Question(
          text: 'Cosa accomuna un negozio, un social e un gioco online dal punto di vista dei dati?',
          options: [
            'I colori usati',
            'Tutti devono rappresentare, custodire e ricordare dati',
            'Lo stesso fornitore',
            'Niente',
          ],
          correctAnswerIndex: 1,
          explanation: 'Cambia il contenuto, il trittico di problemi resta.',
        ),
      ],
    ),
    'quiz_data_represent': const Quiz(
      id: 'quiz_data_represent',
      topicId: 'data_represent',
      passingThreshold: 80,
      questions: [
        const Question(
          text: 'Perché i computer usano il binario ma sul web viaggia tanto testo?',
          options: [
            'Il testo è più moderno',
            'Il testo è leggibile da persone e programmi diversi: fa da ponte universale',
            'Il binario è vietato',
            'Il testo pesa sempre meno',
          ],
          correctAnswerIndex: 1,
          explanation: 'Interoperabilità batte compattezza nello scambio.',
        ),
        const Question(
          text: 'Un catalogo deve scambiare prodotti tra negozio e fornitori con sistemi diversi: perché un formato testuale standard aiuta?',
          options: [
            'È più colorato',
            'Ogni sistema lo legge e lo produce senza accordi segreti',
            'È più veloce del binario',
            'Non serve Internet',
          ],
          correctAnswerIndex: 1,
          explanation: 'Lo standard elimina il bisogno di parlare la stessa lingua madre.',
        ),
        const Question(
          text: 'Quando conviene pensare a "lista" e quando a "mappa"?',
          options: [
            'Sono uguali',
            'Lista quando conta l\u2019ordine (commenti in sequenza), mappa quando conta ritrovare per nome (utente→profilo)',
            'Lista per i numeri, mappa per le foto',
            'A caso',
          ],
          correctAnswerIndex: 1,
          explanation: 'La domanda è "come lo ritroverò?".',
        ),
        const Question(
          text: 'Perché dire che una pagina è "un albero" (DOM)?',
          options: [
            'È verde',
            'È fatta di nodi annidati (pagina→sezioni→titoli→testi) che si possono attraversare e aggiornare pezzo per pezzo',
            'Cresce da sola',
            'Ha radici nel server',
          ],
          correctAnswerIndex: 1,
          explanation: 'La gerarchia permette di toccare un ramo senza abbattere il bosco.',
        ),
        const Question(
          text: 'Spedisci una foto in un formato che il destinatario non apre: dov\u2019è il problema?',
          options: [
            'Nella foto',
            'Nella rappresentazione scelta: senza formato condiviso, il dato è muto',
            'Nel cavo',
            'Nel browser',
          ],
          correctAnswerIndex: 1,
          explanation: 'Il dato esiste solo se entrambe le parti lo interpretano.',
        ),
      ],
    ),
    'quiz_data_where': const Quiz(
      id: 'quiz_data_where',
      topicId: 'data_where',
      passingThreshold: 80,
      questions: [
        const Question(
          text: 'Perché dividere frontend, backend e database invece di fare tutto in un unico posto?',
          options: [
            'Per usare più computer',
            'Ogni parte evolve e si rompe per conto suo: si cambia un pezzo senza riscrivere tutto',
            'Perché è più veloce sempre',
            'Perché lo chiede il browser',
          ],
          correctAnswerIndex: 1,
          explanation: 'Separare permette di riparare e far crescere pezzo per pezzo.',
        ),
        const Question(
          text: 'Dove terresti il saldo del conto corrente: nel browser o nel backend col database?',
          options: [
            'Nel browser, è più comodo',
            'Nel backend: è condiviso, protetto e sopravvive alla chiusura del browser',
            'Nel DNS',
            'Nel CSS',
          ],
          correctAnswerIndex: 1,
          explanation: 'Ciò che deve essere vero per tutti vive sotto custodia.',
        ),
        const Question(
          text: 'Perché il frontend chiede i dati invece di possederli?',
          options: [
            'Pigrizia',
            'Mostra una copia fresca al momento del bisogno, senza portarsi dietro tutto il mondo',
            'Non sa contare',
            'Costa meno il server',
          ],
          correctAnswerIndex: 1,
          explanation: 'Chiedere all\u2019occorrenza evita copie vecchie e pesanti.',
        ),
        const Question(
          text: 'Il sito mostra prezzi vecchi dopo un cambio: quale confine sospetti?',
          options: [
            'I colori',
            'La copia tra database, backend e frontend non si è aggiornata lungo il viaggio',
            'Il DNS',
            'La tastiera',
          ],
          correctAnswerIndex: 1,
          explanation: 'Più case = più copie: bisogna capire quale è rimasta indietro.',
        ),
        const Question(
          text: 'Cosa succede se il database cade ma frontend e backend sono accesi?',
          options: [
            'Nulla',
            'Le pagine si aprono ma i dati veri (prodotti, profili, ordini) mancano',
            'Il browser si chiude',
            'Il DNS smette',
          ],
          correctAnswerIndex: 1,
          explanation: 'Ogni casa è un singolo punto di rottura per il suo mestiere.',
        ),
      ],
    ),
    'quiz_data_state': const Quiz(
      id: 'quiz_data_state',
      topicId: 'data_state',
      passingThreshold: 80,
      questions: [
        const Question(
          text: 'Perché HTTP è "smemorato" e perché è un problema?',
          options: [
            'È rotto',
            'Ogni richiesta riparte da zero: senza aiuti il server non sa chi sei né a che punto eri',
            'Dimentica le password apposta',
            'Solo di notte',
          ],
          correctAnswerIndex: 1,
          explanation: 'La semplicità del protocollo scarica la memoria su altri meccanismi.',
        ),
        const Question(
          text: 'Come fa un sito a ricordarti il login da una pagina all\u2019altra?',
          options: [
            'Indovina',
            'Il browser ripresenta un bigliettino (cookie) e il server lo lega alla tua sessione',
            'Lo scrive nell\u2019URL in chiaro',
            'Lo chiede ogni volta',
          ],
          correctAnswerIndex: 1,
          explanation: 'Riconoscimento = gettone ripresentato + registro lato server.',
        ),
        const Question(
          text: 'Perché il carrello sopravvive se ricarichi ma sparisce in un altro browser?',
          options: [
            'Magia',
            'La memoria vive in quel browser (cookie/spazio locale), non legata al tuo account server',
            'Il server è pieno',
            'Il DNS filtra',
          ],
          correctAnswerIndex: 1,
          explanation: 'Conta DOVE vive la memoria: dispositivo o account.',
        ),
        const Question(
          text: 'A cosa serve la cache e qual è il suo rischio?',
          options: [
            'A nulla',
            'Riusa copie per velocità e risparmio, ma rischia di mostrare contenuti vecchi',
            'Cifra i dati',
            'Sostituisce il database',
          ],
          correctAnswerIndex: 1,
          explanation: 'Velocità contro freschezza, sempre.',
        ),
        const Question(
          text: 'Un sito bancario su PC condiviso: perché il logout conta?',
          options: [
            'Spegne il PC',
            'Invalida la sessione: il bigliettino da solo non basta più a entrare',
            'Cancella Internet',
            'Cambia password',
          ],
          correctAnswerIndex: 1,
          explanation: 'Chiudere la sessione brucia il gettone agli occhi del server.',
        ),
      ],
    ),
    'quiz_web_building': const Quiz(
      id: 'quiz_web_building',
      topicId: 'web_building',
      passingThreshold: 80,
      questions: [
        const Question(
          text: 'Perché "costruire sul web" non significa solo "scrivere pagine"?',
          options: [
            'Perché le pagine non servono',
            'Perché bisogna anche gestire la complessità crescente e portare il lavoro sui server degli utenti',
            'Perché serve un server in casa',
            'Perché i browser scrivono da soli',
          ],
          correctAnswerIndex: 1,
          explanation: 'Mostrare, organizzare e spedire sono tre mestieri diversi.',
        ),
        const Question(
          text: 'Perché il browser è il primo "giudice" del tuo lavoro?',
          options: [
            'Perché paga lo stipendio',
            'Qualunque cosa costruisci, è lui a interpretarla e mostrarla all\u2019utente',
            'Perché scrive il codice',
            'Perché sceglie i colori',
          ],
          correctAnswerIndex: 1,
          explanation: 'Il traguardo è sempre ciò che il browser capisce.',
        ),
        const Question(
          text: 'Perché un progetto piccolo resta semplice e uno grande diventa caos?',
          options: [
            'Per sfortuna',
            'Più pagine e interazioni = più pezzi che si influenzano: serve organizzazione apposta',
            'Perché i computer rallentano',
            'Perché Internet è lento',
          ],
          correctAnswerIndex: 1,
          explanation: 'La complessità cresce con le connessioni tra pezzi.',
        ),
        const Question(
          text: 'Perché "spedire" (pubblicare) è parte del costruire?',
          options: [
            'Non lo è',
            'Finché sta solo sul tuo computer, nessun utente può usarlo: il viaggio verso il server completa il lavoro',
            'Solo per fare backup',
            'Solo per i siti grandi',
          ],
          correctAnswerIndex: 1,
          explanation: 'Costruire include mettere il lavoro nelle mani degli utenti.',
        ),
        const Question(
          text: 'Perché serve tenere traccia delle versioni mentre costruisci?',
          options: [
            'Per occupare disco',
            'Per poter sbagliare senza paura: tornare indietro e confrontare idee',
            'Perché è obbligatorio per legge',
            'Per andare più veloci',
          ],
          correctAnswerIndex: 1,
          explanation: 'Le versioni sono la memoria del progetto.',
        ),
      ],
    ),
    'quiz_build_browser': const Quiz(
      id: 'quiz_build_browser',
      topicId: 'build_browser',
      passingThreshold: 80,
      questions: [
        const Question(
          text: 'Cosa fa il browser quando "apre" una pagina?',
          options: [
            'Mostra il file così com\u2019è',
            'Legge il testo, costruisce l\u2019albero dei nodi e poi calcola aspetto, posizioni e pittura',
            'Chiede all\u2019utente',
            'Lancia il server',
          ],
          correctAnswerIndex: 1,
          explanation: 'Interpretare, non fotocopiare.',
        ),
        const Question(
          text: 'Perché separare cosa c\u2019è, come appare e cosa fa?',
          options: [
            'Moda',
            'Per cambiare un aspetto senza rompere gli altri: nuovi colori, stessi contenuti',
            'Per andare offline',
            'Per usare più file',
          ],
          correctAnswerIndex: 1,
          explanation: 'Separazione = modifiche indipendenti.',
        ),
        const Question(
          text: 'Cambi i colori e sparisce un paragrafo: cosa sospetti?',
          options: [
            'Il server',
            'Presentazione e struttura erano mescolate: toccando l\u2019aspetto hai rotto il contenuto',
            'Il DNS',
            'Il Wi-Fi',
          ],
          correctAnswerIndex: 1,
          explanation: 'L\u2019intreccio trasforma ogni ritocco in rischio.',
        ),
        const Question(
          text: 'Perché un errore in un punto può lasciare mezza pagina visibile?',
          options: [
            'Fortuna',
            'Il browser costruisce e mostra pezzo per pezzo: ciò che ha capito lo dipinge',
            'Il server aiuta',
            'La cache nasconde',
          ],
          correctAnswerIndex: 1,
          explanation: 'Il render è progressivo, non tutto-o-niente.',
        ),
        const Question(
          text: 'Due siti con stessi contenuti ma aspetto ed extra diversi: cosa condividono?',
          options: [
            'Niente',
            'La struttura di base: stessi nodi, diversa veste e diverso comportamento',
            'Il server',
            'Il database',
          ],
          correctAnswerIndex: 1,
          explanation: 'Una struttura, molte presentazioni.',
        ),
      ],
    ),
    'quiz_build_framework': const Quiz(
      id: 'quiz_build_framework',
      topicId: 'build_framework',
      passingThreshold: 80,
      questions: [
        const Question(
          text: 'Quando una pagina diventa "app" e perché tutto si complica?',
          options: [
            'Quando è lunga',
            'Quando molti pezzi si aggiornano da soli e si influenzano: ogni cambio ne tocca altri',
            'Quando ha immagini',
            'Quando è online',
          ],
          correctAnswerIndex: 1,
          explanation: 'La complessità è nelle connessioni tra pezzi.',
        ),
        const Question(
          text: 'A cosa serve l\u2019idea di componente (pulsante, scheda, carrello)?',
          options: [
            'A scrivere di più',
            'A impacchettare un pezzo con un mestiere chiaro e riusarlo senza ricopiare',
            'A colorare',
            'A velocizzare Internet',
          ],
          correctAnswerIndex: 1,
          explanation: 'Un pezzo, un mestiere, riuso invece di copia-incolla.',
        ),
        const Question(
          text: 'Cos\u2019è lo "stato dell\u2019interfaccia" in una riga?',
          options: [
            'La nazione dell\u2019utente',
            'La fonte di verità del momento (cosa selezionato, cosa nel carrello) da cui la vista discende',
            'La velocità',
            'Il server',
          ],
          correctAnswerIndex: 1,
          explanation: 'Prima i fatti, poi ciò che si vede li riflette.',
        ),
        const Question(
          text: 'Il contatore del carrello dice 3 ma dentro ci sono 2 oggetti: dov\u2019è il problema?',
          options: [
            'Nei colori',
            'Vista e stato si sono disallineati: la vista non riflette più la verità',
            'Nel DNS',
            'Nel Wi-Fi',
          ],
          correctAnswerIndex: 1,
          explanation: 'Il bug classico è la doppia verità.',
        ),
        const Question(
          text: 'Perché "copiare e adattare" lo stesso pezzo in 10 punti diventa un incubo?',
          options: [
            'Occupa disco',
            'Ogni correzione va rifatta 10 volte e una verrà dimenticata',
            'È vietato',
            'Rallenta il browser',
          ],
          correctAnswerIndex: 1,
          explanation: 'La duplicazione moltiplica il futuro lavoro di riparazione.',
        ),
      ],
    ),
    'quiz_build_ship': const Quiz(
      id: 'quiz_build_ship',
      topicId: 'build_ship',
      passingThreshold: 80,
      questions: [
        const Question(
          text: 'Perché salvare tappe (versioni) invece del solo file finale?',
          options: [
            'Per nostalgia',
            'Per tornare indietro, confrontare idee e capire quando si è rotto cosa',
            'Per occupare spazio',
            'Per legge',
          ],
          correctAnswerIndex: 1,
          explanation: 'La storia rende gli errori economici.',
        ),
        const Question(
          text: 'A cosa serve un ramo (branch) come idea, senza tecnicismi?',
          options: [
            'A decorare',
            'A provare un\u2019idea in parallelo senza disturbare il lavoro che funziona',
            'A duplicare il server',
            'A cancellare',
          ],
          correctAnswerIndex: 1,
          explanation: 'Sperimentare al sicuro.',
        ),
        const Question(
          text: 'Due persone cambiano la stessa parte e poi fondono (merge): cosa può succedere?',
          options: [
            'Nulla mai',
            'Le idee cozzano (conflitto): bisogna decidere a mano cosa tenere',
            'Il server esplode',
            'Il DNS cambia',
          ],
          correctAnswerIndex: 1,
          explanation: 'Il merge unisce, ma le contraddizioni si risolvono a mano.',
        ),
        const Question(
          text: 'Perché "sul mio computer funziona" non basta?',
          options: [
            'Perché mente',
            'Il tuo computer non è quello degli utenti: manca la consegna uguale-per-tutti dal server',
            'Perché è lento',
            'Perché manca il DNS',
          ],
          correctAnswerIndex: 1,
          explanation: 'Finché non è impacchettato e consegnato, non esiste per gli altri.',
        ),
        const Question(
          text: 'Perché spedire spesso piccoli passi è più sicuro di un unico grande lancio?',
          options: [
            'Non lo è',
            'Se qualcosa si rompe, sai quale passo è colpevole e torni indietro di poco',
            'Costa meno',
            'È più emozionante',
          ],
          correctAnswerIndex: 1,
          explanation: 'Piccoli passi = colpevoli piccoli e vicini.',
        ),
      ],
    ),
  };

  @override
  Future<Quiz> getQuizForTopic(String topicId) async {
    await Future.delayed(const Duration(milliseconds: 300)); // Simulate loading
    final quiz = _quizzes['quiz_$topicId'];
    if (quiz == null) {
      throw Exception('Quiz not found for topic: $topicId');
    }
    return quiz;
  }

  @override
  Future<QuizResult> submitQuizAnswers(String quizId, List<int> selectedAnswers) async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate processing

    final quiz = _quizzes[quizId];
    if (quiz == null) {
      throw Exception('Quiz not found: $quizId');
    }

    int correctAnswers = 0;
    for (int i = 0; i < selectedAnswers.length; i++) {
      if (i < quiz.questions.length && selectedAnswers[i] == quiz.questions[i].correctAnswerIndex) {
        correctAnswers++;
      }
    }

    final percentage = (correctAnswers / quiz.questions.length) * 100;
    final passed = percentage >= quiz.passingThreshold;

    return QuizResult(
      quizId: quizId,
      correctAnswers: correctAnswers,
      totalQuestions: quiz.questions.length,
      percentage: percentage,
      passed: passed,
      completedAt: DateTime.now(),
    );
  }
}
