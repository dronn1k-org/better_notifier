import 'package:better_notifier/core/better_notifier.dart';

/// Extension to provide additional methods for `VN<Set<T>>`.
///
/// The `BetterSetNotifications` extension enhances the functionality of `VN<Set<T>>`
/// by adding convenience methods for common set operations, while respecting
/// the [ChangeType] configuration of the parent `VN` instance.
///
/// ### Features:
/// - Index-based element retrieval.
/// - Set inspection properties (`isEmpty`, `isNotEmpty`, `length`, etc.).
/// - Methods for adding, removing, and clearing elements.
/// - Functional utilities for set transformations.
extension BetterSetNotifications<T> on VN<Set<T>> {
  /// Retrieves the element at the specified [index] in the set.
  ///
  /// - [index]: The index of the element to retrieve.
  /// - Returns: The element at the specified [index].
  T operator [](int index) => value.elementAt(index);

  /// Returns `true` if the set has no elements.
  bool get isEmpty => value.isEmpty;

  /// Returns `true` if the set has one or more elements.
  bool get isNotEmpty => value.isNotEmpty;

  /// Returns the number of elements in the set.
  int get length => value.length;

  /// Returns the first element in the set.
  ///
  /// Throws a [StateError] if the set is empty.
  T get first => value.first;

  /// Returns the last element in the set.
  ///
  /// Throws a [StateError] if the set is empty.
  T get last => value.last;

  /// Returns the first element in the set, or `null` if the set is empty.
  T? get firstOrNull => isNotEmpty ? value.first : null;

  /// Returns the last element in the set, or `null` if the set is empty.
  T? get lastOrNull => isNotEmpty ? value.last : null;

  /// Adds the given [value] to the set.
  ///
  /// - [value]: The element to add to the set.
  /// - Returns: `true` if the value was added, `false` if it was already in the set.
  bool add(T value) {
    switch (changeType) {
      case ChangeType.hard:
      case ChangeType.smart:
        return smartAdd(value);
      case ChangeType.silent:
        return silentAdd(value);
    }
  }

  /// Adds the given [value] to the set without notifying listeners.
  ///
  /// - [value]: The element to add to the set.
  /// - Returns: `true` if the value was added, `false` otherwise.
  bool silentAdd(T value) => this.value.add(value);

  /// Adds the given [value] to the set and notifies listeners if the value was added.
  ///
  /// - [value]: The element to add to the set.
  /// - Returns: `true` if the value was added, `false` otherwise.
  bool smartAdd(T value) {
    final added = this.value.add(value);
    if (added) {
      notify();
    }
    return added;
  }

  /// Adds all elements from the given [values] to the set.
  ///
  /// - [values]: The elements to add to the set.
  void addAll(Iterable<T> values) {
    switch (changeType) {
      case ChangeType.hard:
      case ChangeType.smart:
        smartAddAll(values);
        break;
      case ChangeType.silent:
        silentAddAll(values);
        break;
    }
  }

  /// Adds all elements from the given [values] to the set without notifying listeners.
  ///
  /// - [values]: The elements to add to the set.
  void silentAddAll(Iterable<T> values) => value.addAll(values);

  /// Adds all elements from the given [values] to the set and notifies listeners if the set changed.
  ///
  /// - [values]: The elements to add to the set.
  void smartAddAll(Iterable<T> values) {
    final oldLength = length;
    value.addAll(values);
    if (oldLength != length) {
      notify();
    }
  }

  /// Removes the given [value] from the set.
  ///
  /// - [value]: The element to remove.
  /// - Returns: `true` if the element was removed, `false` otherwise.
  bool remove(Object? value) {
    switch (changeType) {
      case ChangeType.hard:
        return hardRemove(value);
      case ChangeType.silent:
        return silentRemove(value);
      case ChangeType.smart:
        return smartRemove(value);
    }
  }

