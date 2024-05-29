import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/task.dart';
import '../../domain/usecases/get_tasks.dart';
import '../../domain/usecases/add_task.dart';

part 'task_event.dart';
part 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final GetTasks getTasks;
  final AddTask addTask;

  TaskBloc({
    required this.getTasks,
    required this.addTask,
  }) : super(TaskInitial());

  @override
  Stream<TaskState> mapEventToState(TaskEvent event) async* {
    if (event is GetTasksEvent) {
      yield TaskLoading();
      final failureOrTasks = await getTasks(NoParams());
      yield failureOrTasks.fold(
            (failure) => TaskError('Failed to load tasks'),
            (tasks) => TaskLoaded(tasks: tasks),
      );
    } else if (event is AddTaskEvent) {
      yield TaskLoading();
      final failureOrVoid = await addTask(event.task);
      yield failureOrVoid.fold(
            (failure) => TaskError('Failed to add task'),
            (_) => TaskAdded(),
      );
      add(GetTasksEvent());
    }
  }
}
