import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:slay_the_roadmap/screens/resource_browser_screen.dart';

/// Fallback Linux della schermata risorsa "Variables & Types":
/// webview_flutter non ha implementazione su Linux desktop, quindi la
/// schermata NON deve istanziare WebView ma mostrare il pannello con
/// "Apri nel browser" (url_launcher) + URL visibile, mantenendo il
/// flusso claim ("Claim Reward Anyway").
void main() {
  test('isResourceWebViewSupported: false su Linux/Windows, true su mobile',
      () {
    debugDefaultTargetPlatformOverride = TargetPlatform.linux;
    expect(isResourceWebViewSupported(), isFalse);

    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    expect(isResourceWebViewSupported(), isFalse);

    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    expect(isResourceWebViewSupported(), isTrue);

    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    expect(isResourceWebViewSupported(), isTrue);

    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('Linux: nessun WebView, pannello browser + claim senza eccezioni',
      (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.linux;
    try {
      const url = 'https://dart.dev/language/variables';
      await tester.pumpWidget(
        const MaterialApp(
          home: ResourceBrowserScreen(
            url: url,
            resourceTitle: 'Variables & Types',
            topicId: 'topic-1',
            resourceIndex: 0,
          ),
        ),
      );
      await tester.pump();

      // Nessuna eccezione durante il mount (prima l'assertion WebViewPlatform crashava).
      expect(tester.takeException(), isNull);

      // Pannello fallback: titolo risorsa, pulsante browser, URL visibile.
      expect(find.text('Variables & Types'), findsWidgets);
      expect(find.text('Apri nel browser'), findsOneWidget);
      expect(find.textContaining(url), findsWidgets);

      // Il flusso claim esistente è invariato.
      expect(find.text('Claim Reward Anyway'), findsOneWidget);

      // Tap claim: qualifica la reward senza eccezioni.
      await tester.tap(find.text('Claim Reward Anyway'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(tester.takeException(), isNull);
      expect(find.text('Reward Ready!'), findsOneWidget);

      // Smonta la schermata per cancellare il timer periodico.
      await tester.pumpWidget(const SizedBox());
      await tester.pump();
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });
}
