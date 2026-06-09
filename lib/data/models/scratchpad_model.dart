import 'package:flutter/foundation.dart';

// immutable ensures the model cannot be accidentally modified after creation
@immutable
class ScratchpadModel {
  final int? id;
  final String task;
  final bool isDone;

  const ScratchpadModel({
    this.id,
    required this.task,
    required this.isDone,
  });

  // converts database map data into a ScratchpadModel object
  factory ScratchpadModel.fromMap(Map<String, dynamic> map) {
    return ScratchpadModel(
      id:     map['id'] as int?,
      task:   (map['task'] ?? '') as String,
      // sqlite stores booleans as integers: 0 = false, 1 = true
      isDone: (map['isDone'] ?? 0) == 1,
    );
  }

  // converts ScratchpadModel object into a map for sqlite database
  Map<String, dynamic> toMap() {
    return {
      // only include id if it exists, sqlite will auto generate otherwise
      if (id != null) 'id': id,
      'task':   task,
      // sqlite doesn't support booleans, so we convert back to integer
      'isDone': isDone ? 1 : 0,
    };
  }

  // creates a modified copy of the model without changing the original
  ScratchpadModel copyWith({
    int? id,
    String? task,
    bool? isDone,
  }) {
    return ScratchpadModel(
      id:     id ?? this.id,
      task:   task ?? this.task,
      isDone: isDone ?? this.isDone,
    );
  }

  @override
  String toString() =>
      'ScratchpadModel(id: $id, task: $task, isDone: $isDone)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ScratchpadModel &&
        other.id == id &&
        other.task == task &&
        other.isDone == isDone;
  }

  @override
  int get hashCode => id.hashCode ^ task.hashCode ^ isDone.hashCode;
}