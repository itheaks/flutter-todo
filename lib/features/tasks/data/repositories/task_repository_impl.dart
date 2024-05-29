import 'package:dartz/dartz.dart';
import 'package:meta/meta.dart';
import 'package:todo/features/tasks/data/models/task_model.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/task_local_data_source.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskLocalDataSource localDataSource;

  TaskRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<Task>>> getTasks() async {
    try {
      final tasks = await localDataSource.getTasks();
      return Right(tasks);
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> addTask(Task task) async {
    try {
      final tasks = await localDataSource.getTasks();
      tasks.add(task as TaskModel);
      await localDataSource.cacheTasks(tasks);
      return Right(null);
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> updateTask(Task task) async {
    try {
      final tasks = await localDataSource.getTasks();
      final index = tasks.indexWhere((t) => t.title == task.title);
      tasks[index] = task as TaskModel;
      await localDataSource.cacheTasks(tasks);
      return Right(null);
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteTask(String taskId) async {
    try {
      final tasks = await localDataSource.getTasks();
      tasks.removeWhere((task) => task.title == taskId);
      await localDataSource.cacheTasks(tasks);
      return Right(null);
    } catch (e) {
      return Left(CacheFailure());
    }
  }
}
