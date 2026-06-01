import '../models/student.dart';
import '../models/grade_entry.dart';
import '../models/todo_item.dart';

abstract class DatabaseService {
  Future<List<Student>> getStudents();
  Stream<Student?> getStudentStream(String studentId);
  Stream<List<GradeEntry>> getGradesStream(String studentId);
  Stream<List<TodoItem>> getTodosStream(String studentId);
  
  Future<void> addTodoItem(TodoItem item);
  Future<void> updateTodoItem(TodoItem item);
  Future<void> deleteTodoItem(String studentId, String itemId);
}
