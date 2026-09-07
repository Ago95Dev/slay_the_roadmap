import { DungeonRoom, Topic } from '../types';

export function generateDungeonRooms(
  topics: Topic[], 
  chapterId: string,
  includeOptional: boolean = true
): DungeonRoom[] {
  const rooms: DungeonRoom[] = [];
  const chapterTopics = topics.filter(t => t.chapterId === chapterId);
  
  // Separate required and optional topics
  const requiredTopics = chapterTopics.filter(t => t.type === 'required');
  const optionalTopics = includeOptional ? chapterTopics.filter(t => t.type === 'optional') : [];
  
  let roomId = 0;
  
  // Create rooms for required topics
  requiredTopics.forEach((topic, index) => {
    const y = Math.floor(index / 3); // 3 rooms per floor
    const x = index % 3;
    
    const room: DungeonRoom = {
      id: `room-${roomId++}`,
      type: 'topic-quiz',
      topicId: topic.id,
      x,
      y,
      connections: [],
      cleared: false,
      optional: false
    };
    
    rooms.push(room);
  });
  
  // Add event rooms between topic rooms
  const eventTypes: Array<'combat' | 'treasure' | 'choice' | 'rest' | 'merchant'> = 
    ['combat', 'treasure', 'choice', 'rest', 'merchant'];
  
  const numEventRooms = Math.floor(requiredTopics.length / 2);
  for (let i = 0; i < numEventRooms; i++) {
    const y = Math.floor((requiredTopics.length + i) / 3);
    const x = (requiredTopics.length + i) % 3;
    const eventType = eventTypes[i % eventTypes.length];
    
    rooms.push({
      id: `room-${roomId++}`,
      type: eventType,
      eventId: `event-${i}`,
      x,
      y,
      connections: [],
      cleared: false,
      optional: false
    });
  }
  
  // Add optional/secret rooms
  optionalTopics.forEach((topic, index) => {
    const baseIndex = requiredTopics.length + numEventRooms;
    const y = Math.floor((baseIndex + index) / 3);
    const x = (baseIndex + index) % 3;
    
    rooms.push({
      id: `room-${roomId++}`,
      type: 'topic-quiz',
      topicId: topic.id,
      x,
      y,
      connections: [],
      cleared: false,
      optional: true
    });
  });
  
  // Connect rooms (simple linear with some branching)
  rooms.forEach((room, index) => {
    // Connect to next room in sequence
    if (index < rooms.length - 1) {
      const nextRoom = rooms[index + 1];
      if (nextRoom.y === room.y || nextRoom.y === room.y + 1) {
        room.connections.push(nextRoom.id);
      }
    }
    
    // Add some branching paths
    if (index < rooms.length - 2 && Math.random() > 0.6) {
      const branchRoom = rooms[index + 2];
      if (branchRoom && branchRoom.y <= room.y + 1) {
        room.connections.push(branchRoom.id);
      }
    }
  });
  
  return rooms;
}

export function calculateRunScore(
  floorsCleared: number,
  cardsCollected: number,
  elitesDefeated: number,
  bossesDefeated: number,
  finalHp: number,
  ascensionLevel: number
): number {
  let score = 0;
  
  score += floorsCleared * 100;
  score += cardsCollected * 10;
  score += elitesDefeated * 50;
  score += bossesDefeated * 200;
  score += finalHp * 2;
  score += ascensionLevel * 500;
  
  return score;
}

export function getAscensionModifiers(level: number): {
  enemyHpMultiplier: number;
  enemyDamageMultiplier: number;
  playerHpMultiplier: number;
  description: string;
} {
  const baseEnemyHp = 1 + (level * 0.15);
  const baseEnemyDamage = 1 + (level * 0.1);
  const basePlayerHp = 1 - (level * 0.05);
  
  let description = 'Standard difficulty';
  
  if (level >= 1) description = 'Enemies have more HP';
  if (level >= 3) description = 'Enemies deal more damage';
  if (level >= 5) description = 'You start with less HP';
  if (level >= 10) description = 'Nightmare mode - all penalties active';
  
  return {
    enemyHpMultiplier: baseEnemyHp,
    enemyDamageMultiplier: baseEnemyDamage,
    playerHpMultiplier: Math.max(0.5, basePlayerHp),
    description
  };
}
