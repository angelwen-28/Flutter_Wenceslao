import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/student.dart';
import '../models/grade_entry.dart';
import '../models/todo_item.dart';
import 'database_service.dart';

class FirebaseDatabaseService implements DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<Student>> getStudents() async {
    final querySnapshot = await _firestore.collection('students').get();
    return querySnapshot.docs
        .map((doc) => studentFromDoc(doc))
        .toList();
  }

  // Helper factory extension for Student to support custom doc ID
  static Student studentFromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Student(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
    );
  }

  @override
  Stream<Student?> getStudentStream(String studentId) {
    return _firestore
        .collection('students')
        .doc(studentId)
        .snapshots()
        .map((doc) {
          if (!doc.exists) return null;
          return studentFromDoc(doc);
        });
  }

  @override
  Stream<List<GradeEntry>> getGradesStream(String studentId) {
    return _firestore
        .collection('students')
        .doc(studentId)
        .collection('grades')
        .orderBy('dateGraded', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => GradeEntry.fromMap(doc.data(), doc.id))
              .toList();
        });
  }

  @override
  Stream<List<TodoItem>> getTodosStream(String studentId) {
    return _firestore
        .collection('students')
        .doc(studentId)
        .collection('todos')
        .orderBy('dueDate', descending: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => TodoItem.fromMap(doc.data(), doc.id))
              .toList();
        });
  }

  @override
  Future<void> addTodoItem(TodoItem item) async {
    await _firestore
        .collection('students')
        .doc(item.studentId)
        .collection('todos')
        .doc(item.id)
        .set(item.toMap());
  }

  @override
  Future<void> updateTodoItem(TodoItem item) async {
    await _firestore
        .collection('students')
        .doc(item.studentId)
        .collection('todos')
        .doc(item.id)
        .update(item.toMap());
  }

  @override
  Future<void> deleteTodoItem(String studentId, String itemId) async {
    await _firestore
        .collection('students')
        .doc(studentId)
        .collection('todos')
        .doc(itemId)
        .delete();
  }
}
