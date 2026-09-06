# 00 — Stato reale del progetto (origin/main 24d8aa3)

## Codice: non più template, ma non compila pulito
- `lib/` ~5390 LOC, 40+ file. `pubspec.yaml`: `provider ^6.1.1`, `equatable ^2.0.5`, `url_launcher ^6.1.11`. Descrizione: "A gamified learning app for roadmap.sh Dart roadmap".
- `lib/main.dart:7-43`: entry `MultiProvider` con solo `RoadmapViewModel(LocalRoadmapRepository())`, `home: HomeScreen`. `setupLocator()` mai chiamato.
- Architettura: layered locale `ChangeNotifier` + `Provider`, repo mock con `Future.delayed`, modelli `Equatable` in `domain/models/`. Navigazione solo imperativa `Navigator.push/MaterialPageRoute` (nessun `go_router`, nessuna routes table).

## Evidenze build (2026-09-06)
- `flutter pub get`: OK (16 pacchetti con major disponibili, `flutter_lints 3.0.2` vs 6.0.0).
- `flutter analyze`: **159 issue, di cui 9 error bloccanti**:
  - `shared_preferences_service.dart:2` + `setup_locator.dart:1-2`: `package:shared_preferences` e `package:get_it` non in `pubspec.yaml` → `uri_does_not_exist`, `undefined_class SharedPreferences/GetIt`
  - `ui/widgets/quiz/quiz_questions.dart:21,57`: `selectedAnswer` non definito su `Question`, `submitQuizResults` non definito su `QuizRepository` → widget quiz alternativo rotto
- `flutter test`: **FAIL** — `test/widget_test.dart:19` cerca ancora testo `"0"`/`Icons.add` del template counter, ma `MyApp` ora monta `HomeScreen` → `Found 0 widgets`. `test/data|domain|ui|utils/` vuote, `testing/fakes|models/` vuote.
- `grep polyglot|gamification|gameId|/gengine/|earn_xp` in `lib/ test/`: **0 hit funzionali** (solo `badge` come label UI in `action_card`, `home_screen`, `topic_detail_screen`). Engine esterno assente.
- `grep SharedPreferencesService|setupLocator|PersistenceRepository`: definiti ma **mai usati dai ViewModel** → persistenza morta.

## Cosa c'è davvero (per area)
- `domain/models/`: `topic.dart` (tree id/title/prereq/quizId/status locked|inProgress|completed), `topic_detail.dart` + `LearningLink` per `url_launcher`, `quiz.dart` (`passingThreshold=80` default, `QuizResult`), `reward.dart` (type attack/defense/utility/special, rarity, effects, `isSelected`, `PlayerInventory maxSlots 20`), `boss_fight.dart` (maxHp/currentHp, playerHp 100, soglie 0.25/0.50/0.75), `player_progress.dart` (`experience`, `level=1` fisso, `completedTopicIds`, `quizResults`, `inventory`, `bossFights`, `toJson/fromJson` completi; `addCompletedTopic +100xp`; `_bossFightFromJson` azzera `adaptiveQuizzes`).
- `data/repositories/`: `roadmap_repository.dart` albero Dart 3 capitoli + 9 subtopics, `update/unlock` solo `print()` stub; `quiz_repository.dart` solo 3 quiz (`dart_basics/variables/functions`), altri topic → `throw`; `boss_repository.dart` 3 boss mock (Syntax Guardian 150HP, Widget Overlord 200HP, Async Demon 250HP) con `availableRewards[3]`; `reward_repository.dart` 6 reward mock, `getRewardsForTopic → shuffle().take(3)` senza UI; `topic_detail_repository.dart` link hard-coded dart.dev/youtube.
- `ui/screens/`: `home_screen 289` (menu → RoadmapSelection + BossFightScreen), `roadmap_selection 162`, `roadmap_screen 266` (`_onTopicTap → TopicDetail`, `_startQuiz → QuizScreen`, `passed → completed`), `topic_detail 261` (+ `url_launcher` + bottone Quiz), `quiz_screen 268` (Radio, result `passed → Continua/pop`), `boss_fight_screen 132` (lista boss), `boss_fight_active_screen 538` (Consumer, quiz-radio, `victory → TODO Show reward selection screen + pop`, reward mai assegnata).
- `ui/view_models/`: `roadmap_view_model` (load + unlock via prerequisites), `quiz_view_model` (load/select/next/submit, null→0), `boss_fight_view_model` (load/start/useCard/startQuiz/submit `danno=percentage/10`, `_executeBossTurn delay 1500ms`, `_selectBossAction` random + heal 15).
- Duplicati legacy morti: `models/roadmap_models.dart`, `services/roadmap_service.dart`, `widgets/roadmap_tree.dart|topic_node.dart`, `ui/view_model/roadmap_view_model.dart` (commenti ITA), `ui/widgets/quiz/quiz_questions.dart` (rotto).
