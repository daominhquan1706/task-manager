import 'package:flutter/material.dart';

import '../../core/utils/color_hex.dart';

class ProjectDraft {
  const ProjectDraft({
    required this.name,
    required this.description,
    required this.team,
    required this.dueDate,
    required this.accentColor,
  });

  final String name;
  final String description;
  final String team;
  final String dueDate;
  final Color accentColor;

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'team': team,
      'dueDate': dueDate,
      'accentColor': hexFromColor(accentColor),
    };
  }
}
