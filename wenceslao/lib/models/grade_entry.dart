import 'package:cloud_firestore/cloud_firestore.dart';

class GradeEntry {
  final String id;
  final String studentId;
  final String title;
  final String category; // Quizzes, Activities, Projects, Attendance, Oral Recitations, Term Exams
  final double score;
  final double maxScore;
  final String term; // Prelim, Midterm, Final
  final DateTime dateGraded;

  GradeEntry({
    required this.id,
    required this.studentId,
    required this.title,
    required this.category,
    required this.score,
    required this.maxScore,
    required this.term,
    required this.dateGraded,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentId': studentId,
      'title': title,
      'category': category,
      'score': score,
      'maxScore': maxScore,
      'term': term,
      'dateGraded': Timestamp.fromDate(dateGraded),
    };
  }

  factory GradeEntry.fromMap(Map<String, dynamic> map, String documentId) {
    DateTime parsedDate;
    if (map['dateGraded'] is Timestamp) {
      parsedDate = (map['dateGraded'] as Timestamp).toDate();
    } else if (map['dateGraded'] is String) {
      parsedDate = DateTime.tryParse(map['dateGraded']) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    return GradeEntry(
      id: documentId,
      studentId: map['studentId'] ?? '',
      title: map['title'] ?? '',
      category: map['category'] ?? '',
      score: (map['score'] as num?)?.toDouble() ?? 0.0,
      maxScore: (map['maxScore'] as num?)?.toDouble() ?? 100.0,
      term: map['term'] ?? 'Prelim',
      dateGraded: parsedDate,
    );
  }
}
