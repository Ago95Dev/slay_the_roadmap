# 🔧 Troubleshooting - Dart Quest Flutter

## ❌ Errori Comuni e Soluzioni

### 1. "Woah! You appear to be trying to run flutter as root"

**Problema**: Stai usando `sudo` per eseguire Flutter

**Soluzione**:
```bash
# ❌ NON fare questo
sudo flutter run

# ✅ Fai questo
flutter run -d linux
```

**Spiegazione**: Flutter non dovrebbe essere eseguito con privilegi di root perché può causare problemi di permessi e sicurezza.

---

### 2. "Error: ... types.g.dart: No such file or directory"

**Problema**: Il file era richiesto da Hive ma ora non serve più

**Stato**: ✅ **RISOLTO** - Abbiamo rimosso la dipendenza da Hive

**Verifica**:
```bash
flutter pub get
flutter run -d linux
```

---

### 3. "Member not found: 'sword'" o "Member not found: 'swords'"

**Problema**: Icone non esistenti in Material Icons

**Stato**: ✅ **RISOLTO** - Abbiamo sostituito con icone esistenti
- `Icons.sword` → `Icons.flash_on`
- `Icons.swords` → `Icons.local_fire_department`

**Verifica**:
```bash
flutter analyze
# Non dovrebbe mostrare errori su icone
```

---

### 4. "CardTheme can't be assigned to CardThemeData"

**Problema**: Tipo errato per il tema delle card

**Stato**: ✅ **RISOLTO** - Usato `CardThemeData` invece di `CardTheme`

**Verifica**:
```bash
grep -r "CardTheme" lib/utils/app_theme.dart
# Dovrebbe mostrare solo CardThemeData
```

---

### 5. "No devices found"

**Problema**: Flutter non trova dispositivi su cui eseguire l'app

**Soluzione**:
```bash
# Abilita piattaforma Linux
flutter config --enable-linux-desktop

# Abilita Web
flutter config --enable-web

# Verifica dispositivi disponibili
flutter devices
```

**Output atteso**:
```
Linux (desktop) • linux • linux-x64 • Linux
Chrome (web)    • chrome • web-javascript • Google Chrome
```

---

### 6. "Waiting for another flutter command to release the startup lock"

**Problema**: Un altro processo Flutter è in esecuzione o è crashato

**Soluzione Linux/macOS**:
```bash
# Trova e termina processi Flutter
pkill -9 flutter
pkill -9 dart

# Rimuovi il lock
rm -rf /tmp/flutter_lock

# Riprova
flutter run -d linux
```

**Soluzione Windows**:
```cmd
# Rimuovi il lock
del %TEMP%\flutter_lock

# Riprova
flutter run -d windows
```

---

### 7. "pub get failed"

**Problema**: Impossibile scaricare le dipendenze

**Soluzione**:
```bash
# 1. Pulisci cache
flutter pub cache repair

# 2. Aggiorna Flutter
flutter upgrade

# 3. Riprova
flutter clean
flutter pub get
```

---

### 8. "Target kernel_snapshot_program failed: Exception"

**Problema**: Errori di compilazione nel codice

**Soluzione**:
```bash
# 1. Analizza il codice per trovare errori
flutter analyze

# 2. Controlla l'output per errori specifici
# Leggi attentamente i messaggi di errore

# 3. Se ci sono errori, correggili

# 4. Pulisci e ricompila
flutter clean
flutter pub get
flutter run -d linux
```

---

### 9. "Build process failed"

**Problema**: Errore generico durante la build

**Soluzione completa**:
```bash
# 1. Pulisci completamente
flutter clean

# 2. Scarica dipendenze
flutter pub get

# 3. Analizza codice
flutter analyze

# 4. Se non ci sono errori critici, riprova
flutter run -d linux -v
# L'opzione -v mostra output dettagliato
```

---

### 10. "Hot reload not working"

**Problema**: Le modifiche non si applicano

**Soluzione**:
```bash
# Durante l'esecuzione dell'app, premi:
R  # Hot restart (riavvio completo)

# Oppure ferma e rilancia:
q  # Quit
flutter run -d linux
```

---

### 11. Font "Inter" non trovato

