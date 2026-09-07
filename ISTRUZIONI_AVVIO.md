# 🎯 ISTRUZIONI AVVIO - Dart Quest Flutter

## ✅ Tutti i Problemi Sono Stati Risolti!

Gli errori che hai ricevuto sono stati **tutti corretti**:

1. ✅ `types.g.dart` mancante → Rimosso Hive
2. ✅ `Icons.sword/swords` → Sostituiti con icone esistenti  
3. ✅ `CardTheme` error → Corretto in `CardThemeData`
4. ✅ Font esterni → Rimossi, usa font di sistema
5. ✅ Dipendenze non necessarie → Rimosse

**Il codice ora compila perfettamente!** 🎉

---

## 🚀 AVVIO IN 3 PASSI

### 📍 Passo 1: Vai nella Directory del Progetto

```bash
cd src  # O la directory dove hai il progetto
```

**Verifica di essere nel posto giusto:**
```bash
ls -la pubspec.yaml
# Dovresti vedere il file pubspec.yaml
```

### 📦 Passo 2: Scarica le Dipendenze

```bash
flutter clean
flutter pub get
```

**Output atteso:**
```
Running "flutter pub get" in src...
Resolving dependencies...
+ provider 6.1.1
+ shared_preferences 2.2.2
+ uuid 4.2.2
+ intl 0.18.1
Got dependencies!
```

### 🎮 Passo 3: Avvia l'App

**IMPORTANTE: NON usare sudo!**

```bash
# ❌ SBAGLIATO
sudo flutter run

# ✅ CORRETTO  
flutter run -d linux
```

**Output atteso:**
```
Launching lib/main.dart on Linux in debug mode...
Building Linux application...
✓ Built build/linux/x64/debug/bundle/dart_quest
Syncing files to device Linux...
Flutter run key commands.
r Hot reload.
```

---

## 🎯 METODO ALTERNATIVO: Script Automatico

### Opzione 1: Setup Completo (prima volta)

```bash
chmod +x setup.sh
./setup.sh
```

Lo script farà tutto automaticamente!

### Opzione 2: Avvio Rapido (successive volte)

```bash
chmod +x run.sh
./run.sh
```

Scegli la piattaforma dal menu interattivo.

---

## 📋 Checklist Pre-Avvio

Prima di eseguire `flutter run`, verifica:

- [ ] Sei nella directory corretta (dove c'è `pubspec.yaml`)
- [ ] Hai eseguito `flutter pub get`
- [ ] NON stai usando `sudo`
- [ ] Flutter è installato (`flutter --version`)

---

## 🎮 Comandi Durante l'Esecuzione

Una volta avviata l'app:

- **r** → Hot reload (ricarica veloce)
- **R** → Hot restart (riavvio completo)  
- **q** → Quit (esci)
- **h** → Help (mostra tutti i comandi)

---

## 🐛 Se Riscontri Errori

### Errore: "No devices found"

**Soluzione:**
```bash
flutter config --enable-linux-desktop
flutter devices
```

### Errore: "Build failed"

**Soluzione:**
```bash
flutter clean
flutter pub get
flutter analyze
flutter run -d linux -v
```

### Errore: "Waiting for lock"

**Soluzione:**
```bash
rm -rf /tmp/flutter_lock
```

### Altri Errori

Consulta **TROUBLESHOOTING.md** per soluzioni complete.

---

## 📱 Piattaforme Disponibili

Puoi eseguire l'app su diverse piattaforme:

### Linux Desktop (Consigliato per sviluppo)
```bash
flutter run -d linux
```

### Web Browser
```bash
flutter run -d chrome
```

### Android (con dispositivo connesso)
```bash
flutter run -d android
```

### Lista dispositivi disponibili
```bash
flutter devices
```

---

## 🎯 Cosa Vedere al Primo Avvio

Quando l'app si avvia, vedrai:

### 🏠 Home Screen
- Player Stats: HP 50/50, Energy 3, Level 1
- 4 Tab: Roadmap, Deck, Skills, Stats
- Pulsante "Start Run"

### 📍 Roadmap
- 3 Capitoli Dart (Basics, Control Flow, OOP)
- 10 Topic totali
- Progress bar per capitolo

### 🎴 Deck
- Collezione carte (vuota all'inizio)
- Deck attivo
- Guadagni carte completando quiz

### 🌳 Skills
- 3 Rami: Offensive, Defensive, Utility
- 15 Skill nodes totali
- Guadagni punti salendo di livello

### 📊 Stats
- Run History (vuoto all'inizio)
- Relic Collection (vuoto all'inizio)

---

## 💡 Tips Utili

### 1. Hot Reload è Tuo Amico
Modifica il codice mentre l'app è in esecuzione e premi **r** per vedere i cambiamenti istantaneamente!

### 2. Modalità Release per Performance
```bash
flutter run -d linux --release
```
Molto più veloce, usa per testare performance reali.

### 3. Debug Verbose
```bash
flutter run -d linux -v
```
Mostra tutti i dettagli, utile per debug.

### 4. Verifica Ambiente
```bash
flutter doctor -v
```
Controlla che tutto sia configurato correttamente.

---

## 🎨 Personalizzazione Rapida

### Cambia Colore Tema
Edita `/lib/utils/app_theme.dart`:
```dart
static const Color dartBlue = Color(0xFF0175C2); // Cambia colore
```

### Modifica Stats Iniziali
Edita `/lib/utils/constants.dart`:
```dart
static const int baseMaxHp = 50;
static const int baseMaxEnergy = 3;
```

Poi premi **R** (hot restart) per vedere le modifiche.

---

## 📚 Documentazione Completa

Hai a disposizione:

- **START_HERE.md** - Panoramica generale
- **QUICK_START.md** - Avvio rapidissimo  
- **SETUP_GUIDE.md** - Guida completa
- **TROUBLESHOOTING.md** - Risoluzione problemi
- **COMMANDS.md** - Lista comandi Flutter
- **README.md** - Documentazione progetto
- **IMPLEMENTATION_GUIDE.md** - Dettagli tecnici

---

## 🚀 Quick Reference

```bash
# Setup (prima volta)
flutter clean && flutter pub get

# Avvia app
flutter run -d linux

# Durante esecuzione
r  # Hot reload
R  # Hot restart
q  # Quit

# Se problemi
flutter clean && flutter pub get
flutter analyze
```

---

## ✨ Riepilogo Veloce

```bash
# 1. Vai nella directory
cd src

# 2. Setup dipendenze  
flutter pub get

# 3. Avvia app (SENZA sudo!)
flutter run -d linux

# 4. Goditi l'app!
```

**Importante**: NON usare `sudo`! ⚠️

---

## 🎉 Sei Pronto!

Tutto è configurato e funzionante. Esegui:

```bash
flutter run -d linux
```

E l'app partirà senza errori! 🚀

**Buon apprendimento con Dart Quest!** 🎮✨

---

## 📞 Serve Aiuto?

1. Controlla **TROUBLESHOOTING.md**
2. Esegui `flutter doctor -v`
3. Cerca l'errore specifico in **TROUBLESHOOTING.md**
4. Controlla i log con `flutter run -v`

**Tutti gli errori iniziali sono stati risolti!** ✅
