import { useState } from 'react';
import { SkillNode, PlayerStats } from '../types';
import { Card } from './ui/card';
import { Button } from './ui/button';
import { Badge } from './ui/badge';
import { Progress } from './ui/progress';
import { Sword, Shield, Sparkles, Lock, Check } from 'lucide-react';
import { motion } from 'motion/react';

interface SkillTreeProps {
  skillTree: SkillNode[];
  playerStats: PlayerStats;
  availablePoints: number;
  onUnlock: (skillId: string) => void;
  onClose: () => void;
}

export function SkillTree({ skillTree, playerStats, availablePoints, onUnlock, onClose }: SkillTreeProps) {
  const [selectedBranch, setSelectedBranch] = useState<'offensive' | 'defensive' | 'utility'>('offensive');

  const branches = {
    offensive: skillTree.filter(s => s.branch === 'offensive'),
    defensive: skillTree.filter(s => s.branch === 'defensive'),
    utility: skillTree.filter(s => s.branch === 'utility')
  };

  const branchIcons = {
    offensive: Sword,
    defensive: Shield,
    utility: Sparkles
  };

  const branchColors = {
    offensive: 'border-red-500 bg-red-50',
    defensive: 'border-blue-500 bg-blue-50',
    utility: 'border-purple-500 bg-purple-50'
  };

  const canUnlock = (skill: SkillNode): boolean => {
    if (skill.unlocked) return false;
    if (availablePoints < skill.cost) return false;
    if (skill.prerequisite) {
      const prereq = skillTree.find(s => s.id === skill.prerequisite);
      return prereq?.unlocked || false;
    }
    return true;
  };

  const getStatBonus = (type: string): number => {
    return skillTree
      .filter(s => s.unlocked && s.effect.type === type)
      .reduce((sum, s) => sum + s.effect.value, 0);
  };

  return (
    <div className="max-w-6xl mx-auto">
      <div className="flex items-center justify-between mb-6">
        <div>
          <h2 className="mb-1">Skill Tree</h2>
          <p className="text-gray-600">
            Spend skill points to unlock permanent upgrades
          </p>
        </div>
        <div className="flex items-center gap-4">
          <div className="text-right">
            <p className="text-sm text-gray-600">Available Points</p>
            <p className="text-2xl">{availablePoints}</p>
          </div>
          <Button variant="outline" onClick={onClose}>
            Close
          </Button>
        </div>
      </div>

      {/* Current Stats */}
      <Card className="p-6 mb-6">
        <h3 className="mb-4">Current Stats</h3>
        <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-6 gap-4">
          <div>
            <p className="text-sm text-gray-600">Max HP</p>
            <p className="text-xl">{playerStats.maxHp}</p>
            {getStatBonus('maxHp') > 0 && (
              <p className="text-xs text-green-600">+{getStatBonus('maxHp')}</p>
            )}
          </div>
          <div>
            <p className="text-sm text-gray-600">Max Energy</p>
            <p className="text-xl">{playerStats.maxEnergy}</p>
            {getStatBonus('maxEnergy') > 0 && (
              <p className="text-xs text-green-600">+{getStatBonus('maxEnergy')}</p>
            )}
          </div>
          <div>
            <p className="text-sm text-gray-600">Draw Size</p>
            <p className="text-xl">{playerStats.drawSize}</p>
            {getStatBonus('drawSize') > 0 && (
              <p className="text-xs text-green-600">+{getStatBonus('drawSize')}</p>
            )}
          </div>
          <div>
            <p className="text-sm text-gray-600">Armor</p>
            <p className="text-xl">{playerStats.armor}</p>
            {getStatBonus('armor') > 0 && (
              <p className="text-xs text-green-600">+{getStatBonus('armor')}</p>
            )}
          </div>
          <div>
            <p className="text-sm text-gray-600">Level</p>
            <p className="text-xl">{playerStats.level}</p>
          </div>
          <div>
            <p className="text-sm text-gray-600">Experience</p>
            <Progress value={(playerStats.experience % 100)} className="mt-2" />
          </div>
        </div>
      </Card>

      {/* Branch Selection */}
      <div className="flex gap-2 mb-6">
        {(['offensive', 'defensive', 'utility'] as const).map(branch => {
          const Icon = branchIcons[branch];
          const unlockedCount = branches[branch].filter(s => s.unlocked).length;
          const totalCount = branches[branch].length;

          return (
            <Button
              key={branch}
              variant={selectedBranch === branch ? 'default' : 'outline'}
              onClick={() => setSelectedBranch(branch)}
              className="flex-1"
            >
              <Icon className="w-4 h-4 mr-2" />
              {branch.charAt(0).toUpperCase() + branch.slice(1)}
              <Badge variant="secondary" className="ml-2">
                {unlockedCount}/{totalCount}
              </Badge>
            </Button>
          );
        })}
      </div>

      {/* Skill Nodes */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        {branches[selectedBranch]
          .sort((a, b) => a.tier - b.tier)
          .map(skill => {
            const unlockable = canUnlock(skill);
            const Icon = branchIcons[skill.branch];
            const isLocked = !skill.unlocked && (skill.prerequisite && !skillTree.find(s => s.id === skill.prerequisite)?.unlocked);

            return (
              <motion.div
                key={skill.id}
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: skill.tier * 0.1 }}
              >
                <Card
                  className={`
                    p-6 transition-all
                    ${skill.unlocked ? branchColors[skill.branch] + ' border-2' : 'border border-gray-200'}
                    ${unlockable ? 'hover:shadow-lg cursor-pointer' : ''}
                    ${isLocked ? 'opacity-50' : ''}
                  `}
                  onClick={() => unlockable && onUnlock(skill.id)}
                >
                  <div className="flex items-start justify-between mb-3">
                    <div className="flex items-center gap-2">
                      <Icon className={`
                        w-6 h-6
                        ${skill.branch === 'offensive' ? 'text-red-600' : ''}
                        ${skill.branch === 'defensive' ? 'text-blue-600' : ''}
                        ${skill.branch === 'utility' ? 'text-purple-600' : ''}
                      `} />
                      <Badge variant="outline" className="text-xs">
                        Tier {skill.tier}
                      </Badge>
                    </div>
                    {skill.unlocked ? (
                      <Check className="w-5 h-5 text-green-600" />
                    ) : isLocked ? (
                      <Lock className="w-5 h-5 text-gray-400" />
                    ) : (
                      <Badge variant="secondary">{skill.cost} pts</Badge>
                    )}
                  </div>

                  <h4 className="mb-2">{skill.name}</h4>
                  <p className="text-sm text-gray-600 mb-3">{skill.description}</p>

                  <div className="flex items-center justify-between text-sm">
                    <span className="text-gray-600">Effect:</span>
                    <span className="font-medium">
                      +{skill.effect.value} {skill.effect.type}
                    </span>
                  </div>

                  {skill.prerequisite && !skill.unlocked && (
                    <p className="text-xs text-gray-500 mt-2">
                      Requires: {skillTree.find(s => s.id === skill.prerequisite)?.name}
                    </p>
                  )}

                  {!skill.unlocked && unlockable && (
                    <Button className="w-full mt-3" size="sm">
                      Unlock
                    </Button>
                  )}
                </Card>
              </motion.div>
            );
          })}
      </div>
    </div>
  );
}
