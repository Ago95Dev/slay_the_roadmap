import '../../domain/models/campaign.dart';
import '../../domain/models/topic_detail.dart';

abstract class TopicDetailRepository {
  Future<TopicDetail?> getTopicDetail(String topicId, {String? campaignId});
  Future<Map<String, TopicDetail>> getAllTopicDetails({String? campaignId});
}

class LocalTopicDetailRepository implements TopicDetailRepository {
  final Map<String, TopicDetail> _topicDetails = {
    'web_network': TopicDetail(
      id: 'web_network',
      title: 'La rete in un quadro',
      description:
          'Il web è una rete di computer che si parlano a strati: ogni strato risolve un problema diverso — trovare l\u2019altro (nomi e indirizzi), mettersi d\u2019accordo su come parlare (protocolli), scambiarsi contenuti. Separare i ruoli significa poter rompere e riparare un pezzo senza buttare tutto: se cambia il Wi-Fi, i nomi restano; se cambia un server, il browser resta. Studiare prima la rete ha senso perché ogni scelta dopo (dati, pagine, app) deve fare i conti con come viaggiano le informazioni.\n\nVisita le seguenti risorse per approfondire:',
      quizId: 'quiz_web_network',
      links: [
        LearningLink(
          title: 'How does the Internet work (MDN)',
          url: 'https://developer.mozilla.org/en-US/docs/Learn_web_development/Howto/Web_mechanics/How_does_the_Internet_work',
          type: LinkType.article,
        ),
        LearningLink(
          title: 'How does the Internet work (Cloudflare)',
          url: 'https://www.cloudflare.com/learning/network-layer/how-does-the-internet-work/',
          type: LinkType.article,
        ),
      ],
    ),
    'net_client_server': TopicDetail(
      id: 'net_client_server',
      title: 'Client e server',
      description:
          'Il web è una conversazione tra due ruoli. Il client (browser) chiede, il server risponde: ogni pagina è una sequenza di richieste e risposte, mai il server che "spinge" da solo. Il codice può girare sul client (interazione immediata) o sul server (dati protetti e condivisi): dove lo metti cambia velocità, sicurezza e chi paga il conto computazionale.\n\nVisita le seguenti risorse per approfondire:',
      quizId: 'quiz_net_client_server',
      links: [
        LearningLink(
          title: 'What is a web server (MDN)',
          url: 'https://developer.mozilla.org/en-US/docs/Learn_web_development/Howto/Web_mechanics/What_is_a_web_server',
          type: LinkType.documentation,
        ),
        LearningLink(
          title: 'How browsers work (web.dev)',
          url: 'https://web.dev/howbrowserswork/',
          type: LinkType.article,
        ),
      ],
    ),
    'net_dns_url': TopicDetail(
      id: 'net_dns_url',
      title: 'Indirizzi e nomi',
      description:
          'I computer si trovano con indirizzi IP numerici, impossibili da ricordare: il DNS è la rubrica che traduce nomi (es. esempio.it) in IP. L\u2019URL è l\u2019indirizzo completo della risorsa: protocollo, nome, porta, percorso e parametri dicono al browser dove andare e cosa chiedere. Senza DNS digiteremmo numeri; senza URL non sapremmo quale pagina di quel server vogliamo.\n\nVisita le seguenti risorse per approfondire:',
      quizId: 'quiz_net_dns_url',
      links: [
        LearningLink(
          title: 'What is DNS (Cloudflare)',
          url: 'https://www.cloudflare.com/learning/dns/what-is-dns/',
          type: LinkType.article,
        ),
        LearningLink(
          title: 'What is a URL (MDN)',
          url: 'https://developer.mozilla.org/en-US/docs/Learn_web_development/Howto/Web_mechanics/What_is_a_URL',
          type: LinkType.documentation,
        ),
      ],
    ),
    'net_http_https': TopicDetail(
      id: 'net_http_https',
      title: 'HTTP e HTTPS',
      description:
          'HTTP è il linguaggio della conversazione web: metodi (GET per leggere, POST per inviare...), status code (200 ok, 404 non trovato, 500 errore server) e header (metadati). Viaggia in chiaro: chi intercetta legge tutto — per questo esiste HTTPS, che cifra il canale con TLS. Il lucchetto non dice "sito onesto", dice "nessuno in mezzo può leggere".\n\nVisita le seguenti risorse per approfondire:',
      quizId: 'quiz_net_http_https',
      links: [
        LearningLink(
          title: 'An overview of HTTP (MDN)',
          url: 'https://developer.mozilla.org/en-US/docs/Web/HTTP/Overview',
          type: LinkType.documentation,
        ),
        LearningLink(
          title: 'What is HTTPS (Cloudflare)',
          url: 'https://www.cloudflare.com/learning/ssl/what-is-https/',
          type: LinkType.article,
        ),
      ],
    ),
    'web_data': TopicDetail(
      id: 'web_data',
      title: 'I dati in un quadro',
      description:
          'Tutto ciò che vedi sul web è dati in viaggio: testi, immagini, prezzi, messaggi. Prima di mostrarli bisogna decidere come rappresentarli (in che forma), dove tenerli (chi li custodisce) e come ricordare da dove eravamo rimasti (lo stato). Queste tre domande tornano in ogni app: un social, un negozio, un gioco. Capirle a livello di idee — senza sintassi — ti permette di valutare qualsiasi tecnologia dopo.\n\nVisita le seguenti risorse per approfondire:',
      quizId: 'quiz_web_data',
      links: [
        LearningLink(
          title: 'JSON e dati sul web (MDN)',
          url: 'https://developer.mozilla.org/en-US/docs/Learn_web_development/Core/Scripting/JSON',
          type: LinkType.documentation,
        ),
        LearningLink(
          title: 'Database roadmap (roadmap.sh)',
          url: 'https://roadmap.sh/databases',
          type: LinkType.article,
        ),
      ],
    ),
    'data_represent': TopicDetail(
      id: 'data_represent',
      title: 'Rappresentare i dati',
      description:
          'I computer in fondo conoscono solo numeri binari, ma noi ragioniamo in testi, immagini, elenchi: servono formati che facciano da ponte. Il testo è il ponte più universale — leggibile da persone e programmi — ed è per questo che i formati testuali leggeri dominano lo scambio web. Per organizzare le informazioni bastano poche forme mentali: liste (ordine), mappe (nome→valore), alberi (gerarchie di contenuti dentro contenuti). La pagina stessa è un albero (il DOM): nodi annidati che il browser attraversa per mostrare e aggiornare.\n\nVisita le seguenti risorse per approfondire:',
      quizId: 'quiz_data_represent',
      links: [
        LearningLink(
          title: 'JSON e dati sul web (MDN)',
          url: 'https://developer.mozilla.org/en-US/docs/Learn_web_development/Core/Scripting/JSON',
          type: LinkType.documentation,
        ),
        LearningLink(
          title: 'Introduction to the DOM (MDN)',
          url: 'https://developer.mozilla.org/en-US/docs/Web/API/Document_Object_Model/Introduction',
          type: LinkType.article,
        ),
      ],
    ),
    'data_where': TopicDetail(
      id: 'data_where',
      title: 'Dove vivono i dati',
      description:
          'Un\u2019app web divide il lavoro in tre case: il frontend (ciò che vedi e tocchi nel browser), il backend (la logica che decide e protegge sul server), il database (la memoria che custodisce e ritrova). Separarli non è burocrazia: ognuno scala e si rompe per conto suo — puoi cambiare i colori senza toccare i pagamenti, o spostare il database senza riscrivere le pagine. Il prezzo è il viaggio: ogni confine attraversato è una richiesta in più, quindi si mette in ogni casa solo ciò che lì ha senso.\n\nVisita le seguenti risorse per approfondire:',
      quizId: 'quiz_data_where',
      links: [
        LearningLink(
          title: 'Introduction to the server side (MDN)',
          url: 'https://developer.mozilla.org/en-US/docs/Learn_web_development/Extensions/Server-side/First_steps/Introduction',
          type: LinkType.documentation,
        ),
        LearningLink(
          title: 'Backend roadmap (roadmap.sh)',
          url: 'https://roadmap.sh/backend',
          type: LinkType.article,
        ),
      ],
    ),
    'data_state': TopicDetail(
      id: 'data_state',
      title: 'Ricordare (stato, sessioni, cache)',
      description:
          'HTTP è smemorato per disegno: ogni richiesta è nuova, il server non ti riconosce tra una pagina e l\u2019altra. Per questo il web ha inventato memorie aggiuntive: i cookie (bigliettini che il browser ripresenta), le sessioni (il server lega quei bigliettini a un utente collegato), la cache (copie di risposte riusate per non richiederle). Ogni memoria ha un prezzo: i cookie viaggiano sempre, le sessioni vanno protette, le cache possono mostrare copie vecchie. Il mestiere è scegliere cosa ricordare, dove, e per quanto.\n\nVisita le seguenti risorse per approfondire:',
      quizId: 'quiz_data_state',
      links: [
        LearningLink(
          title: 'HTTP cookies (MDN)',
          url: 'https://developer.mozilla.org/en-US/docs/Web/HTTP/Cookies',
          type: LinkType.documentation,
        ),
        LearningLink(
          title: 'HTTP caching (MDN)',
          url: 'https://developer.mozilla.org/en-US/docs/Web/HTTP/Caching',
          type: LinkType.article,
        ),
      ],
    ),
    'web_building': TopicDetail(
      id: 'web_building',
      title: 'Costruire in un quadro',
      description:
          'Costruire sul web significa tre cose: trasformare dati in pagine che il browser sa mostrare, domare la complessità quando le pagine diventano app, e spedire il tutto dal proprio computer ai server degli utenti. Ogni fase ha un suo ostacolo: il browser che interpreta, il caos dell\u2019interfaccia che cresce, il rischio di rompere tutto pubblicando. Questo capitolo ti dà i modelli mentali per non perderti: come ragiona un browser, perché nascono gli strumenti moderni, perché si versiona e si pubblica con cura.\n\nVisita le seguenti risorse per approfondire:',
      quizId: 'quiz_web_building',
      links: [
        LearningLink(
          title: 'What will your website look like (MDN)',
          url: 'https://developer.mozilla.org/en-US/docs/Learn_web_development/Getting_started/Your_first_website/What_will_your_website_look_like',
          type: LinkType.article,
        ),
        LearningLink(
          title: 'Frontend roadmap (roadmap.sh)',
          url: 'https://roadmap.sh/frontend',
          type: LinkType.article,
        ),
      ],
    ),
    'build_browser': TopicDetail(
      id: 'build_browser',
      title: 'Come ragiona il browser',
      description:
          'Il browser non "apre file", interpreta: legge il testo della pagina, lo trasforma in albero di nodi (parsing→DOM), poi decide aspetto e posizione di ogni nodo (render) e lo dipinge. Struttura, presentazione e comportamento sono tre mestieri separati: cosa c\u2019è (contenuti e gerarchia), come appare (stili e layout), cosa fa quando interagisci (reazioni). Mescolarli sembra veloce all\u2019inizio, ma ogni modifica tocca tutto: separarli significa cambiare i colori senza rompere i contenuti, o rifare un\u2019interazione senza riscrivere la pagina.\n\nVisita le seguenti risorse per approfondire:',
      quizId: 'quiz_build_browser',
      links: [
        LearningLink(
          title: 'How browsers work (web.dev)',
          url: 'https://web.dev/howbrowserswork/',
          type: LinkType.article,
        ),
        LearningLink(
          title: 'How browsers work (MDN)',
          url: 'https://developer.mozilla.org/en-US/docs/Web/Performance/How_browsers_work',
          type: LinkType.documentation,
        ),
      ],
    ),
    'build_framework': TopicDetail(
      id: 'build_framework',
      title: 'Domare la complessità',
      description:
          'Quando le pagine diventano app — decine di schermate che si aggiornano da sole — tenere tutto a mano diventa caos: ogni pezzo tocca gli altri. Gli strumenti moderni rispondono con due idee: i componenti (pezzi riusabili con un mestiere chiaro: pulsante, scheda prodotto, carrello) e lo stato dell\u2019interfaccia (una fonte di verità da cui la vista discende). Il problema vero non è il colore del pulsante, è "quando i dati cambiano, cosa si aggiorna e perché quella cosa lì". Capire il problema vale più di qualsiasi nome di strumento.\n\nVisita le seguenti risorse per approfondire:',
      quizId: 'quiz_build_framework',
      links: [
        LearningLink(
          title: 'Introduction to frameworks (MDN)',
          url: 'https://developer.mozilla.org/en-US/docs/Learn_web_development/Core/Frameworks/Introduction',
          type: LinkType.documentation,
        ),
        LearningLink(
          title: 'Frontend roadmap (roadmap.sh)',
          url: 'https://roadmap.sh/frontend',
          type: LinkType.article,
        ),
      ],
    ),
    'build_ship': TopicDetail(
      id: 'build_ship',
      title: 'Versionare e spedire',
      description:
          'Costruire da soli senza rete di sicurezza significa aver paura di ogni modifica: per questo si versiona — ogni tappa salvata è un punto a cui tornare e confrontare. I rami (branch) sono idee parallele che vivono senza disturbarsi, la fusione (merge) è il momento in cui si decide cosa entra nella storia principale. Spedire (dal repo al server) è l\u2019ultimo miglio: impacchettare il lavoro e consegnarlo dove gli utenti lo useranno, con lo stesso risultato ogni volta. Chi versiona e spedisce con cura può osare di più, perché sbagliare costa poco.\n\nVisita le seguenti risorse per approfondire:',
      quizId: 'quiz_build_ship',
      links: [
        LearningLink(
          title: 'About Version Control (git-scm)',
          url: 'https://git-scm.com/book/en/v2/Getting-Started-About-Version-Control',
          type: LinkType.documentation,
        ),
        LearningLink(
          title: 'Git & GitHub roadmap (roadmap.sh)',
          url: 'https://roadmap.sh/git-github',
          type: LinkType.article,
        ),
      ],
    ),
  };

  @override
  Future<TopicDetail?> getTopicDetail(String topicId,
      {String? campaignId}) async {
    CampaignRepository.requireActive(campaignId);
    await Future.delayed(const Duration(milliseconds: 300));
    return _topicDetails[topicId];
  }

  @override
  Future<Map<String, TopicDetail>> getAllTopicDetails(
      {String? campaignId}) async {
    CampaignRepository.requireActive(campaignId);
    await Future.delayed(const Duration(milliseconds: 500));
    return _topicDetails;
  }
}
