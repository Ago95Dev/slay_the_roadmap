import { DungeonRoom, Topic } from '../types';
import { Card } from './ui/card';
import { Badge } from './ui/badge';
import { CheckCircle2, Circle, Lock, Star, Gift, Swords, HelpCircle, Coffee, ShoppingCart, Crown } from 'lucide-react';
import { motion } from 'motion/react';

interface DungeonMapProps {
  rooms: DungeonRoom[];
  currentRoomId: string | null;
  topics: Topic[];
  onRoomSelect: (roomId: string) => void;
}

const roomTypeIcons = {
  'topic-quiz': HelpCircle,
  'combat': Swords,
  'treasure': Gift,
  'choice': Star,
  'rest': Coffee,
  'merchant': ShoppingCart,
  'elite': Crown,
  'boss': Crown,
  'secret': Star
};

const roomTypeColors = {
  'topic-quiz': 'bg-blue-500',
  'combat': 'bg-red-500',
  'treasure': 'bg-yellow-500',
  'choice': 'bg-purple-500',
  'rest': 'bg-green-500',
  'merchant': 'bg-orange-500',
  'elite': 'bg-pink-500',
  'boss': 'bg-red-700',
  'secret': 'bg-indigo-500'
};

export function DungeonMap({ rooms, currentRoomId, topics, onRoomSelect }: DungeonMapProps) {
  const getRoom = (id: string) => rooms.find(r => r.id === id);
  const currentRoom = currentRoomId ? getRoom(currentRoomId) : null;

  // Calculate available rooms (rooms connected to current room or cleared rooms)
  const availableRooms = rooms.filter(room => {
    if (room.cleared) return false;
    if (!currentRoom) return room.y === 0; // Start rooms
    return currentRoom.connections.includes(room.id);
  });

  // Group rooms by Y coordinate (floor level)
  const maxY = Math.max(...rooms.map(r => r.y), 0);
  const roomsByFloor: { [key: number]: DungeonRoom[] } = {};
  for (let y = 0; y <= maxY; y++) {
    roomsByFloor[y] = rooms.filter(r => r.y === y).sort((a, b) => a.x - b.x);
  }

  const isRoomAvailable = (room: DungeonRoom): boolean => {
    return availableRooms.includes(room);
  };

  const getRoomTopic = (room: DungeonRoom): Topic | undefined => {
    if (room.topicId) {
      return topics.find(t => t.id === room.topicId);
    }
    return undefined;
  };

  return (
    <div className="relative">
      <div className="mb-6">
        <h3 className="mb-2">Dungeon Map</h3>
        <p className="text-sm text-gray-600">
          Navigate through rooms to progress. Each topic becomes a challenge room!
        </p>
      </div>

      {/* Legend */}
      <Card className="p-4 mb-6">
        <div className="flex flex-wrap gap-4 text-sm">
          <div className="flex items-center gap-2">
            <div className="w-3 h-3 rounded-full bg-blue-500" />
            <span>Quiz</span>
          </div>
          <div className="flex items-center gap-2">
            <div className="w-3 h-3 rounded-full bg-red-500" />
            <span>Combat</span>
          </div>
          <div className="flex items-center gap-2">
            <div className="w-3 h-3 rounded-full bg-yellow-500" />
            <span>Treasure</span>
          </div>
          <div className="flex items-center gap-2">
            <div className="w-3 h-3 rounded-full bg-green-500" />
            <span>Rest</span>
          </div>
          <div className="flex items-center gap-2">
            <div className="w-3 h-3 rounded-full bg-purple-500" />
            <span>Event</span>
          </div>
          <div className="flex items-center gap-2">
            <div className="w-3 h-3 rounded-full bg-orange-500" />
            <span>Merchant</span>
          </div>
        </div>
      </Card>

      {/* Map */}
      <div className="space-y-8 overflow-x-auto pb-4">
        {Object.entries(roomsByFloor).reverse().map(([floor, floorRooms]) => (
          <div key={floor} className="relative">
            <div className="text-xs text-gray-500 mb-2 font-medium">
              Floor {maxY - parseInt(floor) + 1}
            </div>
            
            <div className="flex justify-center gap-12 relative">
              {floorRooms.map(room => {
                const Icon = roomTypeIcons[room.type];
                const isAvailable = isRoomAvailable(room);
                const isCurrent = room.id === currentRoomId;
                const topic = getRoomTopic(room);

                return (
                  <motion.div
                    key={room.id}
                    initial={{ scale: 0, opacity: 0 }}
                    animate={{ scale: 1, opacity: 1 }}
                    transition={{ delay: parseInt(floor) * 0.1 }}
                    className="relative"
                  >
                    {/* Connections to rooms above */}
                    {room.connections.map(connId => {
                      const connRoom = getRoom(connId);
                      if (!connRoom || connRoom.y <= room.y) return null;
                      
                      return (
                        <svg
                          key={`${room.id}-${connId}`}
                          className="absolute top-0 left-1/2 -translate-x-1/2 -translate-y-full pointer-events-none"
                          style={{ height: '4rem', width: '100px' }}
                        >
                          <line
                            x1="50"
                            y1="64"
                            x2="50"
                            y2="0"
                            stroke="#e5e7eb"
                            strokeWidth="2"
                            strokeDasharray={room.optional ? "4" : "0"}
                          />
                        </svg>
                      );
                    })}

                    <button
                      onClick={() => isAvailable && onRoomSelect(room.id)}
                      disabled={!isAvailable && !room.cleared}
                      className={`
                        relative group transition-all
                        ${isAvailable ? 'cursor-pointer' : 'cursor-not-allowed'}
                      `}
                    >
                      <div className={`
                        w-16 h-16 rounded-full flex items-center justify-center
                        transition-all border-4
                        ${room.cleared ? 'bg-gray-200 border-gray-400' : roomTypeColors[room.type]}
                        ${isCurrent ? 'border-white ring-4 ring-blue-500 scale-110' : 'border-white'}
                        ${isAvailable && !room.cleared ? 'hover:scale-110 shadow-lg' : ''}
                        ${!isAvailable && !room.cleared ? 'opacity-40' : ''}
                      `}>
                        {room.cleared ? (
                          <CheckCircle2 className="w-8 h-8 text-gray-600" />
                        ) : !isAvailable ? (
                          <Lock className="w-8 h-8 text-white" />
                        ) : (
                          <Icon className="w-8 h-8 text-white" />
                        )}
                      </div>

                      {room.optional && (
                        <Badge 
                          variant="secondary" 
                          className="absolute -top-2 -right-2 text-xs"
                        >
                          ?
                        </Badge>
                      )}

                      {/* Tooltip */}
                      <Card className={`
                        absolute z-10 p-3 w-48 left-1/2 -translate-x-1/2 bottom-full mb-2
                        opacity-0 group-hover:opacity-100 transition-opacity pointer-events-none
                        ${!isAvailable && !room.cleared ? 'hidden' : ''}
                      `}>
                        <p className="text-sm mb-1">
                          {topic ? topic.title : room.type.split('-').map(w => w.charAt(0).toUpperCase() + w.slice(1)).join(' ')}
                        </p>
                        <p className="text-xs text-gray-600">
                          {room.cleared ? 'Completed' : isAvailable ? 'Available' : 'Locked'}
                        </p>
                        {topic && (
                          <p className="text-xs text-gray-500 mt-1">
                            {topic.description}
                          </p>
                        )}
                      </Card>
                    </button>
                  </motion.div>
                );
              })}
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
