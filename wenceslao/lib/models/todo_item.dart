import 'package:cloud_firestore/cloud_firestore.dart';

class TodoItem {
  final String id;
  final String studentId;
  final String title;
  final String description;
  final DateTime dueDate;
  final bool isCompleted;

  TodoItem({
    required this.id,
    required this.studentId,
    required this.title,
    required this.description,
    required this.dueDate,
    this.isCompleted = false,
  });

  TodoItem copyWith({
    String? title,
    String? description,
    DateTime? dueDate,
    bool? isCompleted,
  }) {
    return TodoItem(
      id: id,
      studentId: studentId,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentId': studentId,
      'title': title,
      'description': description,
      'dueDate': Timestamp.fromDate(dueDate),
      'isCompleted': isCompleted,
    };
  }

  factory TodoItem.fromMap(Map<String, dynamic> map, String documentId) {
    DateTime parsedDate;
    if (map['dueDate'] is Timestamp) {
      parsedDate = (map['dueDate'] as Timestamp).toDate();
    } else if (map['dueDate'] is String) {
      parsedDate = DateTime.tryParse(map['dueDate']) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    return TodoItem(
      id: documentId,
      studentId: map['studentId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      dueDate: parsedDate,
      isCompleted: map['isCompleted'] ?? false,
    );
  }
}
