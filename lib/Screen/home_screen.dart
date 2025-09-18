import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui/widgets/new_task_input.dart'; 
import 'package:ui/widgets/task_list.dart'; 
import 'package:ui/widgets/task_summary_card.dart'; 

// The HomeScreen is now a clean container that assembles the other widgets.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Tasks',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: const Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TaskSummaryCard(),
            SizedBox(height: 25),
            NewTaskInput(),
            SizedBox(height: 25),
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
