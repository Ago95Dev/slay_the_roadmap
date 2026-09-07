import { useState } from 'react';
import { ChevronRight, ChevronDown, Lock, CheckCircle2, Circle, Star } from 'lucide-react';
import { Topic, TopicStatus } from '../types';
import { Badge } from './ui/badge';
import { Button } from './ui/button';

interface RoadmapTreeProps {
  topics: Topic[];
  completedTopics: string[];
  currentTopic: string | null;
  onTopicSelect: (topicId: string) => void;
}

export function RoadmapTree({ topics, completedTopics, currentTopic, onTopicSelect }: RoadmapTreeProps) {
  const [expandedTopics, setExpandedTopics] = useState<Set<string>>(new Set(['dart-basics', 'control-flow', 'oop']));

  const getTopicStatus = (topic: Topic): TopicStatus => {
    if (completedTopics.includes(topic.id)) {
      return 'completed';
    }
    
    if (currentTopic === topic.id) {
      return 'in-progress';
    }

    // Check if prerequisites are met
    if (topic.parentId) {
      const parent = topics.find(t => t.id === topic.parentId);
      if (parent && !completedTopics.includes(parent.id)) {
        return 'locked';
      }
    }

    return 'available';
  };

  const toggleExpand = (topicId: string) => {
    const newExpanded = new Set(expandedTopics);
    if (newExpanded.has(topicId)) {
      newExpanded.delete(topicId);
    } else {
      newExpanded.add(topicId);
    }
    setExpandedTopics(newExpanded);
  };

  const renderTopic = (topic: Topic, level: number = 0) => {
    const status = getTopicStatus(topic);
    const hasChildren = topic.children.length > 0;
    const isExpanded = expandedTopics.has(topic.id);
    const isLocked = status === 'locked';

    const statusIcon = {
      'locked': <Lock className="w-4 h-4 text-gray-400" />,
      'available': <Circle className="w-4 h-4 text-blue-500" />,
      'in-progress': <Circle className="w-4 h-4 text-yellow-500 fill-yellow-500" />,
      'completed': <CheckCircle2 className="w-4 h-4 text-green-500" />
    };

    return (
      <div key={topic.id} style={{ marginLeft: `${level * 24}px` }}>
        <div
          className={`
            flex items-center gap-2 p-3 rounded-lg mb-2 transition-colors
            ${isLocked ? 'opacity-50 cursor-not-allowed' : 'cursor-pointer hover:bg-gray-50'}
            ${currentTopic === topic.id ? 'bg-blue-50 border-2 border-blue-300' : 'border border-gray-200'}
          `}
          onClick={() => !isLocked && onTopicSelect(topic.id)}
        >
          {hasChildren && (
            <button
              onClick={(e) => {
                e.stopPropagation();
                toggleExpand(topic.id);
              }}
              className="p-1 hover:bg-gray-200 rounded"
            >
              {isExpanded ? <ChevronDown className="w-4 h-4" /> : <ChevronRight className="w-4 h-4" />}
            </button>
          )}
          {!hasChildren && <div className="w-6" />}
          
          <div className="flex-shrink-0">
            {statusIcon[status]}
          </div>

          <div className="flex-1 min-w-0">
            <div className="flex items-center gap-2">
              <span className={`${isLocked ? 'text-gray-400' : ''}`}>
                {topic.title}
              </span>
              {topic.type === 'optional' && (
                <Badge variant="outline" className="text-xs">
                  <Star className="w-3 h-3 mr-1" />
                  Optional
                </Badge>
              )}
            </div>
            <p className="text-sm text-gray-500 truncate">{topic.description}</p>
          </div>

          {status === 'completed' && (
            <Badge variant="default" className="bg-green-500">
              Completed
            </Badge>
          )}
        </div>

        {hasChildren && isExpanded && (
          <div>
            {topic.children.map(childId => {
              const childTopic = topics.find(t => t.id === childId);
              return childTopic ? renderTopic(childTopic, level + 1) : null;
            })}
          </div>
        )}
      </div>
    );
  };

  const rootTopics = topics.filter(t => t.parentId === null);

  return (
    <div className="space-y-2">
      <div className="mb-4">
        <h2 className="mb-2">Dart Learning Roadmap</h2>
        <p className="text-gray-600">
          Complete topics to unlock new content and earn rewards for boss fights!
        </p>
      </div>
      
      <div className="space-y-1">
        {rootTopics.map(topic => renderTopic(topic))}
      </div>
    </div>
  );
}
