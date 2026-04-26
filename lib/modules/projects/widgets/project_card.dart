import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/kanban_project.dart';

class ProjectCard extends StatelessWidget {
  const ProjectCard({required this.project, required this.onTap, super.key});

  final KanbanProject project;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.surfaceContainerHigh),
          ),
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(height: 4, color: project.accentColor),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: project.accentColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.rocket_launch_rounded,
                            color: project.accentColor,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            project.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.onSurface,
                              fontSize: 18,
                              height: 26 / 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.more_vert_rounded,
                          color: AppColors.outline,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      project.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 14,
                        height: 20 / 14,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        _MemberStack(project: project),
                        const Spacer(),
                        const Icon(
                          Icons.check_circle_outline_rounded,
                          size: 16,
                          color: AppColors.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          project.dueDate,
                          style: const TextStyle(
                            color: AppColors.onSurfaceVariant,
                            fontSize: 11,
                            height: 14 / 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MemberStack extends StatelessWidget {
  const _MemberStack({required this.project});

  final KanbanProject project;

  @override
  Widget build(BuildContext context) {
    final members = project.memberEmails.isEmpty
        ? [project.team]
        : project.memberEmails;
    final visibleMembers = members.take(3).toList();
    final hiddenCount = members.length - visibleMembers.length;
    return SizedBox(
      height: 32,
      width: 32.0 + (visibleMembers.length - 1).clamp(0, 2) * 22 + 42,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (final entry in visibleMembers.indexed)
            Positioned(
              left: entry.$1 * 22,
              child: _MemberAvatar(label: entry.$2),
            ),
          if (hiddenCount > 0)
            Positioned(
              left: visibleMembers.length * 22,
              child: _MoreMembers(count: hiddenCount),
            ),
        ],
      ),
    );
  }
}

class _MemberAvatar extends StatelessWidget {
  const _MemberAvatar({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final initial = label.trim().isEmpty ? '?' : label.trim()[0].toUpperCase();
    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.primaryFixed,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.surfaceLowest, width: 2),
      ),
      child: Text(
        initial,
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 11,
          height: 14 / 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _MoreMembers extends StatelessWidget {
  const _MoreMembers({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.surfaceLowest, width: 2),
      ),
      child: Text(
        '+$count',
        style: const TextStyle(
          color: AppColors.onSurfaceVariant,
          fontSize: 11,
          height: 14 / 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
