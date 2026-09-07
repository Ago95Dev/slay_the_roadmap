import 'package:flutter/material.dart';

import '../widgets/my_numbers_card.dart';

/// Schermata "I miei numeri" dell'Hub: mostra la [MyNumbersCard]
/// condivisa con Settings (stessi conteggi, nessuna logica duplicata).
class MyNumbersScreen extends StatelessWidget {
  const MyNumbersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('hub_numbers_screen'),
      appBar: AppBar(
        title: const Text('📊 I miei numeri'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          MyNumbersCard(),
        ],
      ),
    );
  }
}
