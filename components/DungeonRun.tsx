import { useState, useEffect } from 'react';
import { DungeonEvent, EventChoice, DungeonRun as DungeonRunType } from '../types';
import { Card } from './ui/card';
import { Button } from './ui/button';
import { Badge } from './ui/badge';
import { Progress } from './ui/progress';
import { Sword, Heart, Zap, Trophy, Gift, MessageSquare, Skull, Map } from 'lucide-react';
import { motion } from 'motion/react';

interface DungeonRunProps {
  dungeonRun: DungeonRunType;
  onEventComplete: (consequence: EventChoice['consequence']) => void;
  onRunComplete: () => void;
  onAbandon: () => void;
}

const dungeonEvents: DungeonEvent[] = [
  {
    id: 'combat-1',
    type: 'combat',
    title: 'Bug Swarm Attack',
    description: 'A swarm of bugs blocks your path. Defeat them in combat!',
    reward: 'code-strike'
  },
  {
    id: 'treasure-1',
    type: 'treasure',
    title: 'Ancient Library',
    description: 'You discover an ancient library filled with knowledge.',
    reward: 'refactor-blast'
  },
  {
    id: 'choice-1',
    type: 'choice',
    title: 'Mysterious Merchant',
    description: 'A mysterious merchant offers you a deal...',
    choices: [
      {
        text: 'Trade HP for a powerful card',
        consequence: { type: 'hp', value: -20 }
      },
      {
        text: 'Trade card for HP restoration',
        consequence: { type: 'hp', value: 30 }
      },
      {
        text: 'Walk away politely',
        consequence: { type: 'reputation', value: 5 }
      }
    ]
  },
  {
    id: 'rest-1',
    type: 'rest',
    title: 'Safe Haven',
    description: 'You find a peaceful spot to rest and recover.',
    choices: [
      {
        text: 'Rest and heal (30 HP)',
        consequence: { type: 'hp', value: 30 }
      },
      {
        text: 'Meditate and restore mana (3 Mana)',
        consequence: { type: 'mana', value: 3 }
      }
    ]
  },
  {
    id: 'choice-2',
    type: 'choice',
    title: 'Fork in the Road',
    description: 'The path splits. Which way will you go?',
    choices: [
      {
        text: 'Take the dangerous path (high risk/reward)',
        consequence: { type: 'reputation', value: 10 }
      },
      {
        text: 'Take the safe path (low risk)',
        consequence: { type: 'mana', value: 1 }
      }
    ]
  },
  {
    id: 'treasure-2',
    type: 'treasure',
    title: 'Hidden Cache',
    description: 'You stumble upon a hidden cache of rewards!',
    reward: 'syntax-shield'
  },
  {
    id: 'combat-2',
    type: 'combat',
    title: 'Elite Guard',
    description: 'An elite guard challenges you to prove your worth!',
    reward: 'null-safety'
  },
  {
    id: 'rest-2',
    type: 'rest',
    title: 'Fountain of Knowledge',
    description: 'A magical fountain offers restoration.',
    choices: [
      {
        text: 'Drink from the fountain (Full heal)',
        consequence: { type: 'hp', value: 100 }
      }
    ]
  }
];

