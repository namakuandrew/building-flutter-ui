// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$filteredTasksHash() => r'58ae24fa8a29850270673ca02a85fbdc80cbae21';

/// See also [filteredTasks].
@ProviderFor(filteredTasks)
final filteredTasksProvider =
    AutoDisposeProvider<AsyncValue<List<Task>>>.internal(
      filteredTasks,
      name: r'filteredTasksProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$filteredTasksHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FilteredTasksRef = AutoDisposeProviderRef<AsyncValue<List<Task>>>;
String _$summaryHash() => r'ac4c64b92e4ed5319fe2281999eaa93374abe008';

/// See also [summary].
@ProviderFor(summary)
final summaryProvider = AutoDisposeProvider<AsyncValue<String>>.internal(
  summary,
  name: r'summaryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$summaryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SummaryRef = AutoDisposeProviderRef<AsyncValue<String>>;
String _$tasksHash() => r'55fb9391926504984e6af4660d979c089afa2627';

/// See also [Tasks].
@ProviderFor(Tasks)
final tasksProvider = AsyncNotifierProvider<Tasks, List<Task>>.internal(
  Tasks.new,
  name: r'tasksProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$tasksHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$Tasks = AsyncNotifier<List<Task>>;
String _$taskFilterStateHash() => r'92ea1f5ed300436fecce3a5cd91812a4407f8b48';

/// See also [TaskFilterState].
@ProviderFor(TaskFilterState)
final taskFilterStateProvider =
    AutoDisposeNotifierProvider<TaskFilterState, TaskFilter>.internal(
      TaskFilterState.new,
      name: r'taskFilterStateProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$taskFilterStateHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$TaskFilterState = AutoDisposeNotifier<TaskFilter>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
