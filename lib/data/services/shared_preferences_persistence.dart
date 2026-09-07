import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/campaign.dart';
import '../../domain/models/player_progress.dart';
import '../repositories/persistence_repository.dart';

/// Implementazione [PersistenceRepository] su `shared_preferences`
/// (F5, US-05; F11: progress isolati per campagna).
///
/// Il save vive sotto un'unica chiave come JSON con una mappa di campagne:
/// `{activeCampaign, campaignSelected, campaigns: {<id>: {progress,
/// completedTopicIds, claimedRewardTopics}}}`. L'istanza è legata a un
/// bucket ([campaignId], default `web_foundations`): i metodi del contratto
/// leggono/scrivono solo quel bucket, così ogni campagna ha progress,
/// claim e wipe isolati. `activeCampaign`/`campaignSelected` vivono a
/// livello di envelope (non di bucket).
///
/// Migrazione senza perdite: un envelope vecchio formato (F5/F10, con
/// `progress` in radice) viene letto come campagna `web_foundations` e
/// riscritto nel nuovo formato al primo accesso in lettura.
class SharedPreferencesPersistence implements PersistenceRepository {
  static const String saveKey = 'slay_save_v1';

  final SharedPreferences? _overrides;

  /// Quando [userId] è impostato il save vive sotto `slay_data_<userId>`
  /// (un save isolato per profilo, F10); altrimenti sotto il legacy
  /// [saveKey] (usato solo dalla migrazione una-tantum e dai vecchi test).
  final String? _userId;

  /// Bucket campagna di questa istanza (F11, default campagna spedita).
  final String _campaignId;

  /// [_overrides] serve solo ai test (istanza già pronta, niente platform
  /// channel); in app usare il costruttore senza argomenti.
  SharedPreferencesPersistence([this._overrides])
      : _userId = null,
        _campaignId = CampaignRepository.webFoundationsId;

  /// Persistenza del save del profilo [userId] (F10), bucket [campaignId]
  /// (F11, default campagna spedita).
  SharedPreferencesPersistence.forUser(this._overrides, String userId,
      {String? campaignId})
      : _userId = userId,
        _campaignId = campaignId ?? CampaignRepository.webFoundationsId;

  /// Chiave del save per il profilo [userId].
  static String dataKey(String userId) => 'slay_data_$userId';

  String get _key => _userId == null ? saveKey : dataKey(_userId!);

  Future<SharedPreferences> get _prefs async =>
      _overrides ?? await SharedPreferences.getInstance();

  // ------------------------------------------------------------ envelope

  /// Envelope normalizzato al nuovo formato (migra il vecchio in memoria;
  /// il chiamante persiste riscrivendo). Mai null: `{}` = nessun save.
  Map<String, dynamic> _normalize(Map<String, dynamic> raw) {
    if (raw['campaigns'] is Map) return raw;
    if (raw['progress'] is Map) {
      return {
        'activeCampaign': CampaignRepository.webFoundationsId,
        'campaignSelected': false,
        'campaigns': {
          CampaignRepository.webFoundationsId: {
            'progress': raw['progress'],
            'completedTopicIds': raw['completedTopicIds'],
            'claimedRewardTopics': raw['claimedRewardTopics'],
          },
        },
      };
    }
    return raw;
  }

  bool _isLegacyFormat(Map<String, dynamic> raw) =>
      raw['campaigns'] is! Map && raw['progress'] is Map;

  Future<Map<String, dynamic>> _readEnvelope() async {
    final prefs = await _prefs;
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return {};
    try {
      final map = Map<String, dynamic>.from(jsonDecode(raw) as Map);
      if (_isLegacyFormat(map)) {
        final migrated = _normalize(map);
        await prefs.setString(_key, jsonEncode(migrated));
        return migrated;
      }
      return map;
    } on Exception {
      return {};
    }
  }

  Map<String, dynamic> _bucketOf(Map<String, dynamic> envelope) {
    final campaigns = envelope['campaigns'];
    if (campaigns is Map && campaigns[_campaignId] is Map) {
      return Map<String, dynamic>.from(campaigns[_campaignId] as Map);
    }
    return {};
  }

  Future<void> _writeBucket(
    SharedPreferences prefs,
    Map<String, dynamic> envelope,
    Map<String, dynamic> bucket,
  ) async {
    final campaigns = envelope['campaigns'] is Map
        ? Map<String, dynamic>.from(envelope['campaigns'] as Map)
        : <String, dynamic>{};
    campaigns[_campaignId] = bucket;
    envelope['campaigns'] = campaigns;
    envelope['activeCampaign'] ??= CampaignRepository.webFoundationsId;
    envelope['campaignSelected'] ??= false;
    await prefs.setString(_key, jsonEncode(envelope));
  }

