import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class Task {
  String title;
  TimeOfDay time;
  int priority;
  bool isCompleted;

  Task({
    required this.title,
    required this.time,
    required this.priority,
    this.isCompleted = false,
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Organizador de Tarefas',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const TaskManagerHome(),
    );
  }
}

class TaskManagerHome extends StatefulWidget {
  const TaskManagerHome({super.key});

  @override
  State<TaskManagerHome> createState() => _TaskManagerHomeState();
}

class _TaskManagerHomeState extends State<TaskManagerHome> {
  final List<Task> _tasks = [];
  int _currentIndex = 0;

  void _addTask() async {
    final result = await showDialog<Task>(
      context: context,
      builder: (context) => AddTaskDialog(),
    );
    
    if (result != null) {
      setState(() {
        _tasks.add(result);
      });
    }
  }

  void _deleteTask(int index) {
    setState(() {
      _tasks.removeAt(index);
    });
  }

  void _toggleTaskComplete(int index) {
    setState(() {
      _tasks[index].isCompleted = !_tasks[index].isCompleted;
    });
  }

  @override
  Widget build(BuildContext context) {
    final activeTasks = _tasks.where((task) => !task.isCompleted).toList();
    final completedTasks = _tasks.where((task) => task.isCompleted).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(_currentIndex == 0 ? 'Tarefas Pendentes' : 'Tarefas Concluídas'),
        backgroundColor: Colors.deepPurple[900],
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: _currentIndex == 0
                ? TaskList(
                    tasks: activeTasks,
                    onDelete: _deleteTask,
                    onToggle: _toggleTaskComplete,
                  )
                : TaskList(
                    tasks: completedTasks,
                    onDelete: _deleteTask,
                    onToggle: _toggleTaskComplete,
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            alignment: Alignment.center,
            child: const Text(
              'Desenvolvido por Felipe de Andrade Godoi',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: _addTask,
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Pendentes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.done_all),
            label: 'Concluídas',
          ),
        ],
      ),
    );
  }
}

class TaskList extends StatelessWidget {
  final List<Task> tasks;
  final Function(int) onDelete;
  final Function(int) onToggle;

  const TaskList({
    super.key,
    required this.tasks,
    required this.onDelete,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return ListTile(
          leading: Checkbox(
            value: task.isCompleted,
            onChanged: (_) => onToggle(index),
          ),
          title: Text(task.title),
          subtitle: Text('Horário: ${task.time.format(context)} - Prioridade: ${task.priority}'),
          trailing: IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => onDelete(index),
          ),
        );
      },
    );
  }
}

class AddTaskDialog extends StatefulWidget {
  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  final _titleController = TextEditingController();
  TimeOfDay _selectedTime = TimeOfDay.now();
  int _priority = 1;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nova Tarefa'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'Título da Tarefa'),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text('Horário: '),
              TextButton(
                onPressed: () async {
                  final TimeOfDay? time = await showTimePicker(
                    context: context,
                    initialTime: _selectedTime,
                  );
                  if (time != null) {
                    setState(() => _selectedTime = time);
                  }
                },
                child: Text(_selectedTime.format(context)),
              ),
            ],
          ),
          Row(
            children: [
              const Text('Prioridade: '),
              Slider(
                value: _priority.toDouble(),
                min: 1,
                max: 5,
                divisions: 4,
                label: _priority.toString(),
                onChanged: (value) => setState(() => _priority = value.round()),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () {
            if (_titleController.text.isNotEmpty) {
              Navigator.of(context).pop(
                Task(
                  title: _titleController.text,
                  time: _selectedTime,
                  priority: _priority,
                ),
              );
            }
          },
          child: const Text('Adicionar'),
        ),
      ],
    );
  }
}
