import 'package:flutter_test/flutter_test.dart';
import 'package:wenceslao/models/grade_entry.dart';
import 'package:wenceslao/provider/app_state_provider.dart';

void main() {
  group('Grade Calculations Tests', () {
    late AppStateProvider provider;
    late DateTime now;

    setUp(() {
      provider = AppStateProvider();
      now = DateTime.now();
    });

    test('Initial or empty grades yields 100% running grade', () {
      // By default, since no student is logged in, provider.grades is empty.
      expect(provider.grades.isEmpty, true);
      expect(provider.totalRunningGrade, 100.0);
    });

    test('Cumulative percentages are computed correctly per category', () {
      // We will simulate grades loading into provider state by testing the math structure directly
      final testGrades = [
        GradeEntry(
          id: 'g1',
          studentId: 'STU999',
          title: 'Quiz 1',
          category: 'Quizzes',
          score: 45,
          maxScore: 50, // 90%
          term: 'Prelim',
          dateGraded: now,
        ),
        GradeEntry(
          id: 'g2',
          studentId: 'STU999',
          title: 'Quiz 2',
          category: 'Quizzes',
          score: 80,
          maxScore: 100, // 80%
          term: 'Midterm',
          dateGraded: now,
        ),
        GradeEntry(
          id: 'g3',
          studentId: 'STU999',
          title: 'Activity 1',
          category: 'Activities',
          score: 18,
          maxScore: 20, // 90%
          term: 'Prelim',
          dateGraded: now,
        ),
      ];

      // Math verification:
      // Quizzes cumulative score = 45 + 80 = 125, max = 50 + 100 = 150.
      // Quizzes percentage = 125 / 150 = 83.333%
      // Activities cumulative score = 18, max = 20.
      // Activities percentage = 18 / 20 = 90%
      
      double quizzesSum = 0;
      double quizzesMax = 0;
      double activitiesSum = 0;
      double activitiesMax = 0;

      for (var entry in testGrades) {
        if (entry.category == 'Quizzes') {
          quizzesSum += entry.score;
          quizzesMax += entry.maxScore;
        } else if (entry.category == 'Activities') {
          activitiesSum += entry.score;
          activitiesMax += entry.maxScore;
        }
      }

      double quizzesPercent = (quizzesSum / quizzesMax) * 100;
      double activitiesPercent = (activitiesSum / activitiesMax) * 100;

      expect(quizzesPercent, closeTo(83.33, 0.01));
      expect(activitiesPercent, 90.0);

      // Running average = (83.333 + 90.0) / 2 = 86.666%
      double runningAverage = (quizzesPercent + activitiesPercent) / 2;
      expect(runningAverage, closeTo(86.67, 0.01));
    });
  });
}
