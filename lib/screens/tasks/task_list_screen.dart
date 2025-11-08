import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../providers/task_provider.dart';
import '../../widgets/task_card.dart';
import 'add_edit_task_screen.dart';

/// Task List Screen
/// Displays tasks with filtering options
class TaskListScreen extends StatefulWidget {
  final bool showAddButton;
  
  const TaskListScreen({super.key, this.showAddButton = false});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  void _loadTasks() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    
    if (authProvider.user != null) {
      taskProvider.loadTasks(authProvider.user!.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final taskProvider = Provider.of<TaskProvider>(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          'My Tasks',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list, color: colorScheme.onSurface),
            onPressed: () => _showFilterDialog(context),
            tooltip: 'Filter',
          ),
          if (taskProvider.subjectFilter != null ||
              taskProvider.statusFilter != 'All')
            IconButton(
              icon: Icon(Icons.clear, color: colorScheme.onSurface),
              onPressed: () {
                taskProvider.clearFilters();
              },
              tooltip: 'Clear Filters',
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context)
              .push(
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      const AddEditTaskScreen(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.0, 1.0),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOut,
                      )),
                      child: child,
                    );
                  },
                ),
              )
              .then((_) => _loadTasks());
        },
        backgroundColor: const Color(0xFF3B82F6),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'Add Task',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          if (authProvider.user != null) {
            await taskProvider.loadTasks(authProvider.user!.uid);
          }
        },
        child: Consumer<TaskProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading && provider.tasks.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.filteredTasks.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B82F6).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.task_alt,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      provider.tasks.isEmpty
                          ? 'No tasks yet!'
                          : 'No tasks match your filters',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      provider.tasks.isEmpty
                          ? 'Tap the + button below to create your first task'
                          : 'Try adjusting your filters',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              itemCount: provider.filteredTasks.length,
              itemBuilder: (context, index) {
                final task = provider.filteredTasks[index];
                return Dismissible(
                  key: Key(task.id.toString()),
                  direction: DismissDirection.horizontal,
                  background: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 20),
                    child: const Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.white, size: 32),
                        SizedBox(width: 12),
                        Text(
                          'Mark Complete',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  secondaryBackground: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Delete',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(width: 12),
                        Icon(Icons.delete, color: Colors.white, size: 32),
                      ],
                    ),
                  ),
                  onDismissed: (direction) {
                    if (direction == DismissDirection.endToStart) {
                      // Delete
                      taskProvider.deleteTask(task.id!, authProvider.user!.uid);
                    } else if (direction == DismissDirection.startToEnd) {
                      // Mark Complete
                      taskProvider.toggleTaskStatus(
                        task.id!,
                        authProvider.user!.uid,
                      );
                    }
                  },
                  confirmDismiss: (direction) async {
                    if (direction == DismissDirection.endToStart) {
                      // Show delete confirmation
                      return await _showDeleteDialog(context, task);
                    }
                    return true;
                  },
                  child: TaskCard(
                    task: task,
                    onTap: () {
                      Navigator.of(context).push(
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) =>
                              AddEditTaskScreen(task: task),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                            return SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0.0, 1.0),
                                end: Offset.zero,
                              ).animate(CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeOut,
                              )),
                              child: child,
                            );
                          },
                        ),
                      ).then((_) => _loadTasks());
                    },
                    onToggle: () {
                      taskProvider.toggleTaskStatus(
                        task.id!,
                        authProvider.user!.uid,
                      );
                    },
                    onDelete: () async {
                      final confirmed = await _showDeleteDialog(context, task);
                      if (confirmed == true && context.mounted) {
                        await taskProvider.deleteTask(task.id!, authProvider.user!.uid);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Task "${task.title}" deleted',
                              style: GoogleFonts.poppins(),
                            ),
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      }
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Tasks'),
        content: FutureBuilder<List<String>>(
          future: taskProvider.getSubjects(authProvider.user!.uid),
          builder: (context, snapshot) {
            final subjects = snapshot.data ?? [];
            
            return StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Status Filter
                    const Text('Status:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(value: 'All', label: Text('All')),
                        ButtonSegment(value: 'Pending', label: Text('Pending')),
                        ButtonSegment(value: 'Completed', label: Text('Completed')),
                      ],
                      selected: {taskProvider.statusFilter},
                      onSelectionChanged: (Set<String> newSelection) {
                        taskProvider.setStatusFilter(newSelection.first);
                      },
                    ),
                    const SizedBox(height: 16),
                    // Subject Filter
                    if (subjects.isNotEmpty) ...[
                      const Text('Subject:', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: taskProvider.subjectFilter,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'All Subjects',
                        ),
                        items: [
                          const DropdownMenuItem<String>(
                            value: null,
                            child: Text('All Subjects'),
                          ),
                          ...subjects.map((subject) => DropdownMenuItem<String>(
                            value: subject,
                            child: Text(subject),
                          )),
                        ],
                        onChanged: (value) {
                          taskProvider.setSubjectFilter(value);
                        },
                      ),
                    ],
                  ],
                );
              },
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              taskProvider.clearFilters();
              Navigator.of(context).pop();
            },
            child: const Text('Clear'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<bool> _showDeleteDialog(BuildContext context, task) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Title
                  Text(
                    'Delete Task',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Description
                  Text(
                    'Are you sure you want to delete "${task.title}"?',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  // Buttons
                  Row(
                    children: [
                      // Cancel Button
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: Colors.grey[300]!),
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Delete Button
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'Delete',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ) ??
        false;
  }
}

