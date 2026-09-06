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
  // Errori (tentativi errati) per indice domanda: dopo 2 errori
  // sulla stessa domanda la UI mostra `explanation` come hint.
  final Map<int, int> _wrongAttempts = {};

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

  /// Vera quando la domanda corrente ha una risposta selezionata.
  bool get canProceed {
    if (_currentQuiz == null) return false;
    if (_currentQuestionIndex < 0 ||
        _currentQuestionIndex >= _selectedAnswers.length) {
      return false;
    }
    return _selectedAnswers[_currentQuestionIndex] != null;
  }

  /// Vera quando tutte le domande hanno una risposta selezionata.
  bool get canSubmit {
    if (_currentQuiz == null || _selectedAnswers.isEmpty) return false;
    return !_selectedAnswers.contains(null);
  }

  /// Numero di tentativi errati per la domanda [questionIndex].
  int wrongAttemptsFor(int questionIndex) =>
      _wrongAttempts[questionIndex] ?? 0;

  /// Vera quando per la domanda [questionIndex] si sono accumulati
  /// almeno 2 errori: la UI deve mostrare l'hint.
  bool shouldShowHint(int questionIndex) =>
      wrongAttemptsFor(questionIndex) >= 2;

  bool get shouldShowHintForCurrent =>
      shouldShowHint(_currentQuestionIndex);

  /// Testo dell'hint per la domanda [questionIndex]: `explanation`
  /// della domanda, oppure un suggerimento generico se vuota.
  /// Ritorna null se l'hint non deve ancora essere mostrato.
  String? hintFor(int questionIndex) {
    if (!shouldShowHint(questionIndex)) return null;
    if (_currentQuiz == null ||
        questionIndex < 0 ||
        questionIndex >= _currentQuiz!.questions.length) {
      return null;
    }
    final explanation =
        _currentQuiz!.questions[questionIndex].explanation.trim();
    if (explanation.isEmpty) return 'Rileggi il topic e riprova.';
    return explanation;
  }

  String? get currentHint => hintFor(_currentQuestionIndex);

  Future<void> loadQuiz(String topicId) async {
    _isLoading = true;
    _error = null;
    _currentQuiz = null;
    _currentQuestionIndex = 0;
    _selectedAnswers = [];
    _quizResult = null;
    _wrongAttempts.clear();
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
    if (_currentQuestionIndex < 0 ||
        _currentQuestionIndex >= _selectedAnswers.length) {
      return;
    }

    _selectedAnswers[_currentQuestionIndex] = answerIndex;
    // Conta come errore ogni selezione diversa dalla corretta.
    final correct =
        _currentQuiz!.questions[_currentQuestionIndex].correctAnswerIndex;
    if (answerIndex != correct) {
      _wrongAttempts[_currentQuestionIndex] =
          wrongAttemptsFor(_currentQuestionIndex) + 1;
    }
    notifyListeners();
  }

  void nextQuestion() {
    if (_currentQuiz == null || _currentQuestionIndex >= totalQuestions - 1) {
      return;
    }
    // Blocco avanzamento senza risposta selezionata (l'UI tiene
    // il bottone Avanti disabilitato; questa è la guardia logica).
    if (!canProceed) return;

    // Azzera il contatore di errori della domanda lasciata.
    _wrongAttempts.remove(_currentQuestionIndex);
    _currentQuestionIndex++;
    notifyListeners();
  }

  void previousQuestion() {
    if (_currentQuestionIndex <= 0) return;

    // Azzera il contatore di errori della domanda lasciata.
    _wrongAttempts.remove(_currentQuestionIndex);
    _currentQuestionIndex--;
    notifyListeners();
  }

  Future<void> submitQuiz() async {
    if (_currentQuiz == null) return;
    // Blocco conclusione senza risposta su tutte le domande
    // (l'UI tiene il bottone Concludi disabilitato).
    if (!canSubmit) return;

    _isLoading = true;
    notifyListeners();

    try {
      // Guardia difensiva: a questo punto non ci sono null (canSubmit).
      // Se un null sfuggisse, -1 non corrisponde a nessun indice valido
      // (>= 0), quindi conta come risposta errata senza falsare l'opzione 0.
      final answers = _selectedAnswers.map((a) => a ?? -1).toList();
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
    _wrongAttempts.clear();
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
