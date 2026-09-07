import 'dart:math';
import '../models/types.dart';

class DungeonGenerator {
  static List<DungeonRoom> generateDungeonRooms(
    List<Topic> topics,
    String chapterId,
    bool includeOptional,
  ) {
    final rooms = <DungeonRoom>[];
    final chapterTopics = topics.where((t) => t.chapterId == chapterId).toList();

    final requiredTopics = chapterTopics.where((t) => t.type == 'required').toList();
    final optionalTopics = includeOptional
        ? chapterTopics.where((t) => t.type == 'optional').toList()
        : <Topic>[];

    var roomId = 0;

    // Create rooms for required topics
    for (var i = 0; i < requiredTopics.length; i++) {
      final topic = requiredTopics[i];
      final y = (i / 3).floor();
      final x = i % 3;

      rooms.add(DungeonRoom(
        id: 'room-${roomId++}',
        type: DungeonRoomType.topicQuiz,
        topicId: topic.id,
        x: x,
        y: y,
        connections: [],
      ));
    }

    // Add event rooms
    final eventTypes = [
      DungeonRoomType.combat,
      DungeonRoomType.treasure,
      DungeonRoomType.choice,
      DungeonRoomType.rest,
      DungeonRoomType.merchant,
    ];

    final numEventRooms = (requiredTopics.length / 2).floor();
    for (var i = 0; i < numEventRooms; i++) {
      final y = ((requiredTopics.length + i) / 3).floor();
      final x = (requiredTopics.length + i) % 3;
      final eventType = eventTypes[i % eventTypes.length];

      rooms.add(DungeonRoom(
        id: 'room-${roomId++}',
        type: eventType,
        eventId: 'event-$i',
        x: x,
        y: y,
        connections: [],
      ));
    }

    // Add optional rooms
    for (var i = 0; i < optionalTopics.length; i++) {
      final topic = optionalTopics[i];
      final baseIndex = requiredTopics.length + numEventRooms;
      final y = ((baseIndex + i) / 3).floor();
      final x = (baseIndex + i) % 3;

      rooms.add(DungeonRoom(
        id: 'room-${roomId++}',
        type: DungeonRoomType.topicQuiz,
        topicId: topic.id,
        x: x,
        y: y,
        connections: [],
        optional: true,
      ));
    }

    // Connect rooms
    final random = Random();
    for (var i = 0; i < rooms.length; i++) {
      final room = rooms[i];

      // Connect to next room
      if (i < rooms.length - 1) {
        final nextRoom = rooms[i + 1];
        if (nextRoom.y == room.y || nextRoom.y == room.y + 1) {
          room.connections.add(nextRoom.id);
        }
      }

      // Add branching paths
      if (i < rooms.length - 2 && random.nextDouble() > 0.6) {
        final branchRoom = rooms[i + 2];
        if (branchRoom.y <= room.y + 1) {
          room.connections.add(branchRoom.id);
        }
      }
    }

    return rooms;
  }

  static int calculateRunScore(
    int floorsCleared,
    int cardsCollected,
    int elitesDefeated,
    int bossesDefeated,
    int finalHp,
    int ascensionLevel,
  ) {
    var score = 0;

    score += floorsCleared * 100;
    score += cardsCollected * 10;
    score += elitesDefeated * 50;
    score += bossesDefeated * 200;
    score += finalHp * 2;
    score += ascensionLevel * 500;

    return score;
  }

  static Map<String, dynamic> getAscensionModifiers(int level) {
    final baseEnemyHp = 1 + (level * 0.15);
    final baseEnemyDamage = 1 + (level * 0.1);
    final basePlayerHp = 1 - (level * 0.05);

    var description = 'Standard difficulty';

    if (level >= 1) description = 'Enemies have more HP';
    if (level >= 3) description = 'Enemies deal more damage';
    if (level >= 5) description = 'You start with less HP';
    if (level >= 10) description = 'Nightmare mode - all penalties active';

    return {
      'enemyHpMultiplier': baseEnemyHp,
      'enemyDamageMultiplier': baseEnemyDamage,
      'playerHpMultiplier': max(0.5, basePlayerHp),
      'description': description,
    };
  }
}
