import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/task_provider.dart';

// Converted to a ConsumerStatefulWidget to hold the local loading state
class NewTaskInput extends ConsumerStatefulWidget {
  const NewTaskInput({super.key});

  @override
  ConsumerState<NewTaskInput> createState() => _NewTaskInputState();
}

class _NewTaskInputState extends ConsumerState<NewTaskInput> {
  bool _isLoading = false;

  // Handles submitting the new task
  void _submitTask(String value) async {
    // Don't submit if the text is empty
    if (value.isEmpty) return;
    if (_isLoading) return; 

    // 1. Set local state to true to show spinner
    setState(() {
      _isLoading = true;
    });

    // Simulate network delay for a better user experience
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      // 2. Call the async addTask method and AWAIT its completion
      await ref.read(tasksProvider.notifier).addTask(value);

      // 3. Clear the text field if the widget is still on screen
      if (mounted) {
        ref.read(textEditingControllerProvider).clear();
      }
    } catch (e) {
      // Optional: Show a snackbar or error if adding fails
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add task: $e')),
        );
      }
    }

    // 4. Set local state to false to hide spinner
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch the controller provider
    final textController = ref.watch(textEditingControllerProvider);

    return TextField(
      controller: textController,
      // Submit when the user presses 'done' on the keyboard
      onSubmitted: (value) => _submitTask(value),
      decoration: InputDecoration(
        hintText: 'Add a new task...',
        filled: true,
        fillColor: const Color(0xFF2C2C2C),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        // Conditionally show spinner or add button
        suffixIcon: _isLoading
            ? const Padding(
                padding: EdgeInsets.all(12.0),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.teal,
                ),
              )
            : IconButton(
                icon: const Icon(Icons.add_circle, color: Colors.teal, size: 30),
                onPressed: () => _submitTask(textController.text),
              ),
      ),
    );
  }
}

