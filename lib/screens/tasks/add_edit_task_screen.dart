import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../providers/task_provider.dart';
import '../../models/task_model.dart';

/// Add/Edit Task Screen
/// Modern form to create or edit a task with validation
class AddEditTaskScreen extends StatefulWidget {
  final Task? task;

  const AddEditTaskScreen({super.key, this.task});

  @override
  State<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends State<AddEditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _subjectController = TextEditingController();

  DateTime _selectedDeadline = DateTime.now().add(const Duration(days: 1));
  String _selectedPriority = 'Medium';
  String _selectedStatus = 'Pending';

  final List<String> _priorities = ['Low', 'Medium', 'High'];
  final List<String> _statuses = ['Pending', 'Completed'];

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _titleController.text = widget.task!.title;
      _descriptionController.text = widget.task!.description;
      _subjectController.text = widget.task!.subject;
      _selectedDeadline = widget.task!.deadline;
      _selectedPriority = widget.task!.priority;
      _selectedStatus = widget.task!.status;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _subjectController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDeadline,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        // Preserve the time when updating the date
        _selectedDeadline = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _selectedDeadline.hour,
          _selectedDeadline.minute,
        );
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDeadline),
    );
    if (picked != null) {
      setState(() {
        // Preserve the date when updating the time
        _selectedDeadline = DateTime(
          _selectedDeadline.year,
          _selectedDeadline.month,
          _selectedDeadline.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  Future<void> _handleSave() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);

      if (authProvider.user == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('User not authenticated')));
        return;
      }

      // Get subject from subject controller
      final subjectText = _subjectController.text.trim();

      final task = Task(
        id: widget.task?.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        subject: subjectText,
        deadline: _selectedDeadline,
        priority: _selectedPriority,
        status: _selectedStatus,
        userId: authProvider.user!.uid,
      );

      bool success;
      if (widget.task == null) {
        success = await taskProvider.createTask(task);
      } else {
        success = await taskProvider.updateTask(task);
      }

      if (success && mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.task == null
                  ? 'Task created successfully'
                  : 'Task updated successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(taskProvider.errorMessage ?? 'Failed to save task'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.task == null ? 'Create New Task' : 'Edit Task',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title Field
              Builder(
                builder: (context) {
                  final theme = Theme.of(context);
                  final colorScheme = theme.colorScheme;
                  return Container(
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: theme.shadowColor.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextFormField(
                      controller: _titleController,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: colorScheme.onSurface,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Task Title',
                        labelStyle: GoogleFonts.poppins(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        prefixIcon: Icon(
                          Icons.title,
                          color: colorScheme.primary,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: theme.cardColor,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 18,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

              // Description Field
              Builder(
                builder: (context) {
                  final theme = Theme.of(context);
                  final colorScheme = theme.colorScheme;
                  return Container(
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: theme.shadowColor.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextFormField(
                      controller: _descriptionController,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: colorScheme.onSurface,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Description',
                        labelStyle: GoogleFonts.poppins(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        prefixIcon: Icon(
                          Icons.description,
                          color: colorScheme.primary,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: theme.cardColor,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 18,
                        ),
                      ),
                      maxLines: 4,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

              // Subject Field
              Builder(
                builder: (context) {
                  final theme = Theme.of(context);
                  final colorScheme = theme.colorScheme;
                  return Container(
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: theme.shadowColor.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextFormField(
                      controller: _subjectController,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: colorScheme.onSurface,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Subject',
                        labelStyle: GoogleFonts.poppins(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        prefixIcon: Icon(
                          Icons.book,
                          color: colorScheme.primary,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: theme.cardColor,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 18,
                        ),
                        hintText: 'Enter subject (e.g., Math, English, etc.)',
                        hintStyle: GoogleFonts.poppins(
                          fontSize: 14,
                          color: colorScheme.onSurfaceVariant.withOpacity(0.6),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a subject';
                        }
                        return null;
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

              // Deadline Field
              Builder(
                builder: (context) {
                  final theme = Theme.of(context);
                  final colorScheme = theme.colorScheme;
                  return Container(
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: theme.shadowColor.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: InkWell(
                      onTap: _selectDate,
                      borderRadius: BorderRadius.circular(16),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Deadline',
                          labelStyle: GoogleFonts.poppins(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          prefixIcon: Icon(
                            Icons.calendar_today,
                            color: colorScheme.primary,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: theme.cardColor,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 18,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              DateFormat('MMM dd, yyyy').format(_selectedDeadline),
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            Icon(
                              Icons.arrow_drop_down,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

              // Time Field
              Builder(
                builder: (context) {
                  final theme = Theme.of(context);
                  final colorScheme = theme.colorScheme;
                  return Container(
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: theme.shadowColor.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: InkWell(
                      onTap: _selectTime,
                      borderRadius: BorderRadius.circular(16),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Time',
                          labelStyle: GoogleFonts.poppins(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          prefixIcon: Icon(
                            Icons.access_time,
                            color: colorScheme.primary,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: theme.cardColor,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 18,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              DateFormat('hh:mm a').format(_selectedDeadline),
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            Icon(
                              Icons.arrow_drop_down,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

              // Priority Field
              Builder(
                builder: (context) {
                  final theme = Theme.of(context);
                  final colorScheme = theme.colorScheme;
                  return Container(
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: theme.shadowColor.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: DropdownButtonFormField<String>(
                      value: _selectedPriority,
                      decoration: InputDecoration(
                        labelText: 'Priority',
                        labelStyle: GoogleFonts.poppins(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        prefixIcon: Icon(
                          Icons.flag,
                          color: colorScheme.primary,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: theme.cardColor,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 18,
                        ),
                      ),
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: colorScheme.onSurface,
                      ),
                      dropdownColor: theme.cardColor,
                      iconEnabledColor: colorScheme.onSurface,
                      iconDisabledColor: colorScheme.onSurfaceVariant,
                  selectedItemBuilder: (BuildContext context) {
                    return _priorities.map((priority) {
                      Color priorityColor;
                      switch (priority) {
                        case 'High':
                          priorityColor = Colors.red;
                          break;
                        case 'Medium':
                          priorityColor = Colors.orange;
                          break;
                        case 'Low':
                          priorityColor = Colors.green;
                          break;
                        default:
                          priorityColor = Colors.grey;
                      }
                      return Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: priorityColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            priority,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ],
                      );
                    }).toList();
                  },
                  items: _priorities.map((priority) {
                    Color priorityColor;
                    switch (priority) {
                      case 'High':
                        priorityColor = Colors.red;
                        break;
                      case 'Medium':
                        priorityColor = Colors.orange;
                        break;
                      case 'Low':
                        priorityColor = Colors.green;
                        break;
                      default:
                        priorityColor = Colors.grey;
                    }

                      return DropdownMenuItem<String>(
                      value: priority,
                      child: DefaultTextStyle(
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: colorScheme.onSurface,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: priorityColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(priority),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedPriority = value!;
                    });
                  },
                ),
                  );
                },
              ),
              const SizedBox(height: 20),

              // Status Field (only show for editing)
              if (widget.task != null)
                Builder(
                  builder: (context) {
                    final theme = Theme.of(context);
                    final colorScheme = theme.colorScheme;
                    return Container(
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: theme.shadowColor.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: DropdownButtonFormField<String>(
                        value: _selectedStatus,
                        decoration: InputDecoration(
                          labelText: 'Status',
                          labelStyle: GoogleFonts.poppins(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          prefixIcon: Icon(
                            Icons.check_circle,
                            color: colorScheme.primary,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: theme.cardColor,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 18,
                          ),
                        ),
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: colorScheme.onSurface,
                        ),
                        dropdownColor: theme.cardColor,
                        iconEnabledColor: colorScheme.onSurface,
                        iconDisabledColor: colorScheme.onSurfaceVariant,
                    selectedItemBuilder: (BuildContext context) {
                      return _statuses.map((status) {
                        return Row(
                          children: [
                            Icon(
                              status == 'Completed'
                                  ? Icons.check_circle
                                  : Icons.radio_button_unchecked,
                              color: status == 'Completed'
                                  ? Colors.green
                                  : Colors.orange,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              status,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ],
                        );
                      }).toList();
                    },
                    items: _statuses.map((status) {
                      return DropdownMenuItem<String>(
                        value: status,
                        child: DefaultTextStyle(
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: colorScheme.onSurface,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                status == 'Completed'
                                    ? Icons.check_circle
                                    : Icons.radio_button_unchecked,
                                color: status == 'Completed'
                                    ? Colors.green
                                    : Colors.orange,
                              ),
                              const SizedBox(width: 8),
                              Text(status),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedStatus = value!;
                      });
                    },
                  ),
                    );
                  },
                ),
              if (widget.task != null) const SizedBox(height: 20),

              // Save Button
              Consumer<TaskProvider>(
                builder: (context, provider, _) {
                  return Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF3B82F6), Color(0xFF10B981)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF3B82F6).withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: provider.isLoading ? null : _handleSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: provider.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Text(
                              widget.task == null
                                  ? 'Create Task'
                                  : 'Update Task',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
