# ⚡ Quick Start - Dart Quest

## 🎯 Avvio Rapido (3 Passi)

### 1️⃣ Setup Automatico (Linux/macOS)

```bash
chmod +x setup.sh
./setup.sh
```

### 2️⃣ Setup Manuale

```bash
flutter clean
flutter pub get
```

### 3️⃣ Avvia l'App

```bash
# Linux
flutter run -d linux

# Web
flutter run -d chrome

# Android (con dispositivo connesso)
flutter run -d android
```

## ⚠️ IMPORTANTE

**NON usare sudo!** 

```bash
# ❌ SBAGLIATO
sudo flutter run

# ✅ CORRETTO
flutter run -d linux
```

## 🔧 Se Qualcosa Non Funziona

```bash
# 1. Pulisci tutto
flutter clean

# 2. Scarica dipendenze
flutter pub get

# 3. Verifica problemi
flutter doctor

# 4. Analizza codice
flutter analyze

# 5. Riprova
flutter run -d linux
```

## 🎮 Comandi Durante l'Esecuzione

- **r** → Hot reload (ricarica veloce senza perdere stato)
- **R** → Hot restart (riavvio completo)
- **q** → Quit (esci dall'app)
- **h** → Help (mostra tutti i comandi)

## 📋 Checklist

- [ ] Flutter installato (`flutter --version`)
- [ ] Sei nella directory corretta (dove c'è `pubspec.yaml`)
- [ ] Hai eseguito `flutter pub get`
- [ ] Almeno un dispositivo disponibile (`flutter devices`)
- [ ] NON stai usando sudo

## 🎉 Primo Avvio

L'app si aprirà mostrando:
- **Home Screen** con statistiche giocatore
- **4 tab**: Roadmap, Deck, Skills, Stats
- **FAB** per iniziare un dungeon run

## 📚 Documentazione Completa

- `SETUP_GUIDE.md` - Guida dettagliata con troubleshooting
- `README.md` - Documentazione completa del progetto
- `IMPLEMENTATION_GUIDE.md` - Dettagli tecnici implementazione

## 🆘 Problemi Comuni

### "No devices found"

```bash
flutter config --enable-linux-desktop
flutter devices
```

### "Build failed"

```bash
flutter clean
flutter pub get
flutter run -d linux
```

### "Waiting for lock"

```bash
rm -rf /tmp/flutter_lock
```

## 💻 Requisiti Minimi

- Flutter SDK ≥ 3.0.0
- Dart SDK ≥ 3.0.0
- 2 GB RAM
- 500 MB spazio disco

## 🚀 Build Produzione

```bash
# Linux
flutter build linux --release

# Web
flutter build web --release

# Android
flutter build apk --release
```

---

**Hai problemi?** Controlla `SETUP_GUIDE.md` per soluzioni dettagliate!
