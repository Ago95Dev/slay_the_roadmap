import { useState, useEffect } from 'react';
import { Chapter, BossQuestion, Reward } from '../types';
import { Card } from './ui/card';
import { Button } from './ui/button';
import { Badge } from './ui/badge';
import { Progress } from './ui/progress';
import { Skull, Heart, Sword, Shield, HeartPulse, Zap, ShieldCheck, ShieldAlert, HeartHandshake, Flame } from 'lucide-react';
import { motion } from 'motion/react';

interface BossFightProps {
  chapter: Chapter;
  questions: BossQuestion[];
  playerInventory: Reward[];
  initialBossHp: number;
  onVictory: () => void;
  onDefeat: () => void;
  onBossHpChange: (hp: number) => void;
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

type GamePhase = 'player-turn' | 'boss-turn' | 'victory' | 'defeat';

export function BossFight({ 
  chapter, 
  questions, 
  playerInventory, 
  initialBossHp,
  onVictory, 
  onDefeat,
  onBossHpChange 
}: BossFightProps) {
  const [bossHp, setBossHp] = useState(initialBossHp);
  const [playerHp, setPlayerHp] = useState(100);
  const [phase, setPhase] = useState<GamePhase>('player-turn');
  const [currentQuestion, setCurrentQuestion] = useState<BossQuestion | null>(null);
  const [selectedAnswer, setSelectedAnswer] = useState<number | null>(null);
  const [showFeedback, setShowFeedback] = useState(false);
  const [usedCards, setUsedCards] = useState<Set<string>>(new Set());
  const [message, setMessage] = useState('Choose a card to play!');
  const [defenseBonus, setDefenseBonus] = useState(0);

  const maxBossHp = chapter.bossHp;
  const bossHpPercentage = (bossHp / maxBossHp) * 100;

  useEffect(() => {
    if (bossHp <= 0) {
      setPhase('victory');
      setTimeout(onVictory, 2000);
    } else if (playerHp <= 0) {
      setPhase('defeat');
      setTimeout(onDefeat, 2000);
    }
  }, [bossHp, playerHp, onVictory, onDefeat]);

  const getRandomQuestion = (): BossQuestion => {
    return questions[Math.floor(Math.random() * questions.length)];
  };

  const checkThresholdBonus = (oldHp: number, newHp: number) => {
    const thresholds = [75, 50, 25];
    for (const threshold of thresholds) {
      const thresholdHp = (threshold / 100) * maxBossHp;
      if (oldHp > thresholdHp && newHp <= thresholdHp) {
        setMessage(`💥 Threshold bonus! Boss weakened at ${threshold}% HP!`);
        return 10; // Bonus damage
      }
    }
    return 0;
  };

  const handleCardPlay = (card: Reward) => {
    if (usedCards.has(card.id) || phase !== 'player-turn') return;

    setUsedCards(prev => new Set([...prev, card.id]));

    if (card.type === 'attack') {
      const oldHp = bossHp;
      const bonusDamage = checkThresholdBonus(oldHp, oldHp - card.effect);
      const totalDamage = card.effect + bonusDamage;
      const newBossHp = Math.max(0, bossHp - totalDamage);
      setBossHp(newBossHp);
      onBossHpChange(newBossHp);
      setMessage(`⚔️ ${card.name} dealt ${totalDamage} damage!`);
    } else if (card.type === 'defense') {
      setDefenseBonus(prev => prev + card.effect);
      setMessage(`🛡️ ${card.name} activated! Damage reduced by ${card.effect} next turn.`);
    } else if (card.type === 'utility') {
      const newPlayerHp = Math.min(100, playerHp + card.effect);
      setPlayerHp(newPlayerHp);
      setMessage(`❤️ ${card.name} restored ${card.effect} HP!`);
    }

    setTimeout(() => {
      if (bossHp > 0) {
        startBossTurn();
      }
    }, 1500);
  };

  const startBossTurn = () => {
    setPhase('boss-turn');
    setMessage('Boss is attacking! Answer correctly to minimize damage!');
    const question = getRandomQuestion();
    setCurrentQuestion(question);
    setSelectedAnswer(null);
    setShowFeedback(false);
  };

  const handleAnswerSubmit = () => {
    if (selectedAnswer === null || !currentQuestion) return;

    setShowFeedback(true);
    const isCorrect = selectedAnswer === currentQuestion.correctAnswer;
    
    let damage = currentQuestion.damage;
    
    if (isCorrect) {
      damage = Math.floor(damage * 0.3); // 70% damage reduction for correct answer
      setMessage(`✅ Correct! Damage reduced to ${damage}!`);
    } else {
      damage = Math.max(0, damage - defenseBonus);
      setMessage(`❌ Wrong! Took ${damage} damage!`);
    }

    setDefenseBonus(0); // Reset defense bonus after use
    const newPlayerHp = Math.max(0, playerHp - damage);
    setPlayerHp(newPlayerHp);

    setTimeout(() => {
      setPhase('player-turn');
      setMessage('Your turn! Choose a card to play!');
      setCurrentQuestion(null);
    }, 2000);
  };

  if (phase === 'victory') {
    return (
      <motion.div
        initial={{ scale: 0.8, opacity: 0 }}
        animate={{ scale: 1, opacity: 1 }}
        className="flex items-center justify-center min-h-[500px]"
      >
        <Card className="p-8 text-center max-w-md">
          <motion.div
            animate={{ rotate: 360 }}
            transition={{ duration: 1 }}
          >
            <Skull className="w-20 h-20 mx-auto mb-4 text-yellow-500" />
          </motion.div>
          <h2 className="mb-2 text-green-600">Victory! 🎉</h2>
          <p className="text-gray-600">
            You defeated {chapter.bossName}!
          </p>
        </Card>
      </motion.div>
    );
  }

  if (phase === 'defeat') {
    return (
      <motion.div
        initial={{ scale: 0.8, opacity: 0 }}
        animate={{ scale: 1, opacity: 1 }}
        className="flex items-center justify-center min-h-[500px]"
      >
        <Card className="p-8 text-center max-w-md">
          <Skull className="w-20 h-20 mx-auto mb-4 text-red-500" />
          <h2 className="mb-2 text-red-600">Defeated</h2>
          <p className="text-gray-600">
            {chapter.bossName} was too strong. Collect more rewards and try again!
          </p>
        </Card>
      </motion.div>
    );
  }

  return (
    <div className="max-w-5xl mx-auto">
      <div className="text-center mb-6">
        <h2 className="mb-2">Boss Fight: {chapter.bossName}</h2>
        <p className="text-gray-600">{chapter.description}</p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mb-6">
        {/* Boss HP */}
        <Card className="p-6">
          <div className="flex items-center justify-between mb-2">
            <div className="flex items-center gap-2">
              <Skull className="w-6 h-6 text-red-600" />
              <span>{chapter.bossName}</span>
            </div>
            <Badge variant="destructive">{bossHp} / {maxBossHp} HP</Badge>
          </div>
          <Progress value={bossHpPercentage} className="h-4" />
          <div className="mt-2 flex gap-1">
            {[75, 50, 25].map(threshold => {
              const thresholdHp = (threshold / 100) * maxBossHp;
              const isPassed = bossHp <= thresholdHp;
              return (
                <div key={threshold} className="flex-1">
                  <div className={`h-1 rounded ${isPassed ? 'bg-yellow-500' : 'bg-gray-300'}`} />
                  <p className="text-xs text-center mt-1">{threshold}%</p>
                </div>
              );
            })}
          </div>
        </Card>

        {/* Player HP */}
        <Card className="p-6">
          <div className="flex items-center justify-between mb-2">
            <div className="flex items-center gap-2">
              <Heart className="w-6 h-6 text-green-600" />
              <span>Your HP</span>
            </div>
            <Badge variant="default" className="bg-green-600">{playerHp} / 100 HP</Badge>
          </div>
          <Progress value={playerHp} className="h-4" />
          {defenseBonus > 0 && (
            <Badge variant="outline" className="mt-2">
              🛡️ Defense: -{defenseBonus} damage
            </Badge>
          )}
        </Card>
      </div>

      {/* Message */}
      <motion.div
        key={message}
        initial={{ opacity: 0, y: -10 }}
        animate={{ opacity: 1, y: 0 }}
        className="text-center mb-6"
      >
        <Badge variant="outline" className="text-lg px-4 py-2">
          {message}
        </Badge>
      </motion.div>

      {phase === 'player-turn' && (
        <div>
          <h3 className="mb-4">Your Cards</h3>
          <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4">
            {playerInventory.map((card) => {
              const Icon = iconMap[card.icon];
              const isUsed = usedCards.has(card.id);

              return (
                <motion.div
                  key={card.id}
                  whileHover={!isUsed ? { scale: 1.05 } : {}}
                  whileTap={!isUsed ? { scale: 0.95 } : {}}
                >
                  <Card
                    className={`
                      p-4 cursor-pointer transition-all
                      ${isUsed ? 'opacity-30 cursor-not-allowed' : 'hover:shadow-lg'}
                      ${card.type === 'attack' ? 'border-red-300' : ''}
                      ${card.type === 'defense' ? 'border-blue-300' : ''}
                      ${card.type === 'utility' ? 'border-green-300' : ''}
                    `}
                    onClick={() => !isUsed && handleCardPlay(card)}
                  >
                    <div className="text-center">
                      <Icon className={`
                        w-8 h-8 mx-auto mb-2
                        ${card.type === 'attack' ? 'text-red-600' : ''}
                        ${card.type === 'defense' ? 'text-blue-600' : ''}
                        ${card.type === 'utility' ? 'text-green-600' : ''}
                      `} />
                      <p className="mb-1">{card.name}</p>
                      <p className="text-xs text-gray-600 mb-2">{card.description}</p>
                      <Badge variant="outline" className="text-xs">
                        {card.type === 'attack' && `${card.effect} DMG`}
                        {card.type === 'defense' && `-${card.effect} DMG`}
                        {card.type === 'utility' && `+${card.effect} HP`}
                      </Badge>
                      {isUsed && (
                        <Badge variant="secondary" className="mt-2 text-xs">Used</Badge>
                      )}
                    </div>
                  </Card>
                </motion.div>
              );
            })}
          </div>
        </div>
      )}

      {phase === 'boss-turn' && currentQuestion && (
        <Card className="p-6">
          <h3 className="mb-4">Boss Question</h3>
          <p className="mb-6">{currentQuestion.question}</p>

          <div className="space-y-3 mb-6">
            {currentQuestion.options.map((option, index) => {
              const isSelected = selectedAnswer === index;
              const isCorrect = index === currentQuestion.correctAnswer;
              const showCorrect = showFeedback && isCorrect;
              const showIncorrect = showFeedback && isSelected && !isCorrect;

              return (
                <button
                  key={index}
                  onClick={() => !showFeedback && setSelectedAnswer(index)}
                  disabled={showFeedback}
                  className={`
                    w-full p-4 text-left border-2 rounded-lg transition-all
                    ${isSelected && !showFeedback ? 'border-blue-500 bg-blue-50' : 'border-gray-200'}
                    ${showCorrect ? 'border-green-500 bg-green-50' : ''}
                    ${showIncorrect ? 'border-red-500 bg-red-50' : ''}
                    ${!showFeedback ? 'hover:border-blue-300 cursor-pointer' : 'cursor-not-allowed'}
                  `}
                >
                  {option}
                </button>
              );
            })}
          </div>

          {showFeedback && (
            <motion.div
              initial={{ opacity: 0, y: -10 }}
              animate={{ opacity: 1, y: 0 }}
              className={`p-4 rounded-lg mb-4 ${
                selectedAnswer === currentQuestion.correctAnswer
                  ? 'bg-green-50 border border-green-200'
                  : 'bg-red-50 border border-red-200'
              }`}
            >
              <p className="text-sm">
                <strong>Explanation:</strong> {currentQuestion.explanation}
              </p>
            </motion.div>
          )}

          {!showFeedback && (
            <Button onClick={handleAnswerSubmit} disabled={selectedAnswer === null}>
              Submit Answer
            </Button>
          )}
        </Card>
      )}
    </div>
  );
}
