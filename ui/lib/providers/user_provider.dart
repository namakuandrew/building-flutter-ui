import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 1. Define the AsyncNotifier
class UserNameNotifier extends AsyncNotifier<String> {
  @override
  Future<String> build() async {
    // This 'build' method is called once when the provider is first read.
    // It's perfect for loading our initial value.
    final prefs = await SharedPreferences.getInstance();
    // We try to get the 'userName'. If it doesn't exist, we return 'My' as the default.
    return prefs.getString('userName') ?? 'My';
  }

  // 2. Add a method to update the name
  Future<void> updateName(String newName) async {
    // Get the SharedPreferences instance
    final prefs = await SharedPreferences.getInstance();
    // Save the new name to storage
    await prefs.setString('userName', newName);

    // 3. Update the provider's state so the UI rebuilds
    //    We update it with 'AsyncData' to show we have a new, valid value.
    state = AsyncData(newName);
  }
}

// 3. Create the provider that the UI will watch
final userNameProvider = AsyncNotifierProvider<UserNameNotifier, String>(() {
  return UserNameNotifier();
});