export function DungeonRun({ dungeonRun, onEventComplete, onRunComplete, onAbandon }: DungeonRunProps) {
  const [currentEvent, setCurrentEvent] = useState<DungeonEvent | null>(null);
  const [selectedChoice, setSelectedChoice] = useState<EventChoice | null>(null);

  useEffect(() => {
    if (dungeonRun.currentRoom < dungeonRun.totalRooms) {
      // Generate random event
      const availableEvents = dungeonEvents.filter(
        e => !dungeonRun.events.includes(e.id)
      );
      if (availableEvents.length > 0) {
        const randomEvent = availableEvents[Math.floor(Math.random() * availableEvents.length)];
        setCurrentEvent(randomEvent);
      }
    } else {
      onRunComplete();
    }
  }, [dungeonRun.currentRoom]);

  const handleChoice = (choice: EventChoice) => {
    setSelectedChoice(choice);
    setTimeout(() => {
      onEventComplete(choice.consequence);
      setSelectedChoice(null);
    }, 1500);
  };

  const handleCombat = () => {
    // Simplified combat - just proceed
    if (currentEvent?.reward) {
      onEventComplete({ type: 'card', value: currentEvent.reward });
    } else {
      onEventComplete({ type: 'hp', value: 0 });
    }
  };

  const handleTreasure = () => {
    if (currentEvent?.reward) {
      onEventComplete({ type: 'card', value: currentEvent.reward });
    }
  };

  if (!currentEvent) {
    return (
      <div className="flex items-center justify-center min-h-[400px]">
        <p className="text-gray-500">Loading next room...</p>
      </div>
    );
  }

  const eventIcons = {
    combat: Sword,
    treasure: Gift,
    choice: MessageSquare,
    rest: Heart
  };

  const EventIcon = eventIcons[currentEvent.type];
  const progressPercentage = (dungeonRun.currentRoom / dungeonRun.totalRooms) * 100;

  return (
    <div className="max-w-4xl mx-auto">
      <div className="mb-6">
        <div className="flex items-center justify-between mb-4">
          <h2>Dungeon Run</h2>
          <Button variant="outline" size="sm" onClick={onAbandon}>
            Abandon Run
          </Button>
        </div>

        {/* Player Stats */}
        <div className="grid grid-cols-3 gap-4 mb-4">
          <Card className="p-4">
            <div className="flex items-center justify-between">
              <span className="text-sm text-gray-600">HP</span>
              <Heart className="w-4 h-4 text-red-500" />
            </div>
            <p className="text-gray-900">{dungeonRun.playerHp} / 100</p>
            <Progress value={dungeonRun.playerHp} className="h-1 mt-2" />
          </Card>

          <Card className="p-4">
            <div className="flex items-center justify-between">
              <span className="text-sm text-gray-600">Mana</span>
              <Zap className="w-4 h-4 text-blue-500" />
            </div>
            <p className="text-gray-900">{dungeonRun.playerMana} / 10</p>
            <Progress value={dungeonRun.playerMana * 10} className="h-1 mt-2" />
          </Card>

          <Card className="p-4">
            <div className="flex items-center justify-between">
              <span className="text-sm text-gray-600">Reputation</span>
              <Trophy className="w-4 h-4 text-yellow-500" />
            </div>
            <p className="text-gray-900">{dungeonRun.reputation}</p>
          </Card>
        </div>

        {/* Progress */}
        <div className="flex items-center gap-2 mb-2">
          <Map className="w-4 h-4 text-gray-600" />
          <span className="text-sm text-gray-600">
            Room {dungeonRun.currentRoom + 1} of {dungeonRun.totalRooms}
          </span>
        </div>
        <Progress value={progressPercentage} className="h-2" />
      </div>

      {/* Current Event */}
      <motion.div
        key={currentEvent.id}
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
      >
        <Card className="p-8">
          <div className="text-center mb-6">
            <motion.div
              initial={{ scale: 0 }}
              animate={{ scale: 1 }}
              transition={{ type: 'spring' }}
            >
              <EventIcon className={`
                w-16 h-16 mx-auto mb-4
                ${currentEvent.type === 'combat' ? 'text-red-500' : ''}
                ${currentEvent.type === 'treasure' ? 'text-yellow-500' : ''}
                ${currentEvent.type === 'choice' ? 'text-purple-500' : ''}
                ${currentEvent.type === 'rest' ? 'text-green-500' : ''}
              `} />
            </motion.div>
            <Badge variant="outline" className="mb-3">
              {currentEvent.type.toUpperCase()}
            </Badge>
            <h3 className="mb-2">{currentEvent.title}</h3>
            <p className="text-gray-600">{currentEvent.description}</p>
          </div>

          {selectedChoice ? (
            <motion.div
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              className="text-center p-4 bg-blue-50 rounded-lg"
            >
              <p className="text-sm text-gray-700">{selectedChoice.text}</p>
              <p className="text-xs text-gray-500 mt-2">Processing...</p>
            </motion.div>
          ) : (
            <div className="space-y-3">
              {currentEvent.type === 'combat' && (
                <Button className="w-full" size="lg" onClick={handleCombat}>
                  <Sword className="w-5 h-5 mr-2" />
                  Fight
                </Button>
              )}

              {currentEvent.type === 'treasure' && (
                <Button className="w-full" size="lg" onClick={handleTreasure}>
                  <Gift className="w-5 h-5 mr-2" />
                  Claim Treasure
                </Button>
              )}

              {currentEvent.choices && currentEvent.choices.map((choice, index) => (
                <Button
                  key={index}
                  variant="outline"
                  className="w-full justify-start text-left h-auto py-4"
                  onClick={() => handleChoice(choice)}
                >
                  <span>{choice.text}</span>
                </Button>
              ))}
            </div>
          )}
        </Card>
      </motion.div>
    </div>
  );
}
