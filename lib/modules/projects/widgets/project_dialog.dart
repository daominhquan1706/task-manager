import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/color_hex.dart';
import '../../../data/models/project_draft.dart';

class ProjectDialog extends StatefulWidget {
  const ProjectDialog({super.key});

  @override
  State<ProjectDialog> createState() => _ProjectDialogState();
}

class _ProjectDialogState extends State<ProjectDialog> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController(
    text: 'Plan, track, and ship a focused batch of work.',
  );
  final _teamController = TextEditingController(text: 'Engineering Team');
  final _dueController = TextEditingController(text: 'May 15');
  Color _accentColor = AppColors.primary;

  static const _accentOptions = [
    AppColors.primary,
    Color(0xFF15803D),
    Color(0xFF924700),
    Color(0xFF7C3AED),
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _teamController.dispose();
    _dueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create project'),
      content: SizedBox(
        width: 460,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Project name'),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _descriptionController,
              minLines: 2,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _teamController,
                    decoration: const InputDecoration(labelText: 'Team'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _dueController,
                    decoration: const InputDecoration(labelText: 'Target date'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 10,
                children: [
                  for (final color in _accentOptions)
                    Tooltip(
                      message: hexFromColor(color),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(999),
                        onTap: () => setState(() => _accentColor = color),
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _accentColor == color
                                  ? AppColors.onSurface
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: Get.back, child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            final name = _nameController.text.trim();
            if (name.isEmpty) {
              return;
            }
            Get.back<ProjectDraft>(
              result: ProjectDraft(
                name: name,
                description: _descriptionController.text.trim().isEmpty
                    ? 'Project workspace'
                    : _descriptionController.text.trim(),
                team: _teamController.text.trim().isEmpty
                    ? 'Workspace'
                    : _teamController.text.trim(),
                dueDate: _dueController.text.trim().isEmpty
                    ? 'No date'
                    : _dueController.text.trim(),
                accentColor: _accentColor,
              ),
            );
          },
          child: const Text('Create'),
        ),
      ],
    );
  }
}
