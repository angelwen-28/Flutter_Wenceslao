import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:uuid/uuid.dart';
import '../models/student.dart';
import '../models/grade_entry.dart';
import '../models/todo_item.dart';
import '../services/database_service.dart';
import '../services/mock_database_service.dart';
import '../services/firebase_database_service.dart';

class AppStateProvider extends ChangeNotifier {
  DatabaseService _dbService = MockDatabaseService();
  bool _firebaseMode = false;

  // --- Settings State ---
  ThemeMode _themeMode = ThemeMode.dark;
  bool _studyReminders = true;

  Student? _currentStudent;
  List<GradeEntry> _grades = [];
  List<TodoItem> _todos = [];

  StreamSubscription? _studentSubscription;
  StreamSubscription? _gradesSubscription;
  StreamSubscription? _todosSubscription;

  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  DatabaseService get dbService => _dbService;
  bool get firebaseMode => _firebaseMode;
  ThemeMode get themeMode => _themeMode;
  bool get studyReminders => _studyReminders;
  Student? get currentStudent => _currentStudent;
  List<GradeEntry> get grades => _grades;
  List<TodoItem> get todos => _todos;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // --- Settings Setters ---
  void setThemeMode(ThemeMode mode) {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
  }

  void setStudyReminders(bool value) {
    if (_studyReminders == value) return;
    _studyReminders = value;
    notifyListeners();
  }

  AppStateProvider() {
    _initializeDatabase();
  }

  void _initializeDatabase() {
    try {
      Firebase.app();
      _dbService = FirebaseDatabaseService();
      _firebaseMode = true;
      debugPrint('AppStateProvider: Initialized in Firebase Mode');
    } catch (e) {
      _dbService = MockDatabaseService();
      _firebaseMode = false;
      debugPrint('AppStateProvider: Firebase not initialized. Initialized in Demo Mode (Mock DB)');
    }
  }

  // Set manual database mode (useful for testing or force demo mode)
  void setDatabaseMode(bool useFirebase) {
    if (useFirebase) {
      try {
        Firebase.app();
        _dbService = FirebaseDatabaseService();
        _firebaseMode = true;
      } catch (e) {
        _errorMessage = 'Firebase is not initialized. Cannot switch to Firebase Mode.';
        notifyListeners();
        return;
      }
    } else {
      _dbService = MockDatabaseService();
      _firebaseMode = false;
    }
    
    _errorMessage = null;
    if (_currentStudent != null) {
      // Re-login to load streams from the new DB service
      login(_currentStudent!.id, email: _currentStudent!.email);
    } else {
      notifyListeners();
    }
  }

  // Get all students for selection in the login screen (useful for demo mode)
  Future<List<Student>> getAvailableStudents() async {
    try {
      return await _dbService.getStudents();
    } catch (e) {
      debugPrint('Error getting students: $e');
      return [];
    }
  }

  // Student Login
  Future<bool> login(String studentId, {String? email}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    // Cancel any previous subscriptions
    await _cancelSubscriptions();

    try {
      // Get student profile stream
      final completer = Completer<Student?>();
      _studentSubscription = _dbService.getStudentStream(studentId).listen(
        (student) {
          _currentStudent = student;
          if (!completer.isCompleted) {
            completer.complete(student);
          }
          notifyListeners();
        },
        onError: (err) {
          if (!completer.isCompleted) {
            completer.completeError(err);
          }
          _errorMessage = 'Error loading student profile: $err';
          notifyListeners();
        }
      );

      final student = await completer.future.timeout(
        const Duration(seconds: 5),
        onTimeout: () => throw TimeoutException('Authentication timed out. Please try again.')
      );

      if (student == null) {
        _errorMessage = 'Student ID "$studentId" not found.';
        _currentStudent = null;
        _isLoading = false;
        await _cancelSubscriptions();
        notifyListeners();
        return false;
      }

      if (email != null && student.email.trim().toLowerCase() != email.trim().toLowerCase()) {
        _errorMessage = 'Incorrect email address for Student ID "$studentId".';
        _currentStudent = null;
        _isLoading = false;
        await _cancelSubscriptions();
        notifyListeners();
        return false;
      }

      // Load grades and todos streams
      _gradesSubscription = _dbService.getGradesStream(studentId).listen(
        (gradesList) {
          _grades = gradesList;
          notifyListeners();
        },
        onError: (err) {
          debugPrint('Grades Stream Error: $err');
        }
      );

      _todosSubscription = _dbService.getTodosStream(studentId).listen(
        (todosList) {
          _todos = todosList;
          notifyListeners();
        },
        onError: (err) {
          debugPrint('Todos Stream Error: $err');
        }
      );

      _isLoading = false;
      notifyListeners();
      return true;

    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _currentStudent = null;
      _isLoading = false;
      await _cancelSubscriptions();
      notifyListeners();
      return false;
    }
  }

