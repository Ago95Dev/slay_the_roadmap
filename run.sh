#!/bin/bash

# Dart Quest - Quick Run Script
# Avvio rapido dell'applicazione Flutter

echo "🎮 Dart Quest - Quick Run"
echo "========================"
echo ""

# Verifica che Flutter sia installato
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter non trovato!"
    echo "   Installa Flutter da: https://flutter.dev/docs/get-started/install"
    exit 1
fi

# Verifica se siamo nella directory corretta
if [ ! -f "pubspec.yaml" ]; then
    echo "❌ File pubspec.yaml non trovato!"
    echo "   Esegui questo script dalla directory root del progetto"
    exit 1
fi

# Verifica se è il primo avvio
if [ ! -d ".dart_tool" ]; then
    echo "📦 Primo avvio rilevato - eseguo setup..."
    echo ""
    
    # Esegui setup
    flutter clean
    flutter pub get
    
    echo ""
    echo "✅ Setup completato!"
    echo ""
fi

# Verifica dispositivi disponibili
echo "📱 Dispositivi disponibili:"
flutter devices
echo ""

# Chiedi quale dispositivo usare
echo "Seleziona piattaforma:"
echo "  1) Linux Desktop"
echo "  2) Web (Chrome)"
echo "  3) Android"
echo "  4) Lascia scegliere a Flutter"
echo ""
read -p "Scelta (1-4): " choice

case $choice in
    1)
        echo ""
        echo "🚀 Avvio su Linux Desktop..."
        flutter run -d linux
        ;;
    2)
        echo ""
        echo "🌐 Avvio su Web (Chrome)..."
        flutter run -d chrome
        ;;
    3)
        echo ""
        echo "📱 Avvio su Android..."
        flutter run -d android
        ;;
    4)
        echo ""
        echo "🚀 Avvio automatico..."
        flutter run
        ;;
    *)
        echo ""
        echo "⚠️  Scelta non valida, avvio automatico..."
        flutter run
        ;;
esac
