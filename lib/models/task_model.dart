/// Task Model
/// Represents a student task with all required fields
class Task {
  final int? id;
  final String title;
  final String description;
  final String subject;
  final DateTime deadline;
  final String priority; // 'Low', 'Medium', 'High'
  final String status; // 'Pending', 'Completed'
  final String userId; // Firebase user ID

  Task({
    this.id,
    required this.title,
    required this.description,
    required this.subject,
    required this.deadline,
    required this.priority,
    required this.status,
    required this.userId,
  });

  /// Convert Task to Map for SQLite storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'subject': subject,
      'deadline': deadline.millisecondsSinceEpoch,
      'priority': priority,
      'status': status,
      'userId': userId,
    };
  }

  /// Create Task from Map (SQLite retrieval)
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as int?,
      title: map['title'] as String,
      description: map['description'] as String,
      subject: map['subject'] as String,
      deadline: DateTime.fromMillisecondsSinceEpoch(map['deadline'] as int),
      priority: map['priority'] as String,
      status: map['status'] as String,
      userId: map['userId'] as String,
    );
  }

  /// Create a copy of the task with updated fields
  Task copyWith({
    int? id,
    String? title,
    String? description,
    String? subject,
    DateTime? deadline,
    String? priority,
    String? status,
    String? userId,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      subject: subject ?? this.subject,
      deadline: deadline ?? this.deadline,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      userId: userId ?? this.userId,
    );
  }

  /// Check if task is overdue
  bool get isOverdue {
    return status == 'Pending' && deadline.isBefore(DateTime.now());
  }

  /// Get days until deadline
  int get daysUntilDeadline {
    final difference = deadline.difference(DateTime.now()).inDays;
    return difference;
  }
}

