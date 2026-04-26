import 'package:flutter/material.dart';

import 'task_enums.dart';

class KanbanColumn {
  const KanbanColumn({
    required this.id,
    required this.label,
    required this.color,
    required this.order,
  });

  final String id;
  final String label;
  final Color color;
  final int order;

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'label': label,
      'color':
          '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}',
      'order': order,
    };
  }

  factory KanbanColumn.fromMap(Map<String, dynamic> data) {
    return KanbanColumn(
      id: data['id'] as String? ?? TaskStatus.todo.name,
      label: data['label'] as String? ?? 'Todo',
      color: _colorFromHex(data['color'] as String?) ?? const Color(0xFF727785),
      order: data['order'] as int? ?? 0,
    );
  }

  static List<KanbanColumn> defaults() {
    return [
      for (var index = 0; index < TaskStatus.values.length; index++)
        KanbanColumn(
          id: TaskStatus.values[index].name,
          label: TaskStatus.values[index].label,
          color: TaskStatus.values[index].color,
          order: (index + 1) * 1000,
        ),
    ];
  }

  static Color? _colorFromHex(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    final normalized = value.replaceFirst('#', '');
    final parsed = int.tryParse(
      normalized.length == 6 ? 'FF$normalized' : normalized,
      radix: 16,
    );
    return parsed == null ? null : Color(parsed);
  }
}
