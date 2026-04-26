import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/kanban_column.dart';
import '../models/kanban_project.dart';
import '../models/project_draft.dart';
import 'auth_repository.dart';

class ProjectRepository {
  ProjectRepository(this._authRepository);

  final AuthRepository _authRepository;

  String get _userId {
    final user = _authRepository.currentUser;
    if (user == null) {
      throw StateError('ProjectRepository requires a signed-in user.');
    }
    return user.uid;
  }

  CollectionReference<Map<String, dynamic>> get _projects =>
      FirebaseFirestore.instance.collection('projects');

  Stream<List<KanbanProject>> watchProjects() {
    return _projects.where('memberIds', arrayContains: _userId).snapshots().map(
      (snapshot) {
        final projects = snapshot.docs.map(KanbanProject.fromSnapshot).toList();
        projects.sort((a, b) => a.order.compareTo(b.order));
        return projects;
      },
    );
  }

  Stream<KanbanProject?> watchProject(String projectId) {
    return _projects.doc(projectId).snapshots().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) {
        return null;
      }
      return KanbanProject.fromSnapshot(snapshot);
    });
  }

  Future<void> createProject(ProjectDraft draft) {
    return _projects.add({
      ...draft.toFirestore(),
      ..._membershipFields,
      'columns': KanbanColumn.defaults()
          .map((column) => column.toFirestore())
          .toList(),
      'order': DateTime.now().millisecondsSinceEpoch,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> addColumn(String projectId, KanbanColumn column) {
    final projectRef = _projects.doc(projectId);
    return FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(projectRef);
      final data = snapshot.data() ?? const <String, dynamic>{};
      final rawColumns = data['columns'];
      final existingColumns = rawColumns is List && rawColumns.isNotEmpty
          ? rawColumns.whereType<Map>().map(Map<String, dynamic>.from).toList()
          : KanbanColumn.defaults()
                .map((defaultColumn) => defaultColumn.toFirestore())
                .toList();
      transaction.update(projectRef, {
        'columns': [...existingColumns, column.toFirestore()],
      });
    });
  }

  Future<void> updateColumns(String projectId, List<KanbanColumn> columns) {
    return _projects.doc(projectId).update({
      'columns': [
        for (var index = 0; index < columns.length; index++)
          KanbanColumn(
            id: columns[index].id,
            label: columns[index].label,
            color: columns[index].color,
            order: (index + 1) * 1000,
          ).toFirestore(),
      ],
    });
  }

  Map<String, dynamic> get _membershipFields {
    final user = _authRepository.currentUser;
    return {
      'ownerId': _userId,
      'memberIds': [_userId],
      'memberEmails': [if (user?.email != null) user!.email!],
    };
  }
}
