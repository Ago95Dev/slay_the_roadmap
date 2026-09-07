import { Topic } from '../types';
import { Card } from './ui/card';
import { Button } from './ui/button';
import { Badge } from './ui/badge';
import { Progress } from './ui/progress';
import { BookOpen, Video, FileText, ExternalLink, Play } from 'lucide-react';
import { Tabs, TabsContent, TabsList, TabsTrigger } from './ui/tabs';

interface TopicDetailProps {
  topic: Topic;
  isCompleted: boolean;
  onStartQuiz: () => void;
  onBack: () => void;
}

export function TopicDetail({ topic, isCompleted, onStartQuiz, onBack }: TopicDetailProps) {
  const resourceIcons = {
    article: FileText,
    video: Video,
    documentation: BookOpen
  };

  const groupedResources = {
    article: topic.resources.filter(r => r.type === 'article'),
    video: topic.resources.filter(r => r.type === 'video'),
    documentation: topic.resources.filter(r => r.type === 'documentation')
  };

  return (
    <div className="max-w-4xl mx-auto">
      <Button variant="outline" onClick={onBack} className="mb-6">
        ← Back to Roadmap
      </Button>

      <div className="mb-6">
        <div className="flex items-center justify-between mb-4">
          <div className="flex items-center gap-3">
            <h1>{topic.title}</h1>
            {isCompleted && (
              <Badge variant="default" className="bg-green-500">
                ✓ Completed
              </Badge>
            )}
            {topic.type === 'optional' && (
              <Badge variant="outline">Optional</Badge>
            )}
          </div>
        </div>

        <p className="text-gray-600 mb-4">{topic.description}</p>

        {isCompleted ? (
          <div className="flex items-center gap-2 text-green-600">
            <div className="w-full bg-green-100 rounded-full h-2">
              <div className="bg-green-500 h-2 rounded-full w-full" />
            </div>
            <span className="text-sm whitespace-nowrap">100%</span>
          </div>
        ) : (
          <div className="flex items-center gap-2 text-gray-600">
            <div className="w-full bg-gray-200 rounded-full h-2">
              <div className="bg-blue-500 h-2 rounded-full w-0" />
            </div>
            <span className="text-sm whitespace-nowrap">0%</span>
          </div>
        )}
      </div>

      <Tabs defaultValue="overview" className="mb-6">
        <TabsList className="grid w-full grid-cols-2">
          <TabsTrigger value="overview">Overview</TabsTrigger>
          <TabsTrigger value="resources">Learning Resources</TabsTrigger>
        </TabsList>

        <TabsContent value="overview" className="mt-6">
          <Card className="p-6">
            <h2 className="mb-4">What you'll learn</h2>
            <div className="prose prose-sm max-w-none">
              <p className="text-gray-700 whitespace-pre-line">
                {topic.detailedDescription}
              </p>
            </div>
          </Card>

          <Card className="p-6 mt-6 bg-blue-50 border-blue-200">
            <div className="flex items-center justify-between">
              <div>
                <h3 className="mb-2">Ready to test your knowledge?</h3>
                <p className="text-sm text-gray-600">
                  Complete the quiz with 80% or higher to unlock rewards and progress
                </p>
              </div>
              <Button size="lg" onClick={onStartQuiz} className="ml-4">
                <Play className="w-5 h-5 mr-2" />
                Start Quiz
              </Button>
            </div>
          </Card>
        </TabsContent>

        <TabsContent value="resources" className="mt-6">
          {topic.resources.length === 0 ? (
            <Card className="p-8 text-center">
              <BookOpen className="w-12 h-12 mx-auto mb-3 text-gray-400" />
              <p className="text-gray-500">No resources available yet</p>
            </Card>
          ) : (
            <div className="space-y-6">
              {Object.entries(groupedResources).map(([type, resources]) => {
                if (resources.length === 0) return null;
                const Icon = resourceIcons[type as keyof typeof resourceIcons];
                
                return (
                  <div key={type}>
                    <h3 className="mb-3 capitalize flex items-center gap-2">
                      <Icon className="w-5 h-5" />
                      {type === 'article' ? 'Articles' : type === 'video' ? 'Videos' : 'Documentation'}
                    </h3>
                    <div className="grid grid-cols-1 gap-3">
                      {resources.map((resource, index) => (
                        <Card key={index} className="p-4 hover:shadow-md transition-shadow">
                          <a
                            href={resource.url}
                            target="_blank"
                            rel="noopener noreferrer"
                            className="flex items-center justify-between group"
                          >
                            <div className="flex items-center gap-3">
                              <Icon className="w-5 h-5 text-gray-600" />
                              <span className="group-hover:text-blue-600 transition-colors">
                                {resource.title}
                              </span>
                            </div>
                            <ExternalLink className="w-4 h-4 text-gray-400 group-hover:text-blue-600 transition-colors" />
                          </a>
                        </Card>
                      ))}
                    </div>
                  </div>
                );
              })}
            </div>
          )}
        </TabsContent>
      </Tabs>
    </div>
  );
}
