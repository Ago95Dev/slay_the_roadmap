import { TopicStats } from '../types';
import { Card } from './ui/card';
import { Badge } from './ui/badge';
import { Progress } from './ui/progress';
import { TrendingUp, Clock, Target, Flame, Award, AlertCircle } from 'lucide-react';

interface StatsDashboardProps {
  totalStudyTime: number;
  currentStreak: number;
  longestStreak: number;
  topicStats: TopicStats[];
  completedTopics: number;
  totalTopics: number;
}

export function StatsDashboard({
  totalStudyTime,
  currentStreak,
  longestStreak,
  topicStats,
  completedTopics,
  totalTopics
}: StatsDashboardProps) {
  const formatTime = (minutes: number) => {
    if (minutes < 60) return `${minutes}m`;
    const hours = Math.floor(minutes / 60);
    const mins = minutes % 60;
    return `${hours}h ${mins}m`;
  };

  const overallAccuracy = topicStats.length > 0
    ? (topicStats.reduce((sum, stat) => sum + (stat.correctAnswers / stat.totalAnswers), 0) / topicStats.length) * 100
    : 0;

  const weakAreas = topicStats
    .filter(stat => stat.totalAnswers >= 3)
    .sort((a, b) => (a.correctAnswers / a.totalAnswers) - (b.correctAnswers / b.totalAnswers))
    .slice(0, 3);

  const strongAreas = topicStats
    .filter(stat => stat.totalAnswers >= 3)
    .sort((a, b) => (b.correctAnswers / b.totalAnswers) - (a.correctAnswers / a.totalAnswers))
    .slice(0, 3);

  return (
    <div className="space-y-6">
      <div>
        <h2 className="mb-2">Learning Statistics</h2>
        <p className="text-gray-600">Track your progress and identify areas for improvement</p>
      </div>

      {/* Key Metrics */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
        <Card className="p-6">
          <div className="flex items-center justify-between mb-2">
            <span className="text-sm text-gray-600">Study Time</span>
            <Clock className="w-5 h-5 text-blue-500" />
          </div>
          <p className="text-gray-900">{formatTime(totalStudyTime)}</p>
        </Card>

        <Card className="p-6">
          <div className="flex items-center justify-between mb-2">
            <span className="text-sm text-gray-600">Current Streak</span>
            <Flame className="w-5 h-5 text-orange-500" />
          </div>
          <p className="text-gray-900">{currentStreak} days</p>
        </Card>

        <Card className="p-6">
          <div className="flex items-center justify-between mb-2">
            <span className="text-sm text-gray-600">Overall Accuracy</span>
            <Target className="w-5 h-5 text-green-500" />
          </div>
          <p className="text-gray-900">{overallAccuracy.toFixed(1)}%</p>
        </Card>

        <Card className="p-6">
          <div className="flex items-center justify-between mb-2">
            <span className="text-sm text-gray-600">Completion</span>
            <Award className="w-5 h-5 text-purple-500" />
          </div>
          <p className="text-gray-900">{completedTopics} / {totalTopics}</p>
        </Card>
      </div>

      {/* Progress Overview */}
      <Card className="p-6">
        <h3 className="mb-4">Overall Progress</h3>
        <div className="space-y-4">
          <div>
            <div className="flex items-center justify-between mb-2">
              <span className="text-sm text-gray-600">Topics Completed</span>
              <span className="text-sm">{((completedTopics / totalTopics) * 100).toFixed(0)}%</span>
            </div>
            <Progress value={(completedTopics / totalTopics) * 100} className="h-2" />
          </div>

          <div className="grid grid-cols-2 gap-4 pt-4 border-t">
            <div>
              <p className="text-sm text-gray-600 mb-1">Longest Streak</p>
              <p className="text-gray-900">{longestStreak} days</p>
            </div>
            <div>
              <p className="text-sm text-gray-600 mb-1">Avg. Accuracy</p>
              <p className="text-gray-900">{overallAccuracy.toFixed(1)}%</p>
            </div>
          </div>
        </div>
      </Card>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Weak Areas */}
        <Card className="p-6">
          <div className="flex items-center gap-2 mb-4">
            <AlertCircle className="w-5 h-5 text-orange-500" />
            <h3>Areas to Improve</h3>
          </div>
          {weakAreas.length === 0 ? (
            <p className="text-sm text-gray-500">Complete more quizzes to see recommendations</p>
          ) : (
            <div className="space-y-3">
              {weakAreas.map(stat => {
                const accuracy = (stat.correctAnswers / stat.totalAnswers) * 100;
                return (
                  <div key={stat.topicId} className="border-l-4 border-orange-500 pl-3">
                    <div className="flex items-center justify-between mb-1">
                      <p className="text-sm">{stat.topicId}</p>
                      <Badge variant="outline" className="text-orange-600 border-orange-300">
                        {accuracy.toFixed(0)}%
                      </Badge>
                    </div>
                    <p className="text-xs text-gray-500">
                      {stat.correctAnswers}/{stat.totalAnswers} correct • Review recommended
                    </p>
                  </div>
                );
              })}
            </div>
          )}
        </Card>

        {/* Strong Areas */}
        <Card className="p-6">
          <div className="flex items-center gap-2 mb-4">
            <TrendingUp className="w-5 h-5 text-green-500" />
            <h3>Strengths</h3>
          </div>
          {strongAreas.length === 0 ? (
            <p className="text-sm text-gray-500">Complete more quizzes to see your strengths</p>
          ) : (
            <div className="space-y-3">
              {strongAreas.map(stat => {
                const accuracy = (stat.correctAnswers / stat.totalAnswers) * 100;
                return (
                  <div key={stat.topicId} className="border-l-4 border-green-500 pl-3">
                    <div className="flex items-center justify-between mb-1">
                      <p className="text-sm">{stat.topicId}</p>
                      <Badge variant="outline" className="text-green-600 border-green-300">
                        {accuracy.toFixed(0)}%
                      </Badge>
                    </div>
                    <p className="text-xs text-gray-500">
                      {stat.correctAnswers}/{stat.totalAnswers} correct • Excellent!
                    </p>
                  </div>
                );
              })}
            </div>
          )}
        </Card>
      </div>
    </div>
  );
}
