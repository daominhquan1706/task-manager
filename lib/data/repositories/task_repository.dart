import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/kanban_task.dart';
import '../models/task_draft.dart';
import 'auth_repository.dart';

class TaskRepository {
  TaskRepository(this._authRepository, this.projectId);

  final AuthRepository _authRepository;
  final String projectId;

  String get _userId {
    final user = _authRepository.currentUser;
    if (user == null) {
      throw StateError('TaskRepository requires a signed-in user.');
    }
    return user.uid;
  }

  CollectionReference<Map<String, dynamic>> get _tasks {
    _userId;
    return FirebaseFirestore.instance
        .collection('projects')
        .doc(projectId)
        .collection('tasks');
  }

  Stream<List<KanbanTask>> watchTasks() {
    return _tasks.orderBy('order').snapshots().map((snapshot) {
      return snapshot.docs.map(KanbanTask.fromSnapshot).toList();
    });
  }

  Future<void> createTask(TaskDraft draft) {
    return _tasks.add({
      ...draft.toFirestore(),
      'order': DateTime.now().millisecondsSinceEpoch,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateStatus(KanbanTask task, String statusId) {
    return _tasks.doc(task.id).update({'status': statusId});
  }

  Future<void> updateTaskPlacement({
    required String statusId,
    required List<KanbanTask> orderedTasks,
  }) {
    final batch = FirebaseFirestore.instance.batch();
    for (var index = 0; index < orderedTasks.length; index++) {
      batch.update(_tasks.doc(orderedTasks[index].id), {
        'status': statusId,
        'order': (index + 1) * 1000,
      });
    }
    return batch.commit();
  }

  Future<void> deleteTask(KanbanTask task) {
    return _tasks.doc(task.id).delete();
  }
}
