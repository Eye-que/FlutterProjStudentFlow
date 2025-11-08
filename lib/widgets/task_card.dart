import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/task_model.dart';

/// Task Card Widget
/// Displays a single task in a card format with animations
class TaskCard extends StatefulWidget {
  final Task task;
  final VoidCallback onTap;
  final VoidCallback? onToggle;
  final VoidCallback? onDelete;

  const TaskCard({
    super.key,
    required this.task,
    required this.onTap,
    this.onToggle,
    this.onDelete,
  });

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color get _priorityColor {
    switch (widget.task.priority) {
      case 'High':
        return Colors.red;
      case 'Medium':
        return Colors.orange;
      case 'Low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = widget.task.status == 'Completed';
    final isOverdue = widget.task.isOverdue;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Card(
        elevation: 0,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: theme.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: isOverdue
              ? BorderSide(color: Colors.red.withOpacity(0.5), width: 2)
              : BorderSide.none,
        ),
        child: InkWell(
          onTap: () {
            _animationController.forward().then((_) {
              _animationController.reverse();
              widget.onTap();
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.task.title,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          decoration: isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                          color: isCompleted
                              ? colorScheme.onSurfaceVariant
                              : colorScheme.onSurface,
                        ),
                      ),
                    ),
                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? const Color(0xFF10B981).withOpacity(0.15)
                            : const Color(0xFFF59E0B).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isCompleted
                              ? const Color(0xFF10B981)
                              : const Color(0xFFF59E0B),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        widget.task.status,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isCompleted
                              ? const Color(0xFF10B981)
                              : const Color(0xFFF59E0B),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  widget.task.description,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: colorScheme.onSurfaceVariant,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B82F6).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.menu_book,
                            size: 16,
                            color: const Color(0xFF3B82F6),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            widget.task.subject,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF3B82F6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _priorityColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _priorityColor, width: 1),
                      ),
                      child: Text(
                        widget.task.priority,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _priorityColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 16,
                            color: isOverdue
                                ? Colors.red[600]
                                : colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  DateFormat(
                                    'MMM dd, yyyy',
                                  ).format(widget.task.deadline),
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: isOverdue
                                        ? Colors.red[600]
                                        : colorScheme.onSurfaceVariant,
                                    fontWeight: isOverdue
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.access_time,
                                      size: 12,
                                      color: isOverdue
                                          ? Colors.red[600]
                                          : colorScheme.onSurfaceVariant,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      DateFormat('hh:mm a').format(
                                        widget.task.deadline,
                                      ),
                                      style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        color: isOverdue
                                            ? Colors.red[600]
                                            : colorScheme.onSurfaceVariant,
                                        fontWeight: isOverdue
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          if (isOverdue) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red[50],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'OVERDUE',
                                style: GoogleFonts.poppins(
                                  color: Colors.red[700],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    // Action Buttons
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.onToggle != null)
                          Builder(
                            builder: (context) {
                              final colorScheme = Theme.of(context).colorScheme;
                              return Container(
                                decoration: BoxDecoration(
                                  color: isCompleted
                                      ? const Color(0xFF10B981).withOpacity(0.1)
                                      : colorScheme.surfaceVariant.withOpacity(0.5),
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: Icon(
                                    isCompleted
                                        ? Icons.check_circle
                                        : Icons.radio_button_unchecked,
                                    color: isCompleted
                                        ? const Color(0xFF10B981)
                                        : colorScheme.onSurfaceVariant,
                                    size: 22,
                                  ),
                                  onPressed: widget.onToggle,
                                  tooltip: isCompleted
                                      ? 'Mark Pending'
                                      : 'Mark Complete',
                                ),
                              );
                            },
                          ),
                        const SizedBox(width: 8),
                        // Edit Button
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF3B82F6).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.edit,
                              color: Color(0xFF3B82F6),
                              size: 20,
                            ),
                            onPressed: widget.onTap,
                            tooltip: 'Edit Task',
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Delete Button
                        if (widget.onDelete != null)
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                                size: 20,
                              ),
                              onPressed: widget.onDelete,
                              tooltip: 'Delete Task',
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
