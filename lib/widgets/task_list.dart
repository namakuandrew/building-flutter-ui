import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart'; // For the empty state image
import '../models/task_model.dart';
import '../providers/task_provider.dart';

class TaskList extends ConsumerWidget {
  const TaskList({super.key});

  // Dialog for deleting a task
  void _showDeleteConfirmationDialog(
      BuildContext context, WidgetRef ref, String taskId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2C2C2C),
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this task?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                // Call the async removeTask method
                ref.read(tasksProvider.notifier).removeTask(taskId);
                Navigator.of(context).pop();
              },
              child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
            ),
          ],
        );
      },
    );
  }

  // Dialog for editing a task
  void _showEditTaskDialog(BuildContext context, WidgetRef ref, Task task) {
    final controller = ref.read(textEditingControllerProvider);
    controller.text = task.title;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2C2C2C),
          title: const Text('Edit Task'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'New task title'),
            style: const TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                // Call the async editTask method
                ref
                    .read(tasksProvider.notifier)
                    .editTask(task.id, controller.text);
                Navigator.of(context).pop();
              },
              child: const Text('Save', style: TextStyle(color: Colors.teal)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Watch the provider. It now returns an AsyncValue
    final tasksAsyncValue = ref.watch(filteredTasksProvider);

    // 2. Use .when() to handle the three possible states
    return tasksAsyncValue.when(
      // 2a. The data is available
      data: (tasks) {
        // This is our old UI, which we now return in the 'data' case
        if (tasks.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.string(
                  _emptyTasksSvg,
                  height: 150,
                ),
                const SizedBox(height: 20),
                const Text(
                  'All tasks completed!',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            return Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                onTap: () {
                  // Call the async toggle method
                  ref.read(tasksProvider.notifier).toggle(task.id);
                },
                leading: Icon(
                  task.isCompleted
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: task.isCompleted ? Colors.teal : Colors.grey,
                ),
                title: Text(
                  task.title,
                  style: TextStyle(
                    decoration: task.isCompleted
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                    color: task.isCompleted ? Colors.grey : Colors.white,
                    fontSize: 16,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined,
                          color: Colors.grey, size: 20),
                      onPressed: () => _showEditTaskDialog(context, ref, task),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline,
                          color: Colors.redAccent, size: 20),
                      onPressed: () =>
                          _showDeleteConfirmationDialog(context, ref, task.id),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      // 2b. An error occurred
      error: (error, stackTrace) => Center(
        child: Text(
          'Error: $error',
          style: const TextStyle(color: Colors.redAccent),
        ),
      ),
      // 2c. The data is still loading
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  // SVG data for the empty state image
  final String _emptyTasksSvg = '''
  <svg width="800px" height="800px" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path d="M9 12L11 14L15 10M20.6179 15.608C20.482 16.593 19.8875 17.458 19.006 18.006C18.1244 18.5541 17.068 18.7297 16.0361 18.5064C15.0042 18.2831 14.1103 17.6795 13.538 16.8407C12.9658 16.0019 12.7661 15.0001 12.9875 14.025C13.2089 13.0499 13.8306 12.2033 14.6947 11.7045C15.5587 11.2057 16.5866 11.0964 17.551 11.4017C18.5154 11.707 19.3113 12.4045 19.742 13.313C20.1727 14.2215 20.198 15.2604 19.813 16.18C19.6222 16.6343 19.349 17.0366 19.006 17.368M17 3H12C10.8954 3 10 3.89543 10 5V6H9C7.89543 6 7 6.89543 7 8V18C7 19.1046 7.89543 20 9 20H15C16.1046 20 17 19.1046 17 18V8C17 6.89543 16.1046 6 15 6H14V5C14 3.89543 13.1046 3 12 3ZM10 8H14V18H10V8Z" stroke="#4a4a4a" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
  </svg>
  ''';
}