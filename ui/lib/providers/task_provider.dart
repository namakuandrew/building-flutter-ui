import 'dart:async';
import 'dart:math'; // For generating random IDs
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/task_model.dart';
import '../services/database_helper.dart'; // Import our new DatabaseHelper

part 'task_provider.g.dart';

// 1. We keep this as an AsyncNotifier. It's perfect for database calls.
@Riverpod(keepAlive: true)
class Tasks extends _$Tasks {
  // Get an instance of the database helper
  DatabaseHelper get dbHelper => ref.watch(databaseHelperProvider);

  @override
  Future<List<Task>> build() async {
    // The build method now just fetches the initial list of tasks
    return await dbHelper.getTasks();
  }

  // --- CRUD Methods ---

  Future<void> addTask(String title) async {
    if (title.isEmpty) return;

    // Create a new task object
    final newTask = Task(
      id: Random().nextDouble().toString(), // Simple unique ID
      title: title,
    );

    // Set the state to loading
    state = const AsyncValue.loading();

    // Optimistic UI update:
    // We get the current list of tasks from the (now loaded) state
    final oldState = state.valueOrNull ?? [];
    // We add the new task immediately to the UI
    state = AsyncValue.data([...oldState, newTask]);

    try {
      // We try to insert into the database.
      // We use newTask.toJson() which converts bool to int
      await dbHelper.insert(newTask);
      // No need to re-fetch, the UI is already correct.
    } catch (e) {
      // If the database insert fails, revert the state
      state = AsyncValue.data(oldState);
      // You could also set an error state here
      // state = AsyncValue.error(e, StackTrace.current);
    }
  }

Future<void> toggle(String taskId) async {
  final oldState = state.valueOrNull ?? [];
  Task? taskToUpdate;

  // Build a new list immutably
  final newState = oldState.map((task) {
    if (task.id == taskId) {
      taskToUpdate = task.copyWith(isCompleted: !task.isCompleted);
      return taskToUpdate!;
    }
    return task;
  }).toList();

  if (taskToUpdate == null) return; // Task not found

  // Optimistic UI update
  state = AsyncValue.data(newState);

  try {
    await dbHelper.update(taskToUpdate!);
  } catch (e) {
    // Revert on failure
    state = AsyncValue.data(oldState);
  }
}


Future<void> editTask(String taskId, String newTitle) async {
  if (newTitle.isEmpty) return;

  final oldState = state.valueOrNull ?? [];
  Task? taskToUpdate;

  final newState = oldState.map((task) {
    if (task.id == taskId) {
      taskToUpdate = task.copyWith(title: newTitle);
      return taskToUpdate!;
    }
    return task;
  }).toList();

  if (taskToUpdate == null) return;

  state = AsyncValue.data(newState);

  try {
    await dbHelper.update(taskToUpdate!);
  } catch (e) {
    state = AsyncValue.data(oldState);
  }
}


  Future<void> removeTask(String taskId) async {
    final oldState = state.valueOrNull ?? [];

    // Optimistic UI update
    // Create a new list *without* the task
    state = AsyncValue.data(oldState.where((t) => t.id != taskId).toList());

    try {
      // Delete from the database
      await dbHelper.delete(taskId);
    } catch (e) {
      // Revert on error
      state = AsyncValue.data(oldState);
    }
  }
}

// --- Other Providers (No changes needed) ---

// This derived provider still works perfectly!
// It just watches the tasksProvider and doesn't care where the data comes from.

final textEditingControllerProvider =
    Provider.autoDispose<TextEditingController>((ref) {
  return TextEditingController();
});

// --- NEW FILTERING LOGIC ---

// 1. Define the possible filter states
enum TaskFilter { all, pending, completed }

// 2. Create a provider to hold the *current* filter state
// We default to showing all tasks
@riverpod
class TaskFilterState extends _$TaskFilterState {
  @override
  TaskFilter build() => TaskFilter.all;

  void setFilter(TaskFilter filter) {
    state = filter;
  }
}

// 3. Create a *derived* provider that returns the filtered list
@riverpod
AsyncValue<List<Task>> filteredTasks(FilteredTasksRef ref) {
  // Get the current filter state
  final filter = ref.watch(taskFilterStateProvider);
  // Watch the AsyncValue state of the main tasks provider
  final tasksAsync = ref.watch(tasksProvider);

  // Use .whenData to transform the list *if* it has data,
  // while automatically passing through loading/error states.
  return tasksAsync.whenData((tasks) {
    // Return the correct list based on the filter
    switch (filter) {
      case TaskFilter.completed:
        return tasks.where((task) => task.isCompleted).toList();
      case TaskFilter.pending:
        return tasks.where((task) => !task.isCompleted).toList();
      case TaskFilter.all:
      default:
        return tasks;
    }
  });
}

// --- UPDATED SUMMARY PROVIDER (CONVERTED) ---

// This derived provider now watches the *filtered* list
// so the summary matches what the user sees.
@riverpod
AsyncValue<String> summary(SummaryRef ref) {
  // Watch the new filteredTasks provider (which returns an AsyncValue)
  final tasksAsync = ref.watch(filteredTasksProvider);

  // Transform the filtered list's AsyncValue into a summary string AsyncValue
  return tasksAsync.whenData((tasks) {
    final completedCount = tasks.where((task) => task.isCompleted).length;
    // The summary will now be "X / Y" of the *filtered* list
    return '$completedCount / ${tasks.length}';
  });
}