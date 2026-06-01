import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('To-Do Urgency States Tests', () {
    // Pure logic simulation of the dashboard's _getUrgencyColor method
    Color getUrgencyColor(DateTime dueDate, bool isCompleted, DateTime now) {
      if (isCompleted) return const Color(0xFF10B981); // Completed Green

      final difference = dueDate.difference(now);

      if (difference.isNegative) {
        return const Color(0xFF64748B); // Overdue Muted Gray
      } else if (difference.inHours < 24) {
        return const Color(0xFFEF4444); // Crimson Red (< 24 hours)
      } else if (difference.inDays < 3) {
        return const Color(0xFFF59E0B); // Amber Yellow (1-3 days)
      } else {
        return const Color(0xFF10B981); // Emerald Green (> 3 days)
      }
    }

    test('Completed To-Dos are always Emerald Green', () {
      final now = DateTime.now();
      final pastDate = now.subtract(const Duration(days: 5));
      final futureDate = now.add(const Duration(days: 5));

      expect(getUrgencyColor(pastDate, true, now), const Color(0xFF10B981));
      expect(getUrgencyColor(futureDate, true, now), const Color(0xFF10B981));
    });

    test('Uncompleted past deadlines are Muted Gray', () {
      final now = DateTime.now();
      final overdueDate = now.subtract(const Duration(seconds: 1));

      expect(getUrgencyColor(overdueDate, false, now), const Color(0xFF64748B));
    });

    test('Uncompleted deadlines under 24 hours are Crimson Red', () {
      final now = DateTime.now();
      final imminentDate = now.add(const Duration(hours: 23, minutes: 59));

      expect(getUrgencyColor(imminentDate, false, now), const Color(0xFFEF4444));
    });

    test('Uncompleted deadlines between 24 and 72 hours are Amber Yellow', () {
      final now = DateTime.now();
      final warningDate = now.add(const Duration(days: 2));

      expect(getUrgencyColor(warningDate, false, now), const Color(0xFFF59E0B));
    });

    test('Uncompleted deadlines with more than 3 days buffer are Emerald Green', () {
      final now = DateTime.now();
      final safeDate = now.add(const Duration(days: 4));

      expect(getUrgencyColor(safeDate, false, now), const Color(0xFF10B981));
    });
  });
}
