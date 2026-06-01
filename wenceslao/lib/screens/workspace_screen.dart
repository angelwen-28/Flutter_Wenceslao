import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../provider/app_state_provider.dart';
import '../models/todo_item.dart';
import 'settings_screen.dart';

class WorkspaceScreen extends StatefulWidget {
  final int initialIndex;
  const WorkspaceScreen({super.key, this.initialIndex = 0});

  @override
  State<WorkspaceScreen> createState() => _WorkspaceScreenState();
}

class _WorkspaceScreenState extends State<WorkspaceScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedTerm = 'Prelim'; // Prelim, Midterm, Final

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: widget.initialIndex);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }


  // --- Card Styling Urgency Helpers ---
  Color _getUrgencyColor(DateTime dueDate, bool isCompleted) {
    if (isCompleted) return const Color(0xFF10B981); // Completed Green

    final now = DateTime.now();
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

  // --- Add/Edit To-Do Bottom Sheet Modal ---
  void _showTodoModal({TodoItem? item}) {
    final titleController = TextEditingController(text: item?.title ?? '');
    final descController = TextEditingController(text: item?.description ?? '');
    DateTime selectedDate = item?.dueDate ?? DateTime.now().add(const Duration(days: 1));
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            top: 24,
            left: 24,
            right: 24,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item == null ? 'Create Study Task' : 'Edit Study Task',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Color(0xFF64748B)),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: titleController,
                  style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w500),
                  decoration: InputDecoration(
                    labelText: 'Task Title',
                    labelStyle: GoogleFonts.inter(color: const Color(0xFF64748B)),
                    filled: true,
                    fillColor: const Color(0xFF1E293B),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFF6366F1), width: 1.5),
                    ),
                  ),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Title is required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: descController,
                  style: GoogleFonts.inter(color: Colors.white),
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Task Description',
                    labelStyle: GoogleFonts.inter(color: const Color(0xFF64748B)),
                    filled: true,
                    fillColor: const Color(0xFF1E293B),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFF6366F1), width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Date & Time Picker Row
                StatefulBuilder(
                  builder: (context, setModalState) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'DUE DATE & TIME',
                                style: GoogleFonts.inter(
                                  color: const Color(0xFF64748B),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                DateFormat('MMM dd, yyyy - hh:mm a').format(selectedDate),
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          TextButton(
                            onPressed: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: selectedDate,
                                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                                lastDate: DateTime.now().add(const Duration(days: 365)),
                              );
                              if (date != null) {
                                if (!context.mounted) return;
                                final time = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.fromDateTime(selectedDate),
                                );
                                if (time != null) {
                                  setModalState(() {
                                    selectedDate = DateTime(
                                      date.year,
                                      date.month,
                                      date.day,
                                      time.hour,
                                      time.minute,
                                    );
                                  });
                                }
                              }
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFF6366F1),
                            ),
                            child: const Text('Change'),
                          ),
                        ],
                      ),
                    );
                  }
                ),
                const SizedBox(height: 24),
                
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      final provider = Provider.of<AppStateProvider>(context, listen: false);
                      if (item == null) {
                        provider.addTodo(
                          titleController.text,
                          descController.text,
                          selectedDate,
                        );
                      } else {
                        provider.editTodo(
                          item,
                          titleController.text,
                          descController.text,
                          selectedDate,
                        );
                      }
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    item == null ? 'Add Task' : 'Save Changes',
                    style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppStateProvider>(context);
    final listTodos = provider.todos;

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F19), // Dark Premium Background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Syllabus Workspace',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
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
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF818CF8),
          unselectedLabelColor: const Color(0xFF64748B),
          indicatorColor: const Color(0xFF6366F1),
          indicatorSize: TabBarIndicatorSize.tab,
          labelStyle: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'To-Do Workspace'),
            Tab(text: 'Academic Grades'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // LEFT TAB: TO-DO MANAGEMENT
          _buildTodoTab(listTodos, provider),

          // RIGHT TAB: DETAILED ACADEMIC GRADES
          _buildGradesTab(provider),
        ],
      ),
    );
  }

  // --- Left Tab: To-Do ---
  Widget _buildTodoTab(List<TodoItem> listTodos, AppStateProvider provider) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add_task_rounded),
        onPressed: () => _showTodoModal(),
      ),
      body: listTodos.isEmpty
          ? Center(
              child: Text(
                'No study tasks logged.\nTap the + button to create a new task.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(color: const Color(0xFF475569), fontSize: 14),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
              itemCount: listTodos.length,
              itemBuilder: (context, index) {
                final todo = listTodos[index];
                final color = _getUrgencyColor(todo.dueDate, todo.isCompleted);
                final isOverdue = !todo.isCompleted && todo.dueDate.isBefore(DateTime.now());

                return Card(
                  color: const Color(0xFF1E293B).withValues(alpha: 0.3),
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: color.withValues(alpha: todo.isCompleted ? 0.2 : 0.6),
                      width: 1.5,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: Checkbox(
                      value: todo.isCompleted,
                      activeColor: const Color(0xFF10B981),
                      checkColor: Colors.white,
                      onChanged: (_) {
                        provider.toggleTodo(todo);
                      },
                    ),
                    title: Text(
                      todo.title,
                      style: GoogleFonts.inter(
                        color: todo.isCompleted || isOverdue ? const Color(0xFF64748B) : Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        decoration: todo.isCompleted || isOverdue
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (todo.description.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            todo.description,
                            style: GoogleFonts.inter(
                              color: const Color(0xFF94A3B8),
                              fontSize: 13,
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              todo.isCompleted
                                  ? Icons.check_circle_outline
                                  : isOverdue
                                      ? Icons.warning_amber_rounded
                                      : Icons.calendar_today_rounded,
                              size: 13,
                              color: color,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              todo.isCompleted
                                  ? 'Completed'
                                  : isOverdue
                                      ? 'Overdue (${DateFormat('MMM dd').format(todo.dueDate)})'
                                      : 'Due: ${DateFormat('MMM dd, hh:mm a').format(todo.dueDate)}',
                              style: GoogleFonts.inter(
                                color: color,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, color: Color(0xFF64748B), size: 20),
                          onPressed: () => _showTodoModal(item: todo),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444), size: 20),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                backgroundColor: const Color(0xFF0F172A),
                                title: Text('Delete Task', style: GoogleFonts.outfit(color: Colors.white)),
                                content: Text('Are you sure you want to delete this study task?', style: GoogleFonts.inter(color: const Color(0xFF94A3B8))),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      provider.deleteTodo(todo.id);
                                      Navigator.pop(context);
                                    },
                                    child: const Text('Delete', style: TextStyle(color: Color(0xFFEF4444))),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  // --- Right Tab: Grades ---
  Widget _buildGradesTab(AppStateProvider provider) {
    // Filter grades for the selected term
    final termGrades = provider.grades.where((g) => g.term == _selectedTerm).toList();

    const categoriesList = [
      'Quizzes',
      'Activities',
      'Oral Recitations',
      'Term Exams',
      'Projects',
      'Attendance',
    ];

    return Column(
      children: [
        // Term Selection Toggle
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          color: const Color(0xFF0F172A),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: ['Prelim', 'Midterm', 'Final'].map((term) {
              final isSelected = _selectedTerm == term;
              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedTerm = term;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF6366F1) : const Color(0xFF1E293B).withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF818CF8) : const Color(0xFF334155),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    term,
                    style: GoogleFonts.inter(
                      color: isSelected ? Colors.white : const Color(0xFF94A3B8),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        // Accordion Category Lists
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: categoriesList.length,
            itemBuilder: (context, index) {
              final cat = categoriesList[index];
              final catGrades = termGrades.where((g) => g.category == cat).toList();
              
              // Calculate cumulative category average strictly for the selected term
              double earnedSum = 0;
              double maxSum = 0;
              for (final entry in catGrades) {
                earnedSum += entry.score;
                maxSum += entry.maxScore;
              }
              final displayAvg = maxSum > 0 ? (earnedSum / maxSum) * 100 : null;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B).withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF334155).withValues(alpha: 0.5),
                      width: 1,
                    ),
                  ),
                  child: Theme(
                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      key: ValueKey<String>(cat),
                      iconColor: const Color(0xFF818CF8),
                      collapsedIconColor: const Color(0xFF64748B),
                      title: Text(
                        cat,
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            displayAvg != null
                                ? '${displayAvg.toStringAsFixed(1)}%'
                                : '--',
                            style: GoogleFonts.outfit(
                              color: displayAvg != null ? const Color(0xFF818CF8) : const Color(0xFF475569),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.expand_more),
                        ],
                      ),
                      children: [
                        if (catGrades.isEmpty)
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              'No grades logged for $_selectedTerm in this category.',
                              style: GoogleFonts.inter(color: const Color(0xFF475569), fontSize: 13),
                            ),
                          )
                        else
                          ListView.builder(
                            key: PageStorageKey<String>('${cat}_list_$_selectedTerm'),
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: catGrades.length,
                            itemBuilder: (context, cIdx) {
                              final entry = catGrades[cIdx];
                              return Container(
                                decoration: const BoxDecoration(
                                  border: Border(
                                    top: BorderSide(color: Color(0xFF334155), width: 0.5),
                                  ),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                  title: Text(
                                    entry.title,
                                    style: GoogleFonts.inter(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  subtitle: Text(
                                    DateFormat('MMM dd, yyyy').format(entry.dateGraded),
                                    style: GoogleFonts.inter(
                                      color: const Color(0xFF64748B),
                                      fontSize: 11,
                                    ),
                                  ),
                                  trailing: Text(
                                    '${entry.score.toStringAsFixed(0)} / ${entry.maxScore.toStringAsFixed(0)}',
                                    style: GoogleFonts.outfit(
                                      color: const Color(0xFF10B981),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
