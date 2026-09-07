import { useState, useEffect } from 'react';
import { PlayerProgress, Achievement, TopicStats } from './types';
import { topics, quizzes, rewards, chapters, bossQuestions } from './data/dartRoadmap';
import { saveProgress, loadProgress, resetProgress } from './utils/storage';
import { RoadmapTree } from './components/RoadmapTree';
import { TopicDetail } from './components/TopicDetail';
import { TopicQuiz } from './components/TopicQuiz';
import { RewardSelection } from './components/RewardSelection';
import { BossFight } from './components/BossFight';
import { InventoryPanel } from './components/InventoryPanel';
import { DeckBuilder } from './components/DeckBuilder';
import { DungeonRun } from './components/DungeonRun';
import { StatsDashboard } from './components/StatsDashboard';
import { Tabs, TabsContent, TabsList, TabsTrigger } from './components/ui/tabs';
import { Button } from './components/ui/button';
import { Card } from './components/ui/card';
import { AlertDialog, AlertDialogAction, AlertDialogCancel, AlertDialogContent, AlertDialogDescription, AlertDialogFooter, AlertDialogHeader, AlertDialogTitle, AlertDialogTrigger } from './components/ui/alert-dialog';
import { Badge } from './components/ui/badge';
import { BookOpen, Trophy, RotateCcw, BarChart3, Map, Package } from 'lucide-react';
import { Toaster } from './components/ui/sonner';
import { toast } from 'sonner@2.0.3';

type AppScreen = 'roadmap' | 'topic-detail' | 'quiz' | 'reward-selection' | 'boss-fight' | 'deck-builder' | 'dungeon-run';

