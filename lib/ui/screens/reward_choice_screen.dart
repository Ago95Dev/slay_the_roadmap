import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/repositories/reward_repository.dart';
import '../../domain/models/reward.dart';
import '../view_models/player_view_model.dart';

/// Scelta di 1 ricompensa su 3 dopo un quiz passato (F3, US-03).
///
/// Mostra le 3 reward di `getRewardsForTopic` con preview (nome, descrizione,
/// tipo, rarità, righe effetti). Il tap su una carta seleziona e conferma:
/// chiama `claimReward` e chiude la schermata.
///
/// Riusabile per F4 (boss fight): è esposta via `screens.dart` ma NON
/// cablata nel boss — sarà la F4 a farlo.
class RewardChoiceScreen extends StatelessWidget {
  final String topicId;
  final RewardRepository? repository;

  const RewardChoiceScreen({
    super.key,
    required this.topicId,
    this.repository,
  });

  @override
  Widget build(BuildContext context) {
    final repo = repository ?? LocalRewardRepository();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scegli la tua ricompensa'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: FutureBuilder<List<Reward>>(
        future: repo.getRewardsForTopic(topicId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Text(
                'Errore nel caricamento delle ricompense',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            );
          }
          final rewards = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: rewards.length,
            itemBuilder: (context, index) {
              final reward = rewards[index];
              return _buildRewardCard(context, reward);
            },
          );
        },
      ),
    );
  }

  Widget _buildRewardCard(BuildContext context, Reward reward) {
    return Card(
      key: ValueKey('reward_card_${reward.id}'),
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Text(
          reward.icon,
          style: const TextStyle(fontSize: 32),
        ),
        title: Text(
          reward.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(reward.description),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildChip(context, reward.type.name, Colors.blue),
                const SizedBox(width: 8),
                _buildChip(context, reward.rarity.name, Colors.amber),
              ],
            ),
            const SizedBox(height: 4),
            ...reward.effects.entries.map(
              (e) => Text(
                '${e.key}: ${e.value}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
        onTap: () {
          final playerVm =
              Provider.of<PlayerViewModel>(context, listen: false);
          final ok = playerVm.claimReward(topicId, reward);
          if (!ok && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Ricompensa non riscattabile'),
              ),
            );
            return;
          }
          Navigator.of(context).pop(reward);
        },
      ),
    );
  }

  Widget _buildChip(BuildContext context, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
