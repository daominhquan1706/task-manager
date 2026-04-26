import 'package:cloud_firestore/cloud_firestore.dart';

import 'task_enums.dart';

class KanbanTask {
  const KanbanTask({
    required this.id,
    required this.title,
    required this.statusId,
    required this.priority,
    required this.dueDate,
    required this.assignee,
    required this.order,
  });

  final String id;
  final String title;
  final String statusId;
  final TaskPriority priority;
  final String dueDate;
  final String assignee;
  final int order;

  factory KanbanTask.fromSnapshot(
    QueryDocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data();
    return KanbanTask(
      id: snapshot.id,
      title: data['title'] as String? ?? 'Untitled task',
      statusId: data['status'] as String? ?? TaskStatus.todo.name,
      priority: TaskPriority.fromName(data['priority'] as String?),
      dueDate: data['dueDate'] as String? ?? 'No date',
      assignee: data['assignee'] as String? ?? 'Unassigned',
      order: data['order'] as int? ?? 0,
    );
  }
}
