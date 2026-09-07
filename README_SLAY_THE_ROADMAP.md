# 🗺️ Slay the Roadmap

Una applicazione gamificata per l'apprendimento di Dart con meccaniche ispirate a Slay the Spire e Hearthstone.

## 🎮 Caratteristiche Principali

### 🗺️ Roadmap Interattiva
- **Struttura ad albero** con nodi multipli per tier
- **Boss strategici** posizionati dopo ogni capitolo
- **Nodi variati**: Topic, Boss, Elite, Treasure, Event, Rest
- **Progressione non lineare** con scelte multiple
- **Rewards per ogni nodo**: carte, reliquie, oro, esperienza, salute

### 🃏 Sistema di Carte Avanzato

#### 4 Livelli di Rarità
- **Comune** (Grigio) - Carte base affidabili
- **Raro** (Blu) - Carte con effetti speciali
- **Epico** (Viola) - Combo potenti
- **Leggendario** (Oro) - Poteri devastanti

#### Effetti Speciali
- **💀 Veleno (Poison)** - Danno nel tempo
- **🏹 Perforazione (Pierce)** - Ignora armatura
- **💥 Critico (Critical)** - Chance di danno doppio
- **🩸 Sanguinamento (Bleed)** - Perde HP quando attacca
- **🔥 Fuoco (Burn)** - Danno crescente ogni turno
- **❄️ Gelo (Freeze)** - Riduce azioni nemiche

#### Keyword Meccaniche
- **Exhaust** - La carta si rimuove dopo l'uso
- **Ethereal** - Scompare se non giocata
- **Retain** - Rimane in mano
- **Combo** - Effetti bonus in sequenza
- **Overload** - Potere immediato, costo futuro
- **Discover** - Scegli tra opzioni random

### 👹 Boss Fight
Tre boss principali con meccaniche uniche:

1. **Syntax Sentinel** (Capitolo 1)
   - 80 HP
   - Punisce errori di sintassi
   - Threshold powers al 50% e 25% HP

2. **Logic Leviathan** (Capitolo 2)
   - 120 HP
   - Master dei loop
   - Abilità multiple per turno

3. **Abstraction Archon** (Capitolo 3)
   - 180 HP
   - Boss finale OOP
   - Poteri devastanti e immunità

### 🌳 Skill Tree
- **3 Rami**: Offensive, Defensive, Utility
- **Potenziamenti permanenti**: HP, Energia, Draw Size, Armor
- **Sistema a punti** basato su livello e prestigio

### 📊 Sistema di Progressione
- **Esperienza e Livelli**
- **Sistema di Oro** per merchant e upgrades
- **Collezione di Reliquie**
- **Run History** con tracking statistiche
- **Ascension Levels** per difficoltà incrementale

## 🎯 Struttura della Roadmap

### Tier 0: Start
Punto di partenza del viaggio

### Tier 1-3: Capitolo 1 - Dart Basics
- Variables & Types
- Operators
- Null Safety
- **Boss**: Syntax Sentinel

### Tier 5-7: Capitolo 2 - Control Flow
- Conditionals
- Loops
- Functions
- Collections
- **Boss**: Logic Leviathan

### Tier 9-11: Capitolo 3 - OOP & Advanced
- Classes & Objects
- Inheritance & Mixins
- Async & Futures
- **Boss Finale**: Abstraction Archon

## 🏆 Rewards System

Ogni nodo della roadmap offre rewards specifici:

### Topic Nodes
- Carte Common/Rare
- Esperienza (50-150 XP)
- Oro (100-200)

### Elite Battles
- Carte Epic/Legendary
- Reliquie rare
- Oro bonus (200-300)

### Boss Nodes
- Carte Legendary multiple
- Reliquie uniche
- Esperienza massiva (200-500 XP)
- Oro abbondante (300-1000)

### Treasure/Event
- Rewards variabili
- Scelte narrative
- Salute bonus

## 🛠️ Setup e Installazione

```bash
# Clone del repository
git clone [repository-url]
cd slay_the_roadmap

# Installa dipendenze
flutter pub get

# Run su Linux
flutter run -d linux

# Run su altri platform
flutter run -d chrome  # Web
flutter run -d windows # Windows
flutter run            # Device connesso
```

## 📦 Dipendenze

- `provider` - State management
- `shared_preferences` - Persistenza locale
- `uuid` - Generazione ID unici
- `intl` - Internazionalizzazione

## 🎨 Design Pattern

- **Provider Pattern** per state management
- **Repository Pattern** per data access
- **Factory Pattern** per generazione procedural
- **Strategy Pattern** per effetti carte

## 📱 Schermate

1. **Home** - Dashboard con statistiche player
2. **Roadmap** - Vista ad albero interattiva
3. **Deck Builder** - Collezione e gestione carte
4. **Skill Tree** - Potenziamenti permanenti
5. **Stats** - Statistiche dettagliate
6. **Boss Fight** - Combattimento a turni
7. **Dungeon Run** - Modalità roguelike

## 🚀 Prossimi Sviluppi

- [ ] Implementazione completa combattimento
- [ ] Animazioni carte
- [ ] Effetti particellari
- [ ] Merchant system
- [ ] Daily challenges
- [ ] Leaderboards
- [ ] Multiplayer PvP

## 📝 Note Tecniche

### Persistenza
Tutto lo stato viene salvato automaticamente usando `SharedPreferences`:
- Progresso roadmap
- Collezione carte
- Skill tree unlocks
- Run history
- Player stats

### Generazione Procedurale
Il sistema genera automaticamente:
- Dungeon layouts
- Event encounters
- Reward pools
- Boss patterns

## 🤝 Contributi

Questo è un progetto didattico per l'apprendimento di Dart e Flutter con meccaniche gamificate.

## 📄 Licenza

Progetto educativo - Uso libero per scopi di apprendimento.

---

**Slay the Roadmap** - Impara Dart conquistando la roadmap! 🗡️📚
