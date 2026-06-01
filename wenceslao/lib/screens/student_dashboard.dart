import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../provider/app_state_provider.dart';
import '../models/todo_item.dart';
import 'login_screen.dart';
import 'workspace_screen.dart';
import 'settings_screen.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppStateProvider>(context);
    final student = provider.currentStudent;

    if (student == null) {
      return const LoginScreen();
    }

    final totalGrade = provider.totalRunningGrade;
    final Map<String, double> categoryPercents = provider.categoryPercentages;
    final listUrgent = provider.urgentTodos;

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F19), // Dark Premium Background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xFF6366F1).withValues(alpha: 0.2),
              child: Text(
                student.name.substring(0, 1).toUpperCase(),
                style: GoogleFonts.outfit(color: const Color(0xFF818CF8), fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.name,
                  style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  'ID: ${student.id} • ${student.email}',
                  style: GoogleFonts.inter(color: const Color(0xFF64748B), fontSize: 11),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded, color: Color(0xFF94A3B8)),
            tooltip: 'Settings',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Color(0xFFEF4444)),
            tooltip: 'Logout',
            onPressed: () {
              provider.logout();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ----------------------------------------------------
            // FRONT VIEW DASHBOARD (Top Section)
            // ----------------------------------------------------
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B).withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color(0xFF334155).withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Analytics Widget (Left)
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'TOTAL RUNNING GRADE',
                                style: GoogleFonts.inter(
                                  color: const Color(0xFF64748B),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${totalGrade.toStringAsFixed(2)}%',
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 12),
                              // Custom Column Chart
                              SizedBox(
                                height: 100,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    _buildBar(categoryPercents['Quizzes'] ?? 0.0, 'QZ'),
                                    _buildBar(categoryPercents['Activities'] ?? 0.0, 'ACT'),
                                    _buildBar(categoryPercents['Oral Recitations'] ?? 0.0, 'ORAL'),
                                    _buildBar(categoryPercents['Term Exams'] ?? 0.0, 'EXM'),
                                    _buildBar(categoryPercents['Projects'] ?? 0.0, 'PRJ'),
                                    _buildBar(categoryPercents['Attendance'] ?? 0.0, 'ATT'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        
                        // Conditional Motivational Engine (Right)
                        Expanded(
                          flex: 2,
                          child: Container(
                            height: 160,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: _getMotivationColors(totalGrade),
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  _getMotivationIcon(totalGrade),
                                  color: Colors.white,
                                  size: 28,
                                ),
                                const SizedBox(height: 12),
                                Expanded(
                                  child: SingleChildScrollView(
                                    child: Text(
                                      _getMotivationText(totalGrade),
                                      style: GoogleFonts.inter(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        height: 1.3,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Urgent Task Radar (Base of Dashboard)
                    Text(
                      'URGENT TASK RADAR',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF64748B),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    UrgentTaskRadarWidget(urgentTodos: listUrgent),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // NAVIGATION HUBS SECTION
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'ACADEMIC PORTALS',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF64748B),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      // To-Do Workspace Hub Button
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const WorkspaceScreen(initialIndex: 0),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E293B).withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFF6366F1).withValues(alpha: 0.4),
                                width: 1.5,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.checklist_rounded,
                                    color: Color(0xFF818CF8),
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'To-Do Workspace',
                                  style: GoogleFonts.outfit(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Manage tasks',
                                  style: GoogleFonts.inter(
                                    color: const Color(0xFF64748B),
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Academic Grades Hub Button
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const WorkspaceScreen(initialIndex: 1),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E293B).withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFF10B981).withValues(alpha: 0.4),
                                width: 1.5,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF10B981).withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.analytics_outlined,
                                    color: Color(0xFF34D399),
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Detailed Grades',
                                  style: GoogleFonts.outfit(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'View syllabus weights',
                                  style: GoogleFonts.inter(
                                    color: const Color(0xFF64748B),
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // --- Chart Bar Builder ---
  Widget _buildBar(double percentage, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          '${percentage.toStringAsFixed(0)}%',
          style: GoogleFonts.inter(
            color: const Color(0xFF818CF8),
            fontSize: 9,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final maxHeight = constraints.maxHeight;
              final barHeight = (percentage / 100.0) * maxHeight;
              return Container(
                width: 14,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.bottomCenter,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  height: barHeight,
                  width: 14,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF6366F1),
                        const Color(0xFF6366F1).withValues(alpha: 0.6),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                        blurRadius: 4,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: GoogleFonts.inter(
            color: const Color(0xFF64748B),
            fontSize: 9,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // --- Motivation Logic Helpers ---
  List<Color> _getMotivationColors(double grade) {
    if (grade >= 85) {
      return [const Color(0xFF10B981), const Color(0xFF047857)]; // Emerald Gradient
    } else if (grade >= 75) {
      return [const Color(0xFFF59E0B), const Color(0xFFB45309)]; // Amber Gradient
    } else {
      return [const Color(0xFFEF4444), const Color(0xFFB91C1C)]; // Crimson Gradient
    }
  }

  IconData _getMotivationIcon(double grade) {
    if (grade >= 85) {
      return Icons.rocket_launch_rounded;
    } else if (grade >= 75) {
      return Icons.emoji_objects_outlined;
    } else {
      return Icons.error_outline_rounded;
    }
  }

  String _getMotivationText(double grade) {
    if (grade >= 85) {
      return 'Excellent work! Your consistency in this subject is paying off. Keep it up!';
    } else if (grade >= 75) {
      return 'Steady focus! You are passing, but stay consistent to secure your grade.';
    } else {
      return 'Wake up! Laziness is holding you back. Push yourself to improve your standing before the term ends.';
    }
  }
}

class UrgentTaskRadarWidget extends StatefulWidget {
  final List<TodoItem> urgentTodos;
  const UrgentTaskRadarWidget({super.key, required this.urgentTodos});

  @override
  State<UrgentTaskRadarWidget> createState() => _UrgentTaskRadarWidgetState();
}

class _UrgentTaskRadarWidgetState extends State<UrgentTaskRadarWidget> {
  Timer? _tickerTimer;

  @override
  void initState() {
    super.initState();
    _tickerTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tickerTimer?.cancel();
    super.dispose();
  }

  String _getCountdownText(DateTime dueDate) {
    final now = DateTime.now();
    final difference = dueDate.difference(now);

    if (difference.isNegative) {
      return 'Overdue';
    }

    final days = difference.inDays;
    final hours = difference.inHours % 24;
    final minutes = difference.inMinutes % 60;
    final seconds = difference.inSeconds % 60;

    if (days > 0) {
      return '${days}d ${hours}h ${minutes}m ${seconds}s';
    } else if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else {
      return '${minutes}m ${seconds}s';
    }
  }

  Color _getUrgencyColor(DateTime dueDate, bool isCompleted) {
    if (isCompleted) return const Color(0xFF10B981);

    final now = DateTime.now();
    final difference = dueDate.difference(now);

    if (difference.isNegative) {
      return const Color(0xFF64748B);
    } else if (difference.inHours < 24) {
      return const Color(0xFFEF4444);
    } else if (difference.inDays < 3) {
      return const Color(0xFFF59E0B);
    } else {
      return const Color(0xFF10B981);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.urgentTodos.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        alignment: Alignment.center,
        child: Text(
          'No upcoming urgent tasks. Good job!',
          style: GoogleFonts.inter(color: const Color(0xFF475569), fontSize: 13, fontWeight: FontWeight.w500),
        ),
      );
    }

    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.urgentTodos.length,
        itemBuilder: (context, index) {
          final todo = widget.urgentTodos[index];
          final color = _getUrgencyColor(todo.dueDate, todo.isCompleted);
          return Container(
            width: 175,
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: color.withValues(alpha: 0.4),
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  todo.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.timer_outlined, color: color, size: 12),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        _getCountdownText(todo.dueDate),
                        style: GoogleFonts.outfit(
                          color: color,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
