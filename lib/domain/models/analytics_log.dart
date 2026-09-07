import 'package:equatable/equatable.dart';

/// Analytics locali per l'Evaluation (F12, disegno utenti_campagne_hub §3).
///
/// Solo conteggi, niente tracking invasivo: che cosa è successo (tipo
/// evento + topic opzionale + timestamp), mai come/dove/perché. Gli eventi
/// vivono dentro [PlayerProgress] (persistiti nel save, isolati per
/// coppia utente×campagna come il resto del progresso) e sono cappati
/// agli ultimi [maxEvents] per tenere il save leggero.
class AnalyticsEvent extends Equatable {
  /// Tipi evento registrati (solo conteggi per l'Evaluation).
  static const String quizPass = 'quiz_pass';
  static const String quizFail = 'quiz_fail';
  static const String bossWin = 'boss_win';
  static const String bossLose = 'boss_lose';
  static const String rewardClaim = 'reward_claim';
  static const String sessionStart = 'session_start';

  final String type;
  final String? topicId;
  final DateTime ts;

  /// Valore opzionale (es. XP del claim); mai dati sensibili.
  final int? value;

  const AnalyticsEvent({
    required this.type,
    this.topicId,
    required this.ts,
    this.value,
  });

  Map<String, dynamic> toJson() => {
        'type': type,
        if (topicId != null) 'topicId': topicId,
        'ts': ts.toIso8601String(),
        if (value != null) 'value': value,
      };

  factory AnalyticsEvent.fromJson(Map<String, dynamic> json) =>
      AnalyticsEvent(
        type: (json['type'] as String?) ?? 'unknown',
        topicId: json['topicId'] as String?,
        ts: DateTime.tryParse(json['ts'] as String? ?? '') ?? DateTime.now(),
        value: (json['value'] as num?)?.toInt(),
      );

  @override
  List<Object?> get props => [type, topicId, ts, value];
}

/// Log in memoria degli eventi (F12): lista cappata agli ultimi
/// [maxEvents] eventi, i più vecchi vengono scartati alla registrazione.
class AnalyticsLog extends Equatable {
  /// Cap del log: oltre questa soglia i più vecchi vengono scartati.
  static const int maxEvents = 200;

  final List<AnalyticsEvent> events;

  const AnalyticsLog({this.events = const []});

  /// Registra un evento (timestamp = ora) scartando i più vecchi oltre
  /// il cap. Ritorna il nuovo log (immutabile).
  AnalyticsLog record(
    String type, {
    String? topicId,
    int? value,
    DateTime? at,
  }) {
    final next = [
      ...events,
      AnalyticsEvent(
        type: type,
        topicId: topicId,
        ts: at ?? DateTime.now(),
        value: value,
      ),
    ];
    final trimmed = next.length > maxEvents
        ? next.sublist(next.length - maxEvents)
        : next;
    return AnalyticsLog(events: trimmed);
  }

  int countOf(String type) => events.where((e) => e.type == type).length;

  /// Conteggi per la schermata "I miei numeri" in Settings.
  int get quizPassed => countOf(AnalyticsEvent.quizPass);
  int get quizFailed => countOf(AnalyticsEvent.quizFail);
  int get bossWon => countOf(AnalyticsEvent.bossWin);
  int get bossLost => countOf(AnalyticsEvent.bossLose);
  int get rewardsClaimed => countOf(AnalyticsEvent.rewardClaim);
  int get sessions => countOf(AnalyticsEvent.sessionStart);

  List<Map<String, dynamic>> toJson() =>
      events.map((e) => e.toJson()).toList();

  factory AnalyticsLog.fromJson(List? json) {
    if (json == null) return const AnalyticsLog();
    final parsed = <AnalyticsEvent>[];
    for (final raw in json) {
      try {
        parsed.add(
          AnalyticsEvent.fromJson(Map<String, dynamic>.from(raw as Map)),
        );
      } on Exception {
        continue;
      }
    }
    // I save non dovrebbero mai superare il cap, ma se succede si tiene
    // la coda (eventi più recenti) invece di scartare tutto.
    final trimmed = parsed.length > maxEvents
        ? parsed.sublist(parsed.length - maxEvents)
        : parsed;
    return AnalyticsLog(events: trimmed);
  }

  @override
  List<Object?> get props => [events];
}
