import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:slay_the_roadmap/data/services/shared_preferences_persistence.dart';
import 'package:slay_the_roadmap/domain/models/player_progress.dart';
import 'package:slay_the_roadmap/providers/game_provider.dart';
import 'package:slay_the_roadmap/services/engine_client.dart';
import 'package:slay_the_roadmap/services/storage_service.dart';

/// Fase 3 (TDD, nasce rosso): auth salata + save per utente + playerId Hub
/// stabile + gate login minimo.
void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> settle() async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
  }

  group('Fase 3: auth salata v2', () {
    test('register/login ok, wrong-pwd ko', () async {
      final storage = StorageService();
      // register via provider per coprire il flusso reale
      final provider = GameProvider();
      expect(await provider.registerLocal('alice', 'secret123'), isTrue);
      // username duplicato rifiutato
      expect(await provider.registerLocal('alice', 'secret123'), isFalse);

      final p2 = GameProvider();
      expect(await p2.loginLocal('alice', 'secret123'), isTrue);
      expect(await p2.loginLocal('alice', 'sbagliata'), isFalse);
      expect(await p2.loginLocal('ghost', 'secret123'), isFalse);
      expect(storage, isNotNull);
    });

    test('rainbow: stessa pwd -> hash diversi (salt random)', () async {
      final provider = GameProvider();
      expect(await provider.registerLocal('u1', 'stessapwd'), isTrue);
      expect(await provider.registerLocal('u2', 'stessapwd'), isTrue);
      final prefs = await SharedPreferences.getInstance();
      final h1 = prefs.getString('user_pwd_v2_u1');
      final h2 = prefs.getString('user_pwd_v2_u2');
      expect(h1, isNotNull);
      expect(h2, isNotNull);
      expect(h1, contains(r'$'));
      expect(h2, contains(r'$'));
      expect(h1, isNot(equals(h2)));
    });

    test('migrazione v1-plaintext -> v2 con cancellazione v1', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_pwd_legacyplain', 'plainpwd');
      final provider = GameProvider();
      expect(await provider.loginLocal('legacyplain', 'plainpwd'), isTrue);
      await settle();
      final v2 = prefs.getString('user_pwd_v2_legacyplain');
      expect(v2, isNotNull);
      expect(v2, contains(r'$'));
      expect(prefs.containsKey('user_pwd_legacyplain'), isFalse);
      // login ancora ok dopo la migrazione
      final p2 = GameProvider();
      expect(await p2.loginLocal('legacyplain', 'plainpwd'), isTrue);
    });

    test('migrazione v1-hash -> v2 con cancellazione v1', () async {
      final prefs = await SharedPreferences.getInstance();
      final v1hash = sha256.convert(utf8.encode('segreta')).toString();
      await prefs.setString('user_pwd_legacyhash', v1hash);
      final provider = GameProvider();
      expect(await provider.loginLocal('legacyhash', 'segreta'), isTrue);
      await settle();
      expect(prefs.getString('user_pwd_v2_legacyhash'), isNotNull);
      expect(prefs.containsKey('user_pwd_legacyhash'), isFalse);
      expect(await provider.loginLocal('legacyhash', 'sbagliata'), isFalse);
    });
  });

  group('Fase 3: save per utente', () {
    test('2 utenti isolati (progress/reward/badge)', () async {
      final alice = GameProvider();
      expect(await alice.registerLocal('alice', 'pw'), isTrue);
      await alice.loadProgress();
      alice.completeTopic('topic_a');
      alice.claimRewardTopic('topic_a');
      await settle();

      await alice.logout();
      final bob = GameProvider();
      expect(await bob.registerLocal('bob', 'pw'), isTrue);
      await bob.loadProgress();
      expect(bob.completedTopics, isNot(contains('topic_a')));
      expect(bob.isRewardClaimed('topic_a'), isFalse);
      expect(bob.badges, isNot(contains('topic:topic_a')));
      bob.completeTopic('topic_b');
      await settle();

      // Ritorno su alice: i suoi dati sono intatti, quelli di bob no.
      final alice2 = GameProvider();
      expect(await alice2.loginLocal('alice', 'pw'), isTrue);
      // login ricarica dal save per-utente
      expect(alice2.completedTopics, contains('topic_a'));
      expect(alice2.isRewardClaimed('topic_a'), isTrue);
      expect(alice2.completedTopics, isNot(contains('topic_b')));
    });

    test('logout pulisce lo stato in-memory', () async {
      final provider = GameProvider();
      expect(await provider.registerLocal('carol', 'pw'), isTrue);
      await provider.loadProgress();
      provider.completeTopic('topic_x');
      provider.claimRewardTopic('topic_x');
      provider.completeTopicQuiz('badge_topic_logout', 5, true);
      expect(provider.completedTopics, isNotEmpty);
      await settle();

      await provider.logout();
      expect(provider.completedTopics, isEmpty);
      expect(provider.claimedRewardTopics, isEmpty);
      expect(provider.badges, isEmpty);
      expect(provider.isLoggedIn, isFalse);
      expect(provider.hubPlayerId, isEmpty);
    });

    test('SharedPreferencesPersistence: saveKey per utente isolato',
        () async {
      final prefs = await SharedPreferences.getInstance();
      final a = SharedPreferencesPersistence.forUser(prefs, 'alice');
      final b = SharedPreferencesPersistence.forUser(prefs, 'bob');
      await a.savePlayerProgress(
        PlayerProgress.initial().copyWith(experience: 150),
      );
      await b.savePlayerProgress(PlayerProgress.initial());
      final ra = await a.loadPlayerProgress();
      final rb = await b.loadPlayerProgress();
      expect(ra!.experience, 150);
      expect(rb!.experience, 0);
    });
  });

  group('Fase 3: playerId Hub stabile', () {
    test('slay_<uuid>, mai username, stabile tra reload', () async {
      final provider = GameProvider();
      expect(await provider.registerLocal('dave', 'pw'), isTrue);
      final id1 = provider.hubPlayerId;
      expect(id1, startsWith('slay_'));
      expect(id1, isNot('dave'));
      expect(id1.length, greaterThan('slay_'.length + 8));

      final reloaded = GameProvider();
      expect(await reloaded.loginLocal('dave', 'pw'), isTrue);
      expect(reloaded.hubPlayerId, id1);
    });

    test('utenti diversi -> playerId diversi; eventi Hub usano slay_ id',
        () async {
      final p1 = GameProvider();
      expect(await p1.registerLocal('eve', 'pw'), isTrue);
      final idEve = p1.hubPlayerId;
      await p1.logout();
      final p2 = GameProvider();
      expect(await p2.registerLocal('mallory', 'pw'), isTrue);
      expect(p2.hubPlayerId, isNot(idEve));

      final engine = p2.engine;
      expect(engine, isA<FakeEngineClient>());
      p2.completeTopicQuiz('hub_topic', 5, true);
      // fire-and-forget: lascia il microtask completare l'execute
      await settle();
      final fake = engine as FakeEngineClient;
      expect(fake.calls, isNotEmpty);
      expect(fake.calls.last['playerId'], startsWith('slay_'));
      expect(fake.calls.last['playerId'], isNot('mallory'));
    });
  });

  group('Fase 3: gate login minimo', () {
    test('isLoggedIn: false -> true -> false', () async {
      final provider = GameProvider();
      expect(provider.isLoggedIn, isFalse);
      expect(await provider.registerLocal('grace', 'pw'), isTrue);
      expect(provider.isLoggedIn, isTrue);
      expect(provider.currentUsername, 'grace');
      await provider.logout();
      expect(provider.isLoggedIn, isFalse);
      expect(provider.currentUsername, isNull);
    });
  });
}
