import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../providers/task_provider.dart';
import '../../models/task_model.dart';

/// Notifications Screen
/// Shows upcoming task reminders and notifications
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        elevation: 0,
      ),
      body: Consumer<TaskProvider>(
        builder: (context, provider, _) {
          // Get upcoming tasks (within 7 days)
          final now = DateTime.now();
          final upcomingTasks = provider.tasks.where((task) {
            return task.status == 'Pending' &&
                task.deadline.isAfter(now) &&
                task.deadline.isBefore(now.add(const Duration(days: 7)));
          }).toList()
            ..sort((a, b) => a.deadline.compareTo(b.deadline));

          // Get overdue tasks
          final overdueTasks = provider.tasks
              .where((task) =>
                  task.status == 'Pending' &&
                  task.deadline.isBefore(DateTime.now()))
              .toList()
            ..sort((a, b) => b.deadline.compareTo(a.deadline));

          if (overdueTasks.isEmpty && upcomingTasks.isEmpty) {
            final theme = Theme.of(context);
            final colorScheme = theme.colorScheme;
            
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off,
                    size: 80,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No notifications',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'All tasks are up to date!',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              if (overdueTasks.isNotEmpty) ...[
                Text(
                  '🔴 Overdue Tasks',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFEF4444),
                  ),
                ),
                const SizedBox(height: 16),
                ...overdueTasks.map((task) => _NotificationCard(
                      task: task,
                      isOverdue: true,
                    )),
                const SizedBox(height: 32),
              ],
              if (upcomingTasks.isNotEmpty) ...[
                Text(
                  '🔔 Upcoming Tasks',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF60A5FA)
                        : const Color(0xFF3B82F6),
                  ),
                ),
                const SizedBox(height: 16),
                ...upcomingTasks.map((task) => _NotificationCard(
                      task: task,
                      isOverdue: false,
                    )),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final Task task;
  final bool isOverdue;

  const _NotificationCard({
    required this.task,
    required this.isOverdue,
  });

  int get daysUntilDeadline {
    return task.deadline.difference(DateTime.now()).inDays;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final timeOfDay = DateFormat('hh:mm a').format(task.deadline);
    final dateFormatted = DateFormat('MMM dd, yyyy').format(task.deadline);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isOverdue 
            ? (isDark ? Colors.red.withOpacity(0.1) : Colors.red[50])
            : (isDark ? const Color(0xFF3B82F6).withOpacity(0.1) : Colors.blue[50]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isOverdue
              ? Colors.red.withOpacity(0.3)
              : const Color(0xFF3B82F6).withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: (isOverdue ? Colors.red : Colors.blue).withOpacity(0.1),
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
            color: (isOverdue ? Colors.red : const Color(0xFF3B82F6))
                .withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            isOverdue ? Icons.warning : Icons.notifications,
            color: isOverdue ? Colors.red : const Color(0xFF3B82F6),
          ),
        ),
        title: Text(
          task.title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
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
                Icon(Icons.calendar_today, size: 14, color: colorScheme.onSurfaceVariant),
                const SizedBox(width: 4),
                Text(
                  '$dateFormatted at $timeOfDay',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              isOverdue
                  ? '⚠️ Overdue'
                  : daysUntilDeadline == 0
                      ? '⚡ Due today'
                      : daysUntilDeadline == 1
                          ? '🔥 Due tomorrow'
                          : '⏰ ${daysUntilDeadline} days left',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isOverdue
                    ? Colors.red
                    : daysUntilDeadline <= 2
                        ? const Color(0xFFF59E0B)
                        : const Color(0xFF10B981),
              ),
            ),
          ],
        ),
        trailing: Icon(
          isOverdue ? Icons.error_outline : Icons.info_outline,
          color: isOverdue ? Colors.red : const Color(0xFF3B82F6),
        ),
      ),
    );
  }
}

