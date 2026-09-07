import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';

class GothicAnalyticsWidget extends StatelessWidget {
  const GothicAnalyticsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();
    final analytics = provider.analytics;
    
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildStatCard(
          'QUIZ COMPLETATI',
          analytics.quizPassed.toString(),
          Icons.school,
          const Color(0xFF4caf50),
        ),
        const SizedBox(height: 12),
        _buildStatCard(
          'BOSS SCONFITTI',
          analytics.bossWon.toString(),
          Icons.api,
          const Color(0xFFf44336),
        ),
        const SizedBox(height: 12),
        _buildStatCard(
          'QUIZ FALLITI',
          analytics.quizFailed.toString(),
          Icons.error_outline,
          const Color(0xFFff9800),
        ),
        const SizedBox(height: 12),
        _buildStatCard(
          'BOSS FALLITI',
          analytics.bossLost.toString(),
          Icons.warning,
          const Color(0xFFe91e63),
        ),
        const SizedBox(height: 24),
        const Text(
          'DA RIPASSARE',
          style: TextStyle(
            color: Color(0xFFd4af37),
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        if (provider.reviewTopics.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Nessun argomento da ripassare. Ottimo lavoro!',
                style: TextStyle(color: Color(0xFF8b6f47)),
              ),
            ),
          )
        else
          ...provider.reviewTopics.map((topicId) => Card(
            color: const Color(0xFF1a1410),
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: Color(0xFF8b6f47), width: 1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListTile(
              leading: const Icon(Icons.menu_book, color: Color(0xFF8b6f47)),
              title: Text(
                topicId,
                style: const TextStyle(
                  color: Color(0xFFf5f5dc),
                  fontWeight: FontWeight.bold,
                ),
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFff9800).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Errori: ${provider.failCount[topicId] ?? 0}',
                  style: const TextStyle(color: Color(0xFFff9800), fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ),
          )),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1a1410),
        border: Border.all(color: const Color(0xFF8b6f47), width: 1),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Color(0xFFf5f5dc),
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
