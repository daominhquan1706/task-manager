import 'package:flutter/material.dart';

enum TaskStatus {
  todo('Todo', Color(0xFF727785)),
  inProgress('In Progress', Color(0xFF0058BE)),
  inReview('In Review', Color(0xFF924700)),
  done('Done', Color(0xFF15803D));

  const TaskStatus(this.label, this.color);

  final String label;
  final Color color;

  static TaskStatus fromName(String? name) {
    return TaskStatus.values.firstWhere(
      (status) => status.name == name,
      orElse: () => TaskStatus.todo,
    );
  }
}

enum TaskPriority {
  low('Low Priority', Color(0xFFD3E4FE), Color(0xFF38485D)),
  medium('Medium Priority', Color(0xFFFFDCC6), Color(0xFF723600)),
  high('High Priority', Color(0xFFFFDAD6), Color(0xFF93000A));

  const TaskPriority(this.label, this.background, this.foreground);

  final String label;
  final Color background;
  final Color foreground;

  static TaskPriority fromName(String? name) {
    return TaskPriority.values.firstWhere(
      (priority) => priority.name == name,
      orElse: () => TaskPriority.medium,
    );
  }
}
