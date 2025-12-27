import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import '../models/task_model.dart';

class ActivityHeatmap extends StatefulWidget {
  final List<Task> tasks;

  const ActivityHeatmap({super.key, required this.tasks});

  @override
  State<ActivityHeatmap> createState() => _ActivityHeatmapState();
}

class _ActivityHeatmapState extends State<ActivityHeatmap> {
  // Only track the Year now
  int _selectedYear = DateTime.now().year;

  Map<DateTime, int> _generateDataset() {
    final Map<DateTime, int> dataset = {};
    for (var task in widget.tasks) {
      try {
        final int timestamp = int.parse(task.id);
        final DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp);
        final DateTime normalizedDate = DateTime(date.year, date.month, date.day);
        dataset[normalizedDate] = (dataset[normalizedDate] ?? 0) + 1;
      } catch (e) {
        // Skip invalid IDs
      }
    }
    return dataset;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22), // GitHub Dark BG
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF30363D)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- HEADER (YEAR SELECTOR ONLY) ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Yearly Contributions",
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
              ),
              // Year Dropdown
              _buildMinimalDropdown(
                value: _selectedYear,
                items: List.generate(5, (index) {
                  final year = DateTime.now().year - index;
                  return DropdownMenuItem(
                    value: year,
                    child: Text(year.toString()),
                  );
                }),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedYear = val);
                },
              ),
            ],
          ),
          const SizedBox(height: 20),

          // --- HEATMAP (FULL YEAR) ---
          Center(
            child: HeatMap(
              datasets: _generateDataset(),
              colorMode: ColorMode.color,
              scrollable: true, 
              showText: false,
              
              // GitHub Colors
              colorsets: const {
                1: Color(0xFF0E4429),
                3: Color(0xFF006D32),
                5: Color(0xFF26A641),
                7: Color(0xFF39D353),
              },
              defaultColor: const Color(0xFF161B22),
              textColor: const Color(0xFF8B949E),
              
              // Show Full Year (Jan 1 - Dec 31)
              startDate: DateTime(_selectedYear, 1, 1),
              endDate: DateTime(_selectedYear, 12, 31),
              
              size: 18, // Slightly smaller squares to fit width better
              fontSize: 10,
              margin: const EdgeInsets.all(2),
              borderRadius: 2,
              onClick: (value) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Contributions on ${value.day}/${value.month}/${value.year}'),
                    backgroundColor: const Color(0xFF2C2C2C),
                    duration: const Duration(milliseconds: 1000),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMinimalDropdown<T>({
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF21262D),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF30363D)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          items: items,
          onChanged: onChanged,
          dropdownColor: const Color(0xFF161B22),
          style: const TextStyle(
            color: Color(0xFFC9D1D9),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF8B949E), size: 18),
          isDense: true,
        ),
      ),
    );
  }
}