import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:slay_the_roadmap/data/services/shared_preferences_persistence.dart';
import 'package:slay_the_roadmap/data/services/user_store.dart';
import 'package:slay_the_roadmap/domain/models/player_progress.dart';
import 'package:slay_the_roadmap/domain/models/reward.dart';
import 'package:slay_the_roadmap/ui/screens/profile_screen.dart';
import 'package:slay_the_roadmap/ui/view_models/session_controller.dart';

/// F10: profili locali multipli + login/registrazione + migrazione save.

Reward _testReward(String id) => Reward(
      id: id,
      name: 'Card $id',
      description: 'desc',
      type: RewardType.attack,
      rarity: RewardRarity.common,
      icon: 'sword',
      effects: const {'damage': 2},
    );

Future<UserStore> _store() async =>
    UserStore(await SharedPreferences.getInstance());

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('UserStore register/login', () {
    test('register ok: profilo attivo + save fresco col displayName', () async {
      final store = await _store();
      final profile =
          await store.register(username: 'Ada', password: 'segreta');

      expect(profile.displayName, 'Ada');
      expect(profile.passwordHash.isNotEmpty, isTrue);
      expect(store.activeUser()?.userId, profile.userId);
      expect(store.listUsers().single.userId, profile.userId);

      final saved =
          await store.dataFor(profile.userId).loadPlayerProgress();
      expect(saved, isNotNull);
      expect(saved!.playerName, 'Ada');
      expect(saved.completedTopicIds, isEmpty);
    });

    test('register ko: duplicato (case-insensitive), vuoti', () async {
      final store = await _store();
      await store.register(username: 'Ada', password: 'x');

      expect(
        () => store.register(username: 'ada', password: 'y'),
        throwsStateError,
      );
      expect(
        () => store.register(username: '  Ada  ', password: 'y'),
        throwsStateError,
      );
      expect(
        () => store.register(username: '   ', password: 'y'),
        throwsStateError,
      );
      expect(
        () => store.register(username: 'Bob', password: ''),
        throwsStateError,
      );
      expect(store.listUsers(), hasLength(1));
    });

    test('login ok rende attivo; ko (password/utente) ritorna null', () async {
      final store = await _store();
      await store.register(username: 'Ada', password: 'segreta');
      await store.logout();
      expect(store.activeUser(), isNull);

      final ok = await store.login(username: 'ada', password: 'segreta');
      expect(ok, isNotNull);
      expect(store.activeUser()?.displayName, 'Ada');

      await store.logout();
      expect(await store.login(username: 'Ada', password: 'sbagliata'),
          isNull);
      expect(store.activeUser(), isNull);
      expect(await store.login(username: 'Nessuno', password: 'x'), isNull);
    });

    test('hash deterministico col salt, diverso tra utenti', () async {
      final store = await _store();
      final a = await store.register(username: 'Ada', password: 'stessa');
      final b = await store.register(username: 'Bob', password: 'stessa');
      expect(a.passwordHash, isNot(UserStore.hashPassword(a.passwordSalt, 'x')));
      expect(a.passwordHash,
          UserStore.hashPassword(a.passwordSalt, 'stessa'));
      // Stessa password, salt diversi → hash diversi.
      expect(a.passwordHash, isNot(b.passwordHash));
    });
  });

  group('Isolamento profili', () {
    test('progress separati: A completa, B parte fresco, switch preserva',
        () async {
      final store = await _store();
      final session = SessionController(store);

      await session.register(username: 'Ada', password: 'x');
      session.player!.addCompletedTopic('web_network');
      session.player!.claimReward('web_network', _testReward('r1'));
      await Future.delayed(const Duration(milliseconds: 100));

      await session.register(username: 'Bob', password: 'y');
      expect(session.activeProfile!.displayName, 'Bob');
      expect(session.player!.hasProgress, isFalse);
      expect(session.player!.hubPlayerId,
          'slay_${session.activeProfile!.userId}_web_foundations');

      await session.login(username: 'Ada', password: 'x');
      expect(session.player!.progress.completedTopicIds, ['web_network']);
      expect(session.player!.isTopicClaimed('web_network'), isTrue);
      expect(session.player!.inventory.rewards.single.id, 'r1');

      await session.login(username: 'Bob', password: 'y');
      expect(session.player!.hasProgress, isFalse);
    });

    test('wipe preserva identità profilo ma cancella progressi', () async {
      final store = await _store();
      final session = SessionController(store);
      await session.register(username: 'Ada', password: 'x');
      session.player!.addCompletedTopic('web_network');
      await session.player!.wipe();
      expect(session.player!.hasProgress, isFalse);
      expect(session.player!.progress.playerName, 'Ada');
    });
  });

  group('Migrazione slay_save_v1', () {
    test('legacy → utente Giocatore con stessi dati, una-tantum', () async {
      final prefs = await SharedPreferences.getInstance();
      final legacy = SharedPreferencesPersistence(prefs);
      final progress = PlayerProgress.initial().copyWith(
        playerName: 'VecchioEroe',
        experience: 200,
        completedTopicIds: const ['web_network'],
      );
      await legacy.savePlayerProgress(progress);
      await legacy.saveClaimedRewardTopics({'web_network'});
      expect(await legacy.hasSave(), isTrue);

      final store = UserStore(prefs);
      final migrated = await store.migrateLegacyIfNeeded();
      expect(migrated, isNotNull);
      expect(migrated!.displayName, 'Giocatore');
      expect(migrated.hasPassword, isFalse);
      expect(store.activeUser()?.userId, migrated.userId);

      final restored =
          await store.dataFor(migrated.userId).loadPlayerProgress();
      expect(restored, isNotNull);
      expect(restored!.playerName, 'VecchioEroe');
      expect(restored.experience, 200);
      expect(restored.completedTopicIds, ['web_network']);
      expect(
        await store.dataFor(migrated.userId).loadClaimedRewardTopics(),
        {'web_network'},
      );

      // Una-tantum: seconda chiamata = null, nessun duplicato.
      expect(await store.migrateLegacyIfNeeded(), isNull);
      expect(store.listUsers(), hasLength(1));
    });

    test('senza legacy nessun profilo; con utenti esistenti ignora legacy',
        () async {
      final prefs = await SharedPreferences.getInstance();
      final store = UserStore(prefs);
      expect(await store.migrateLegacyIfNeeded(), isNull);
      expect(store.listUsers(), isEmpty);

      await store.register(username: 'Ada', password: 'x');
      // Legacy scritto DOPO (caso limite): ignorato, utenti invariati.
      await SharedPreferencesPersistence(prefs)
          .savePlayerProgress(PlayerProgress.initial());
      expect(await store.migrateLegacyIfNeeded(), isNull);
      expect(store.listUsers().single.displayName, 'Ada');
    });

    test('login profilo migrato senza password', () async {
      final prefs = await SharedPreferences.getInstance();
      await SharedPreferencesPersistence(prefs)
          .savePlayerProgress(PlayerProgress.initial());
      final store = UserStore(prefs);
      await store.migrateLegacyIfNeeded();
      await store.logout();
      final back = await store.login(username: 'giocatore', password: 'qualunque');
      expect(back, isNotNull);
    });
  });

  group('SessionController switch/logout', () {
    test('logout smonta i ViewModel e pulisce attivo', () async {
      final store = await _store();
      final session = SessionController(store);
      await session.register(username: 'Ada', password: 'x');
      expect(session.isLoggedIn, isTrue);
      expect(session.player, isNotNull);
      expect(session.roadmap, isNotNull);

      await session.logout();
      expect(session.isLoggedIn, isFalse);
      expect(session.player, isNull);
      expect(session.roadmap, isNull);
      expect(store.activeUser(), isNull);
    });

    test('restore NON riapre l\'utente: serve login esplicito (BUG 1)',
        () async {
      final store = await _store();
      final first = SessionController(store);
      await first.register(username: 'Ada', password: 'x');
      first.player!.addCompletedTopic('web_network');
      await Future.delayed(const Duration(milliseconds: 100));

      // Bootstrap: restore segna pronto ma non apre nessuna sessione.
      final second = SessionController(store);
      await second.restore();
      expect(second.ready, isTrue);
      expect(second.isLoggedIn, isFalse);
      expect(second.player, isNull);

      // Login esplicito: progressi ripristinati con roadmap applicata.
      await second.login(username: 'Ada', password: 'x');
      expect(second.activeProfile!.displayName, 'Ada');
      expect(second.player!.progress.completedTopicIds, ['web_network']);
      expect(second.roadmap!.topics, isNotEmpty);
    });

    test('restore senza attivo: pronto ma senza sessione', () async {
      final store = await _store();
      final session = SessionController(store);
      await session.restore();
      expect(session.ready, isTrue);
      expect(session.isLoggedIn, isFalse);
    });
  });

  group('ProfileSwitchScreen', () {
    testWidgets('0 utenti → form registrazione diretto', (tester) async {
      final session = SessionController(await _store());
      await tester.pumpWidget(
        MaterialApp(home: ProfileSwitchScreen(session: session)),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('profile_register_submit')), findsOneWidget);
      expect(find.byKey(const Key('profile_new_button')), findsNothing);

      await tester.enterText(
          find.byKey(const Key('profile_register_username')), 'Ada');
      await tester.enterText(
          find.byKey(const Key('profile_register_password')), 'segreta');
      await tester.tap(find.byKey(const Key('profile_register_submit')));
      await tester.pumpAndSettle();

      expect(session.isLoggedIn, isTrue);
      expect(session.activeProfile!.displayName, 'Ada');
    });

    testWidgets('≥1 utenti → lista + login ko/ok', (tester) async {
      final store = await _store();
      final session = SessionController(store);
      // Setup pre-pump in tempo reale: loadRoadmap ha delay di 500ms che
      // nel fake-async dei widget test avanza solo con i pump.
      await tester.runAsync(() async {
        await session.register(username: 'Ada', password: 'segreta');
        await session.logout();
      });

      await tester.pumpWidget(
        MaterialApp(home: ProfileSwitchScreen(session: session)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Ada'), findsOneWidget);
      expect(find.byKey(const Key('profile_register_submit')), findsNothing);

      await tester.tap(find.text('Ada'));
      await tester.pumpAndSettle();
      expect(
          find.byKey(const Key('profile_login_password')), findsOneWidget);

      // Password errata → resta sloggato + SnackBar.
      await tester.enterText(
          find.byKey(const Key('profile_login_password')), 'sbagliata');
      await tester.tap(find.byKey(const Key('profile_login_submit')));
      await tester.pumpAndSettle();
      expect(session.isLoggedIn, isFalse);
      expect(find.text('Password errata. Riprova.'), findsOneWidget);

      // Password giusta → loggato.
      await tester.enterText(
          find.byKey(const Key('profile_login_password')), 'segreta');
      await tester.tap(find.byKey(const Key('profile_login_submit')));
      await tester.pumpAndSettle();
      expect(session.isLoggedIn, isTrue);
    });

    testWidgets('Nuovo profilo dalla lista', (tester) async {
      final store = await _store();
      final session = SessionController(store);
      await tester.runAsync(() async {
        await session.register(username: 'Ada', password: 'x');
        await session.logout();
      });

      await tester.pumpWidget(
        MaterialApp(home: ProfileSwitchScreen(session: session)),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('profile_new_button')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('profile_register_submit')), findsOneWidget);

      await tester.enterText(
          find.byKey(const Key('profile_register_username')), 'Bob');
      await tester.enterText(
          find.byKey(const Key('profile_register_password')), 'y');
      await tester.tap(find.byKey(const Key('profile_register_submit')));
      await tester.pumpAndSettle();

      expect(session.activeProfile!.displayName, 'Bob');
      expect(store.listUsers(), hasLength(2));
    });
  });
}
