import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/user_provider.dart';
import '../providers/task_provider.dart';
import '../models/task_model.dart';
import 'package:ui/widgets/task_list.dart';
import 'package:ui/widgets/task_summary_card.dart';
import 'package:ui/widgets/activity_heatmap.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

  // --- STATS TAB STATE ---
  String _statsType = 'Monthly'; 
  int _statsYear = DateTime.now().year;
  int _statsMonth = DateTime.now().month;

  // --- DIALOG & SHEET METHODS ---
  void _showEditNameDialog(BuildContext context, WidgetRef ref, String currentName) {
    final controller = TextEditingController(text: currentName == 'My' ? '' : currentName);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF242424),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text('Enter Your Name', style: TextStyle(fontWeight: FontWeight.bold)),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Your name...',
              hintStyle: const TextStyle(color: Colors.grey),
              filled: true,
              fillColor: Colors.black26,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            ),
            style: const TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                String newName = controller.text.trim();
                if (newName.isEmpty) newName = 'My';
                ref.read(userNameProvider.notifier).updateName(newName);
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showAddTaskSheet(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController(); 
    String? selectedFolder;
    
    final tasks = ref.read(tasksProvider).valueOrNull ?? [];
    final existingFolders = tasks
        .where((t) => t.title.startsWith('[') && t.title.contains(']'))
        .map((t) => t.title.substring(1, t.title.indexOf(']')))
        .toSet()
        .toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            
            void showCreateProjectDialog() {
              final projectController = TextEditingController();
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: const Color(0xFF242424),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  title: const Text('New Project', style: TextStyle(fontWeight: FontWeight.bold)),
                  content: TextField(
                    controller: projectController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Project Name (e.g. Work, Health)',
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.black26,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.grey))),
                    TextButton(
                      onPressed: () {
                        if (projectController.text.trim().isNotEmpty) {
                          final newProject = projectController.text.trim();
                          setModalState(() {
                            if (!existingFolders.contains(newProject)) {
                              existingFolders.add(newProject);
                            }
                            selectedFolder = newProject;
                          });
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('Create', style: TextStyle(color: Colors.teal)),
                    ),
                  ],
                ),
              );
            }

            return BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Padding(
                padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: Color(0xE61E1E1E),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
                        ),
                      ),
                      const Text('Add a new task', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Assign to Project', style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w600)),
                          GestureDetector(
                            onTap: showCreateProjectDialog,
                            child: const Text('+ New Project', style: TextStyle(color: Colors.teal, fontSize: 13, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            ChoiceChip(
                              label: const Text('General'),
                              selected: selectedFolder == null,
                              onSelected: (selected) => setModalState(() => selectedFolder = null),
                              backgroundColor: Colors.transparent,
                              selectedColor: Colors.teal.withOpacity(0.4),
                              side: BorderSide(color: selectedFolder == null ? Colors.teal : Colors.white10),
                            ),
                            const SizedBox(width: 8),
                            ...existingFolders.map((folder) => Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: ChoiceChip(
                                label: Text(folder),
                                selected: selectedFolder == folder,
                                onSelected: (selected) => setModalState(() => selectedFolder = folder),
                                backgroundColor: Colors.transparent,
                                selectedColor: Colors.teal.withOpacity(0.4),
                                side: BorderSide(color: selectedFolder == folder ? Colors.teal : Colors.white10),
                              ),
                            )),
                            const SizedBox(width: 4),
                            IconButton(
                              onPressed: showCreateProjectDialog,
                              icon: const Icon(Icons.add_circle_outline, color: Colors.white24, size: 28),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      TextField(
                        controller: controller,
                        autofocus: true,
                        style: const TextStyle(fontSize: 18),
                        decoration: InputDecoration(
                          hintText: 'What\'s on your mind?',
                          filled: true,
                          fillColor: Colors.black38,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                          suffixIcon: Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: IconButton(
                              icon: const Icon(Icons.arrow_upward_rounded, color: Colors.teal, size: 28),
                              onPressed: () {
                                if (controller.text.isNotEmpty) {
                                  final finalTitle = selectedFolder != null 
                                      ? '[$selectedFolder] ${controller.text}' 
                                      : controller.text;
                                  ref.read(tasksProvider.notifier).addTask(finalTitle);
                                  Navigator.of(context).pop();
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            );
          }
        );
      },
    );
  }

  void _dismissFolder(BuildContext context, WidgetRef ref, String folderName, List<Task> tasks) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Dismiss $folderName?'),
        content: const Text('This will remove all tasks associated with this project. This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              final folderPrefix = '[$folderName]';
              for (var task in tasks) {
                if (task.title.startsWith(folderPrefix)) {
                  ref.read(tasksProvider.notifier).removeTask(task.id);
                }
              }
              Navigator.pop(context);
            },
            child: const Text('Dismiss', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userNameAsync = ref.watch(userNameProvider);
    final allTasksAsync = ref.watch(tasksProvider); 

    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: userNameAsync.when(
            data: (name) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedIndex == 0 ? "Hello, $name" : "Your Stats",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 28, letterSpacing: -0.5),
                ),
                if (_selectedIndex == 0)
                  const Text("Let's get things done today.", style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w400)),
              ],
            ),
            error: (e, st) => const Text('My Tasks'),
            loading: () => const SizedBox.shrink(),
          ),
        ),
        actions: [
          if (_selectedIndex == 0)
            userNameAsync.when(
              data: (name) => Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: CircleAvatar(
                  backgroundColor: Colors.teal.withOpacity(0.1),
                  child: IconButton(
                    icon: const Icon(Icons.settings_outlined, color: Colors.teal, size: 24),
                    onPressed: () => _showEditNameDialog(context, ref, name),
                  ),
                ),
              ),
              loading: () => const SizedBox.shrink(),
              error: (e, s) => const SizedBox.shrink(),
            ),
        ],
      ),
      body: Stack(
        children: [
          _selectedIndex == 0 
            ? _buildTasksTab(context, ref, allTasksAsync)
            : _buildStatsTab(allTasksAsync),
          
          Positioned(
            left: 20,
            right: 20,
            bottom: 30,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildNavItem(0, Icons.grid_view_rounded, "Tasks"),
                      _buildNavItem(1, Icons.analytics_rounded, "Stats"),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _selectedIndex == 0
          ? Padding(
              padding: const EdgeInsets.only(bottom: 100.0),
              child: FloatingActionButton.large(
                onPressed: () => _showAddTaskSheet(context, ref),
                backgroundColor: Colors.teal,
                elevation: 10,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: const Icon(Icons.add_rounded, color: Colors.white, size: 36),
              ),
            )
          : null,
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: isSelected ? Colors.teal : Colors.white38, size: 26),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: isSelected ? Colors.teal : Colors.white38, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildTasksTab(BuildContext context, WidgetRef ref, AsyncValue<List<Task>> allTasksAsync) {
    final currentFilter = ref.watch(taskFilterStateProvider);
    
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const TaskSummaryCard(),
                const SizedBox(height: 32),
                const Text('Active Projects', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
                const SizedBox(height: 16),
                allTasksAsync.when(
                  data: (tasks) => _buildFolderGrid(tasks),
                  loading: () => const SizedBox(height: 120, child: Center(child: CircularProgressIndicator())),
                  error: (_, __) => const SizedBox.shrink(),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    const Expanded(child: Text('All Tasks', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: -0.5))),
                    _buildFilterPill(ref, TaskFilter.all, "All", currentFilter),
                    const SizedBox(width: 8),
                    _buildFilterPill(ref, TaskFilter.pending, "ToDo", currentFilter),
                    const SizedBox(width: 8),
                    _buildFilterPill(ref, TaskFilter.completed, "Done", currentFilter),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
        // FIXED: Using TaskList directly as a Sliver.
        // TaskList now returns a SliverList, so we must not wrap it in SliverToBoxAdapter.
        const SliverPadding(
          padding: EdgeInsets.fromLTRB(20, 0, 20, 180),
          sliver: TaskList(),
        ),
      ],
    );
  }

  Widget _buildFilterPill(WidgetRef ref, TaskFilter filter, String label, TaskFilter current) {
    bool isSelected = filter == current;
    return GestureDetector(
      onTap: () => ref.read(taskFilterStateProvider.notifier).setFilter(filter),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.teal : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? Colors.teal : Colors.white10),
        ),
        child: Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.grey, fontSize: 12)),
      ),
    );
  }

  Widget _buildFolderGrid(List<Task> tasks) {
    final Map<String, List<Task>> folders = {};
    for (var task in tasks) {
      if (task.title.startsWith('[') && task.title.contains(']')) {
        final folderName = task.title.substring(1, task.title.indexOf(']'));
        folders.putIfAbsent(folderName, () => []).add(task);
      }
    }
    folders.removeWhere((name, taskList) => taskList.every((t) => t.isCompleted));

    if (folders.isEmpty) {
      return Container(
        height: 110,
        width: double.infinity,
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.03), borderRadius: BorderRadius.circular(24)),
        child: const Center(child: Text('No active projects', style: TextStyle(color: Colors.white24, fontSize: 13))),
      );
    }

    return SizedBox(
      height: 170, // FIXED: Increased height to 170 to accommodate internal padding and spacers
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: folders.keys.length,
        itemBuilder: (context, index) {
          final folderName = folders.keys.elementAt(index);
          final folderTasks = folders[folderName]!;
          final completed = folderTasks.where((t) => t.isCompleted).length;
          final total = folderTasks.length;
          final double progress = completed / total;

          return Container(
            width: 180,
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, // FIXED: Added min size
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.teal.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.folder_copy_rounded, color: Colors.teal, size: 18),
                    ),
                    IconButton(
                      icon: const Icon(Icons.more_horiz_rounded, color: Colors.white24, size: 18),
                      onPressed: () => _dismissFolder(context, ref, folderName, tasks),
                    ),
                  ],
                ),
                const Spacer(), // Pushes text and progress to bottom
                Text(
                  folderName, 
                  maxLines: 1, 
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, overflow: TextOverflow.ellipsis)
                ),
                const SizedBox(height: 8),
                Text('$completed/$total Tasks', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress, 
                    backgroundColor: Colors.white.withOpacity(0.05), 
                    color: Colors.teal, 
                    minHeight: 6
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsTab(AsyncValue<List<Task>> allTasksAsync) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 120),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Quick Insights", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
            const SizedBox(height: 20),
            allTasksAsync.when(
              data: (tasks) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildQuickMetricsRow(tasks),
                  const SizedBox(height: 32),
                  const Text("Consistency Map", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
                  const SizedBox(height: 16),
                  ActivityHeatmap(tasks: tasks),
                  const SizedBox(height: 32),
                  const Text("Trend Analysis", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
                  const SizedBox(height: 16),
                  _buildCompletionStatsCard(tasks),
                ],
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Center(child: Text("Error: $e")),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickMetricsRow(List<Task> tasks) {
    final int streak = _calculateStreak(tasks);
    final double rate = tasks.isEmpty ? 0 : (tasks.where((t) => t.isCompleted).length / tasks.length) * 100;
    return Row(
      children: [
        Expanded(child: _buildMetricCard(title: "Streak", value: "$streak Days", icon: Icons.local_fire_department_rounded, color: Colors.orangeAccent)),
        const SizedBox(width: 16),
        Expanded(child: _buildMetricCard(title: "Focus Score", value: "${rate.toStringAsFixed(0)}%", icon: Icons.psychology_rounded, color: Colors.purpleAccent)),
      ],
    );
  }

  Widget _buildMetricCard({required String title, required String value, required IconData icon, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(28)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 20),
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  int _calculateStreak(List<Task> tasks) {
    if (tasks.isEmpty) return 0;
    final completedDates = tasks.where((t) => t.isCompleted).map((t) => DateTime.fromMillisecondsSinceEpoch(int.parse(t.id))).map((d) => DateTime(d.year, d.month, d.day)).toSet();
    int streak = 0;
    DateTime dateToCheck = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    while (completedDates.contains(dateToCheck)) {
      streak++;
      dateToCheck = dateToCheck.subtract(const Duration(days: 1));
    }
    return streak;
  }

  Widget _buildCompletionStatsCard(List<Task> tasks) {
    int completedCount = 0;
    for (var task in tasks) {
      if (task.isCompleted) {
        try {
          final DateTime date = DateTime.fromMillisecondsSinceEpoch(int.parse(task.id));
          if (date.year == _statsYear && (_statsType == 'Yearly' || date.month == _statsMonth)) completedCount++;
        } catch (e) {}
      }
    }
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E), 
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // FIXED: Ensures the column doesn't expand unnecessarily
        children: [
          Row(
            children: [
              _buildDropdown<String>(value: _statsType, items: ['Monthly', 'Yearly'], onChanged: (val) => setState(() => _statsType = val!), itemLabel: (val) => val),
              const SizedBox(width: 10),
              _buildDropdown<int>(value: _statsYear, items: List.generate(5, (i) => DateTime.now().year - i), onChanged: (val) => setState(() => _statsYear = val!), itemLabel: (val) => val.toString()),
              if (_statsType == 'Monthly') ...[
                const SizedBox(width: 10),
                _buildDropdown<int>(value: _statsMonth, items: List.generate(12, (i) => i + 1), onChanged: (val) => setState(() => _statsMonth = val!), itemLabel: (val) => _monthName(val)),
              ],
            ],
          ),
          const SizedBox(height: 16), // FIXED: Reduced spacing to prevent overflow
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("Accomplishments", style: TextStyle(color: Colors.grey, fontSize: 14)),
                    const SizedBox(height: 4),
                    Text(_statsType == 'Monthly' ? "${_monthName(_statsMonth)} $_statsYear" : "$_statsYear", style: const TextStyle(color: Colors.white70, fontSize: 16)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(color: Colors.teal.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
                child: Text("$completedCount", style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.teal)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown<T>({required T value, required List<T> items, required ValueChanged<T?> onChanged, required String Function(T) itemLabel}) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white10)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          dropdownColor: const Color(0xFF2C2C2C),
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.teal, size: 20),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
          items: items.map((item) => DropdownMenuItem(value: item, child: Text(itemLabel(item)))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  String _monthName(int month) => ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"][month - 1];
}