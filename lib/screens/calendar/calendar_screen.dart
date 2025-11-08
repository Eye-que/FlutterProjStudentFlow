import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../providers/task_provider.dart';
import '../../models/task_model.dart';

/// Calendar View Screen
/// Shows tasks organized by date on a calendar
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Calendar View',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Calendar Header
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF3B82F6),
                  const Color(0xFF06B6D4),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF3B82F6).withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  DateFormat('MMMM yyyy').format(_selectedDate),
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  DateFormat('EEEE, d').format(_selectedDate),
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          // Task List for Selected Date
          Expanded(
            child: Consumer<TaskProvider>(
              builder: (context, provider, _) {
                final dateTasks = provider.tasks.where((task) {
                  return task.deadline.year == _selectedDate.year &&
                      task.deadline.month == _selectedDate.month &&
                      task.deadline.day == _selectedDate.day;
                }).toList();

                if (dateTasks.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 80,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No tasks for this date',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: dateTasks.length,
                  itemBuilder: (context, index) {
                    return _CalendarTaskCard(task: dateTasks[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CalendarTaskCard extends StatelessWidget {
  final Task task;

  const _CalendarTaskCard({required this.task});

  Color _getPriorityColor() {
    switch (task.priority) {
      case 'High':
        return const Color(0xFFEF4444);
      case 'Medium':
        return const Color(0xFFF59E0B);
      case 'Low':
        return const Color(0xFF10B981);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final timeOfDay = DateFormat('hh:mm a').format(task.deadline);
    final isOverdue =
        task.deadline.isBefore(DateTime.now()) && task.status == 'Pending';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isOverdue ? Colors.red.withOpacity(0.3) : Colors.transparent,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: _getPriorityColor().withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.task,
            color: _getPriorityColor(),
          ),
        ),
        title: Text(
          task.title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
            decoration:
                task.status == 'Completed' ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.book, size: 14, color: colorScheme.onSurfaceVariant),
                const SizedBox(width: 4),
                Text(
                  task.subject,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.access_time, size: 14, color: colorScheme.onSurfaceVariant),
                const SizedBox(width: 4),
                Text(
                  timeOfDay,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: isOverdue ? Colors.red : colorScheme.onSurfaceVariant,
                    fontWeight: isOverdue ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _getPriorityColor().withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            task.priority,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _getPriorityColor(),
            ),
          ),
        ),
      ),
    );
  }
}

