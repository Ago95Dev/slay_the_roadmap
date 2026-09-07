import { useState } from 'react';
import { Reward } from '../types';
import { Card } from './ui/card';
import { Button } from './ui/button';
import { Badge } from './ui/badge';
import { Sword, Shield, Heart, Zap, ShieldCheck, ShieldAlert, HeartPulse, HeartHandshake, Flame } from 'lucide-react';
import { motion } from 'motion/react';

interface RewardSelectionProps {
  availableRewards: Reward[];
  onRewardSelect: (rewardId: string) => void;
  topicTitle: string;
}

const iconMap: { [key: string]: any } = {
  Sword,
  Shield,
  Heart,
  Zap,
  ShieldCheck,
  ShieldAlert,
  HeartPulse,
  HeartHandshake,
  Flame
};

export function RewardSelection({ availableRewards, onRewardSelect, topicTitle }: RewardSelectionProps) {
  const [selectedReward, setSelectedReward] = useState<string | null>(null);
  const [hoveredReward, setHoveredReward] = useState<string | null>(null);

  const groupedRewards = {
    attack: availableRewards.filter(r => r.type === 'attack').slice(0, 3),
    defense: availableRewards.filter(r => r.type === 'defense').slice(0, 3),
    utility: availableRewards.filter(r => r.type === 'utility').slice(0, 3)
  };

  const handleConfirm = () => {
    if (selectedReward) {
      onRewardSelect(selectedReward);
    }
  };

  const typeColors = {
    attack: 'border-red-500 bg-red-50',
    defense: 'border-blue-500 bg-blue-50',
    utility: 'border-green-500 bg-green-50'
  };

  const typeLabels = {
    attack: 'Attack',
    defense: 'Defense',
    utility: 'Utility'
  };

  return (
    <div className="max-w-4xl mx-auto">
      <div className="text-center mb-8">
        <motion.div
          initial={{ scale: 0 }}
          animate={{ scale: 1 }}
          transition={{ type: 'spring', duration: 0.5 }}
        >
          <h2 className="mb-2">🎉 {topicTitle} Completed!</h2>
        </motion.div>
        <p className="text-gray-600">
          Choose one reward to add to your deck for boss fights
        </p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
        {Object.entries(groupedRewards).map(([type, rewards]) => (
          <div key={type}>
            <h3 className="mb-4 text-center capitalize">{typeLabels[type as keyof typeof typeLabels]}</h3>
            <div className="space-y-3">
              {rewards.map((reward) => {
                const Icon = iconMap[reward.icon];
                const isSelected = selectedReward === reward.id;
                const isHovered = hoveredReward === reward.id;

                return (
                  <motion.div
                    key={reward.id}
                    whileHover={{ scale: 1.05 }}
                    whileTap={{ scale: 0.95 }}
                  >
                    <Card
                      className={`
                        p-4 cursor-pointer transition-all border-2
                        ${isSelected ? typeColors[type as keyof typeof typeColors] : 'border-gray-200'}
                        ${isHovered && !isSelected ? 'border-gray-400' : ''}
                      `}
                      onClick={() => setSelectedReward(reward.id)}
                      onMouseEnter={() => setHoveredReward(reward.id)}
                      onMouseLeave={() => setHoveredReward(null)}
                    >
                      <div className="flex items-start gap-3">
                        <div className={`
                          p-2 rounded-lg
                          ${type === 'attack' ? 'bg-red-100' : ''}
                          ${type === 'defense' ? 'bg-blue-100' : ''}
                          ${type === 'utility' ? 'bg-green-100' : ''}
                        `}>
                          <Icon className={`
                            w-6 h-6
                            ${type === 'attack' ? 'text-red-600' : ''}
                            ${type === 'defense' ? 'text-blue-600' : ''}
                            ${type === 'utility' ? 'text-green-600' : ''}
                          `} />
                        </div>
                        
                        <div className="flex-1">
                          <div className="flex items-center justify-between mb-1">
                            <span>{reward.name}</span>
                            {isSelected && (
                              <Badge variant="default">Selected</Badge>
                            )}
                          </div>
                          <p className="text-sm text-gray-600 mb-2">
                            {reward.description}
                          </p>
                          <div className="flex items-center gap-2">
                            <Badge variant="outline" className="text-xs">
                              {type === 'attack' && `${reward.effect} DMG`}
                              {type === 'defense' && `-${reward.effect} DMG`}
                              {type === 'utility' && `+${reward.effect} HP`}
                            </Badge>
                          </div>
                        </div>
                      </div>
                    </Card>
                  </motion.div>
                );
              })}
            </div>
          </div>
        ))}
      </div>

      {selectedReward && (
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          className="text-center"
        >
          <Button onClick={handleConfirm} size="lg">
            Confirm Selection
          </Button>
        </motion.div>
      )}
    </div>
  );
}
