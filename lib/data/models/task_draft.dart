import 'task_enums.dart';

class TaskDraft {
  const TaskDraft({
    required this.title,
    required this.statusId,
    required this.priority,
    required this.dueDate,
    required this.assignee,
  });

  final String title;
  final String statusId;
  final TaskPriority priority;
  final String dueDate;
  final String assignee;

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'status': statusId,
      'priority': priority.name,
      'dueDate': dueDate,
      'assignee': assignee,
    };
  }
}
