import 'package:shared_preferences/shared_preferences.dart';
import '../models/task_model.dart';

abstract class TaskLocalDataSource {
  Future<List<TaskModel>> getTasks();
  Future<void> cacheTasks(List<TaskModel> tasks);
}

class TaskLocalDataSourceImpl implements TaskLocalDataSource {
  final SharedPreferences sharedPreferences;

  TaskLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<TaskModel>> getTasks() async {
    final taskStrings = sharedPreferences.getStringList('tasks') ?? [];
    return taskStrings.map((taskString) {
      return TaskModel.fromJson(Map<String, dynamic>.from(taskString as Map));
    }).toList();
  }

  @override
  Future<void> cacheTasks(List<TaskModel> tasks) async {
    final taskStrings = tasks.map((task) => task.toJson().toString()).toList();
    await sharedPreferences.setStringList('tasks', taskStrings);
  }
}