export default function App() {
  const [progress, setProgress] = useState<PlayerProgress>({
    completedTopics: [],
    currentTopic: null,
    inventory: [],
    activeDeck: [],
    chapterProgress: {},
    achievements: [],
    dungeonRun: null,
    stats: {
      totalStudyTime: 0,
      currentStreak: 0,
      longestStreak: 0,
      topicStats: []
    }
  });

  const [currentScreen, setCurrentScreen] = useState<AppScreen>('roadmap');
  const [selectedTopic, setSelectedTopic] = useState<string | null>(null);
  const [quizScore, setQuizScore] = useState<number>(0);
  const [selectedChapter, setSelectedChapter] = useState<string | null>(null);
  const [quizStartTime, setQuizStartTime] = useState<number>(0);

  // Load progress on mount
  useEffect(() => {
    const saved = loadProgress();
    if (saved) {
      // Merge with defaults for new fields
      const mergedProgress: PlayerProgress = {
        ...saved,
        activeDeck: saved.activeDeck || [],
        achievements: saved.achievements || [],
        dungeonRun: saved.dungeonRun || null,
        stats: saved.stats || {
          totalStudyTime: 0,
          currentStreak: 0,
          longestStreak: 0,
          topicStats: []
        }
      };
      setProgress(mergedProgress);
      toast.success('Progress loaded!');
    }
  }, []);

  // Auto-save progress whenever it changes
  useEffect(() => {
    saveProgress(progress);
  }, [progress]);

  const handleTopicSelect = (topicId: string) => {
    const topic = topics.find(t => t.id === topicId);
    if (!topic) return;

    // Check if already completed - allow viewing but show it's completed
    if (progress.completedTopics.includes(topicId)) {
      setSelectedTopic(topicId);
      setCurrentScreen('topic-detail');
      return;
    }

    // Check if locked
    if (topic.parentId) {
      const parent = topics.find(t => t.id === topic.parentId);
      if (parent && !progress.completedTopics.includes(parent.id)) {
        toast.error('Complete the prerequisite topic first!');
        return;
      }
    }

    setSelectedTopic(topicId);
    setProgress(prev => ({
      ...prev,
      currentTopic: topicId
    }));
    setCurrentScreen('topic-detail');
  };

  const handleStartQuiz = () => {
    setQuizStartTime(Date.now());
    setCurrentScreen('quiz');
  };

  const handleQuizComplete = (passed: boolean, score: number) => {
    if (!selectedTopic) return;

    const timeSpent = Math.floor((Date.now() - quizStartTime) / 60000); // minutes
    const topic = topics.find(t => t.id === selectedTopic);

    // Update topic stats
    const existingStatIndex = progress.stats.topicStats.findIndex(s => s.topicId === selectedTopic);
    const quiz = quizzes.find(q => q.topicId === selectedTopic);
    const totalQuestions = quiz?.questions.length || 0;
    const correctAnswers = Math.round((score / 100) * totalQuestions);

    let newTopicStats = [...progress.stats.topicStats];
    if (existingStatIndex >= 0) {
      const existingStat = newTopicStats[existingStatIndex];
      newTopicStats[existingStatIndex] = {
        ...existingStat,
        attempts: existingStat.attempts + 1,
        correctAnswers: existingStat.correctAnswers + correctAnswers,
        totalAnswers: existingStat.totalAnswers + totalQuestions,
        averageTime: (existingStat.averageTime * existingStat.attempts + timeSpent) / (existingStat.attempts + 1),
        lastAttempt: new Date()
      };
    } else {
      newTopicStats.push({
        topicId: selectedTopic,
        attempts: 1,
        correctAnswers,
        totalAnswers: totalQuestions,
        averageTime: timeSpent,
        lastAttempt: new Date()
      });
    }

    if (passed) {
      setQuizScore(score);
      setProgress(prev => ({
        ...prev,
        stats: {
          ...prev.stats,
          totalStudyTime: prev.stats.totalStudyTime + timeSpent,
          currentStreak: prev.stats.currentStreak + 1,
          longestStreak: Math.max(prev.stats.longestStreak, prev.stats.currentStreak + 1),
          topicStats: newTopicStats
        }
      }));
      setCurrentScreen('reward-selection');
      toast.success(`Quiz passed with ${score.toFixed(0)}%!`);
    } else {
      setProgress(prev => ({
        ...prev,
        currentTopic: null,
        stats: {
          ...prev.stats,
          totalStudyTime: prev.stats.totalStudyTime + timeSpent,
          topicStats: newTopicStats
        }
      }));
      setCurrentScreen('roadmap');
      setSelectedTopic(null);
      toast.error(`Quiz failed. You need 80% to pass.`);
    }
  };

  const handleRewardSelect = (rewardId: string) => {
    if (!selectedTopic) return;

    const reward = rewards.find(r => r.id === rewardId);
    if (!reward) return;

    setProgress(prev => ({
      ...prev,
      completedTopics: [...prev.completedTopics, selectedTopic],
      inventory: [...prev.inventory, rewardId],
      currentTopic: null
    }));

    toast.success(`${reward.name} added to inventory!`);
    setCurrentScreen('roadmap');
    setSelectedTopic(null);
  };

  const handleStartBossFight = (chapterId: string) => {
    const chapter = chapters.find(c => c.id === chapterId);
    if (!chapter) return;

    // Check if all required topics are completed
    const requiredTopics = topics.filter(
      t => t.chapterId === chapterId && t.type === 'required'
    );
    const allCompleted = requiredTopics.every(t => 
      progress.completedTopics.includes(t.id)
    );

    if (!allCompleted) {
      toast.error('Complete all required topics first!');
      return;
    }

    if (progress.activeDeck.length === 0) {
      toast.error('Build a deck before fighting the boss!');
      return;
    }

    // Check if already defeated
    if (progress.chapterProgress[chapterId]?.defeated) {
      toast.info('Boss already defeated!');
      return;
    }

    // Initialize chapter progress if not exists
    if (!progress.chapterProgress[chapterId]) {
      setProgress(prev => ({
        ...prev,
        chapterProgress: {
          ...prev.chapterProgress,
          [chapterId]: {
            bossHp: chapter.bossHp,
            defeated: false
          }
        }
      }));
    }

    setSelectedChapter(chapterId);
    setCurrentScreen('boss-fight');
  };

  const handleBossVictory = () => {
    if (!selectedChapter) return;

    setProgress(prev => ({
      ...prev,
      chapterProgress: {
        ...prev.chapterProgress,
        [selectedChapter]: {
          bossHp: 0,
          defeated: true
        }
      }
    }));

    toast.success('Boss defeated! Chapter completed!');
    setCurrentScreen('roadmap');
    setSelectedChapter(null);
  };

  const handleBossDefeat = () => {
    toast.error('You were defeated. Build your deck and try again!');
    setCurrentScreen('roadmap');
    setSelectedChapter(null);
  };

  const handleBossHpChange = (hp: number) => {
    if (!selectedChapter) return;
    
    setProgress(prev => ({
      ...prev,
      chapterProgress: {
        ...prev.chapterProgress,
        [selectedChapter]: {
          ...prev.chapterProgress[selectedChapter],
          bossHp: hp
        }
      }
    }));
  };

  const handleDeckUpdate = (deckIds: string[]) => {
    setProgress(prev => ({
      ...prev,
      activeDeck: deckIds
    }));
    toast.success('Deck updated!');
  };

  const handleStartDungeonRun = () => {
    if (progress.dungeonRun && progress.dungeonRun.active) {
      toast.info('Continue your current dungeon run!');
      setCurrentScreen('dungeon-run');
      return;
    }

    const newRun = {
      id: Date.now().toString(),
      currentRoom: 0,
      totalRooms: 8,
      playerHp: 100,
      playerMana: 10,
      reputation: 0,
      events: [],
      active: true
    };

    setProgress(prev => ({
      ...prev,
      dungeonRun: newRun
    }));

    setCurrentScreen('dungeon-run');
    toast.success('Dungeon run started!');
  };

  const handleDungeonEventComplete = (consequence: any) => {
    if (!progress.dungeonRun) return;

    let updatedRun = { ...progress.dungeonRun };

    // Apply consequence
    switch (consequence.type) {
      case 'hp':
        updatedRun.playerHp = Math.min(100, Math.max(0, updatedRun.playerHp + consequence.value));
        break;
      case 'mana':
        updatedRun.playerMana = Math.min(10, updatedRun.playerMana + consequence.value);
        break;
      case 'card':
        // Add card to inventory
        setProgress(prev => ({
          ...prev,
          inventory: [...prev.inventory, consequence.value]
        }));
        toast.success('New card acquired!');
        break;
      case 'reputation':
        updatedRun.reputation += consequence.value;
        break;
    }

    updatedRun.currentRoom += 1;

    setProgress(prev => ({
      ...prev,
      dungeonRun: updatedRun
    }));
  };

  const handleDungeonRunComplete = () => {
    if (!progress.dungeonRun) return;

    setProgress(prev => ({
      ...prev,
      dungeonRun: {
        ...prev.dungeonRun!,
        active: false,
        completedAt: new Date()
      }
    }));

    toast.success('Dungeon run completed!');
    setTimeout(() => {
      setCurrentScreen('roadmap');
    }, 2000);
  };

  const handleAbandonDungeon = () => {
    setProgress(prev => ({
      ...prev,
      dungeonRun: null
    }));
    setCurrentScreen('roadmap');
    toast.info('Dungeon run abandoned');
  };

  const handleReset = () => {
    resetProgress();
    setProgress({
      completedTopics: [],
      currentTopic: null,
      inventory: [],
      activeDeck: [],
      chapterProgress: {},
      achievements: [],
      dungeonRun: null,
      stats: {
        totalStudyTime: 0,
        currentStreak: 0,
        longestStreak: 0,
        topicStats: []
      }
    });
    setCurrentScreen('roadmap');
    setSelectedTopic(null);
    setSelectedChapter(null);
    toast.success('Progress reset!');
  };

  const currentTopic = selectedTopic ? topics.find(t => t.id === selectedTopic) : null;
  const currentQuiz = selectedTopic ? quizzes.find(q => q.topicId === selectedTopic) : null;
  const currentChapter = selectedChapter ? chapters.find(c => c.id === selectedChapter) : null;
  const currentBossQuestions = selectedChapter ? bossQuestions[selectedChapter] : [];

  const playerInventoryRewards = progress.inventory.map(rewardId => 
    typeof rewardId === 'string' 
      ? rewards.find(r => r.id === rewardId)! 
      : rewardId
  ).filter(Boolean);

  const activeDeckRewards = progress.activeDeck.map(rewardId => 
    rewards.find(r => r.id === rewardId)!
  ).filter(Boolean);

  const getChapterCompletion = (chapterId: string) => {
    const chapterTopics = topics.filter(
      t => t.chapterId === chapterId && t.type === 'required'
    );
    const completed = chapterTopics.filter(t => 
      progress.completedTopics.includes(t.id)
    ).length;
    return {
      completed,
      total: chapterTopics.length,
      percentage: (completed / chapterTopics.length) * 100
    };
  };

  const requiredTopicsCount = topics.filter(t => t.type === 'required').length;

  return (
    <div className="min-h-screen bg-gray-50">
      <Toaster />
      
      <header className="bg-white border-b border-gray-200 p-4 sticky top-0 z-10">
        <div className="max-w-7xl mx-auto flex items-center justify-between">
          <div className="flex items-center gap-3">
            <BookOpen className="w-8 h-8 text-blue-600" />
            <div>
              <h1>Dart Quest</h1>
              <p className="text-sm text-gray-600">Learn Dart through gamified challenges</p>
            </div>
          </div>
          
          <div className="flex items-center gap-4">
            <div className="flex items-center gap-2">
              <Trophy className="w-5 h-5 text-yellow-500" />
              <span className="text-sm">
                {progress.completedTopics.length} / {requiredTopicsCount} Required Topics
              </span>
            </div>
            
            <AlertDialog>
              <AlertDialogTrigger asChild>
                <Button variant="outline" size="sm">
                  <RotateCcw className="w-4 h-4 mr-2" />
                  Reset
                </Button>
              </AlertDialogTrigger>
              <AlertDialogContent>
                <AlertDialogHeader>
                  <AlertDialogTitle>Reset Progress?</AlertDialogTitle>
                  <AlertDialogDescription>
                    This will delete all your completed topics, inventory, and boss progress. This action cannot be undone.
                  </AlertDialogDescription>
                </AlertDialogHeader>
                <AlertDialogFooter>
                  <AlertDialogCancel>Cancel</AlertDialogCancel>
                  <AlertDialogAction onClick={handleReset}>
                    Reset Everything
                  </AlertDialogAction>
                </AlertDialogFooter>
              </AlertDialogContent>
            </AlertDialog>
          </div>
        </div>
      </header>

      <main className="max-w-7xl mx-auto p-6">
        {currentScreen === 'roadmap' && (
          <Tabs defaultValue="roadmap" className="w-full">
            <TabsList className="grid w-full max-w-2xl grid-cols-5 mb-6">
              <TabsTrigger value="roadmap">Roadmap</TabsTrigger>
              <TabsTrigger value="inventory">Deck</TabsTrigger>
              <TabsTrigger value="bosses">Bosses</TabsTrigger>
              <TabsTrigger value="dungeon">Dungeon</TabsTrigger>
              <TabsTrigger value="stats">Stats</TabsTrigger>
            </TabsList>

            <TabsContent value="roadmap">
              <RoadmapTree
                topics={topics}
                completedTopics={progress.completedTopics}
                currentTopic={progress.currentTopic}
                onTopicSelect={handleTopicSelect}
              />
            </TabsContent>

            <TabsContent value="inventory">
              <div className="space-y-6">
                <Card className="p-6">
                  <div className="flex items-center justify-between mb-4">
                    <div>
                      <h3 className="mb-1">Active Deck</h3>
                      <p className="text-sm text-gray-600">
                        {progress.activeDeck.length} / 12 cards selected
                      </p>
                    </div>
                    <Button onClick={() => setCurrentScreen('deck-builder')}>
                      <Package className="w-4 h-4 mr-2" />
                      Manage Deck
                    </Button>
                  </div>
                  {activeDeckRewards.length > 0 ? (
                    <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4">
                      {activeDeckRewards.map((reward, index) => (
                        <Card key={`${reward.id}-${index}`} className="p-3 text-center border-blue-300">
                          <p className="text-sm mb-1">{reward.name}</p>
                          <Badge variant="outline" className="text-xs">
                            {reward.manaCost} Mana
                          </Badge>
                        </Card>
                      ))}
                    </div>
                  ) : (
                    <p className="text-center text-gray-500 py-8">No cards in active deck</p>
                  )}
                </Card>

                <div>
                  <h3 className="mb-4">Full Collection</h3>
                  <InventoryPanel inventory={playerInventoryRewards} />
                </div>
              </div>
            </TabsContent>

            <TabsContent value="bosses">
              <div className="space-y-6">
                <div>
                  <h2 className="mb-2">Chapter Bosses</h2>
                  <p className="text-gray-600 mb-6">
                    Complete all required topics in a chapter to unlock its boss fight!
                  </p>
                </div>

                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                  {chapters.map(chapter => {
                    const completion = getChapterCompletion(chapter.id);
                    const isDefeated = progress.chapterProgress[chapter.id]?.defeated;
                    const canFight = completion.percentage === 100 && !isDefeated && progress.activeDeck.length > 0;

                    return (
                      <Card key={chapter.id} className="p-6">
                        <div className="mb-4">
                          <div className="flex items-start justify-between mb-2">
                            <h3>{chapter.title}</h3>
                            {isDefeated && (
                              <Badge variant="default" className="bg-green-500">
                                ✓ Defeated
                              </Badge>
                            )}
                          </div>
                          <p className="text-sm text-gray-600 mb-4">{chapter.description}</p>
                        </div>

                        <div className="mb-4">
                          <div className="flex items-center justify-between text-sm mb-2">
                            <span>Boss: {chapter.bossName}</span>
                            <span>{chapter.bossHp} HP</span>
                          </div>
                          <div className="flex items-center justify-between text-sm text-gray-600">
                            <span>Topics Completed</span>
                            <span>{completion.completed} / {completion.total}</span>
                          </div>
                          <div className="w-full bg-gray-200 rounded-full h-2 mt-2">
                            <div
                              className="bg-blue-500 h-2 rounded-full transition-all"
                              style={{ width: `${completion.percentage}%` }}
                            />
                          </div>
                        </div>

                        <Button
                          className="w-full"
                          onClick={() => handleStartBossFight(chapter.id)}
                          disabled={!canFight}
                        >
                          {isDefeated ? 'Already Defeated' : canFight ? 'Fight Boss' : progress.activeDeck.length === 0 ? 'Build Deck First' : 'Complete Topics First'}
                        </Button>
                      </Card>
                    );
                  })}
                </div>
              </div>
            </TabsContent>

            <TabsContent value="dungeon">
              <div className="space-y-6">
                <div>
                  <h2 className="mb-2">Dungeon Run</h2>
                  <p className="text-gray-600 mb-6">
                    Navigate procedurally generated rooms with random events and choices!
                  </p>
                </div>

                <Card className="p-6">
                  {progress.dungeonRun && progress.dungeonRun.active ? (
                    <div>
                      <div className="flex items-center justify-between mb-4">
                        <div>
                          <h3 className="mb-1">Run in Progress</h3>
                          <p className="text-sm text-gray-600">
                            Room {progress.dungeonRun.currentRoom} / {progress.dungeonRun.totalRooms}
                          </p>
                        </div>
                        <Button onClick={() => setCurrentScreen('dungeon-run')}>
                          Continue Run
                        </Button>
                      </div>
                      <div className="grid grid-cols-3 gap-4">
                        <div>
                          <p className="text-sm text-gray-600">HP</p>
                          <p>{progress.dungeonRun.playerHp} / 100</p>
                        </div>
                        <div>
                          <p className="text-sm text-gray-600">Mana</p>
                          <p>{progress.dungeonRun.playerMana} / 10</p>
                        </div>
                        <div>
                          <p className="text-sm text-gray-600">Reputation</p>
                          <p>{progress.dungeonRun.reputation}</p>
                        </div>
                      </div>
                    </div>
                  ) : (
                    <div className="text-center py-8">
                      <Map className="w-16 h-16 mx-auto mb-4 text-gray-400" />
                      <h3 className="mb-2">No Active Run</h3>
                      <p className="text-gray-600 mb-4">
                        Start a new dungeon run to explore and earn rewards!
                      </p>
                      <Button onClick={handleStartDungeonRun}>
                        <Map className="w-4 h-4 mr-2" />
                        Start New Run
                      </Button>
                    </div>
                  )}
                </Card>
              </div>
            </TabsContent>

            <TabsContent value="stats">
              <StatsDashboard
                totalStudyTime={progress.stats.totalStudyTime}
                currentStreak={progress.stats.currentStreak}
                longestStreak={progress.stats.longestStreak}
                topicStats={progress.stats.topicStats}
                completedTopics={progress.completedTopics.length}
                totalTopics={requiredTopicsCount}
              />
            </TabsContent>
          </Tabs>
        )}

        {currentScreen === 'topic-detail' && currentTopic && (
          <TopicDetail
            topic={currentTopic}
            isCompleted={progress.completedTopics.includes(currentTopic.id)}
            onStartQuiz={handleStartQuiz}
            onBack={() => {
              setCurrentScreen('roadmap');
              setSelectedTopic(null);
            }}
          />
        )}

        {currentScreen === 'quiz' && currentTopic && currentQuiz && (
          <div>
            <Button
              variant="outline"
              onClick={() => setCurrentScreen('topic-detail')}
              className="mb-6"
            >
              ← Back
            </Button>
            
            <TopicQuiz
              quiz={currentQuiz}
              topicTitle={currentTopic.title}
              onComplete={handleQuizComplete}
              onCancel={() => {
                setCurrentScreen('topic-detail');
                setProgress(prev => ({
                  ...prev,
                  currentTopic: null
                }));
              }}
            />
          </div>
        )}

        {currentScreen === 'reward-selection' && currentTopic && (
          <RewardSelection
            availableRewards={rewards}
            onRewardSelect={handleRewardSelect}
            topicTitle={currentTopic.title}
          />
        )}

        {currentScreen === 'boss-fight' && currentChapter && (
          <div>
            <Button
              variant="outline"
              onClick={() => {
                setCurrentScreen('roadmap');
                setSelectedChapter(null);
              }}
              className="mb-6"
            >
              ← Retreat
            </Button>
            
            <BossFight
              chapter={currentChapter}
              questions={currentBossQuestions}
              playerInventory={activeDeckRewards}
              initialBossHp={progress.chapterProgress[currentChapter.id]?.bossHp || currentChapter.bossHp}
              onVictory={handleBossVictory}
              onDefeat={handleBossDefeat}
              onBossHpChange={handleBossHpChange}
            />
          </div>
        )}

        {currentScreen === 'deck-builder' && (
          <DeckBuilder
            inventory={playerInventoryRewards}
            activeDeck={progress.activeDeck}
            maxDeckSize={12}
            onDeckUpdate={handleDeckUpdate}
            onClose={() => setCurrentScreen('roadmap')}
          />
        )}

        {currentScreen === 'dungeon-run' && progress.dungeonRun && (
          <DungeonRun
            dungeonRun={progress.dungeonRun}
            onEventComplete={handleDungeonEventComplete}
            onRunComplete={handleDungeonRunComplete}
            onAbandon={handleAbandonDungeon}
          />
        )}
      </main>
    </div>
  );
}
