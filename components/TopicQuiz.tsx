import { useState } from 'react';
import { Quiz, Question } from '../types';
import { Card } from './ui/card';
import { Button } from './ui/button';
import { Badge } from './ui/badge';
import { CheckCircle2, XCircle, Trophy } from 'lucide-react';
import { motion } from 'motion/react';

interface TopicQuizProps {
  quiz: Quiz;
  topicTitle: string;
  onComplete: (passed: boolean, score: number) => void;
  onCancel: () => void;
}

export function TopicQuiz({ quiz, topicTitle, onComplete, onCancel }: TopicQuizProps) {
  const [currentQuestionIndex, setCurrentQuestionIndex] = useState(0);
  const [selectedAnswer, setSelectedAnswer] = useState<number | null>(null);
  const [showFeedback, setShowFeedback] = useState(false);
  const [correctAnswers, setCorrectAnswers] = useState(0);
  const [isComplete, setIsComplete] = useState(false);

  const currentQuestion = quiz.questions[currentQuestionIndex];
  const totalQuestions = quiz.questions.length;
  const isLastQuestion = currentQuestionIndex === totalQuestions - 1;

  const handleAnswerSelect = (answerIndex: number) => {
    if (showFeedback) return;
    setSelectedAnswer(answerIndex);
  };

  const handleSubmitAnswer = () => {
    if (selectedAnswer === null) return;
    
    setShowFeedback(true);
    
    if (selectedAnswer === currentQuestion.correctAnswer) {
      setCorrectAnswers(prev => prev + 1);
    }
  };

  const handleNext = () => {
    if (isLastQuestion) {
      const finalScore = selectedAnswer === currentQuestion.correctAnswer 
        ? correctAnswers + 1 
        : correctAnswers;
      const scorePercentage = (finalScore / totalQuestions) * 100;
      const passed = scorePercentage >= 80;
      
      setIsComplete(true);
      setTimeout(() => {
        onComplete(passed, scorePercentage);
      }, 2000);
    } else {
      setCurrentQuestionIndex(prev => prev + 1);
      setSelectedAnswer(null);
      setShowFeedback(false);
    }
  };

  const scorePercentage = ((correctAnswers + (selectedAnswer === currentQuestion.correctAnswer && showFeedback ? 1 : 0)) / totalQuestions) * 100;

  if (isComplete) {
    const passed = scorePercentage >= 80;
    return (
      <motion.div
        initial={{ scale: 0.8, opacity: 0 }}
        animate={{ scale: 1, opacity: 1 }}
        className="flex items-center justify-center min-h-[400px]"
      >
        <Card className="p-8 text-center max-w-md">
          {passed ? (
            <>
              <Trophy className="w-16 h-16 mx-auto mb-4 text-yellow-500" />
              <h3 className="mb-2 text-green-600">Quiz Passed! 🎉</h3>
              <p className="text-gray-600 mb-4">
                You scored {scorePercentage.toFixed(0)}%
              </p>
              <p className="text-sm text-gray-500">
                Proceeding to reward selection...
              </p>
            </>
          ) : (
            <>
              <XCircle className="w-16 h-16 mx-auto mb-4 text-red-500" />
              <h3 className="mb-2 text-red-600">Quiz Failed</h3>
              <p className="text-gray-600 mb-4">
                You scored {scorePercentage.toFixed(0)}%. You need 80% to pass.
              </p>
              <p className="text-sm text-gray-500">
                Review the material and try again!
              </p>
            </>
          )}
        </Card>
      </motion.div>
    );
  }

  return (
    <div className="max-w-3xl mx-auto">
      <div className="mb-6">
        <div className="flex items-center justify-between mb-2">
          <h2>{topicTitle} Quiz</h2>
          <Badge>
            Question {currentQuestionIndex + 1} of {totalQuestions}
          </Badge>
        </div>
        <div className="w-full bg-gray-200 rounded-full h-2">
          <div
            className="bg-blue-500 h-2 rounded-full transition-all"
            style={{ width: `${((currentQuestionIndex + 1) / totalQuestions) * 100}%` }}
          />
        </div>
        <p className="text-sm text-gray-600 mt-2">
          Current Score: {correctAnswers} / {currentQuestionIndex + (showFeedback ? 1 : 0)} ({scorePercentage.toFixed(0)}%)
        </p>
      </div>

      <Card className="p-6 mb-6">
        <h3 className="mb-6">{currentQuestion.question}</h3>

        <div className="space-y-3">
          {currentQuestion.options.map((option, index) => {
            const isSelected = selectedAnswer === index;
            const isCorrect = index === currentQuestion.correctAnswer;
            const showCorrect = showFeedback && isCorrect;
            const showIncorrect = showFeedback && isSelected && !isCorrect;

            return (
              <button
                key={index}
                onClick={() => handleAnswerSelect(index)}
                disabled={showFeedback}
                className={`
                  w-full p-4 text-left border-2 rounded-lg transition-all
                  ${isSelected && !showFeedback ? 'border-blue-500 bg-blue-50' : 'border-gray-200'}
                  ${showCorrect ? 'border-green-500 bg-green-50' : ''}
                  ${showIncorrect ? 'border-red-500 bg-red-50' : ''}
                  ${!showFeedback ? 'hover:border-blue-300 cursor-pointer' : 'cursor-not-allowed'}
                `}
              >
                <div className="flex items-center justify-between">
                  <span>{option}</span>
                  {showCorrect && <CheckCircle2 className="w-5 h-5 text-green-500" />}
                  {showIncorrect && <XCircle className="w-5 h-5 text-red-500" />}
                </div>
              </button>
            );
          })}
        </div>

        {showFeedback && (
          <motion.div
            initial={{ opacity: 0, y: -10 }}
            animate={{ opacity: 1, y: 0 }}
            className={`mt-4 p-4 rounded-lg ${
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
      </Card>

      <div className="flex justify-between">
        <Button variant="outline" onClick={onCancel} disabled={showFeedback}>
          Cancel
        </Button>
        
        {!showFeedback ? (
          <Button onClick={handleSubmitAnswer} disabled={selectedAnswer === null}>
            Submit Answer
          </Button>
        ) : (
          <Button onClick={handleNext}>
            {isLastQuestion ? 'Finish Quiz' : 'Next Question'}
          </Button>
        )}
      </div>
    </div>
  );
}
