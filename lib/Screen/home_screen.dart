import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/user_provider.dart'; 
import '../providers/task_provider.dart';
import 'package:ui/widgets/task_list.dart'; 
import 'package:ui/widgets/task_summary_card.dart'; 

// The HomeScreen is now a clean container that assembles the other widgets.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  // 2. Add the method to show our new dialog
  void _showEditNameDialog(BuildContext context, WidgetRef ref, String currentName) {
    // We can re-use the text controller provider from task_provider.dart
    final controller = TextEditingController();

    // Pre-fill the text field with the current name (if it's loaded)
    final currentName = ref.read(userNameProvider).valueOrNull ?? '';
    // Don't pre-fill if the name is the default 'My'
    controller.text = currentName == 'My' ? '' : currentName;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2C2C2C),
          title: const Text('Enter Your Name'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
                hintText: 'Your name...', hintStyle: TextStyle(color: Colors.grey)),
            style: const TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                String newName = controller.text.trim();
                if (newName.isEmpty) {
                  // If they clear the name, reset it to 'My'
                  newName = 'My';
                }
                // Call the notifier's method to save the name
                ref.read(userNameProvider.notifier).updateName(newName);
                Navigator.of(context).pop();
              },
              child: const Text('Save', style: TextStyle(color: Colors.teal)),
            ),
          ],
        );
      },
    );
  }

  // This new method shows a modal bottom sheet for adding a task.
  void _showAddTaskModal(BuildContext context, WidgetRef ref) {
    // A *new* local controller just for this sheet
    final controller = TextEditingController();

    showModalBottomSheet(
      context: context,
      // This ensures the sheet moves up with the keyboard
      isScrollControlled: true,
      // Transparent background to show our rounded corners
      backgroundColor: Colors.transparent,
      builder: (context) {
        return
            // Padding to avoid the keyboard
            Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFF2C2C2C), // Our card color
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Take only needed space
              children: [
                const Text(
                  'Add New Task',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                // Use a new TextField, not the NewTaskInput widget
                TextField(
                  controller: controller,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'What do you need to do?',
                    filled: true,
                    fillColor: const Color(0xFF1A1A1A), // Background color
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // A dedicated "Save" button for the modal
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: () {
                    final title = controller.text;
                    if (title.isNotEmpty) {
                      // Call the provider directly to add the task
                      ref.read(tasksProvider.notifier).addTask(title);
                      // Close the bottom sheet
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text(
                    'Save Task',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  // 3. Change build method to accept WidgetRef
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 4. Watch the new provider
    final userNameAsync = ref.watch(userNameProvider);

    final currentFilter = ref.watch(taskFilterStateProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskModal(context, ref), // Pass ref
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      appBar: AppBar(
        // 5. Update the title to be dynamic using .when()
        title: userNameAsync.when(
          data: (name) => Text(
            "$name's Tasks",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          ),
          error: (e, st) => const Text(
            'My Tasks', // Fallback title on error
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          ),
          loading: () => const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        // 6. Add the 'actions' button to edit the name
        actions: [
          userNameAsync.when(
            data: (name) => IconButton(
              icon: const Icon(Icons.edit_note_outlined,
                  color: Colors.grey, size: 30),
              // Pass the loaded name to the dialog
              onPressed: () => _showEditNameDialog(context, ref, name)
            ),
            loading: () => const SizedBox.shrink(), // No button while loading
            error: (e, s) => const SizedBox.shrink(), // No button on error
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TaskSummaryCard(),
            SizedBox(height: 25),
             // --- NEW: Add the SegmentedButton for filtering ---
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<TaskFilter>(
                // The set of segments to display
                segments: const [
                  ButtonSegment(
                      value: TaskFilter.all,
                      label: Text('All'),
                      icon: Icon(Icons.list_alt_outlined)),
                  ButtonSegment(
                      value: TaskFilter.pending,
                      label: Text('Pending'),
                      icon: Icon(Icons.hourglass_bottom_outlined)),
                  ButtonSegment(
                      value: TaskFilter.completed,
                      label: Text('Completed'),
                      icon: Icon(Icons.check_circle_outline)),
                ],
                // The currently selected segment
                selected: {currentFilter},
                // The callback when the user selects a new segment
                onSelectionChanged: (Set<TaskFilter> newFilter) {
                  // Update the provider with the new filter
                  // We use .first because only one can be selected
                  ref
                      .read(taskFilterStateProvider.notifier)
                      .setFilter(newFilter.first);
                },
                style: SegmentedButton.styleFrom(
                  backgroundColor: const Color(0xFF2C2C2C),
                  foregroundColor: Colors.grey,
                  selectedForegroundColor: Colors.white,
                  selectedBackgroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),

            Text(
              'Today\'s Tasks',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 15),
            Expanded(
              child: TaskList(),
            ),
          ],
        ),
      ),
    );
  }
}