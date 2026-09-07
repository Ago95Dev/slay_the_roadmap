# 🎮 Comandi Essenziali - Dart Quest Flutter

## 📋 Comandi Base

### Setup Iniziale
```bash
# Pulisci progetto
flutter clean

# Scarica dipendenze
flutter pub get

# Verifica ambiente
flutter doctor
```

### Avvio App
```bash
# Linux
flutter run -d linux

# Web
flutter run -d chrome

# Android (dispositivo connesso)
flutter run -d android

# Verbose (con log dettagliati)
flutter run -d linux -v

# Release mode (veloce)
flutter run -d linux --release
```

### Durante l'Esecuzione
```bash
r  # Hot reload (ricarica senza perdere stato)
R  # Hot restart (riavvio completo)
q  # Quit (esci)
h  # Help (mostra tutti i comandi)
p  # Mostra performance overlay
P  # Mostra grid di debug
```

---

## 🔧 Manutenzione

### Pulizia
```bash
# Pulizia base
flutter clean

# Pulizia profonda
flutter clean
rm -rf build/
rm -rf .dart_tool/
```

### Aggiornamenti
```bash
# Aggiorna Flutter
flutter upgrade

# Aggiorna dipendenze
flutter pub upgrade

# Ripara cache
flutter pub cache repair
```

### Analisi Codice
```bash
# Analizza tutto
flutter analyze

# Analizza ignorando info
flutter analyze --no-fatal-infos

# Formatta codice
flutter format lib/
```

---

## 🏗️ Build

### Debug Build
```bash
# Linux
flutter build linux

# Web
flutter build web

# Android
flutter build apk
```

### Release Build
```bash
# Linux
flutter build linux --release

# Web
flutter build web --release

# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release
```

---

## 🔍 Diagnostica

### Informazioni Sistema
```bash
# Info dettagliate Flutter
flutter doctor -v

# Versione Flutter
flutter --version

# Versione Dart
dart --version

# Info dispositivi
flutter devices

# Info canali
flutter channel
```

### Debug & Test
```bash
# Esegui test
flutter test

# Esegui test con coverage
flutter test --coverage

# Test specifico
flutter test test/models/types_test.dart
```

### Performance
```bash
# Profile mode
flutter run --profile

# Trace startup
flutter run --trace-startup

# Observatory (DevTools)
flutter run --observatory-port=8888
```

---

## 📦 Gestione Dipendenze

### Installazione
```bash
# Scarica dipendenze
flutter pub get

# Scarica dipendenze offline
flutter pub get --offline

# Aggiorna pubspec.lock
flutter pub upgrade
```

### Informazioni
```bash
# Lista dipendenze
flutter pub deps

# Lista dipendenze outdated
flutter pub outdated

# Controlla versioni
flutter pub version
```

---

## 🎨 Configurazione

### Piattaforme
```bash
# Abilita Linux
flutter config --enable-linux-desktop

# Abilita macOS
flutter config --enable-macos-desktop

# Abilita Windows
flutter config --enable-windows-desktop

# Abilita Web
flutter config --enable-web

# Abilita Android
flutter config --enable-android

# Disabilita analytics
flutter config --no-analytics
```

### Impostazioni
```bash
# Mostra configurazione
flutter config

# Usa canale stable
flutter channel stable

# Usa canale beta
flutter channel beta
```

---

## 🐛 Troubleshooting

### Reset
```bash
# Reset completo
flutter clean
rm -rf build/ .dart_tool/
flutter pub cache repair
flutter pub get
```

### Processi
```bash
# Termina processi Flutter (Linux/macOS)
pkill -9 flutter
pkill -9 dart

# Rimuovi lock (Linux/macOS)
rm -rf /tmp/flutter_lock
```

### Cache
```bash
# Pulisci cache pub
flutter pub cache clean

# Ripara cache
flutter pub cache repair

# Lista cache
flutter pub cache list
```

---

## 📱 Dispositivi

### Gestione
```bash
# Lista dispositivi
flutter devices

# Avvia emulatore
flutter emulators

# Lista emulatori
flutter emulators --list

# Crea emulatore
flutter emulators --create
```

### Screenshot & Recording
```bash
# Screenshot (durante l'esecuzione)
s  # Premi 's' nella console

# Screenshot manuale
flutter screenshot

# Video recording (Android)
adb shell screenrecord /sdcard/demo.mp4
```

---

## 🌐 Web Specifico

### Sviluppo
```bash
# Avvia con porta specifica
flutter run -d chrome --web-port=8080

# Avvia con hostname
flutter run -d chrome --web-hostname=localhost

# Build web con renderer specifico
flutter build web --web-renderer html
flutter build web --web-renderer canvaskit
```

---

## 📊 DevTools

### Avvio
```bash
# Installa DevTools
flutter pub global activate devtools

# Avvia DevTools
flutter pub global run devtools

# Avvia con app
flutter run --devtools
```

---

## 🔐 Certificati & Signing (Android)

### Keystore
```bash
# Genera keystore
keytool -genkey -v -keystore ~/key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias key

# Verifica keystore
keytool -list -v -keystore ~/key.jks

# Build firmato
flutter build apk --release
```

---

## 📝 Generazione Codice

### Icons & Assets
```bash
# Genera launcher icons
flutter pub run flutter_launcher_icons:main

# Genera splash screen
flutter pub run flutter_native_splash:create
```

---

## 🎯 Quick Commands

```bash
# Setup veloce
flutter clean && flutter pub get

# Analizza e esegui
flutter analyze && flutter run -d linux

# Build release
flutter clean && flutter build linux --release

# Test e coverage
flutter test --coverage

# Aggiorna tutto
flutter upgrade && flutter pub upgrade
```

---

## 💡 Aliases Consigliati

Aggiungi al tuo `.bashrc` o `.zshrc`:

```bash
# Flutter aliases
alias fget='flutter pub get'
alias fclean='flutter clean'
alias frun='flutter run -d linux'
alias frunv='flutter run -d linux -v'
alias ftest='flutter test'
alias fbuild='flutter build linux --release'
alias fanalyze='flutter analyze'
alias fdoctor='flutter doctor -v'
alias fdevices='flutter devices'

# Workflow completo
alias fsetup='flutter clean && flutter pub get'
alias fcheck='flutter analyze && flutter test'
```

Ricarica shell:
```bash
source ~/.bashrc  # o ~/.zshrc
```

Usa:
```bash
fsetup  # Invece di flutter clean && flutter pub get
frun    # Invece di flutter run -d linux
```

---

## 📚 Riferimenti Rapidi

- **Documentazione**: https://flutter.dev/docs
- **API Reference**: https://api.flutter.dev/
- **Pub.dev**: https://pub.dev/
- **GitHub**: https://github.com/flutter/flutter
- **Discord**: https://discord.gg/flutter

---

**Suggerimento**: Crea uno script personalizzato con i comandi che usi più spesso!
