import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/types.dart';
import '../providers/game_provider.dart';
import '../utils/app_theme.dart';

class RewardSelectionScreen extends StatefulWidget {
  final List<RoadmapReward> rewards;
  final String topicTitle;
  final String topicId;

  const RewardSelectionScreen({
    super.key,
    required this.rewards,
    required this.topicTitle,
    required this.topicId,
  });

  @override
  State<RewardSelectionScreen> createState() => _RewardSelectionScreenState();
}

class _RewardSelectionScreenState extends State<RewardSelectionScreen> {
  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Your Reward'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Card(
              color: Colors.green.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Icon(
                      Icons.emoji_events,
                      size: 48,
                      color: Colors.amber,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Topic Completed!',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.topicTitle,
                      style: theme.textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Instructions
            Text(
              'Choose 1 reward to add to your collection:',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Rewards list
            Expanded(
              child: ListView.builder(
                itemCount: widget.rewards.length,
                itemBuilder: (context, index) {
                  final reward = widget.rewards[index];
                  final isSelected = _selectedIndex == index;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: _RewardCard(
                      reward: reward,
                      isSelected: isSelected,
                      onTap: () {
                        setState(() {
                          _selectedIndex = index;
                        });
                      },
                    ),
                  );
                },
              ),
            ),

            // Confirm button
            FilledButton(
              onPressed: _selectedIndex != null ? _confirmSelection : null,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Confirm Selection',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmSelection() {
    if (_selectedIndex == null) return;

    final selectedReward = widget.rewards[_selectedIndex!];
    final gameProvider = context.read<GameProvider>();

    // Process the selected reward
    _processReward(gameProvider, selectedReward);

    // Show confirmation and return
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Reward Claimed!'),
          ],
        ),
        content: Text(_getRewardDescription(selectedReward)),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close reward selection screen
              Navigator.pop(context); // Close quiz screen
              // Now back at roadmap
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _processReward(GameProvider provider, RoadmapReward reward) {
    switch (reward.type) {
      case 'card':
        // Generate a card based on rarity (placeholder for now)
        final cardId = 'card_${reward.rarity?.name}_${DateTime.now().millisecondsSinceEpoch}';
        provider.addCardToInventory(cardId);
        break;
      case 'relic':
        if (reward.id != null) {
          provider.addCardToInventory(reward.id!); // Using inventory for relics too
        }
        break;
      case 'gold':
        provider.addGold(reward.amount ?? 0);
        break;
      case 'experience':
        // XP already awarded by quiz completion
        break;
      case 'health':
        // Health will be applied (handled in completeTopicQuiz)
        break;
    }
  }

  String _getRewardDescription(RoadmapReward reward) {
    switch (reward.type) {
      case 'card':
        final rarityName = reward.rarity?.name ?? 'common';
        return 'You received a $rarityName card! Check your deck builder to see it.';
      case 'relic':
        return 'You obtained a powerful relic! It will help you in future battles.';
      case 'gold':
        return 'You earned ${reward.amount} gold! Use it wisely.';
      case 'experience':
        return 'You gained ${reward.amount} experience points!';
      case 'health':
        return 'Restored ${reward.amount} HP!';
      default:
        return 'Reward claimed!';
    }
  }
}

class _RewardCard extends StatelessWidget {
  final RoadmapReward reward;
  final bool isSelected;
  final VoidCallback onTap;

  const _RewardCard({
    required this.reward,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (icon, title, description, color) = _getRewardInfo();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withOpacity(0.2)
              : theme.colorScheme.surfaceContainerHighest,
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 3 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: color,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            // Selection indicator
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 20,
                ),
              ),
          ],
        ),
      ),
    );
  }

  (IconData, String, String, Color) _getRewardInfo() {
    switch (reward.type) {
      case 'card':
        final rarityName = reward.rarity?.name ?? 'common';
        final color = AppTheme.getRarityColor(rarityName);
        return (
          Icons.style,
          '${_capitalize(rarityName)} Card',
          'Add a $rarityName card to your collection',
          color,
        );
      case 'relic':
        return (
          Icons.military_tech,
          'Relic',
          'A powerful artifact with special effects',
          Colors.purple,
        );
      case 'gold':
        return (
          Icons.monetization_on,
          '${reward.amount} Gold',
          'Currency for purchasing items and upgrades',
          Colors.amber,
        );
      case 'experience':
        return (
          Icons.star,
          '${reward.amount} XP',
          'Progress towards your next level',
          Colors.cyan,
        );
      case 'health':
        return (
          Icons.favorite,
          '+${reward.amount} HP',
          'Restore your health',
          Colors.red,
        );
      default:
        return (
          Icons.card_giftcard,
          'Mystery Reward',
          'A special reward awaits',
          Colors.grey,
        );
    }
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}
