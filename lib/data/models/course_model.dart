import 'package:flutter/foundation.dart';

@immutable
class CourseModel {
  final int? id;
  final String title;
  final int progress;
  final int targetHours;

  const CourseModel({
    this.id,
    required this.title,
    required this.progress,
    required this.targetHours,
  });
// converts database map data into a CourseModel object
  factory CourseModel.fromMap(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id'] as int?,
      title: (json['title'] ?? '') as String,
      progress: (json['progress'] ?? 0) as int,
      targetHours: (json['targetHours'] ?? 0) as int,
    );
  }
// converts CourseModel object into a map for Sqlite database
  Map<String, dynamic> toMap() {
    return {
      // for Sqlite, if  id is null, send
      if (id != null) 'id': id,
      'title': title,
      'progress': progress,
      'targetHours': targetHours,
    };
  }

  CourseModel copyWith({
    int? id,
    String? title,
    int? progress,
    int? targetHours,
  }) {
    return CourseModel(
      id: id ?? this.id,
      title: title ?? this.title,
      progress: progress ?? this.progress,
      targetHours: targetHours ?? this.targetHours,
    );
  }

  @override
  String toString() {
    return 'CourseModel(id: $id, title: $title, progress: $progress, targetHours: $targetHours)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CourseModel &&
        other.id == id &&
        other.title == title &&
        other.progress == progress &&
        other.targetHours == targetHours;
  }

  @override
  int get hashCode {
    return id.hashCode ^
    title.hashCode ^
    progress.hashCode ^
    targetHours.hashCode;
  }
}