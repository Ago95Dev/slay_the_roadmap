import 'package:flutter/material.dart';
import '../../domain/models/player_progress.dart';
import '../../domain/models/reward.dart';

/// Store globale condiviso del giocatore (F3, US-03).
///
/// Tiene un'istanza condivisa di [PlayerProgress] (prima nessuno la
/// possedeva) e il set dei topic per cui la reward è già stata riscattata
/// (limite 1 reward/topic).
class PlayerViewModel with ChangeNotifier {
  PlayerProgress _progress;
  final Set<String> _claimedRewardTopics = {};

  PlayerViewModel({PlayerProgress? initialProgress})
      : _progress = initialProgress ?? PlayerProgress.initial();

  PlayerProgress get progress => _progress;
  PlayerInventory get inventory => _progress.inventory;
  Set<String> get claimedRewardTopics =>
      Set.unmodifiable(_claimedRewardTopics);

  bool isTopicClaimed(String topicId) =>
      _claimedRewardTopics.contains(topicId);

  bool get isInventoryFull => !inventory.hasEmptySlots;

  bool canClaim(String topicId) =>
      !isTopicClaimed(topicId) && !isInventoryFull;

  /// Riscatta [reward] per [topicId].
  /// Ritorna false (e ignora) se il topic ha già riscosso o se
  /// l'inventario è pieno.
  bool claimReward(String topicId, Reward reward) {
    if (isTopicClaimed(topicId)) return false;
    if (isInventoryFull) return false;
    _progress = _progress.addReward(reward.copyWith(isSelected: true));
    _claimedRewardTopics.add(topicId);
    notifyListeners();
    return true;
  }

  /// Delega a [PlayerProgress.addCompletedTopic] (+100xp).
  void addCompletedTopic(String topicId) {
    _progress = _progress.addCompletedTopic(topicId);
    notifyListeners();
  }
}
