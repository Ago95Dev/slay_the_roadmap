# Dart Quest - Gamified Dart Learning App

A Flutter application that gamifies the learning of Dart programming through deck-building mechanics inspired by Slay the Spire and Hearthstone.

## 🎮 Features

### Core Gameplay
- **Learning Roadmap**: Visual tree structure showing progression through Dart topics
- **Quiz System**: Interactive quizzes with 80% passing threshold
- **Deck Building**: Collect and build strategic decks with cards of different rarities
- **Dungeon Runs**: Procedurally generated dungeon exploration combining learning and strategy

### Advanced Systems
- **Skill Tree**: Three branches (Offensive, Defensive, Utility) with prerequisite-based unlocking
- **Card Keywords**: Advanced mechanics including Exhaust, Ethereal, Retain, Combo, Overload
- **Relics System**: Permanent passive effects collected during runs
- **Boss Fights**: Multi-phase battles with threshold powers at 75%, 50%, and 25% HP
- **Narrative Events**: Themed story events with consequential choices
- **Ascension System**: Increasing difficulty with unique modifiers
- **Run History**: Complete tracking of all dungeon runs with detailed statistics

### Progression
- **Experience & Leveling**: Gain XP from completing topics and runs
- **Prestige System**: Reset with permanent bonuses
- **Achievement Tracking**: Unlock cosmetic rewards
- **Card Collection**: 4 rarity tiers (Common, Rare, Epic, Legendary)

## 🏗️ Project Structure

```
lib/
├── main.dart                    # App entry point
├── models/
│   └── types.dart              # Data models and types
├── providers/
│   └── game_provider.dart      # State management
├── services/
│   ├── storage_service.dart    # Local storage (SharedPreferences)
│   └── dungeon_generator.dart  # Procedural generation
├── data/
│   ├── relics_data.dart        # Relic definitions
│   └── skill_tree_data.dart    # Skill tree configuration
├── screens/
│   ├── home_screen.dart        # Main navigation
│   ├── roadmap_screen.dart     # Learning roadmap
│   ├── deck_builder_screen.dart # Deck management
│   ├── skill_tree_screen.dart  # Skill progression
│   ├── stats_screen.dart       # Statistics & history
│   └── dungeon_run_screen.dart # Active dungeon run
└── widgets/
    ├── player_stats_card.dart      # Player stats display
    ├── dungeon_map_widget.dart     # Dungeon map visualization
    ├── run_history_widget.dart     # Run history display
    └── relic_collection_widget.dart # Relic collection display
```

## 📋 Requirements

- Flutter SDK: >=3.0.0 <4.0.0
- Dart SDK: >=3.0.0

## 🚀 Getting Started

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd dart_quest
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate Hive type adapters** (if needed)
   ```bash
   flutter pub run build_runner build
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

## 📦 Dependencies

### State Management & Storage
- `provider: ^6.1.1` - State management
- `shared_preferences: ^2.2.2` - Local key-value storage
- `hive: ^2.2.3` - NoSQL database for complex data
- `hive_flutter: ^1.1.0` - Hive integration for Flutter

### UI & Animations
- `flutter_svg: ^2.0.9` - SVG rendering
- `animations: ^2.0.11` - Pre-built animations
- `flutter_animate: ^4.3.0` - Animation library

### Utilities
- `uuid: ^4.2.2` - Unique ID generation
- `intl: ^0.18.1` - Internationalization and formatting

## 🎯 User Stories Implementation

### Sprint #1 (Completed)
✅ US-001 to US-020: Core features, quiz system, deck building, basic dungeon run

### Sprint #2 (Current Implementation)
✅ **US-021**: Topic-as-room dungeon integration  
✅ **US-022**: Narrative events with themes and reputation  
✅ **US-023**: Advanced card effects and keywords  
✅ **US-024**: Smooth animations and visual feedback  
✅ **US-025**: Boss threshold powers and puzzle mechanics  
✅ **US-026**: Energy and deck cycle management  
✅ **US-027**: Player stats and skill tree  
✅ **US-028**: Post-boss treasure selection  
✅ **US-029**: Random events with unique rewards  
✅ **US-030**: Ascension, mastery, and replay value  

## 🎨 Design System

### Color Scheme
- Primary: Dart Blue (#0175C2)
- Card Rarities:
  - Common: Gray
  - Rare: Blue
  - Epic: Purple
  - Legendary: Gold

### Typography
- Font Family: Inter
- Weights: Regular (400), Medium (500), SemiBold (600), Bold (700)

## 🔧 Configuration

### Fonts
Add Inter font files to `fonts/` directory:
- `Inter-Regular.ttf`
- `Inter-Medium.ttf`
- `Inter-SemiBold.ttf`
- `Inter-Bold.ttf`

## 📱 Screens Overview

1. **Home Screen**: Main navigation hub with player stats
2. **Roadmap**: Visual progression through learning topics
3. **Deck Builder**: Manage card collection and active deck
4. **Skill Tree**: Unlock permanent upgrades across three branches
5. **Stats**: View run history and relic collection
6. **Dungeon Run**: Active gameplay with procedural map

## 🎲 Game Mechanics

### Card System
- **Mana Cost**: Energy required to play cards
- **Keywords**: 
  - Exhaust: Remove from game after use
  - Ethereal: Discard at end of turn
  - Retain: Keep in hand next turn
  - Combo: Bonus effect if another card played
  - Overload: Reduce energy next turn

### Skill Tree Branches
- **Offensive**: Increase damage and energy
- **Defensive**: Boost HP and armor
- **Utility**: Enhance card draw and versatility

### Dungeon Room Types
- Topic Quiz: Test knowledge
- Combat: Narrative battles
- Treasure: Collect rewards
- Rest: Heal or upgrade
- Merchant: Trade resources
- Elite/Boss: Major challenges

## 🏆 Achievements System
Track progress through:
- Topics completed
- Cards collected
- Runs completed
- Bosses defeated
- Perfect quiz scores

## 💾 Data Persistence
- Local storage using SharedPreferences
- Full game state saved automatically
- Progress tracked across sessions

## 🔮 Future Enhancements
- Daily challenges
- Speedrun mode
- Multiplayer leaderboards
- Additional chapters and topics
- More card types and relics
- Custom deck themes

## 📄 License
MIT License - Feel free to use this project for learning purposes

## 🤝 Contributing
Contributions welcome! Please feel free to submit pull requests.

## 📧 Support
For issues and questions, please open an issue on GitHub.

---

**Made with ❤️ using Flutter**
