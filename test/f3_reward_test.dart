import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:slay_the_roadmap/data/repositories/reward_repository.dart';
import 'package:slay_the_roadmap/domain/models/player_progress.dart';
import 'package:slay_the_roadmap/domain/models/reward.dart';
import 'package:slay_the_roadmap/ui/screens/reward_choice_screen.dart';
import 'package:slay_the_roadmap/ui/view_models/player_view_model.dart';

/// F3 (US-03): reward pick-1-of-3, limite 1/topic, inventory pieno.
class FakeRewardRepository implements RewardRepository {
  final List<Reward> rewards;
  FakeRewardRepository(this.rewards);

  @override
  Future<List<Reward>> getAvailableRewards() async => rewards;

  @override
  Future<List<Reward>> getRewardsForTopic(String topicId) async => rewards;
}

Reward _testReward(String id, String name) => Reward(
      id: id,
      name: name,
      description: 'desc $name',
      type: RewardType.attack,
      rarity: RewardRarity.common,
      icon: '🔥',
      effects: {'damage': 2},
    );

void main() {
  group('PlayerViewModel.claimReward', () {
    test('claim aggiunge la reward a inventory', () {
      final vm = PlayerViewModel();
      expect(vm.inventory.rewards, isEmpty);

      final ok = vm.claimReward('topic1', _testReward('r1', 'R1'));

      expect(ok, isTrue);
      expect(vm.inventory.rewards, hasLength(1));
      expect(vm.inventory.rewards.first.id, 'r1');
      expect(vm.inventory.rewards.first.isSelected, isTrue);
      expect(vm.isTopicClaimed('topic1'), isTrue);
    });

    test('secondo claim per lo stesso topic ignorato', () {
      final vm = PlayerViewModel();
      vm.claimReward('topic1', _testReward('r1', 'R1'));

      final ok = vm.claimReward('topic1', _testReward('r2', 'R2'));

      expect(ok, isFalse);
      expect(vm.inventory.rewards, hasLength(1));
      expect(vm.inventory.rewards.first.id, 'r1');
    });

    test('inventory pieno rifiuta il claim', () {
      final full = PlayerProgress.initial().copyWith(
        inventory: PlayerInventory(
          rewards: [_testReward('r0', 'R0')],
          maxSlots: 1,
        ),
      );
      final vm = PlayerViewModel(initialProgress: full);
      expect(vm.isInventoryFull, isTrue);

      final ok = vm.claimReward('topic1', _testReward('r1', 'R1'));

      expect(ok, isFalse);
      expect(vm.inventory.rewards, hasLength(1));
      expect(vm.isTopicClaimed('topic1'), isFalse);
    });
  });

  group('RewardChoiceScreen', () {
    testWidgets('mostra 3 opzioni e conferma la scelta', (tester) async {
      final rewards = [
        _testReward('r1', 'Fake Alpha'),
        _testReward('r2', 'Fake Beta'),
        _testReward('r3', 'Fake Gamma'),
      ];
      final vm = PlayerViewModel();

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: vm,
          child: MaterialApp(
            home: RewardChoiceScreen(
              topicId: 'topic1',
              repository: FakeRewardRepository(rewards),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 3 opzioni con preview visibili.
      expect(find.text('Fake Alpha'), findsOneWidget);
      expect(find.text('Fake Beta'), findsOneWidget);
      expect(find.text('Fake Gamma'), findsOneWidget);
      expect(find.byKey(const ValueKey('reward_card_r1')), findsOneWidget);
      expect(find.byKey(const ValueKey('reward_card_r2')), findsOneWidget);
      expect(find.byKey(const ValueKey('reward_card_r3')), findsOneWidget);
      // Preview effetti.
      expect(find.textContaining('damage'), findsWidgets);

      // Tap = seleziona e conferma -> claim + chiudi.
      await tester.tap(find.text('Fake Beta'));
      await tester.pumpAndSettle();

      expect(vm.inventory.rewards, hasLength(1));
      expect(vm.inventory.rewards.first.id, 'r2');
      expect(vm.isTopicClaimed('topic1'), isTrue);
      expect(find.byType(RewardChoiceScreen), findsNothing);
    });
  });
}
