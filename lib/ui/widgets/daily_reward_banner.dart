import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../view_models/player_view_model.dart';

/// Banner ricompensa giornaliera (Fase 1B-E, locale): visibile solo se
/// il claim di oggi è disponibile. Tap = claim + SnackBar di conferma.
///
/// Widget condiviso tra Home (gioco) e Hub personale: l'unica fonte è
/// [PlayerViewModel] (`isDailyRewardAvailable` / `claimDailyReward`),
/// quindi il claim fatto da una schermata nasconde il banner anche
/// nell'altra (nessuna duplicazione di logica o di stato).
class DailyRewardBanner extends StatelessWidget {
  /// Chiave della Card (default: quella storica della Home, per non
  /// rompere i test esistenti). L'Hub passa le sue chiavi `hub_*`.
  final Key cardKey;

  /// Chiave dell'area tappabile (default: quella storica della Home).
  final Key tapKey;

  const DailyRewardBanner({
    super.key,
    this.cardKey = const Key('home_daily_reward'),
    this.tapKey = const Key('home_daily_reward_tap'),
  });

  @override
  Widget build(BuildContext context) {
    final playerVm = context.watch<PlayerViewModel>();
    if (!playerVm.isDailyRewardAvailable) return const SizedBox.shrink();
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth > 600 ? 400.0 : screenWidth * 0.85;
    return SizedBox(
      width: cardWidth,
      child: Card(
        key: cardKey,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: InkWell(
          key: tapKey,
          borderRadius: BorderRadius.circular(15),
          onTap: () {
            final claimed = context.read<PlayerViewModel>().claimDailyReward();
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  claimed
                      ? '🎁 Ricompensa riscattata! +${PlayerViewModel.dailyRewardXp} XP'
                      : 'Già riscattata oggi, torna domani!',
                ),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.deepPurple, Colors.purpleAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Row(
              children: [
                Icon(Icons.card_giftcard, color: Colors.white, size: 28),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '🎁 Ricompensa giornaliera +25 XP',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
