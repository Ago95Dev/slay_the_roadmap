import { Relic } from '../types';
import { Card } from './ui/card';
import { Badge } from './ui/badge';
import { Eye, BookOpen, Coffee, ShieldCheck, RotateCcw, Database, Sparkles, Zap, HeartHandshake, Layers, Cpu, Lock } from 'lucide-react';

interface RelicCollectionProps {
  ownedRelics: string[];
  allRelics: Relic[];
  showLocked?: boolean;
}

const iconMap: { [key: string]: any } = {
  Eye,
  BookOpen,
  Coffee,
  ShieldCheck,
  RotateCcw,
  Database,
  Sparkles,
  Zap,
  HeartHandshake,
  Layers,
  Cpu
};

const rarityColors = {
  common: 'border-gray-400 bg-gray-50',
  rare: 'border-blue-400 bg-blue-50',
  epic: 'border-purple-400 bg-purple-50',
  legendary: 'border-yellow-400 bg-yellow-50'
};

const rarityBadgeColors = {
  common: 'bg-gray-500',
  rare: 'bg-blue-500',
  epic: 'bg-purple-500',
  legendary: 'bg-yellow-500'
};

export function RelicCollection({ ownedRelics, allRelics, showLocked = false }: RelicCollectionProps) {
  const displayRelics = showLocked 
    ? allRelics 
    : allRelics.filter(r => ownedRelics.includes(r.id));

  const groupedByRarity = {
    legendary: displayRelics.filter(r => r.rarity === 'legendary'),
    epic: displayRelics.filter(r => r.rarity === 'epic'),
    rare: displayRelics.filter(r => r.rarity === 'rare'),
    common: displayRelics.filter(r => r.rarity === 'common')
  };

  if (displayRelics.length === 0) {
    return (
      <Card className="p-12 text-center">
        <Sparkles className="w-12 h-12 mx-auto mb-3 text-gray-400" />
        <h3 className="mb-2">No Relics Yet</h3>
        <p className="text-gray-600">
          Defeat bosses and complete dungeon runs to collect powerful relics!
        </p>
      </Card>
    );
  }

  return (
    <div className="space-y-6">
      {Object.entries(groupedByRarity).map(([rarity, relics]) => {
        if (relics.length === 0) return null;

        return (
          <div key={rarity}>
            <div className="flex items-center gap-2 mb-4">
              <h3 className="capitalize">{rarity} Relics</h3>
              <Badge variant="outline" className={rarityBadgeColors[rarity as keyof typeof rarityBadgeColors]}>
                {relics.length}
              </Badge>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
              {relics.map(relic => {
                const Icon = iconMap[relic.icon] || Sparkles;
                const isOwned = ownedRelics.includes(relic.id);
                const isLocked = !isOwned && showLocked;

                return (
                  <Card
                    key={relic.id}
                    className={`
                      p-6 border-2 transition-all
                      ${isOwned ? rarityColors[relic.rarity] : 'opacity-50 bg-gray-100'}
                      ${isOwned ? 'hover:shadow-md' : ''}
                    `}
                  >
                    <div className="flex items-start gap-4">
                      <div className={`
                        p-3 rounded-lg
                        ${rarity === 'legendary' ? 'bg-yellow-200' : ''}
                        ${rarity === 'epic' ? 'bg-purple-200' : ''}
                        ${rarity === 'rare' ? 'bg-blue-200' : ''}
                        ${rarity === 'common' ? 'bg-gray-200' : ''}
                      `}>
                        {isLocked ? (
                          <Lock className="w-8 h-8 text-gray-500" />
                        ) : (
                          <Icon className={`
                            w-8 h-8
                            ${rarity === 'legendary' ? 'text-yellow-700' : ''}
                            ${rarity === 'epic' ? 'text-purple-700' : ''}
                            ${rarity === 'rare' ? 'text-blue-700' : ''}
                            ${rarity === 'common' ? 'text-gray-700' : ''}
                          `} />
                        )}
                      </div>

                      <div className="flex-1">
                        <div className="flex items-start justify-between mb-2">
                          <h4 className="text-sm">{isLocked ? '???' : relic.name}</h4>
                          <Badge 
                            variant="default" 
                            className={`text-xs ${rarityBadgeColors[relic.rarity]}`}
                          >
                            {relic.rarity}
                          </Badge>
                        </div>
                        <p className="text-xs text-gray-600">
                          {isLocked ? 'Locked - Complete challenges to unlock' : relic.description}
                        </p>
                      </div>
                    </div>
                  </Card>
                );
              })}
            </div>
          </div>
        );
      })}
    </div>
  );
}
