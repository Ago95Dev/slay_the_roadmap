import { RunHistory } from '../types';
import { Card } from './ui/card';
import { Badge } from './ui/badge';
import { Trophy, Skull, Clock, TrendingUp, Award } from 'lucide-react';

interface RunHistoryPanelProps {
  runHistory: RunHistory[];
}

export function RunHistoryPanel({ runHistory }: RunHistoryPanelProps) {
  const sortedRuns = [...runHistory].sort((a, b) => 
    new Date(b.completedAt).getTime() - new Date(a.completedAt).getTime()
  );

  const stats = {
    totalRuns: runHistory.length,
    victories: runHistory.filter(r => r.victory).length,
    defeats: runHistory.filter(r => !r.victory).length,
    highestFloor: Math.max(...runHistory.map(r => r.floor), 0),
    highestScore: Math.max(...runHistory.map(r => r.finalScore), 0),
    totalElites: runHistory.reduce((sum, r) => sum + r.elitesDefeated, 0),
    totalBosses: runHistory.reduce((sum, r) => sum + r.bossesDefeated, 0)
  };

  const winRate = stats.totalRuns > 0 
    ? ((stats.victories / stats.totalRuns) * 100).toFixed(1) 
    : '0';

  const formatDuration = (minutes: number) => {
    if (minutes < 60) return `${minutes}m`;
    const hours = Math.floor(minutes / 60);
    const mins = minutes % 60;
    return `${hours}h ${mins}m`;
  };

  const formatDate = (date: Date) => {
    return new Date(date).toLocaleDateString('en-US', { 
      month: 'short', 
      day: 'numeric', 
      hour: '2-digit', 
      minute: '2-digit' 
    });
  };

  if (runHistory.length === 0) {
    return (
      <Card className="p-12 text-center">
        <Trophy className="w-12 h-12 mx-auto mb-3 text-gray-400" />
        <h3 className="mb-2">No Runs Yet</h3>
        <p className="text-gray-600">
          Complete your first dungeon run to start building your history!
        </p>
      </Card>
    );
  }

  return (
    <div className="space-y-6">
      {/* Overall Stats */}
      <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
        <Card className="p-4">
          <div className="flex items-center justify-between mb-1">
            <span className="text-sm text-gray-600">Total Runs</span>
            <TrendingUp className="w-4 h-4 text-blue-500" />
          </div>
          <p className="text-2xl">{stats.totalRuns}</p>
        </Card>

        <Card className="p-4">
          <div className="flex items-center justify-between mb-1">
            <span className="text-sm text-gray-600">Win Rate</span>
            <Trophy className="w-4 h-4 text-yellow-500" />
          </div>
          <p className="text-2xl">{winRate}%</p>
          <p className="text-xs text-gray-500">{stats.victories}W - {stats.defeats}L</p>
        </Card>

        <Card className="p-4">
          <div className="flex items-center justify-between mb-1">
            <span className="text-sm text-gray-600">Highest Floor</span>
            <Award className="w-4 h-4 text-purple-500" />
          </div>
          <p className="text-2xl">{stats.highestFloor}</p>
        </Card>

        <Card className="p-4">
          <div className="flex items-center justify-between mb-1">
            <span className="text-sm text-gray-600">High Score</span>
            <Trophy className="w-4 h-4 text-green-500" />
          </div>
          <p className="text-2xl">{stats.highestScore}</p>
        </Card>
      </div>

      {/* Run History */}
      <div>
        <h3 className="mb-4">Recent Runs</h3>
        <div className="space-y-3">
          {sortedRuns.slice(0, 10).map((run) => (
            <Card 
              key={run.id} 
              className={`p-4 ${run.victory ? 'border-l-4 border-green-500' : 'border-l-4 border-red-500'}`}
            >
              <div className="flex items-start justify-between">
                <div className="flex-1">
                  <div className="flex items-center gap-2 mb-2">
                    {run.victory ? (
                      <Trophy className="w-5 h-5 text-green-600" />
                    ) : (
                      <Skull className="w-5 h-5 text-red-600" />
                    )}
                    <span className="font-medium">
                      {run.victory ? 'Victory' : 'Defeat'}
                    </span>
                    <Badge variant="outline" className="text-xs">
                      Floor {run.floor}
                    </Badge>
                    {run.ascensionLevel > 0 && (
                      <Badge variant="secondary" className="text-xs">
                        A{run.ascensionLevel}
                      </Badge>
                    )}
                  </div>

                  <div className="grid grid-cols-2 md:grid-cols-4 gap-4 text-sm">
                    <div>
                      <p className="text-xs text-gray-600">Score</p>
                      <p className="font-medium">{run.finalScore}</p>
                    </div>
                    <div>
                      <p className="text-xs text-gray-600">Cards</p>
                      <p className="font-medium">{run.cardsCollected}</p>
                    </div>
                    <div>
                      <p className="text-xs text-gray-600">Elites</p>
                      <p className="font-medium">{run.elitesDefeated}</p>
                    </div>
                    <div>
                      <p className="text-xs text-gray-600">Bosses</p>
                      <p className="font-medium">{run.bossesDefeated}</p>
                    </div>
                  </div>
                </div>

                <div className="text-right text-sm">
                  <div className="flex items-center gap-1 text-gray-600 mb-1">
                    <Clock className="w-3 h-3" />
                    <span>{formatDuration(run.duration)}</span>
                  </div>
                  <p className="text-xs text-gray-500">
                    {formatDate(run.completedAt)}
                  </p>
                </div>
              </div>
            </Card>
          ))}
        </div>
      </div>

      {/* Additional Stats */}
      <Card className="p-6">
        <h4 className="mb-4">Combat Statistics</h4>
        <div className="grid grid-cols-2 gap-4 text-sm">
          <div>
            <p className="text-gray-600 mb-1">Total Elites Defeated</p>
            <p className="text-xl">{stats.totalElites}</p>
          </div>
          <div>
            <p className="text-gray-600 mb-1">Total Bosses Defeated</p>
            <p className="text-xl">{stats.totalBosses}</p>
          </div>
        </div>
      </Card>
    </div>
  );
}
