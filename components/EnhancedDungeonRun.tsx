import { useState, useEffect } from 'react';
import { DungeonRun, DungeonRoom, DungeonEvent, Topic, Quiz, Relic } from '../types';
import { Card } from './ui/card';
import { Button } from './ui/button';
import { Badge } from './ui/badge';
import { Progress } from './ui/progress';
import { DungeonMap } from './DungeonMap';
import { TopicQuiz } from './TopicQuiz';
import { Sword, Heart, Zap, Trophy, Gift, MessageSquare, Sparkles, ArrowLeft } from 'lucide-react';
import { motion } from 'motion/react';

interface EnhancedDungeonRunProps {
  dungeonRun: DungeonRun;
  topics: Topic[];
  quizzes: Quiz[];
  narrativeEvents: DungeonEvent[];
  relics: Relic[];
  onRoomComplete: (roomId: string, rewards: string[]) => void;
  onRunComplete: () => void;
  onAbandon: () => void;
}

type RoomScreen = 'map' | 'quiz' | 'event' | 'rest' | 'treasure' | 'merchant';

export function EnhancedDungeonRun({
  dungeonRun,
  topics,
  quizzes,
  narrativeEvents,
  relics,
  onRoomComplete,
  onRunComplete,
  onAbandon
}: EnhancedDungeonRunProps) {
  const [currentScreen, setCurrentScreen] = useState<RoomScreen>('map');
  const [selectedRoom, setSelectedRoom] = useState<DungeonRoom | null>(null);
  const [currentEvent, setCurrentEvent] = useState<DungeonEvent | null>(null);

  const currentRoom = dungeonRun.currentRoomId 
    ? dungeonRun.rooms.find(r => r.id === dungeonRun.currentRoomId) 
    : null;

  // Check if all rooms are cleared
  useEffect(() => {
    const allCleared = dungeonRun.rooms.filter(r => !r.optional).every(r => r.cleared);
    if (allCleared && dungeonRun.active) {
      onRunComplete();
    }
  }, [dungeonRun.rooms]);

  const handleRoomSelect = (roomId: string) => {
    const room = dungeonRun.rooms.find(r => r.id === roomId);
    if (!room) return;

    setSelectedRoom(room);

    switch (room.type) {
      case 'topic-quiz':
        setCurrentScreen('quiz');
        break;
      case 'choice':
      case 'combat':
        // Find event for this room
        const event = narrativeEvents.find(e => e.id === room.eventId);
        if (event) {
          setCurrentEvent(event);
          setCurrentScreen('event');
        }
        break;
      case 'rest':
        setCurrentScreen('rest');
        break;
      case 'treasure':
        setCurrentScreen('treasure');
        break;
      case 'merchant':
        setCurrentScreen('merchant');
        break;
    }
  };

  const handleQuizComplete = (passed: boolean, score: number) => {
    if (!selectedRoom) return;

    if (passed) {
      // Award rewards based on score
      const rewards: string[] = [];
      if (score >= 90) rewards.push('perfect-clear-bonus');
      
      onRoomComplete(selectedRoom.id, rewards);
      setCurrentScreen('map');
      setSelectedRoom(null);
    } else {
      // Failed - return to map but don't clear room
      setCurrentScreen('map');
      setSelectedRoom(null);
    }
  };

  const handleEventChoice = (choice: any) => {
    if (!selectedRoom) return;

    const rewards: string[] = [];
    if (choice.consequence.type === 'card') {
      rewards.push(choice.consequence.value);
    }

    onRoomComplete(selectedRoom.id, rewards);
    setCurrentScreen('map');
    setSelectedRoom(null);
    setCurrentEvent(null);
  };

  const handleRestComplete = (choice: 'heal' | 'upgrade') => {
    if (!selectedRoom) return;
    onRoomComplete(selectedRoom.id, []);
    setCurrentScreen('map');
    setSelectedRoom(null);
  };

  const handleTreasureCollect = () => {
    if (!selectedRoom) return;
    // Grant random reward
    onRoomComplete(selectedRoom.id, ['random-card']);
    setCurrentScreen('map');
    setSelectedRoom(null);
  };

  const hpPercentage = (dungeonRun.playerStats.currentHp / dungeonRun.playerStats.maxHp) * 100;
  const energyPercentage = (dungeonRun.playerStats.currentEnergy / dungeonRun.playerStats.maxEnergy) * 100;

  return (
    <div className="max-w-6xl mx-auto">
      {/* Header with stats */}
      <div className="mb-6">
        <div className="flex items-center justify-between mb-4">
          <div>
            <h2>Dungeon Run - Floor {dungeonRun.floor}</h2>
            <p className="text-sm text-gray-600">
              Ascension Level {dungeonRun.ascensionLevel}
            </p>
          </div>
          <Button variant="outline" size="sm" onClick={onAbandon}>
            Abandon Run
          </Button>
        </div>

        {/* Player Stats */}
        <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
          <Card className="p-4">
            <div className="flex items-center justify-between mb-1">
              <span className="text-sm text-gray-600">HP</span>
              <Heart className="w-4 h-4 text-red-500" />
            </div>
            <p className="text-lg mb-1">
              {dungeonRun.playerStats.currentHp} / {dungeonRun.playerStats.maxHp}
            </p>
            <Progress value={hpPercentage} className="h-2" />
          </Card>

          <Card className="p-4">
            <div className="flex items-center justify-between mb-1">
              <span className="text-sm text-gray-600">Energy</span>
              <Zap className="w-4 h-4 text-yellow-500" />
            </div>
            <p className="text-lg mb-1">
              {dungeonRun.playerStats.currentEnergy} / {dungeonRun.playerStats.maxEnergy}
            </p>
            <Progress value={energyPercentage} className="h-2" />
          </Card>

          <Card className="p-4">
            <div className="flex items-center justify-between mb-1">
              <span className="text-sm text-gray-600">Armor</span>
              <Sparkles className="w-4 h-4 text-blue-500" />
            </div>
            <p className="text-lg">{dungeonRun.playerStats.armor}</p>
          </Card>

          <Card className="p-4">
            <div className="flex items-center justify-between mb-1">
              <span className="text-sm text-gray-600">Reputation</span>
              <Trophy className="w-4 h-4 text-purple-500" />
            </div>
            <p className="text-lg">{dungeonRun.reputation}</p>
          </Card>
        </div>

        {/* Active Relics */}
        {dungeonRun.relics.length > 0 && (
          <Card className="p-4 mt-4">
            <h4 className="text-sm mb-2">Active Relics</h4>
            <div className="flex flex-wrap gap-2">
              {dungeonRun.relics.map((relicId, index) => {
                const relic = relics.find(r => r.id === relicId);
                return (
                  <Badge key={`${relicId}-${index}`} variant="outline">
                    {relic?.name || relicId}
                  </Badge>
                );
              })}
            </div>
          </Card>
        )}
      </div>

      {/* Main Content */}
      {currentScreen === 'map' && (
        <DungeonMap
          rooms={dungeonRun.rooms}
          currentRoomId={dungeonRun.currentRoomId}
          topics={topics}
          onRoomSelect={handleRoomSelect}
        />
      )}

      {currentScreen === 'quiz' && selectedRoom && selectedRoom.topicId && (
        <div>
          <Button
            variant="outline"
            onClick={() => {
              setCurrentScreen('map');
              setSelectedRoom(null);
            }}
            className="mb-4"
          >
            <ArrowLeft className="w-4 h-4 mr-2" />
            Back to Map
          </Button>

          <TopicQuiz
            quiz={quizzes.find(q => q.topicId === selectedRoom.topicId)!}
            topicTitle={topics.find(t => t.id === selectedRoom.topicId)?.title || 'Topic'}
            onComplete={handleQuizComplete}
            onCancel={() => {
              setCurrentScreen('map');
              setSelectedRoom(null);
            }}
          />
        </div>
      )}

      {currentScreen === 'event' && currentEvent && (
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
        >
          <Button
            variant="outline"
            onClick={() => {
              setCurrentScreen('map');
              setSelectedRoom(null);
              setCurrentEvent(null);
            }}
            className="mb-4"
          >
            <ArrowLeft className="w-4 h-4 mr-2" />
            Back to Map
          </Button>

          <Card className="p-8">
            <div className="text-center mb-6">
              <Badge variant="outline" className="mb-3">
                {currentEvent.theme?.toUpperCase() || 'EVENT'}
              </Badge>
              <h2 className="mb-3">{currentEvent.title}</h2>
              <p className="text-gray-600">{currentEvent.description}</p>
            </div>

            <div className="space-y-3">
              {currentEvent.choices?.map((choice, index) => (
                <Button
                  key={index}
                  variant="outline"
                  className="w-full justify-start text-left h-auto py-4"
                  onClick={() => handleEventChoice(choice)}
                >
                  <div>
                    <p className="mb-1">{choice.text}</p>
                    <p className="text-xs text-gray-500">
                      {choice.consequence.type === 'hp' && `${choice.consequence.value > 0 ? '+' : ''}${choice.consequence.value} HP`}
                      {choice.consequence.type === 'reputation' && `${choice.consequence.value > 0 ? '+' : ''}${choice.consequence.value} Reputation`}
                      {choice.consequence.type === 'card' && 'Gain a card'}
                    </p>
                  </div>
                </Button>
              ))}
            </div>
          </Card>
        </motion.div>
      )}

      {currentScreen === 'rest' && (
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
        >
          <Button
            variant="outline"
            onClick={() => {
              setCurrentScreen('map');
              setSelectedRoom(null);
            }}
            className="mb-4"
          >
            <ArrowLeft className="w-4 h-4 mr-2" />
            Back to Map
          </Button>

          <Card className="p-8 text-center">
            <Heart className="w-16 h-16 mx-auto mb-4 text-green-500" />
            <h2 className="mb-3">Rest Site</h2>
            <p className="text-gray-600 mb-6">
              Take a moment to recover or upgrade your abilities
            </p>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <Button
                variant="outline"
                className="h-24"
                onClick={() => handleRestComplete('heal')}
              >
                <div>
                  <Heart className="w-6 h-6 mx-auto mb-2 text-red-500" />
                  <p className="font-medium">Rest</p>
                  <p className="text-xs text-gray-600">Heal 30 HP</p>
                </div>
              </Button>

              <Button
                variant="outline"
                className="h-24"
                onClick={() => handleRestComplete('upgrade')}
              >
                <div>
                  <Sparkles className="w-6 h-6 mx-auto mb-2 text-purple-500" />
                  <p className="font-medium">Meditate</p>
                  <p className="text-xs text-gray-600">Restore Energy</p>
                </div>
              </Button>
            </div>
          </Card>
        </motion.div>
      )}

      {currentScreen === 'treasure' && (
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
        >
          <Button
            variant="outline"
            onClick={() => {
              setCurrentScreen('map');
              setSelectedRoom(null);
            }}
            className="mb-4"
          >
            <ArrowLeft className="w-4 h-4 mr-2" />
            Back to Map
          </Button>

          <Card className="p-8 text-center">
            <Gift className="w-16 h-16 mx-auto mb-4 text-yellow-500" />
            <h2 className="mb-3">Treasure!</h2>
            <p className="text-gray-600 mb-6">
              You found a valuable reward!
            </p>

            <Button onClick={handleTreasureCollect}>
              <Gift className="w-4 h-4 mr-2" />
              Claim Treasure
            </Button>
          </Card>
        </motion.div>
      )}
    </div>
  );
}
