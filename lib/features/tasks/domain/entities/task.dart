import 'package:equatable/equatable.dart';

enum TaskPriority { low, medium, high }

class Task extends Equatable {
  final String title;
  final String description;
  final bool isCompleted;
  final TaskPriority priority;
  final DateTime dueDate;

  Task({
    required this.title,
    required this.description,
    required this.isCompleted,
    required this.priority,
    required this.dueDate,
  });

  @override
  List<Object> get props => [title, description, isCompleted, priority, dueDate];
}
