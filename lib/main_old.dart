import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum TaskPriority { low, medium, high }
enum TaskFilter { all, completed, notCompleted, lowPriority, mediumPriority, highPriority }

void main() => runApp(MyApp());

class Task {
  String title;
  String description;
  bool isCompleted;
  TaskPriority priority;
  DateTime dueDate;

  Task(this.title, this.description, this.isCompleted, this.priority, this.dueDate);

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'priority': priority.toString(),
      'dueDate': dueDate.toIso8601String(),
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      map['title'],
      map['description'],
      map['isCompleted'],
      TaskPriority.values.firstWhere(
            (priority) => priority.toString() == map['priority'],
        orElse: () => TaskPriority.low,
      ),
      DateTime.parse(map['dueDate']),
    );
  }
}

class TaskProvider with ChangeNotifier {
  List<Task> _tasks = [];

  List<Task> get tasks => _tasks;

  Future<void> loadTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> taskStrings = prefs.getStringList('tasks') ?? [];

    _tasks = taskStrings.map((taskString) {
      Map<String, dynamic> taskData = Map.fromIterable(
        taskString.split('|'),
        key: (item) => item.split(':')[0],
        value: (item) => item.split(':')[1],
      );
      return Task.fromMap(taskData);
    }).toList();

    notifyListeners();
  }

  void saveTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> taskStrings = _tasks.map((task) {
      Map<String, dynamic> taskData = task.toMap();
      return taskData.entries.map((entry) {
        return '${entry.key}:${entry.value}';
      }).join('|');
    }).toList();

    prefs.setStringList('tasks', taskStrings);
  }

  void addTask(Task task) {
    _tasks.add(task);
    saveTasks();
    notifyListeners();
  }

  void editTask(int index, Task task) {
    _tasks[index] = task;
    saveTasks();
    notifyListeners();
  }

  void toggleTaskStatus(int index) {
    _tasks[index].isCompleted = !_tasks[index].isCompleted;
    saveTasks();
    notifyListeners();
  }

  void deleteTask(int index) {
    _tasks.removeAt(index);
    saveTasks();
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TaskProvider()..loadTasks(),
      child: MaterialApp(
        title: 'To-Do List App',
        theme: ThemeData(
          primarySwatch: Colors.brown,
        ),
        home: HomeScreen(),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TaskFilter _currentFilter = TaskFilter.all;

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    List<Task> filteredTasks = taskProvider.tasks;

    // Apply filters
    if (_currentFilter == TaskFilter.completed) {
      filteredTasks = filteredTasks.where((task) => task.isCompleted).toList();
    } else if (_currentFilter == TaskFilter.notCompleted) {
      filteredTasks = filteredTasks.where((task) => !task.isCompleted).toList();
    } else if (_currentFilter == TaskFilter.lowPriority) {
      filteredTasks = filteredTasks.where((task) => task.priority == TaskPriority.low).toList();
    } else if (_currentFilter == TaskFilter.mediumPriority) {
      filteredTasks = filteredTasks.where((task) => task.priority == TaskPriority.medium).toList();
    } else if (_currentFilter == TaskFilter.highPriority) {
      filteredTasks = filteredTasks.where((task) => task.priority == TaskPriority.high).toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('To-Do List App'),
        backgroundColor: Colors.brown,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Center(
                child: Text(
                  'Filters',
                  style: TextStyle(
                    fontSize: 60.0, // Adjust the font size as needed
                    fontWeight: FontWeight.bold, // Optionally, make it bold
                  ),
                ),
              ),
              decoration: BoxDecoration(
                color: Colors.brown,
              ),
            ),

            ListTile(
              title: Text('All Tasks'),
              onTap: () {
                setState(() {
                  _currentFilter = TaskFilter.all;
                  Navigator.pop(context);
                });
              },
              selected: _currentFilter == TaskFilter.all,
            ),
            ListTile(
              title: Text('Completed Tasks'),
              onTap: () {
                setState(() {
                  _currentFilter = TaskFilter.completed;
                  Navigator.pop(context);
                });
              },
              selected: _currentFilter == TaskFilter.completed,
            ),
            ListTile(
              title: Text('Not Completed Tasks'),
              onTap: () {
                setState(() {
                  _currentFilter = TaskFilter.notCompleted;
                  Navigator.pop(context);
                });
              },
              selected: _currentFilter == TaskFilter.notCompleted,
            ),
            ListTile(
              title: Text('Low Priority Tasks'),
              onTap: () {
                setState(() {
                  _currentFilter = TaskFilter.lowPriority;
                  Navigator.pop(context);
                });
              },
              selected: _currentFilter == TaskFilter.lowPriority,
            ),
            ListTile(
              title: Text('Medium Priority Tasks'),
              onTap: () {
                setState(() {
                  _currentFilter = TaskFilter.mediumPriority;
                  Navigator.pop(context);
                });
              },
              selected: _currentFilter == TaskFilter.mediumPriority,
            ),
            ListTile(
              title: Text('High Priority Tasks'),
              onTap: () {
                setState(() {
                  _currentFilter = TaskFilter.highPriority;
                  Navigator.pop(context);
                });
              },
              selected: _currentFilter == TaskFilter.highPriority,
            ),
            Divider(),
            ListTile(
              title: Text('Help'),
              onTap: () {
                Navigator.pop(context);
                showAboutDialog(
                  context: context,
                  applicationName: 'Instruction',
                  applicationLegalese: '''
  1. Add a New Task:
     - Tap the floating "+" button at the bottom right corner of the main screen.
     - Fill in the task details, including the title, description, priority, and due date.
     - Tap the "Add Task" button to create a new task.

  2. View Tasks:
     - The main screen displays a list of your tasks.
     - Each task shows its title, description, priority, due date, and completion status.
     - Tasks are color-coded based on their priority: High priority (orange), Medium priority (yellow), Low priority (light yellowish-green).

  3. Edit a Task:
     - To edit a task, tap on the task in the main screen list.
     - Update the task details as needed, including the title, description, priority, and due date.
     - Tap the "Update Task" button to save your changes.

  4. Delete a Task:
     - To delete a task, press and hold the task in the main screen list.
     - A confirmation prompt will appear. Tap "Yes" to delete the task or "Cancel" to keep it.

  5. Mark Task as Complete:
     - To mark a task as complete, tap the checkbox next to the task title in the main screen list.
     - The task's text color will change to brown to indicate that it's completed.

  6. Filter Tasks:
     - Open the filter drawer by tapping the menu icon (three horizontal lines) at the top left corner of the main screen.
     - You can filter tasks by different criteria:
       - "All Tasks": Shows all tasks.
       - "Completed Tasks": Displays only completed tasks.
       - "Not Completed Tasks": Displays only tasks that are not completed.
       - "Low Priority Tasks": Shows tasks with low priority (light yellowish-green).
       - "Medium Priority Tasks": Shows tasks with medium priority (yellow).
       - "High Priority Tasks": Shows tasks with high priority (orange).

  7. About Color Coding:
     - The app uses color coding to visually represent task priorities and completion status:
       - High Priority: Orange
       - Medium Priority: Yellow
       - Low Priority: Light yellowish-green
       - Completed Task: Text color changes to brown

  These instructions should help you use the to-do list app effectively. You can easily add, edit, delete, and filter tasks based on your preferences and priorities.
  ''',
                );
              },
            ),
            ListTile(
              title: Text('About'),
              onTap: () {
                Navigator.pop(context);
                showAboutDialog(
                  context: context,
                  applicationName: 'To-Do List App',
                  applicationVersion: '1.0',
                  applicationLegalese: 'Created by Amit Kumar Singh',
                );
              },
            ),
          ],
        ),
      ),
      body: ListView.builder(
        itemCount: filteredTasks.length,
        itemBuilder: (context, index) {
          final task = filteredTasks[index];
          Color taskColor;
          if (task.priority == TaskPriority.high) {
            taskColor = Colors.orange;
          } else if (task.priority == TaskPriority.medium) {
            taskColor = Colors.yellow;
          } else {
            taskColor = Colors.lightGreen;
          }

          return ListTile(
            title: Text(
              task.title,
              style: TextStyle(
                color: task.isCompleted ? Colors.brown : Colors.black,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  task.description,
                  style: TextStyle(
                    color: task.isCompleted ? Colors.brown : Colors.grey,
                  ),
                ),
                Text(
                  'Due Date: ${DateFormat('dd/MM/yyyy').format(task.dueDate)}',
                  style: TextStyle(
                    color: Colors.cyan,
                  ),
                ),
              ],
            ),
            trailing: Checkbox(
              value: task.isCompleted,
              onChanged: (_) {
                taskProvider.toggleTaskStatus(index);
              },
            ),
            tileColor: taskColor,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TaskEditScreen(index: index),
                ),
              );
            },
            onLongPress: () {
              taskProvider.deleteTask(index);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TaskEditScreen(),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class TaskEditScreen extends StatefulWidget {
  final int? index;

  TaskEditScreen({this.index});

  @override
  _TaskEditScreenState createState() => _TaskEditScreenState();
}

class _TaskEditScreenState extends State<TaskEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  TaskPriority _selectedPriority = TaskPriority.medium;
  DateTime _selectedDueDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.index != null) {
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      final task = taskProvider.tasks[widget.index!];
      _titleController.text = task.title;
      _descriptionController.text = task.description;
      _selectedPriority = task.priority;
      _selectedDueDate = task.dueDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.index != null ? 'Edit Task' : 'Create Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
              SizedBox(height: 16.0),
              DropdownButtonFormField<TaskPriority>(
                value: _selectedPriority,
                onChanged: (priority) {
                  setState(() {
                    _selectedPriority = priority!;
                  });
                },
                items: TaskPriority.values.map((priority) {
                  return DropdownMenuItem(
                    value: priority,
                    child: Text(priority.toString().split('.').last),
                  );
                }).toList(),
                decoration: InputDecoration(labelText: 'Priority'),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Due Date'),
                readOnly: true,
                controller: TextEditingController(
                  text: DateFormat('dd/MM/yyyy').format(_selectedDueDate),
                ),
                onTap: () async {
                  final selectedDate = await showDatePicker(
                    context: context,
                    initialDate: _selectedDueDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2101),
                  );

                  if (selectedDate != null && selectedDate != _selectedDueDate) {
                    setState(() {
                      _selectedDueDate = selectedDate;
                    });
                  }
                },
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState != null &&
                      _formKey.currentState!.validate()) {
                    final taskProvider =
                    Provider.of<TaskProvider>(context, listen: false);

                    if (widget.index != null) {
                      taskProvider.editTask(
                        widget.index!,
                        Task(
                          _titleController.text,
                          _descriptionController.text,
                          taskProvider.tasks[widget.index!].isCompleted,
                          _selectedPriority,
                          _selectedDueDate,
                        ),
                      );
                    } else {
                      taskProvider.addTask(
                        Task(
                          _titleController.text,
                          _descriptionController.text,
                          false,
                          _selectedPriority,
                          _selectedDueDate,
                        ),
                      );
                    }

                    Navigator.pop(context);
                  }
                },
                child: Text(widget.index != null ? 'Update Task' : 'Add Task'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

