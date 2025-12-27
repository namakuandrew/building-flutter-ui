import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task_model.dart';

class DatabaseHelper {
  // Use 10.0.2.2 for Android Emulator to reach localhost on your PC
  static const String _baseUrl = 'http://10.0.2.2:3000'; 
  
  // Singleton pattern (kept so we don't break your other code)
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // --- CRUD Operations (Now talking to Server instead of SQLite) ---

  Future<List<Task>> getTasks() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/tasks'));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Task.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print("Server error: $e");
      return []; // Return empty list so app doesn't crash
    }
  }

  // We change return type to Future<void> because your provider 
  // doesn't actually use the returned 'int' ID.
  Future<void> insert(Task task) async {
    try {
      await http.post(
        Uri.parse('$_baseUrl/tasks'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(task.toJson()),
      );
    } catch (e) {
      print("Error adding task: $e");
      rethrow; // Throw so provider knows to revert optimistic update
    }
  }

  Future<void> update(Task task) async {
    try {
      await http.put(
        Uri.parse('$_baseUrl/tasks/${task.id}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(task.toJson()),
      );
    } catch (e) {
      print("Error updating task: $e");
      rethrow;
    }
  }

  Future<void> delete(String id) async {
    try {
      await http.delete(Uri.parse('$_baseUrl/tasks/$id'));
    } catch (e) {
      print("Error deleting task: $e");
      rethrow;
    }
  }
}

// The provider stays exactly the same!
final databaseHelperProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper.instance;
});