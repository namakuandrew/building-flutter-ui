class Task {
  final String id;
  final String title;
  final bool isCompleted;

  Task({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });

  // --- DATABASE & API CONVERSION ---

  // Factory constructor for creating a new Task instance from a map.
  // This is used for both API (JSON) and Database (Map).
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'].toString(), // Ensure ID is always a string
      title: json['title'],
      
      // MODIFIED: Convert data from database/API to bool
      // SQLite: Reads 'isCompleted' (an INTEGER) and converts 1 to true, 0 to false.
      // API: Reads 'completed' (a bool) and evaluates it.
      isCompleted: json['completed'] == true || json['isCompleted'] == 1,
    );
  }

  // Method for creating a map from a Task instance.
  // This is used for both API (JSON) and Database (Map).
  Map<String, dynamic> toJson() {
    return {
      // For SQLite, we must use the exact column names
      // from DatabaseHelper
      'id': id,
      'title': title,
      'isCompleted': isCompleted ? 1 : 0,
    };
  }

  // --- HELPER METHOD ---

  // Returns a copy of the task with optional new values.
  Task copyWith({
    String? id,
    String? title,
    bool? isCompleted,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}