  /// Removes the given [value] from the set and notifies listeners.
  ///
  /// - [value]: The element to remove.
  /// - Returns: `true` if the element was removed, `false` otherwise.
  bool hardRemove(Object? value) {
    final result = this.value.remove(value);
    notify();
    return result;
  }

  /// Removes the given [value] from the set without notifying listeners.
  ///
  /// - [value]: The element to remove.
  /// - Returns: `true` if the element was removed, `false` otherwise.
  bool silentRemove(Object? value) => this.value.remove(value);

  /// Removes the given [value] from the set and notifies listeners if the set changed.
  ///
  /// - [value]: The element to remove.
  /// - Returns: `true` if the element was removed, `false` otherwise.
  bool smartRemove(Object? value) {
    final result = this.value.remove(value);
    if (result) {
      notify();
    }
    return result;
  }

  /// Removes all elements from the set that satisfy the given predicate [where].
  ///
  /// - [where]: A function that returns `true` for elements to remove.
  void removeWhere(bool Function(T) where) {
    switch (changeType) {
      case ChangeType.hard:
        hardRemoveWhere(where);
        break;
      case ChangeType.silent:
        silentRemoveWhere(where);
        break;
      case ChangeType.smart:
        smartRemoveWhere(where);
        break;
    }
  }

  /// Removes all elements from the set that satisfy the predicate [where] and notifies listeners.
  ///
  /// - [where]: A function that returns `true` for elements to remove.
  void hardRemoveWhere(bool Function(T) where) {
    value.removeWhere(where);
    notify();
  }

  /// Removes all elements from the set that satisfy the predicate [where] without notifying listeners.
  ///
  /// - [where]: A function that returns `true` for elements to remove.
  void silentRemoveWhere(bool Function(T) where) {
    value.removeWhere(where);
  }

  /// Removes all elements from the set that satisfy the predicate [where], with behavior determined by [ChangeType].
  ///
  /// - [where]: A function that returns `true` for elements to remove.
  void smartRemoveWhere(bool Function(T) where) {
    final originalLength = value.length;
    value.removeWhere(where);
    if (value.length != originalLength) {
      notify();
    }
  }

  /// Removes all elements from the set.
  ///
  /// The update behavior is determined by the [ChangeType] of the `VN`.
  void clear() {
    switch (changeType) {
      case ChangeType.hard:
        hardClear();
        break;
      case ChangeType.silent:
        silentClear();
        break;
      case ChangeType.smart:
        smartClear();
        break;
    }
  }

  /// Removes all elements from the set and notifies listeners.
  void hardClear() {
    value.clear();
    notify();
  }

  /// Removes all elements from the set without notifying listeners.
  void silentClear() {
    value.clear();
  }

  /// Removes all elements from the set and notifies listeners if the set was not empty.
  void smartClear() {
    if (value.isNotEmpty) {
      value.clear();
      notify();
    }
  }

  /// Transforms the set by applying a function to all its elements.
  ///
  /// - [map]: A function that transforms each element of the set.
  /// - Returns: A lazy iterable of transformed elements.
  Iterable<R> map<R>(R Function(T e) map) => value.map(map);

  /// Returns a new lazy [Iterable] with all elements that satisfy the predicate [function].
  ///
  /// - [function]: A function that returns `true` for elements to include.
  /// - Returns: A lazy iterable of matching elements.
  Iterable<T> where(bool Function(T function) function) =>
      value.where(function);

  /// Returns the first element that satisfies the given predicate [function].
  ///
  /// - [function]: A function that returns `true` for the desired element.
  /// - Returns: The first matching element.
  /// - Throws: A [StateError] if no element matches.
  T firstWhere(bool Function(T function) function) =>
      value.firstWhere(function);

  /// Returns the last element that satisfies the given predicate [function].
  ///
  /// - [function]: A function that returns `true` for the desired element.
  /// - Returns: The last matching element.
  /// - Throws: A [StateError] if no element matches.
  T lastWhere(bool Function(T function) function) => value.lastWhere(function);
}
