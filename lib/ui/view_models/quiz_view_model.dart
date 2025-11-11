import 'package:flutter/material.dart';
import '../../domain/models/quiz.dart';
import '../../data/repositories/quiz_repository.dart';

class QuizViewModel with ChangeNotifier {
  final QuizRepository _repository;
  
  Quiz? _currentQuiz;
  bool _isLoading = false;
  String? _error;
  int _currentQuestionIndex = 0;
  List<int?> _selectedAnswers = [];
  QuizResult? _quizResult;

  QuizViewModel(this._repository);

  Quiz? get currentQuiz => _currentQuiz;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get currentQuestionIndex => _currentQuestionIndex;
  List<int?> get selectedAnswers => _selectedAnswers;
  QuizResult? get quizResult => _quizResult;
  
  int get totalQuestions => _currentQuiz?.questions.length ?? 0;
  bool get isLastQuestion => _currentQuestionIndex >= totalQuestions - 1;
  bool get isQuizComplete => _quizResult != null;

  Future<void> loadQuiz(String topicId) async {
    _isLoading = true;
    _error = null;
    _currentQuiz = null;
    _currentQuestionIndex = 0;
    _selectedAnswers = [];
    _quizResult = null;
    notifyListeners();

    try {
      _currentQuiz = await _repository.getQuizForTopic(topicId);
      _selectedAnswers = List.filled(_currentQuiz!.questions.length, null);
      _error = null;
    } catch (e) {
      _error = 'Failed to load quiz: $e';
      print('Error loading quiz: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectAnswer(int answerIndex) {
    if (_currentQuiz == null) return;
    
    _selectedAnswers[_currentQuestionIndex] = answerIndex;
    notifyListeners();
  }

  void nextQuestion() {
    if (_currentQuiz == null || _currentQuestionIndex >= totalQuestions - 1) {
      return;
    }
    
    _currentQuestionIndex++;
    notifyListeners();
  }

  void previousQuestion() {
    if (_currentQuestionIndex <= 0) return;
    
    _currentQuestionIndex--;
    notifyListeners();
  }

  Future<void> submitQuiz() async {
    if (_currentQuiz == null) return;
    
    _isLoading = true;
    notifyListeners();

    try {
      // Filter out null answers (shouldn't happen if all questions are answered)
      final answers = _selectedAnswers.map((a) => a ?? 0).toList();
      _quizResult = await _repository.submitQuizAnswers(_currentQuiz!.id, answers);
      _error = null;
    } catch (e) {
      _error = 'Failed to submit quiz: $e';
      print('Error submitting quiz: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void restartQuiz() {
    _currentQuestionIndex = 0;
    _selectedAnswers = List.filled(_currentQuiz!.questions.length, null);
    _quizResult = null;
    notifyListeners();
  }

  bool isQuestionAnswered(int questionIndex) {
    return _selectedAnswers[questionIndex] != null;
  }

  bool isAnswerCorrect(int questionIndex, int answerIndex) {
    return _currentQuiz?.questions[questionIndex].correctAnswerIndex == answerIndex;
  }

  void retryLoading() {
    if (_currentQuiz != null) {
      loadQuiz(_currentQuiz!.topicId);
    }
  }
}
