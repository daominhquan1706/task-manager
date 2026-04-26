import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/kanban_project.dart';
import 'project_card.dart';

class ProjectDashboard extends StatelessWidget {
  const ProjectDashboard({
    required this.projects,
    required this.onCreateProject,
    required this.onOpenProject,
    super.key,
  });

  final List<KanbanProject> projects;
  final VoidCallback onCreateProject;
  final ValueChanged<KanbanProject> onOpenProject;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 640;
                return Wrap(
                  spacing: 16,
                  runSpacing: 12,
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    SizedBox(
                      width: compact ? constraints.maxWidth : 420,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Projects',
                            style: TextStyle(
                              color: AppColors.onSurface,
                              fontSize: 30,
                              height: 38 / 30,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Manage and track your active initiatives.',
                            style: TextStyle(
                              color: AppColors.onSurfaceVariant,
                              fontSize: 14,
                              height: 20 / 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: onCreateProject,
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text('New Project'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(144, 40),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(24),
          sliver: SliverGrid.builder(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 390,
              mainAxisExtent: 204,
              crossAxisSpacing: 24,
              mainAxisSpacing: 24,
            ),
            itemCount: projects.length + 1,
            itemBuilder: (context, index) {
              if (index == projects.length) {
                return _CreateProjectCard(onCreateProject: onCreateProject);
              }
              final project = projects[index];
              return ProjectCard(
                project: project,
                onTap: () => onOpenProject(project),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CreateProjectCard extends StatelessWidget {
  const _CreateProjectCard({required this.onCreateProject});

  final VoidCallback onCreateProject;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onCreateProject,
        child: CustomPaint(
          painter: _DashedBorderPainter(),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.add_circle_outline_rounded,
                  size: 32,
                  color: AppColors.outline,
                ),
                SizedBox(height: 8),
                Text(
                  'Create New Project',
                  style: TextStyle(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 12,
                    height: 16 / 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const dashWidth = 8.0;
    const dashSpace = 6.0;
    final radius = BorderRadius.circular(12).toRRect(Offset.zero & size);
    final path = Path()..addRRect(radius);
    final metric = path.computeMetrics().first;
    final paint = Paint()
      ..color = AppColors.outlineVariant
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    var distance = 0.0;
    while (distance < metric.length) {
      final next = distance + dashWidth;
      canvas.drawPath(metric.extractPath(distance, next), paint);
      distance = next + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