  // ------------------------------------------------- contratto (bucket)

  @override
  Future<void> savePlayerProgress(PlayerProgress progress) async {
    final prefs = await _prefs;
    final envelope = await _readEnvelope();
    final bucket = _bucketOf(envelope);
    final claimed = bucket['claimedRewardTopics'];
    await _writeBucket(prefs, envelope, {
      'progress': progress.toJson(),
      'completedTopicIds': progress.completedTopicIds,
      'claimedRewardTopics': claimed is List ? claimed : <String>[],
    });
  }

  @override
  Future<PlayerProgress?> loadPlayerProgress() async {
    final bucket = _bucketOf(await _readEnvelope());
    if (bucket['progress'] is! Map) return null;
    try {
      return PlayerProgress.fromJson(
        Map<String, dynamic>.from(bucket['progress'] as Map),
      );
    } on Exception {
      return null;
    }
  }

  @override
  Future<void> resetProgress() async {
    final prefs = await _prefs;
    final envelope = await _readEnvelope();
    await _writeBucket(prefs, envelope, {
      'claimedRewardTopics': <String>[],
    });
  }

  @override
  Future<void> saveClaimedRewardTopics(Set<String> topicIds) async {
    final prefs = await _prefs;
    final envelope = await _readEnvelope();
    final bucket = _bucketOf(envelope);
    PlayerProgress? progress;
    if (bucket['progress'] is Map) {
      try {
        progress = PlayerProgress.fromJson(
          Map<String, dynamic>.from(bucket['progress'] as Map),
        );
      } on Exception {
        progress = null;
      }
    }
    progress ??= PlayerProgress.initial();
    await _writeBucket(prefs, envelope, {
      'progress': progress.toJson(),
      'completedTopicIds': progress.completedTopicIds,
      'claimedRewardTopics': topicIds.toList(),
    });
  }

  @override
  Future<Set<String>> loadClaimedRewardTopics() async {
    final bucket = _bucketOf(await _readEnvelope());
    final list = (bucket['claimedRewardTopics'] as List?) ?? const [];
    return List<String>.from(list).toSet();
  }

  @override
  Future<bool> hasSave() async {
    final bucket = _bucketOf(await _readEnvelope());
    try {
      final progress = bucket['progress'] is Map
          ? Map<String, dynamic>.from(bucket['progress'] as Map)
          : const <String, dynamic>{};
      final completed =
          List<String>.from(progress['completedTopicIds'] as List? ?? const []);
      final claimed =
          List<String>.from(bucket['claimedRewardTopics'] as List? ?? const []);
      final xp = (progress['experience'] as num?)?.toInt() ?? 0;
      final rewards =
          ((progress['inventory'] as Map?)?['rewards'] as List?) ?? const [];
      final bosses = (progress['bossFights'] as Map?) ?? const {};
      return completed.isNotEmpty ||
          claimed.isNotEmpty ||
          xp > 0 ||
          rewards.isNotEmpty ||
          bosses.isNotEmpty;
    } on Exception {
      return false;
    }
  }

  // --------------------------------------------- stato campagna (F11)

  /// Id campagna attiva salvata (null = mai scelta, va mostrata la
  /// selezione). Default campagna spedita quando l'envelope esiste ma
  /// il campo manca (save migrati).
  Future<String?> loadActiveCampaignId() async {
    final envelope = await _readEnvelope();
    if (envelope.isEmpty) return null;
    final id = envelope['activeCampaign'] as String?;
    return (id == null || id.isEmpty)
        ? CampaignRepository.webFoundationsId
        : id;
  }

  Future<void> saveActiveCampaignId(String? campaignId) async {
    final prefs = await _prefs;
    final envelope = await _readEnvelope();
    envelope['activeCampaign'] = campaignId;
    await prefs.setString(_key, jsonEncode(envelope));
  }

  /// True se l'utente ha già scelto una campagna (niente più selezione
  /// obbligatoria al login, si continua dove si era).
  Future<bool> loadCampaignSelected() async {
    final envelope = await _readEnvelope();
    return (envelope['campaignSelected'] as bool?) ?? false;
  }

  Future<void> saveCampaignSelected(bool selected) async {
    final prefs = await _prefs;
    final envelope = await _readEnvelope();
    envelope['campaignSelected'] = selected;
    await prefs.setString(_key, jsonEncode(envelope));
  }

  /// Id delle campagne con un bucket presente (debug/test).
  Future<Set<String>> loadCampaignIds() async {
    final envelope = await _readEnvelope();
    final campaigns = envelope['campaigns'];
    if (campaigns is! Map) return {};
    return campaigns.keys.map((e) => e.toString()).toSet();
  }
}
