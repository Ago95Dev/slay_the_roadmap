import 'package:flutter/material.dart';

import '../../domain/models/campaign.dart';
import '../view_models/session_controller.dart';

/// Selezione campagna (F11, DOPO il login e PRIMA della Home).
///
/// Lista le campagne di [SessionController.availableCampaigns]: quelle
/// attive con bottone "Gioca", quelle coming soon disabilitate con badge
/// "Prossimamente" (niente contenuti, mai selezionabili). A scelta riuscita
/// la [SessionController] notifica e la root monta la Home della campagna.
class CampaignSelectionScreen extends StatelessWidget {
  final SessionController session;

  const CampaignSelectionScreen({super.key, required this.session});

  Future<void> _play(BuildContext context, Campaign campaign) async {
    try {
      await session.selectCampaign(campaign.id);
    } on StateError catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final campaigns = session.availableCampaigns;
    return Scaffold(
      appBar: AppBar(
        title: const Text('🗺️ Scegli la campagna'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Ciao, ${session.activeProfile?.displayName ?? 'Giocatore'}! '
                    'Dove vuoi avventurarti?',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ...campaigns.map((c) => _buildTile(context, c)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTile(BuildContext context, Campaign campaign) {
    final comingSoon = campaign.isComingSoon;
    return Card(
      key: Key('campaign_${campaign.id}'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    campaign.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                if (comingSoon)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .secondaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Prossimamente',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              comingSoon ? 'Contenuti in costruzione.' : campaign.subtitle,
            ),
            const SizedBox(height: 12),
            if (comingSoon)
              OutlinedButton(
                key: Key('campaign_soon_${campaign.id}'),
                onPressed: null,
                child: const Text('Non ancora disponibile'),
              )
            else
              FilledButton(
                key: Key('campaign_play_${campaign.id}'),
                onPressed: () => _play(context, campaign),
                child: const Text('Gioca'),
              ),
          ],
        ),
      ),
    );
  }
}
