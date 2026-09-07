import { useState } from 'react';
import { Reward } from '../types';
import { Card } from './ui/card';
import { Button } from './ui/button';
import { Badge } from './ui/badge';
import { Sword, Shield, Zap, ShieldCheck, ShieldAlert, HeartPulse, HeartHandshake, Flame, Heart, Sparkles } from 'lucide-react';
import { motion } from 'motion/react';

interface DeckBuilderProps {
  inventory: Reward[];
  activeDeck: string[];
  maxDeckSize: number;
  onDeckUpdate: (deckIds: string[]) => void;
  onClose: () => void;
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
  Flame,
  Sparkles
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

export function DeckBuilder({ inventory, activeDeck, maxDeckSize, onDeckUpdate, onClose }: DeckBuilderProps) {
  const [selectedCards, setSelectedCards] = useState<string[]>(activeDeck);

  const toggleCard = (cardId: string) => {
    if (selectedCards.includes(cardId)) {
      setSelectedCards(selectedCards.filter(id => id !== cardId));
    } else if (selectedCards.length < maxDeckSize) {
      setSelectedCards([...selectedCards, cardId]);
    }
  };

  const handleSave = () => {
    onDeckUpdate(selectedCards);
    onClose();
  };

  const handleReset = () => {
    setSelectedCards([]);
  };

  const totalManaCost = selectedCards.reduce((sum, cardId) => {
    const card = inventory.find(c => c.id === cardId);
    return sum + (card?.manaCost || 0);
  }, 0);

  const cardsByType = {
    attack: inventory.filter(c => c.type === 'attack'),
    defense: inventory.filter(c => c.type === 'defense'),
    utility: inventory.filter(c => c.type === 'utility')
  };

  return (
    <div className="max-w-6xl mx-auto">
      <div className="flex items-center justify-between mb-6">
        <div>
          <h2>Deck Builder</h2>
          <p className="text-gray-600">
            Select up to {maxDeckSize} cards for your active deck
          </p>
        </div>
        <div className="flex gap-2">
          <Button variant="outline" onClick={handleReset}>
            Clear All
          </Button>
          <Button variant="outline" onClick={onClose}>
            Cancel
          </Button>
          <Button onClick={handleSave}>
            Save Deck
          </Button>
        </div>
      </div>

      {/* Deck Stats */}
      <Card className="p-4 mb-6">
        <div className="grid grid-cols-4 gap-4 text-center">
          <div>
            <p className="text-sm text-gray-600 mb-1">Cards Selected</p>
            <p className="text-gray-900">
              {selectedCards.length} / {maxDeckSize}
            </p>
          </div>
          <div>
            <p className="text-sm text-gray-600 mb-1">Total Mana Cost</p>
            <p className="text-gray-900">{totalManaCost}</p>
          </div>
          <div>
            <p className="text-sm text-gray-600 mb-1">Avg. Mana Cost</p>
            <p className="text-gray-900">
              {selectedCards.length > 0 ? (totalManaCost / selectedCards.length).toFixed(1) : '0'}
            </p>
          </div>
          <div>
            <p className="text-sm text-gray-600 mb-1">Total Cards Owned</p>
            <p className="text-gray-900">{inventory.length}</p>
          </div>
        </div>
      </Card>

      {/* Card Selection */}
      <div className="space-y-6">
        {Object.entries(cardsByType).map(([type, cards]) => {
          if (cards.length === 0) return null;
          
          return (
            <div key={type}>
              <h3 className="mb-4 capitalize flex items-center gap-2">
                {type === 'attack' && <Sword className="w-5 h-5 text-red-500" />}
                {type === 'defense' && <Shield className="w-5 h-5 text-blue-500" />}
                {type === 'utility' && <Sparkles className="w-5 h-5 text-purple-500" />}
                {type} Cards ({cards.length})
              </h3>
              
              <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4">
                {cards.map(card => {
                  const Icon = iconMap[card.icon];
                  const isSelected = selectedCards.includes(card.id);
                  const canSelect = isSelected || selectedCards.length < maxDeckSize;

                  return (
                    <motion.div
                      key={card.id}
                      whileHover={canSelect ? { scale: 1.05 } : {}}
                      whileTap={canSelect ? { scale: 0.95 } : {}}
                    >
                      <Card
                        className={`
                          p-4 cursor-pointer transition-all border-2
                          ${isSelected ? rarityColors[card.rarity] + ' ring-2 ring-offset-2' : 'border-gray-200'}
                          ${isSelected && card.rarity === 'common' ? 'ring-gray-400' : ''}
                          ${isSelected && card.rarity === 'rare' ? 'ring-blue-400' : ''}
                          ${isSelected && card.rarity === 'epic' ? 'ring-purple-400' : ''}
                          ${isSelected && card.rarity === 'legendary' ? 'ring-yellow-400' : ''}
                          ${!canSelect ? 'opacity-50 cursor-not-allowed' : ''}
                        `}
                        onClick={() => canSelect && toggleCard(card.id)}
                      >
                        <div className="text-center">
                          <div className="flex items-center justify-between mb-2">
                            <Badge 
                              variant="default" 
                              className={`text-xs ${rarityBadgeColors[card.rarity]}`}
                            >
                              {card.rarity}
                            </Badge>
                            <Badge variant="outline" className="text-xs">
                              {card.manaCost} <Zap className="w-3 h-3 ml-1" />
                            </Badge>
                          </div>
                          
                          <Icon className={`
                            w-8 h-8 mx-auto mb-2
                            ${card.type === 'attack' ? 'text-red-600' : ''}
                            ${card.type === 'defense' ? 'text-blue-600' : ''}
                            ${card.type === 'utility' ? 'text-purple-600' : ''}
                          `} />
                          
                          <p className="mb-1 text-sm">{card.name}</p>
                          <p className="text-xs text-gray-600 mb-2 line-clamp-2">
                            {card.description}
                          </p>
                          
                          <Badge variant="outline" className="text-xs">
                            {card.type === 'attack' && `${card.effect} DMG`}
                            {card.type === 'defense' && `-${card.effect} DMG`}
                            {card.type === 'utility' && `Effect: ${card.effect}`}
                          </Badge>

                          {isSelected && (
                            <Badge variant="default" className="mt-2 text-xs bg-green-500">
                              ✓ In Deck
                            </Badge>
                          )}

                          {card.synergies && card.synergies.length > 0 && (
                            <div className="mt-2 pt-2 border-t border-gray-200">
                              <p className="text-xs text-gray-500">
                                Synergy: {card.synergies.join(', ')}
                              </p>
                            </div>
                          )}
                        </div>
                      </Card>
                    </motion.div>
                  );
                })}
              </div>
            </div>
          );
        })}
      </div>

      {inventory.length === 0 && (
        <Card className="p-12 text-center">
          <Sparkles className="w-12 h-12 mx-auto mb-3 text-gray-400" />
          <h3 className="mb-2">No Cards Yet</h3>
          <p className="text-gray-600">
            Complete topics to earn cards and build your deck!
          </p>
        </Card>
      )}
    </div>
  );
}
