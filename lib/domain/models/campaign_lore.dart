/// Narrativa CD1 (Fase 1B-A): intro capitoli, lore boss pre-fight, finale.
/// Testi in italiano semplice, tema web-fantasy coerente con
/// `docs/assignment/campagna_web.md`. Solo contenuti + helper puri:
/// nessuna meccanica, nessun numero di gioco.
library;

/// Intro evocative (2-3 righe) mostrate alla prima apertura del capitolo.
const Map<String, String> chapterIntroTitles = {
  'web_network': 'Capitolo 1 — La Rete',
  'web_data': 'Capitolo 2 — Dati e Stato',
  'web_building': 'Capitolo 3 — Costruire sul Web',
};

const Map<String, String> chapterIntros = {
  'web_network':
      'Ogni pagina che apri è un messaggio partito da lontano: corre tra '
      'cavi e Wi-Fi, bussa a porte invisibili, chiede il permesso di entrare.\n'
      'In questo capitolo impari a seguire le sue tracce — e a capire chi, '
      'nell\u2019ombra della rete, potrebbe starlo leggendo.',
  'web_data':
      'Il web dimentica tutto in fretta: ogni richiesta riparte da zero, '
      'come se non ti avesse mai visto.\n'
      'In questo capitolo scopri dove vivono davvero i dati — e come il web '
      'fa a ricordarsi di te, tra bigliettini, registri e copie nascoste.',
  'web_building':
      'Fin qui hai capito come viaggiano le informazioni e dove riposano. '
      'Ora si costruisce: pagine che diventano app, idee che diventano versioni, '
      'lavoro che parte dal tuo computer e arriva nelle mani di tutti.\n'
      'Ma attenzione: qualcosa di grosso e aggrovigliato ti aspetta in fondo al cantiere…',
};

/// Lore estesa dei boss (la prima riga riprende la riga del doc).
const Map<String, String> bossNames = {
  'man_in_the_middle': 'Man-in-the-Middle',
  'the_amnesiac': 'The Amnesiac',
  'spaghetti_colossus': 'Spaghetti Colossus',
};

const Map<String, String> bossLores = {
  'man_in_the_middle':
      'Vive nei Wi-Fi aperti e legge ci\u00f2 che non \u00e8 cifrato.\n'
      'Si siede in silenzio tra te e il server e copia ogni messaggio in '
      'chiaro: password, carte, segreti. Solo ciò che viaggia cifrato gli '
      'resta illeggibile. Chiudigli la porta in faccia.',
  'the_amnesiac':
      'Ha cancellato la memoria del web: ti costringe a ricordare tutto da '
      'solo, tra bigliettini, sessioni e copie stantie.\n'
      'Si nutre di ogni conversazione dimenticata. Per sconfiggerlo devi '
      'dimostrare di sapere dove vive la memoria — e quanto costa fidarsi '
      'di una copia vecchia.',
  'spaghetti_colossus':
      'Un ammasso di pagine copiate e mai versionate: ogni modifica spezza '
      'qualcos\u2019altro.\n'
      'È nato da anni di copia-incolla senza rete di sicurezza, e ora cresce '
      'a ogni tocco maldestro. L\u2019ultimo guardiano del web: crolla solo '
      'davanti a chi costruisce con ordine e spedisce con cura.',
};

/// Tratti passivi dei boss (Voce C, 1 per boss): mostrati come riga
/// "Tratto: ..." nel dialog lore pre-fight. Solo flavor + promemoria
/// della meccanica, nessun numero nascosto.
const Map<String, String> bossTraits = {
  'man_in_the_middle':
      'Tratto: Intercettazione — sotto il 75% di HP i suoi colpi '
      'diventano speciali (-2).',
  'the_amnesiac':
      'Tratto: Oblio — ogni risposta errata ti fa dimenticare (-1 ⚡).',
  'spaghetti_colossus':
      'Tratto: Corazza — ignora il primo punto danno da carte '
      '(i quiz la aggirano).',
};

/// Tratto passivo del boss (stringa vuota se boss sconosciuto).
String bossTrait(String bossId) => bossTraits[bossId] ?? '';

/// Finale narrativo con stats (chiude il bug endgame aperto).
const String campaignCompleteTitle = 'Campagna completata! 🎉';

const String campaignCompleteBody =
    'Lo Spaghetti Colossus si sbroglia in un filo ordinato e il web torna a '
    'respirare: richieste, dati e pagine al loro posto.\n'
    'Hai attraversato la Rete, ricucito la Memoria e domato il Cantiere. '
    'Il percorso è tuo.';

// Capitoli root in ordine (allineati a LocalRoadmapRepository).
const List<String> chapterIds = ['web_network', 'web_data', 'web_building'];

// Boss finali in ordine (allineati a BossRepository).
const List<String> campaignBossIds = [
  'man_in_the_middle',
  'the_amnesiac',
  'spaghetti_colossus',
];

/// Titoli per capitolo (Fase 1B-B): assegnati al completamento del
/// capitolo (tutti i topic + boss sconfitto). L'ultimo vinto è attivo.
const Map<String, String> chapterTitles = {
  'web_network': 'Sentinella della Rete',
  'web_data': 'Custode dei Dati',
  'web_building': 'Architetto del Web',
};

/// Capitolo di appartenenza di un boss finale.
String? chapterIdForBossId(String bossId) {
  switch (bossId) {
    case 'man_in_the_middle':
      return 'web_network';
    case 'the_amnesiac':
      return 'web_data';
    case 'spaghetti_colossus':
      return 'web_building';
    default:
      return null;
  }
}

/// Boss finale di un capitolo root.
String? bossIdForChapterId(String chapterId) {
  switch (chapterId) {
    case 'web_network':
      return 'man_in_the_middle';
    case 'web_data':
      return 'the_amnesiac';
    case 'web_building':
      return 'spaghetti_colossus';
    default:
      return null;
  }
}

/// Capitolo di appartenenza di un topic (root o subtopic).
String? chapterIdForTopicId(String topicId) {
  switch (topicId) {
    case 'web_network':
    case 'net_client_server':
    case 'net_dns_url':
    case 'net_http_https':
      return 'web_network';
    case 'web_data':
    case 'data_represent':
    case 'data_where':
    case 'data_state':
      return 'web_data';
    case 'web_building':
    case 'build_browser':
    case 'build_framework':
    case 'build_ship':
      return 'web_building';
    default:
      return null;
  }
}
