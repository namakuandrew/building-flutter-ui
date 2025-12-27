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
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      // FIX 1: Force ID to be a String (handles int IDs safely)
      id: json['id'].toString(), 
      
      // FIX 2: If title is missing/null, use a default string so the app doesn't crash
      title: json['title']?.toString() ?? 'No Title', 
      
      // FIX 3: Robust check. Handles:
      // - Integer 1 (SQLite/Your toJson)
      // - Boolean true (Firebase default)
      // - Legacy key 'completed' (just in case)
      isCompleted: json['isCompleted'] == 1 || 
                   json['isCompleted'] == true || 
                   json['completed'] == true,
    );
  }

  // Method for creating a map from a Task instance.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      // We keep this as 1/0 since your other code (SQLite) likely expects it.
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