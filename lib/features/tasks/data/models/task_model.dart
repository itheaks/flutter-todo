import '../../domain/entities/task.dart';

class TaskModel extends Task {
  TaskModel({
    required String title,
    required String description,
    required bool isCompleted,
    required TaskPriority priority,
    required DateTime dueDate,
  }) : super(
    title: title,
    description: description,
    isCompleted: isCompleted,
    priority: priority,
    dueDate: dueDate,
  );

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      title: json['title'],
      description: json['description'],
      isCompleted: json['isCompleted'],
      priority: TaskPriority.values.firstWhere((e) => e.toString() == json['priority']),
      dueDate: DateTime.parse(json['dueDate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'priority': priority.toString(),
      'dueDate': dueDate.toIso8601String(),
    };
  }
}
