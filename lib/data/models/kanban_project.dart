import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../core/utils/color_hex.dart';
import 'kanban_column.dart';

class KanbanProject {
  const KanbanProject({
    required this.id,
    required this.name,
    required this.description,
    required this.team,
    required this.dueDate,
    required this.accentColor,
    required this.order,
    required this.ownerId,
    required this.memberIds,
    required this.memberEmails,
    required this.columns,
  });

  final String id;
  final String name;
  final String description;
  final String team;
  final String dueDate;
  final Color accentColor;
  final int order;
  final String ownerId;
  final List<String> memberIds;
  final List<String> memberEmails;
  final List<KanbanColumn> columns;

  bool isVisibleTo(String userId) {
    return memberIds.isEmpty || ownerId == userId || memberIds.contains(userId);
  }

  factory KanbanProject.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? const <String, dynamic>{};
    return KanbanProject(
      id: snapshot.id,
      name: data['name'] as String? ?? 'Untitled project',
      description: data['description'] as String? ?? '',
      team: data['team'] as String? ?? 'Workspace',
      dueDate: data['dueDate'] as String? ?? 'No date',
      accentColor: colorFromHex(data['accentColor'] as String?),
      order: data['order'] as int? ?? 0,
      ownerId: data['ownerId'] as String? ?? '',
      memberIds: _stringList(data['memberIds']),
      memberEmails: _stringList(data['memberEmails']),
      columns: _columns(data['columns']),
    );
  }

  static List<String> _stringList(Object? value) {
    if (value is! List) {
      return const [];
    }
    return value.whereType<String>().toList(growable: false);
  }

  static List<KanbanColumn> _columns(Object? value) {
    if (value is! List) {
      return KanbanColumn.defaults();
    }
    final columns = value
        .whereType<Map>()
        .map(
          (column) => KanbanColumn.fromMap(Map<String, dynamic>.from(column)),
        )
        .toList();
    if (columns.isEmpty) {
      return KanbanColumn.defaults();
    }
    columns.sort((a, b) => a.order.compareTo(b.order));
    return columns;
  }
}
