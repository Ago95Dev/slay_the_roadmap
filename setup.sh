#!/bin/bash

# Dart Quest - Setup Script
# Questo script automatizza il setup iniziale dell'applicazione Flutter

echo "🚀 Dart Quest - Setup Automatico"
echo "================================"
echo ""

# Colori per output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Funzione per stampare messaggi di successo
success() {
    echo -e "${GREEN}✓${NC} $1"
}

# Funzione per stampare messaggi di errore
error() {
    echo -e "${RED}✗${NC} $1"
}

# Funzione per stampare warning
warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

# Verifica che non stiamo usando sudo
if [ "$EUID" -eq 0 ]; then 
    error "NON eseguire questo script con sudo!"
    error "Flutter funziona meglio senza privilegi di root"
    exit 1
fi

# Verifica che Flutter sia installato
echo "🔍 Verifica installazione Flutter..."
if ! command -v flutter &> /dev/null; then
    error "Flutter non trovato!"
    echo "   Installa Flutter da: https://flutter.dev/docs/get-started/install"
    exit 1
fi
success "Flutter trovato!"

# Mostra versione Flutter
FLUTTER_VERSION=$(flutter --version | head -n 1)
echo "   $FLUTTER_VERSION"
echo ""

# Verifica Flutter Doctor
echo "🏥 Esecuzione Flutter Doctor..."
flutter doctor
echo ""

# Chiedi conferma per continuare
read -p "Vuoi continuare con il setup? (y/n) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    warning "Setup annullato dall'utente"
    exit 0
fi

# Pulisci build precedenti
echo "🧹 Pulizia build precedenti..."
flutter clean
if [ $? -eq 0 ]; then
    success "Build pulite!"
else
    error "Errore durante la pulizia"
    exit 1
fi
echo ""

# Scarica dipendenze
echo "📦 Download dipendenze..."
flutter pub get
if [ $? -eq 0 ]; then
    success "Dipendenze installate!"
else
    error "Errore durante l'installazione delle dipendenze"
    exit 1
fi
echo ""

# Verifica dispositivi disponibili
echo "📱 Dispositivi disponibili:"
flutter devices
echo ""

# Analizza il codice
echo "🔍 Analisi codice..."
flutter analyze --no-fatal-infos
if [ $? -eq 0 ]; then
    success "Codice analizzato - nessun errore!"
else
    warning "Analisi completata con warning (normale)"
fi
echo ""

# Abilita piattaforme desktop se necessario
echo "🖥️  Configurazione piattaforme..."
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    flutter config --enable-linux-desktop > /dev/null 2>&1
    success "Linux desktop abilitato"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    flutter config --enable-macos-desktop > /dev/null 2>&1
    success "macOS desktop abilitato"
elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
    flutter config --enable-windows-desktop > /dev/null 2>&1
    success "Windows desktop abilitato"
fi

flutter config --enable-web > /dev/null 2>&1
success "Web abilitato"
echo ""

# Setup completato
echo "================================"
echo -e "${GREEN}✅ Setup completato con successo!${NC}"
echo "================================"
echo ""
echo "🎮 Per avviare l'applicazione:"
echo ""
echo "   Linux:   flutter run -d linux"
echo "   Web:     flutter run -d chrome"
echo "   Android: flutter run -d android"
echo ""
echo "💡 Durante lo sviluppo:"
echo "   r - Hot reload (ricarica veloce)"
echo "   R - Hot restart (riavvio completo)"
echo "   q - Quit (esci)"
echo ""
echo "📚 Guide utili:"
echo "   - SETUP_GUIDE.md - Guida setup completa"
echo "   - README.md - Documentazione progetto"
echo "   - IMPLEMENTATION_GUIDE.md - Dettagli implementazione"
echo ""

# Chiedi se avviare subito l'app
read -p "Vuoi avviare l'app adesso? (y/n) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    echo "🚀 Avvio applicazione..."
    echo ""
    
    # Determina la piattaforma migliore
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        flutter run -d linux
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        flutter run -d macos
    elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
        flutter run -d windows
    else
        flutter run -d chrome
    fi
else
    echo ""
    echo "👋 Setup completato! Esegui 'flutter run -d <device>' quando sei pronto."
fi
