import 'dart:async';
import '../models/student.dart';
import '../models/grade_entry.dart';
import '../models/todo_item.dart';
import 'database_service.dart';

class MockDatabaseService implements DatabaseService {
  // Local in-memory storage
  final List<Student> _students = [];
  final List<GradeEntry> _grades = [];
  final List<TodoItem> _todos = [];

  // Controllers to stream updates
  final _studentControllers = <String, StreamController<Student?>>{};
  final _gradeControllers = <String, StreamController<List<GradeEntry>>>{};
  final _todoControllers = <String, StreamController<List<TodoItem>>>{};

  MockDatabaseService() {
    _seedData();
  }

  void _seedData() {
    // 1. Seed Students
    _students.addAll([
      Student(
        id: '2023-6015',
        name: 'Angel Wenceslao',
        email: 'angelwenceslao@gmail.com',
      ),
      Student(id: 'STU001', name: 'John Doe', email: 'john.doe@class.com'),
      Student(id: 'STU002', name: 'Jane Smith', email: 'jane.smith@class.com'),
      Student(id: 'STU003', name: 'Alex Lee', email: 'alex.lee@class.com'),
    ]);

    // 2. Seed Grades
    final now = DateTime.now();

    // 2023-6015 - Angel Wenceslao (High Grades ~ 97%)
    _grades.addAll([
      // Quizzes
      GradeEntry(
        id: 'g0_1',
        studentId: '2023-6015',
        title: 'Quiz 1: Flutter Basics',
        category: 'Quizzes',
        score: 40,
        maxScore: 50,
        term: 'Prelim',
        dateGraded: now.subtract(const Duration(days: 20)),
      ),
      GradeEntry(
        id: 'g0_2',
        studentId: '2023-6015',
        title: 'Quiz 2: State Management',
        category: 'Quizzes',
        score: 88,
        maxScore: 100,
        term: 'Midterm',
        dateGraded: now.subtract(const Duration(days: 10)),
      ),
      GradeEntry(
        id: 'g0_3',
        studentId: '2023-6015',
        title: 'Quiz 3: Firebase Integration',
        category: 'Quizzes',
        score: 39,
        maxScore: 50,
        term: 'Final',
        dateGraded: now.subtract(const Duration(days: 2)),
      ),

      // Activities
      GradeEntry(
        id: 'g0_4',
        studentId: '2023-6015',
        title: 'Activity 1: UI Design',
        category: 'Activities',
        score: 20,
        maxScore: 20,
        term: 'Prelim',
        dateGraded: now.subtract(const Duration(days: 18)),
      ),
      GradeEntry(
        id: 'g0_5',
        studentId: '2023-6015',
        title: 'Activity 2: Navigation',
        category: 'Activities',
        score: 25,
        maxScore: 30,
        term: 'Midterm',
        dateGraded: now.subtract(const Duration(days: 12)),
      ),
      GradeEntry(
        id: 'g0_6',
        studentId: '2023-6015',
        title: 'Activity 3: Custom Painter',
        category: 'Activities',
        score: 40,
        maxScore: 50,
        term: 'Final',
        dateGraded: now.subtract(const Duration(days: 4)),
      ),

      // Oral Recitations (Capped at 50 max points)
      GradeEntry(
        id: 'g0_7',
        studentId: '2023-6015',
        title: 'Oral Recitation 1',
        category: 'Oral Recitations',
        score: 39,
        maxScore: 50,
        term: 'Prelim',
        dateGraded: now.subtract(const Duration(days: 15)),
      ),
      GradeEntry(
        id: 'g0_8',
        studentId: '2023-6015',
        title: 'Oral Recitation 2',
        category: 'Oral Recitations',
        score: 38,
        maxScore: 50,
        term: 'Final',
        dateGraded: now.subtract(const Duration(days: 3)),
      ),

      // Projects
      GradeEntry(
        id: 'g0_9',
        studentId: '2023-6015',
        title: 'Midterm Project: E-Commerce App',
        category: 'Projects',
        score: 85,
        maxScore: 100,
        term: 'Midterm',
        dateGraded: now.subtract(const Duration(days: 8)),
      ),
      GradeEntry(
        id: 'g0_10',
        studentId: '2023-6015',
        title: 'Final Project: Social Media App',
        category: 'Projects',
        score: 41,
        maxScore: 50,
        term: 'Final',
        dateGraded: now.subtract(const Duration(days: 1)),
      ),

      // Attendance
      GradeEntry(
        id: 'g0_11',
        studentId: '2023-6015',
        title: 'Prelim Attendance',
        category: 'Attendance',
        score: 10,
        maxScore: 10,
        term: 'Prelim',
        dateGraded: now.subtract(const Duration(days: 14)),
      ),
      GradeEntry(
        id: 'g0_12',
        studentId: '2023-6015',
        title: 'Midterm Attendance',
        category: 'Attendance',
        score: 10,
        maxScore: 10,
        term: 'Midterm',
        dateGraded: now.subtract(const Duration(days: 7)),
      ),
      GradeEntry(
        id: 'g0_13',
        studentId: '2023-6015',
        title: 'Final Attendance',
        category: 'Attendance',
        score: 5,
        maxScore: 10,
        term: 'Final',
        dateGraded: now.subtract(const Duration(days: 1)),
      ),

      // Exams (Strictly exactly one per term)
      GradeEntry(
        id: 'g0_14',
        studentId: '2023-6015',
        title: 'Prelim Exam',
        category: 'Term Exams',
        score: 87,
        maxScore: 100,
        term: 'Prelim',
        dateGraded: now.subtract(const Duration(days: 14)),
      ),
      GradeEntry(
        id: 'g0_15',
        studentId: '2023-6015',
        title: 'Midterm Exam',
        category: 'Term Exams',
        score: 92,
        maxScore: 100,
        term: 'Midterm',
        dateGraded: now.subtract(const Duration(days: 7)),
      ),
      GradeEntry(
        id: 'g0_16',
        studentId: '2023-6015',
        title: 'Final Exam',
        category: 'Term Exams',
        score: 82,
        maxScore: 100,
        term: 'Final',
        dateGraded: now.subtract(const Duration(days: 1)),
      ),
    ]);

    // STU001 - John Doe (High Grades ~ 92%)
    _grades.addAll([
      // Quizzes
      GradeEntry(
        id: 'g1_1',
        studentId: 'STU001',
        title: 'Quiz 1: Flutter Basics',
        category: 'Quizzes',
        score: 45,
        maxScore: 50,
        term: 'Prelim',
        dateGraded: now.subtract(const Duration(days: 20)),
      ),
      GradeEntry(
        id: 'g1_2',
        studentId: 'STU001',
        title: 'Quiz 2: State Management',
        category: 'Quizzes',
        score: 90,
        maxScore: 100,
        term: 'Midterm',
        dateGraded: now.subtract(const Duration(days: 10)),
      ),
      GradeEntry(
        id: 'g1_3',
        studentId: 'STU001',
        title: 'Quiz 3: Firebase Integration',
        category: 'Quizzes',
        score: 48,
        maxScore: 50,
        term: 'Final',
        dateGraded: now.subtract(const Duration(days: 2)),
      ),

      // Activities
      GradeEntry(
        id: 'g1_4',
        studentId: 'STU001',
        title: 'Activity 1: UI Design',
        category: 'Activities',
        score: 19,
        maxScore: 20,
        term: 'Prelim',
        dateGraded: now.subtract(const Duration(days: 18)),
      ),
      GradeEntry(
        id: 'g1_5',
        studentId: 'STU001',
        title: 'Activity 2: Navigation',
        category: 'Activities',
        score: 28,
        maxScore: 30,
        term: 'Midterm',
        dateGraded: now.subtract(const Duration(days: 12)),
      ),
      GradeEntry(
        id: 'g1_6',
        studentId: 'STU001',
        title: 'Activity 3: Custom Painter',
        category: 'Activities',
        score: 45,
        maxScore: 50,
        term: 'Final',
        dateGraded: now.subtract(const Duration(days: 4)),
      ),

      // Oral Recitations (Capped at 50 max points)
      GradeEntry(
        id: 'g1_7',
        studentId: 'STU001',
        title: 'Oral Recitation 1',
        category: 'Oral Recitations',
        score: 45,
        maxScore: 50,
        term: 'Prelim',
        dateGraded: now.subtract(const Duration(days: 15)),
      ),
      GradeEntry(
        id: 'g1_8',
        studentId: 'STU001',
        title: 'Oral Recitation 2',
        category: 'Oral Recitations',
        score: 48,
        maxScore: 50,
        term: 'Final',
        dateGraded: now.subtract(const Duration(days: 3)),
      ),

      // Projects
      GradeEntry(
        id: 'g1_9',
        studentId: 'STU001',
        title: 'Midterm Project: E-Commerce App',
        category: 'Projects',
        score: 95,
        maxScore: 100,
        term: 'Midterm',
        dateGraded: now.subtract(const Duration(days: 8)),
      ),
      GradeEntry(
        id: 'g1_10',
        studentId: 'STU001',
        title: 'Final Project: Social Media App',
        category: 'Projects',
        score: 47,
        maxScore: 50,
        term: 'Final',
        dateGraded: now.subtract(const Duration(days: 1)),
      ),

      // Attendance
      GradeEntry(
        id: 'g1_11',
        studentId: 'STU001',
        title: 'Prelim Attendance',
        category: 'Attendance',
        score: 10,
        maxScore: 10,
        term: 'Prelim',
        dateGraded: now.subtract(const Duration(days: 14)),
      ),
      GradeEntry(
        id: 'g1_12',
        studentId: 'STU001',
        title: 'Midterm Attendance',
        category: 'Attendance',
        score: 10,
        maxScore: 10,
        term: 'Midterm',
        dateGraded: now.subtract(const Duration(days: 7)),
      ),
      GradeEntry(
        id: 'g1_13',
        studentId: 'STU001',
        title: 'Final Attendance',
        category: 'Attendance',
        score: 9,
        maxScore: 10,
        term: 'Final',
        dateGraded: now.subtract(const Duration(days: 1)),
      ),

      // Exams (Strictly exactly one per term)
      GradeEntry(
        id: 'g1_14',
        studentId: 'STU001',
        title: 'Prelim Exam',
        category: 'Term Exams',
        score: 92,
        maxScore: 100,
        term: 'Prelim',
        dateGraded: now.subtract(const Duration(days: 14)),
      ),
      GradeEntry(
        id: 'g1_15',
        studentId: 'STU001',
        title: 'Midterm Exam',
        category: 'Term Exams',
        score: 90,
        maxScore: 100,
        term: 'Midterm',
        dateGraded: now.subtract(const Duration(days: 7)),
      ),
      GradeEntry(
        id: 'g1_16',
        studentId: 'STU001',
        title: 'Final Exam',
        category: 'Term Exams',
        score: 94,
        maxScore: 100,
        term: 'Final',
        dateGraded: now.subtract(const Duration(days: 1)),
      ),
    ]);

    // STU002 - Jane Smith (Borderline passing grades ~ 77%)
    _grades.addAll([
      // Quizzes
      GradeEntry(
        id: 'g2_1',
        studentId: 'STU002',
        title: 'Quiz 1: Flutter Basics',
        category: 'Quizzes',
        score: 38,
        maxScore: 50,
        term: 'Prelim',
        dateGraded: now.subtract(const Duration(days: 20)),
      ),
      GradeEntry(
        id: 'g2_2',
        studentId: 'STU002',
        title: 'Quiz 2: State Management',
        category: 'Quizzes',
        score: 75,
        maxScore: 100,
        term: 'Midterm',
        dateGraded: now.subtract(const Duration(days: 10)),
      ),
      GradeEntry(
        id: 'g2_3',
        studentId: 'STU002',
        title: 'Quiz 3: Firebase Integration',
        category: 'Quizzes',
        score: 37,
        maxScore: 50,
        term: 'Final',
        dateGraded: now.subtract(const Duration(days: 2)),
      ),

      // Activities
      GradeEntry(
        id: 'g2_4',
        studentId: 'STU002',
        title: 'Activity 1: UI Design',
        category: 'Activities',
        score: 15,
        maxScore: 20,
        term: 'Prelim',
        dateGraded: now.subtract(const Duration(days: 18)),
      ),
      GradeEntry(
        id: 'g2_5',
        studentId: 'STU002',
        title: 'Activity 2: Navigation',
        category: 'Activities',
        score: 23,
        maxScore: 30,
        term: 'Midterm',
        dateGraded: now.subtract(const Duration(days: 12)),
      ),
      GradeEntry(
        id: 'g2_6',
        studentId: 'STU002',
        title: 'Activity 3: Custom Painter',
        category: 'Activities',
        score: 38,
        maxScore: 50,
        term: 'Final',
        dateGraded: now.subtract(const Duration(days: 4)),
      ),

      // Oral Recitations
      GradeEntry(
        id: 'g2_7',
        studentId: 'STU002',
        title: 'Oral Recitation 1',
        category: 'Oral Recitations',
        score: 38,
        maxScore: 50,
        term: 'Prelim',
        dateGraded: now.subtract(const Duration(days: 15)),
      ),
      GradeEntry(
        id: 'g2_8',
        studentId: 'STU002',
        title: 'Oral Recitation 2',
        category: 'Oral Recitations',
        score: 39,
        maxScore: 50,
        term: 'Final',
        dateGraded: now.subtract(const Duration(days: 3)),
      ),

      // Projects
      GradeEntry(
        id: 'g2_9',
        studentId: 'STU002',
        title: 'Midterm Project: E-Commerce App',
        category: 'Projects',
        score: 78,
        maxScore: 100,
        term: 'Midterm',
        dateGraded: now.subtract(const Duration(days: 8)),
      ),
      GradeEntry(
        id: 'g2_10',
        studentId: 'STU002',
        title: 'Final Project: Social Media App',
        category: 'Projects',
        score: 38,
        maxScore: 50,
        term: 'Final',
        dateGraded: now.subtract(const Duration(days: 1)),
      ),

      // Attendance
      GradeEntry(
        id: 'g2_11',
        studentId: 'STU002',
        title: 'Prelim Attendance',
        category: 'Attendance',
        score: 8,
        maxScore: 10,
        term: 'Prelim',
        dateGraded: now.subtract(const Duration(days: 14)),
      ),
      GradeEntry(
        id: 'g2_12',
        studentId: 'STU002',
        title: 'Midterm Attendance',
        category: 'Attendance',
        score: 8,
        maxScore: 10,
        term: 'Midterm',
        dateGraded: now.subtract(const Duration(days: 7)),
      ),
      GradeEntry(
        id: 'g2_13',
        studentId: 'STU002',
        title: 'Final Attendance',
        category: 'Attendance',
        score: 8,
        maxScore: 10,
        term: 'Final',
        dateGraded: now.subtract(const Duration(days: 1)),
      ),

      // Exams
      GradeEntry(
        id: 'g2_14',
        studentId: 'STU002',
        title: 'Prelim Exam',
        category: 'Term Exams',
        score: 76,
        maxScore: 100,
        term: 'Prelim',
        dateGraded: now.subtract(const Duration(days: 14)),
      ),
      GradeEntry(
        id: 'g2_15',
        studentId: 'STU002',
        title: 'Midterm Exam',
        category: 'Term Exams',
        score: 78,
        maxScore: 100,
        term: 'Midterm',
        dateGraded: now.subtract(const Duration(days: 7)),
      ),
      GradeEntry(
        id: 'g2_16',
        studentId: 'STU002',
        title: 'Final Exam',
        category: 'Term Exams',
        score: 75,
        maxScore: 100,
        term: 'Final',
        dateGraded: now.subtract(const Duration(days: 1)),
      ),
    ]);

    // STU003 - Alex Lee (Failing grades ~ 62%)
    _grades.addAll([
      // Quizzes
      GradeEntry(
        id: 'g3_1',
        studentId: 'STU003',
        title: 'Quiz 1: Flutter Basics',
        category: 'Quizzes',
        score: 28,
        maxScore: 50,
        term: 'Prelim',
        dateGraded: now.subtract(const Duration(days: 20)),
      ),
      GradeEntry(
        id: 'g3_2',
        studentId: 'STU003',
        title: 'Quiz 2: State Management',
        category: 'Quizzes',
        score: 60,
        maxScore: 100,
        term: 'Midterm',
        dateGraded: now.subtract(const Duration(days: 10)),
      ),
      GradeEntry(
        id: 'g3_3',
        studentId: 'STU003',
        title: 'Quiz 3: Firebase Integration',
        category: 'Quizzes',
        score: 30,
        maxScore: 50,
        term: 'Final',
        dateGraded: now.subtract(const Duration(days: 2)),
      ),

      // Activities
      GradeEntry(
        id: 'g3_4',
        studentId: 'STU003',
        title: 'Activity 1: UI Design',
        category: 'Activities',
        score: 11,
        maxScore: 20,
        term: 'Prelim',
        dateGraded: now.subtract(const Duration(days: 18)),
      ),
      GradeEntry(
        id: 'g3_5',
        studentId: 'STU003',
        title: 'Activity 2: Navigation',
        category: 'Activities',
        score: 18,
        maxScore: 30,
        term: 'Midterm',
        dateGraded: now.subtract(const Duration(days: 12)),
      ),
      GradeEntry(
        id: 'g3_6',
        studentId: 'STU003',
        title: 'Activity 3: Custom Painter',
        category: 'Activities',
        score: 29,
        maxScore: 50,
        term: 'Final',
        dateGraded: now.subtract(const Duration(days: 4)),
      ),

      // Oral Recitations
      GradeEntry(
        id: 'g3_7',
        studentId: 'STU003',
        title: 'Oral Recitation 1',
        category: 'Oral Recitations',
        score: 30,
        maxScore: 50,
        term: 'Prelim',
        dateGraded: now.subtract(const Duration(days: 15)),
      ),
      GradeEntry(
        id: 'g3_8',
        studentId: 'STU003',
        title: 'Oral Recitation 2',
        category: 'Oral Recitations',
        score: 32,
        maxScore: 50,
        term: 'Final',
        dateGraded: now.subtract(const Duration(days: 3)),
      ),

      // Projects
      GradeEntry(
        id: 'g3_9',
        studentId: 'STU003',
        title: 'Midterm Project: E-Commerce App',
        category: 'Projects',
        score: 62,
        maxScore: 100,
        term: 'Midterm',
        dateGraded: now.subtract(const Duration(days: 8)),
      ),
      GradeEntry(
        id: 'g3_10',
        studentId: 'STU003',
        title: 'Final Project: Social Media App',
        category: 'Projects',
        score: 31,
        maxScore: 50,
        term: 'Final',
        dateGraded: now.subtract(const Duration(days: 1)),
      ),

      // Attendance
      GradeEntry(
        id: 'g3_11',
        studentId: 'STU003',
        title: 'Prelim Attendance',
        category: 'Attendance',
        score: 6,
        maxScore: 10,
        term: 'Prelim',
        dateGraded: now.subtract(const Duration(days: 14)),
      ),
      GradeEntry(
        id: 'g3_12',
        studentId: 'STU003',
        title: 'Midterm Attendance',
        category: 'Attendance',
        score: 7,
        maxScore: 10,
        term: 'Midterm',
        dateGraded: now.subtract(const Duration(days: 7)),
      ),
      GradeEntry(
        id: 'g3_13',
        studentId: 'STU003',
        title: 'Final Attendance',
        category: 'Attendance',
        score: 6,
        maxScore: 10,
        term: 'Final',
        dateGraded: now.subtract(const Duration(days: 1)),
      ),

      // Exams
      GradeEntry(
        id: 'g3_14',
        studentId: 'STU003',
        title: 'Prelim Exam',
        category: 'Term Exams',
        score: 64,
        maxScore: 100,
        term: 'Prelim',
        dateGraded: now.subtract(const Duration(days: 14)),
      ),
      GradeEntry(
        id: 'g3_15',
        studentId: 'STU003',
        title: 'Midterm Exam',
        category: 'Term Exams',
        score: 62,
        maxScore: 100,
        term: 'Midterm',
        dateGraded: now.subtract(const Duration(days: 7)),
      ),
      GradeEntry(
        id: 'g3_16',
        studentId: 'STU003',
        title: 'Final Exam',
        category: 'Term Exams',
        score: 60,
        maxScore: 100,
        term: 'Final',
        dateGraded: now.subtract(const Duration(days: 1)),
      ),
    ]);

    // 3. Seed To-Dos for each student
    for (final student in _students) {
      _todos.addAll([
        TodoItem(
          id: '${student.id}_t1',
          studentId: student.id,
          title: 'Finish Science Research Paper',
          description: 'Write section on micro-expressions in public speaking.',
          dueDate: now.add(const Duration(days: 5, hours: 4)),
          isCompleted: false,
        ),
        TodoItem(
          id: '${student.id}_t2',
          studentId: student.id,
          title: 'Math Homework Assignment',
          description: 'Solve problems 1-15 in Chapter 4: Quadratic Equations.',
          dueDate: now.add(const Duration(days: 2, hours: 8)),
          isCompleted: false,
        ),
        TodoItem(
          id: '${student.id}_t3',
          studentId: student.id,
          title: 'Prepare for Oral Recitation',
          description:
              'Review presentation slides for the class feedback session.',
          dueDate: now.add(const Duration(hours: 15, minutes: 30)),
          isCompleted: false,
        ),
        TodoItem(
          id: '${student.id}_t4',
          studentId: student.id,
          title: 'Submit English Portfolio',
          description: 'Compile poems and analytical essays from unit 2.',
          dueDate: now.subtract(const Duration(days: 2)),
          isCompleted: false,
        ),
        TodoItem(
          id: '${student.id}_t5',
          studentId: student.id,
          title: 'Group Brainstorming Session',
          description: 'Meet on Discord to outline project responsibilities.',
          dueDate: now.subtract(const Duration(days: 4)),
          isCompleted: true,
        ),
      ]);
    }
  }

