import { Reward } from '../types';
import { Card } from './ui/card';
import { Badge } from './ui/badge';
import { Sword, Shield, Heart, Zap, ShieldCheck, ShieldAlert, HeartPulse, HeartHandshake, Flame, Package } from 'lucide-react';

interface InventoryPanelProps {
  inventory: Reward[];
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

export function InventoryPanel({ inventory }: InventoryPanelProps) {
  if (inventory.length === 0) {
    return (
      <Card className="p-6 text-center">
        <Package className="w-12 h-12 mx-auto mb-3 text-gray-400" />
        <p className="text-gray-500">
          No rewards collected yet. Complete topics to earn cards!
        </p>
      </Card>
    );
  }

  return (
    <div>
      <h3 className="mb-4">Your Inventory ({inventory.length} cards)</h3>
      <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4">
        {inventory.map((reward, index) => {
          const Icon = iconMap[reward.icon];
          
          return (
            <Card key={`${reward.id}-${index}`} className="p-4">
              <div className="text-center">
                <Icon className={`
                  w-8 h-8 mx-auto mb-2
                  ${reward.type === 'attack' ? 'text-red-600' : ''}
                  ${reward.type === 'defense' ? 'text-blue-600' : ''}
                  ${reward.type === 'utility' ? 'text-green-600' : ''}
                `} />
                <p className="mb-1">{reward.name}</p>
                <p className="text-xs text-gray-600 mb-2">{reward.description}</p>
                <Badge 
                  variant="outline" 
                  className={`text-xs
                    ${reward.type === 'attack' ? 'border-red-300 text-red-600' : ''}
                    ${reward.type === 'defense' ? 'border-blue-300 text-blue-600' : ''}
                    ${reward.type === 'utility' ? 'border-green-300 text-green-600' : ''}
                  `}
                >
                  {reward.type === 'attack' && `${reward.effect} DMG`}
                  {reward.type === 'defense' && `-${reward.effect} DMG`}
                  {reward.type === 'utility' && `+${reward.effect} HP`}
                </Badge>
              </div>
            </Card>
          );
        })}
      </div>
    </div>
  );
}
