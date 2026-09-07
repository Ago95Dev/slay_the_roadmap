import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../data/relics_data.dart';
import '../widgets/run_history_widget.dart';
import '../widgets/relic_collection_widget.dart';
import '../widgets/card_compendium_widget.dart';
import '../widgets/gothic_leaderboard_widget.dart';
import '../widgets/gothic_analytics_widget.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0a0806),
            Color(0xFF1a1410),
          ],
        ),
      ),
      child: Column(
        children: [
          // Gothic Tab Bar
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: const Color(0xFF8b6f47),
                width: 2,
              ),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorColor: const Color(0xFFd4af37),
              indicatorWeight: 3,
              labelColor: const Color(0xFFfbbf24),
              unselectedLabelColor: const Color(0xFF8b6f47),
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
                fontSize: 11,
              ),
              tabs: const [
                Tab(
                  text: 'HISTORY',
                  icon: Icon(Icons.history),
                ),
                Tab(
                  text: 'RANKINGS',
                  icon: Icon(Icons.emoji_events),
                ),
                Tab(
                  text: 'ANALYTICS',
                  icon: Icon(Icons.query_stats),
                ),
                Tab(
                  text: 'RELICS',
                  icon: Icon(Icons.auto_awesome),
                ),
                Tab(
                  text: 'CARDS',
                  icon: Icon(Icons.style),
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                RunHistoryWidget(),
                GothicLeaderboardWidget(),
                GothicAnalyticsWidget(),
                RelicCollectionWidget(),
                CardCompendiumWidget(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
