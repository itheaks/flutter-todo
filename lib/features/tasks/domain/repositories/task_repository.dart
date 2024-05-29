import 'package:dartz/dartz.dart';
import '../entities/task.dart';
import '../../../../core/error/failures.dart';

abstract class TaskRepository {
  Future<Either<Failure, List<Task>>> getTasks();
  Future<Either<Failure, void>> addTask(Task task);
  Future<Either<Failure, void>> updateTask(Task task);
  Future<Either<Failure, void>> deleteTask(String taskId);
}