  // --- Helper Controllers Accessors ---
  StreamController<Student?> _getStudentController(String studentId) {
    return _studentControllers.putIfAbsent(
      studentId,
      () => StreamController<Student?>.broadcast(),
    );
  }

  StreamController<List<GradeEntry>> _getGradeController(String studentId) {
    return _gradeControllers.putIfAbsent(
      studentId,
      () => StreamController<List<GradeEntry>>.broadcast(),
    );
  }

  StreamController<List<TodoItem>> _getTodoController(String studentId) {
    return _todoControllers.putIfAbsent(
      studentId,
      () => StreamController<List<TodoItem>>.broadcast(),
    );
  }

  // --- DatabaseService Interface Implementation ---

  @override
  Future<List<Student>> getStudents() async {
    await Future.delayed(
      const Duration(milliseconds: 300),
    ); // Simulate network latency
    return List.from(_students);
  }

  @override
  Stream<Student?> getStudentStream(String studentId) {
    final controller = _getStudentController(studentId);
    Future.microtask(() {
      try {
        final student = _students.firstWhere((s) => s.id == studentId);
        controller.add(student);
      } catch (_) {
        controller.add(null);
      }
    });
    return controller.stream;
  }

  @override
  Stream<List<GradeEntry>> getGradesStream(String studentId) {
    final controller = _getGradeController(studentId);
    Future.microtask(() {
      final gradesList = _grades
          .where((g) => g.studentId == studentId)
          .toList();
      controller.add(gradesList);
    });
    return controller.stream;
  }

  @override
  Stream<List<TodoItem>> getTodosStream(String studentId) {
    final controller = _getTodoController(studentId);
    Future.microtask(() {
      final todosList = _todos.where((t) => t.studentId == studentId).toList();
      controller.add(todosList);
    });
    return controller.stream;
  }

  @override
  Future<void> addTodoItem(TodoItem item) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _todos.add(item);
    _triggerTodoUpdate(item.studentId);
  }

  @override
  Future<void> updateTodoItem(TodoItem item) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _todos.indexWhere((t) => t.id == item.id);
    if (index != -1) {
      _todos[index] = item;
      _triggerTodoUpdate(item.studentId);
    }
  }

  @override
  Future<void> deleteTodoItem(String studentId, String itemId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _todos.removeWhere((t) => t.id == itemId);
    _triggerTodoUpdate(studentId);
  }

  void _triggerTodoUpdate(String studentId) {
    final todosList = _todos.where((t) => t.studentId == studentId).toList();
    _getTodoController(studentId).add(todosList);
  }
}
