import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';

import '../models/task_model.dart'; // Import the model

// The StateNotifier class that holds all the business logic for the task list.
class TaskNotifier extends StateNotifier<List<Task>> {
  TaskNotifier()
      : super([
          Task(id: '1', title: 'Learn Flutter State Management', isCompleted: true),
          Task(id: '2', title: 'Create a multi-file structure'),
          Task(id: '3', title: 'Submit project to GitHub'),
        ]);

  void addTask(String title) {
    if (title.isEmpty) return;
    state = [
      ...state,
      Task(id: Random().nextDouble().toString(), title: title),
    ];
  }

  void removeTask(String taskId) {
    state = state.where((task) => task.id != taskId).toList();
  }

  void toggle(String taskId) {
    state = [
      for (final task in state)
        if (task.id == taskId)
          // Use the copyWith method for cleaner updates
          task.copyWith(isCompleted: !task.isCompleted)
        else
          task,
    ];
  }
}

// --- PROVIDERS ---

// Provider for the task list state itself
final tasksProvider = StateNotifierProvider<TaskNotifier, List<Task>>((ref) {
  return TaskNotifier();
});

// A "derived" provider that calculates the summary string from the tasksProvider.
// It will automatically update when the task list changes.
final summaryProvider = Provider<String>((ref) {
  final tasks = ref.watch(tasksProvider);
  final completedCount = tasks.where((task) => task.isCompleted).length;
  return '$completedCount / ${tasks.length}';
});

// A provider for the text field's controller.
// Using autoDispose will automatically clean up the controller when the widget is removed.
final textEditingControllerProvider =
    Provider.autoDispose<TextEditingController>((ref) {
  return TextEditingController();
});