**Problema**: L'app cerca font esterni non disponibili

**Stato**: ✅ **RISOLTO** - Rimosso riferimento a font Inter dal `pubspec.yaml`

**Verifica**:
```bash
grep -i "inter" pubspec.yaml
# Non dovrebbe trovare nulla
```

---

### 12. "Permission denied" durante la build

**Problema**: Permessi insufficienti

**Soluzione Linux**:
```bash
# Assicurati di essere proprietario dei file
chown -R $USER:$USER .

# Verifica permessi
ls -la

# Non usare sudo!
flutter run -d linux
```

---

### 13. Performance scarse / App lenta

**Problema**: L'app gira in debug mode

**Soluzione**:
```bash
# Debug mode (lento, per sviluppo)
flutter run -d linux

# Release mode (veloce, per produzione)
flutter run -d linux --release

# Profile mode (bilanciato, per debug performance)
flutter run -d linux --profile
```

---

### 14. "Version solving failed"

**Problema**: Conflitti tra versioni dipendenze

**Soluzione**:
```bash
# 1. Aggiorna Flutter
flutter upgrade

# 2. Pulisci
flutter clean

# 3. Aggiorna dipendenze
flutter pub upgrade

# 4. Riprova
flutter pub get
```

---

### 15. App si chiude immediatamente

**Problema**: Crash all'avvio

**Soluzione**:
```bash
# Esegui con output verbose
flutter run -d linux -v

# Controlla i log per errori specifici
# Gli errori appariranno nella console
```

---

## 🔍 Comandi di Diagnostica

### Verifica Ambiente
```bash
flutter doctor -v
```

### Analizza Codice
```bash
flutter analyze
```

### Pulisci Build
```bash
flutter clean
```

### Ripara Cache
```bash
flutter pub cache repair
```

### Lista Dispositivi
```bash
flutter devices
```

### Versione Flutter
```bash
flutter --version
```

---

## 📊 Workflow di Debug Consigliato

1. **Verifica errori sintassi**:
   ```bash
   flutter analyze
   ```

2. **Pulisci build**:
   ```bash
   flutter clean
   ```

3. **Reinstalla dipendenze**:
   ```bash
   flutter pub get
   ```

4. **Verifica ambiente**:
   ```bash
   flutter doctor
   ```

5. **Esegui con verbose**:
   ```bash
   flutter run -d linux -v
   ```

6. **Leggi attentamente i messaggi di errore**

7. **Cerca l'errore specifico** in questa guida

---

## 🆘 Se Nulla Funziona

### Reset Completo

```bash
# 1. Rimuovi build e cache
flutter clean
rm -rf build/
rm -rf .dart_tool/

# 2. Aggiorna Flutter
flutter upgrade

# 3. Ripara cache
flutter pub cache repair

# 4. Reinstalla dipendenze
flutter pub get

# 5. Verifica ambiente
flutter doctor

# 6. Riprova
flutter run -d linux
```

### Reinstalla Flutter

Se proprio non funziona nulla, considera di reinstallare Flutter:

```bash
# Backup del progetto
cd ..
cp -r src src_backup

# Reinstalla Flutter seguendo la guida ufficiale:
# https://flutter.dev/docs/get-started/install

# Riprova
cd src
flutter pub get
flutter run -d linux
```

---

## 📞 Ottieni Aiuto

1. **Controlla i log**: Leggi attentamente l'output di `flutter run -v`
2. **Flutter Doctor**: Esegui `flutter doctor -v` e condividi l'output
3. **Codice errore**: Cerca il codice/messaggio specifico online
4. **Stack Overflow**: Cerca su https://stackoverflow.com/questions/tagged/flutter
5. **GitHub Issues**: Controlla https://github.com/flutter/flutter/issues

---

## ✅ Verifiche Post-Fix

Dopo aver risolto un problema, verifica:

```bash
# 1. Analizza codice
flutter analyze

# 2. Nessun errore critico
echo $?  # Dovrebbe essere 0

# 3. Test run
flutter run -d linux

# 4. Hot reload funziona
# Premi 'r' durante l'esecuzione
```

---

**Ultimo aggiornamento**: Tutti gli errori iniziali sono stati risolti! ✅