  // Logout student
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    await _cancelSubscriptions();
    _currentStudent = null;
    _grades = [];
    _todos = [];
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _cancelSubscriptions() async {
    await _studentSubscription?.cancel();
    await _gradesSubscription?.cancel();
    await _todosSubscription?.cancel();
    _studentSubscription = null;
    _gradesSubscription = null;
    _todosSubscription = null;
  }

  @override
  void dispose() {
    _cancelSubscriptions();
    super.dispose();
  }

  // --- Grade Calculations ---

  // Calculated cumulative percentage for a specific category
  double? getCategoryPercentage(String category) {
    final catGrades = _grades.where((g) => g.category == category).toList();
    if (catGrades.isEmpty) return null;

    double earnedSum = 0;
    double maxSum = 0;
    for (final entry in catGrades) {
      earnedSum += entry.score;
      maxSum += entry.maxScore;
    }

    if (maxSum == 0) return 0.0;
    return (earnedSum / maxSum) * 100.0;
  }

  // List of all categories and their percentages (returns 0.0 for empty categories to draw in chart)
  Map<String, double> get categoryPercentages {
    final Map<String, double> result = {};
    const categories = [
      'Quizzes',
      'Activities',
      'Oral Recitations',
      'Term Exams',
      'Projects',
      'Attendance',
    ];
    for (final cat in categories) {
      result[cat] = getCategoryPercentage(cat) ?? 0.0;
    }
    return result;
  }

  // Calculated overall running grade (average of active categories)
  double get totalRunningGrade {
    const categories = [
      'Quizzes',
      'Activities',
      'Oral Recitations',
      'Term Exams',
      'Projects',
      'Attendance',
    ];

    double sum = 0.0;
    int count = 0;

    for (final cat in categories) {
      final percentage = getCategoryPercentage(cat);
      if (percentage != null) {
        sum += percentage;
        count++;
      }
    }

    if (count == 0) return 100.0; // Default when no items are graded yet
    return sum / count;
  }

  // --- To-Do Operations ---

  Future<void> addTodo(String title, String description, DateTime dueDate) async {
    if (_currentStudent == null) return;
    
    final newItem = TodoItem(
      id: const Uuid().v4(),
      studentId: _currentStudent!.id,
      title: title.trim(),
      description: description.trim(),
      dueDate: dueDate,
      isCompleted: false,
    );

    await _dbService.addTodoItem(newItem);
  }

  Future<void> toggleTodo(TodoItem item) async {
    if (_currentStudent == null) return;
    final updated = item.copyWith(isCompleted: !item.isCompleted);
    await _dbService.updateTodoItem(updated);
  }

  Future<void> deleteTodo(String itemId) async {
    if (_currentStudent == null) return;
    await _dbService.deleteTodoItem(_currentStudent!.id, itemId);
  }

  Future<void> editTodo(TodoItem item, String title, String description, DateTime dueDate) async {
    if (_currentStudent == null) return;
    final updated = item.copyWith(
      title: title.trim(),
      description: description.trim(),
      dueDate: dueDate,
    );
    await _dbService.updateTodoItem(updated);
  }

  // Get active (uncompleted) To-Dos sorted by closest deadline
  List<TodoItem> get uncompletedTodos {
    return _todos
        .where((t) => !t.isCompleted && t.dueDate.isAfter(DateTime.now()))
        .toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }

  // Get top 3 urgent tasks (uncompleted with closest deadlines)
  List<TodoItem> get urgentTodos {
    final list = uncompletedTodos;
    if (list.length > 3) {
      return list.sublist(0, 3);
    }
    return list;
  }
}
