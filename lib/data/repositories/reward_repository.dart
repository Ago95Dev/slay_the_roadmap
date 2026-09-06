import '../../domain/models/reward.dart';

abstract class RewardRepository {
  Future<List<Reward>> getAvailableRewards();
  Future<List<Reward>> getRewardsForTopic(String topicId);
}

class LocalRewardRepository implements RewardRepository {
  /// Libreria a tema fondamenta web. Effetti semplici, MAI oltre 2
  /// (damage 1-2, block 1, heal 1): boss HP 10 / player HP 3.
  final List<Reward> _allRewards = [
    Reward(
      id: 'semantic_strike',
      name: 'Semantic Strike',
      description: 'Tag semantici precisi: 2 danni al boss',
      type: RewardType.attack,
      rarity: RewardRarity.common,
      icon: '🏷️',
      effects: {'damage': 2},
    ),
    Reward(
      id: 'dns_resolve',
      name: 'DNS Resolve',
      description: 'Risolvi il nome e colpisci: 1 danno al boss',
      type: RewardType.attack,
      rarity: RewardRarity.common,
      icon: '🌐',
      effects: {'damage': 1},
    ),
    Reward(
      id: 'json_parse',
      name: 'JSON Parse',
      description: 'Dati ben formati: 1 danno al boss',
      type: RewardType.attack,
      rarity: RewardRarity.common,
      icon: '📦',
      effects: {'damage': 1},
    ),
    Reward(
      id: 'cache_shield',
      name: 'Cache Shield',
      description: 'Copia fresca a portata di mano: blocca 1 danno',
      type: RewardType.defense,
      rarity: RewardRarity.common,
      icon: '🛡️',
      effects: {'block': 1},
    ),
    Reward(
      id: 'flexbox_guard',
      name: 'Flexbox Guard',
      description: 'Layout che assorbe i colpi: blocca 1 danno',
      type: RewardType.defense,
      rarity: RewardRarity.rare,
      icon: '🧱',
      effects: {'block': 1},
    ),
    Reward(
      id: 'tls_tunnel',
      name: 'TLS Tunnel',
      description: 'Canale cifrato e sicuro: recupera 1 HP',
      type: RewardType.utility,
      rarity: RewardRarity.rare,
      icon: '🔒',
      effects: {'heal': 1},
    ),
  ];

  @override
  Future<List<Reward>> getAvailableRewards() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _allRewards;
  }

  @override
  Future<List<Reward>> getRewardsForTopic(String topicId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    // 3 carte di 3 TIPI diversi: priorità attack, defense, utility
    // poi special; random dentro il tipo; fallback se un tipo esaurito.
    const priority = [
      RewardType.attack,
      RewardType.defense,
      RewardType.utility,
      RewardType.special,
    ];
    final picked = <Reward>[];
    final pickedIds = <String>{};
    for (final type in priority) {
      if (picked.length >= 3) break;
      final pool = _allRewards.where(
        (r) => r.type == type && !pickedIds.contains(r.id),
      ).toList()
        ..shuffle();
      if (pool.isNotEmpty) {
        picked.add(pool.first);
        pickedIds.add(pool.first.id);
      }
    }
    // Fallback: riempi con le rimanenti se qualche tipo era esaurito.
    if (picked.length < 3) {
      final rest = _allRewards.where(
        (r) => !pickedIds.contains(r.id),
      ).toList()
        ..shuffle();
      for (final r in rest) {
        if (picked.length >= 3) break;
        // Evita duplicati di tipo se possibile.
        if (picked.any((p) => p.type == r.type)) continue;
        picked.add(r);
        pickedIds.add(r.id);
      }
      // Ultima spiaggia: prendi comunque le rimanenti (tipi ripetuti).
      for (final r in rest) {
        if (picked.length >= 3) break;
        if (pickedIds.contains(r.id)) continue;
        picked.add(r);
        pickedIds.add(r.id);
      }
    }
    return picked;
  }
}
