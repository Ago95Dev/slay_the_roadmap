# 🚀 Guida Setup e Avvio - Dart Quest Flutter

## ✅ Problemi Risolti

1. ✅ Rimosso Hive e dipendenze da `types.g.dart`
2. ✅ Sostituite icone mancanti (sword → flash_on, swords → local_fire_department)
3. ✅ Corretto CardTheme → CardThemeData
4. ✅ Rimossi font esterni (Inter) - usa font di sistema
5. ✅ Pulito pubspec.yaml da dipendenze non necessarie

## 📋 Requisiti

- Flutter SDK: >=3.0.0
- Dart SDK: >=3.0.0
- Linux/Windows/macOS/Android/iOS

## 🔧 Setup Passo-Passo

### 1. Verifica Installazione Flutter

```bash
flutter --version
flutter doctor
```

Assicurati che tutto sia ✓ (almeno per la piattaforma che vuoi usare).

### 2. Naviga nella Directory del Progetto

```bash
cd src  # O la directory dove hai il progetto Flutter
```

### 3. Pulisci e Ottieni le Dipendenze

```bash
# Pulisci eventuali build precedenti
flutter clean

# Scarica tutte le dipendenze
flutter pub get
```

Dovresti vedere un output simile a:
```
Running "flutter pub get" in src...
Resolving dependencies...
+ provider 6.1.1
+ shared_preferences 2.2.2
+ uuid 4.2.2
+ intl 0.18.1
...
Got dependencies!
```

### 4. Verifica le Piattaforme Disponibili

```bash
flutter devices
```

Dovresti vedere un output come:
```
Linux (desktop) • linux • linux-x64 • Linux
Chrome (web)    • chrome • web-javascript • Google Chrome
[altre piattaforme se disponibili]
```

### 5. Avvia l'Applicazione

**IMPORTANTE: NON usare sudo!**

#### Opzione A: Linux Desktop (Consigliato per sviluppo)

```bash
flutter run -d linux
```

#### Opzione B: Web Browser

```bash
flutter run -d chrome
```

#### Opzione C: Android (se hai dispositivo connesso)

```bash
flutter run -d android
```

#### Opzione D: Specifica dispositivo

```bash
# Lista dispositivi
flutter devices

# Usa l'ID del dispositivo
flutter run -d <device-id>
```

### 6. Hot Reload Durante lo Sviluppo

Una volta avviata l'app, puoi usare:
- **r** - Hot reload (ricarica veloce)
- **R** - Hot restart (riavvio completo)
- **q** - Quit (esci)
- **h** - Help (aiuto)

## 🐛 Risoluzione Problemi Comuni

### Problema: "Error: Build process failed"

**Soluzione:**
```bash
flutter clean
flutter pub get
flutter run -d linux
```

### Problema: "Target kernel_snapshot_program failed"

**Soluzione:**
```bash
# Verifica errori di sintassi
flutter analyze

# Se ci sono errori, correggili prima di rilanciare
```

### Problema: "No devices found"

**Soluzione:**
```bash
# Per Linux desktop
flutter config --enable-linux-desktop

# Per Web
flutter config --enable-web

# Poi rilancia
flutter devices
```

### Problema: "Waiting for another flutter command to release the startup lock"

**Soluzione:**
```bash
# Rimuovi il lock manualmente
rm -rf /tmp/flutter_lock
# O su Windows
del %TEMP%\flutter_lock
```

### Problema: Dipendenze non si installano

**Soluzione:**
```bash
# Aggiorna Flutter
flutter upgrade

# Pulisci cache pub
flutter pub cache repair

# Riprova
flutter pub get
```

## 📱 Build per Produzione

### Linux Desktop

```bash
flutter build linux --release
```

L'eseguibile sarà in: `build/linux/x64/release/bundle/`

### Web

```bash
flutter build web --release
```

I file saranno in: `build/web/`

### Android APK

```bash
flutter build apk --release
```

L'APK sarà in: `build/app/outputs/flutter-apk/app-release.apk`

### Android App Bundle (per Google Play)

```bash
flutter build appbundle --release
```

## 🎯 Primo Avvio - Cosa Aspettarsi

Al primo avvio vedrai:

1. **Home Screen** con:
   - Player Stats Card (HP: 50/50, Energy: 3, etc.)
   - Bottom Navigation (Roadmap, Deck, Skills, Stats)
   - Floating Action Button "Start Run"

2. **4 Tab principali**:
   - 📍 **Roadmap**: Capitoli di apprendimento
   - 🎴 **Deck**: Collezione carte (vuota all'inizio)
   - 🌳 **Skills**: Albero abilità (nessun punto all'inizio)
   - 📊 **Stats**: Statistiche e storico run (vuoto all'inizio)

3. **Funzionalità iniziali**:
   - Esplora i capitoli nel Roadmap
   - Visualizza lo Skill Tree (senza punti per ora)
   - Il deck è vuoto (guadagni carte completando topic)

## 🔍 Debug Mode

Per vedere i log dettagliati durante lo sviluppo:

```bash
flutter run -d linux -v
```

Per vedere solo gli errori:

```bash
flutter run -d linux --release
```

## 📊 Performance Analysis

Per analizzare le performance:

```bash
# Avvia con profiling
flutter run --profile -d linux

# Oppure con DevTools
flutter pub global activate devtools
flutter pub global run devtools
```

## 🎨 Personalizzazione Rapida

### Cambiare il Colore Primario

Modifica `/lib/utils/app_theme.dart`:

```dart
static const Color dartBlue = Color(0xFF0175C2); // Cambia questo
```

### Modificare Stats Iniziali

Modifica `/lib/utils/constants.dart`:

```dart
static const int baseMaxHp = 50;      // HP iniziali
static const int baseMaxEnergy = 3;   // Energia iniziale
static const int baseDrawSize = 5;    // Carte pescate
```

## 📚 Prossimi Passi Consigliati

1. **Esplora l'app** - Naviga tra le varie schermate
2. **Leggi il codice** - Inizia da `/lib/main.dart`
3. **Personalizza** - Modifica colori e costanti
4. **Aggiungi dati** - Popola topic e carte in `/lib/data/`
5. **Implementa gameplay** - Crea le schermate quiz e boss fight

## 🆘 Supporto

Se incontri problemi:

1. Controlla i log con `flutter run -v`
2. Esegui `flutter doctor` per verificare l'ambiente
3. Pulisci con `flutter clean && flutter pub get`
4. Controlla gli errori con `flutter analyze`

## ✅ Checklist Pre-Avvio

- [ ] Flutter installato e aggiornato
- [ ] `flutter doctor` senza errori critici
- [ ] `flutter clean` eseguito
- [ ] `flutter pub get` completato con successo
- [ ] Almeno un dispositivo disponibile (`flutter devices`)
- [ ] NON stai usando sudo
- [ ] Sei nella directory corretta (dove c'è `pubspec.yaml`)

## 🎉 Avvio Rapido (TL;DR)

```bash
# Setup iniziale (una volta sola)
flutter clean
flutter pub get

# Avvia l'app (SENZA sudo!)
flutter run -d linux

# Durante sviluppo, premi 'r' per hot reload
```

Buon sviluppo! 🚀
