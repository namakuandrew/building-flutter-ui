import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/task_provider.dart';

class NewTaskInput extends ConsumerWidget {
  const NewTaskInput({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // We watch the controller provider to get the controller instance.
    final textController = ref.watch(textEditingControllerProvider);

    return TextField(
      controller: textController,
      decoration: InputDecoration(
        hintText: 'Add a new task...',
        filled: true,
        fillColor: const Color(0xFF2C2C2C),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        suffixIcon: IconButton(
          icon: const Icon(Icons.add_circle, color: Colors.teal),
          onPressed: () {
            // We use ref.read to call a method on our notifier.
            // This adds the task and clears the text field.
            ref.read(tasksProvider.notifier).addTask(textController.text);
            textController.clear();
          },
        ),
      ),
      // This allows submitting with the keyboard's "done" button.
      onSubmitted: (value) {
        ref.read(tasksProvider.notifier).addTask(value);
        textController.clear();
      },
    );
  }
}