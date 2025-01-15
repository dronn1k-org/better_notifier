import 'package:better_notifier/core/better_notifier.dart';

/// Extension to provide additional methods for `VN<Set<T>>`.
extension BetterSetNotifications<T> on VN<Set<T>> {
  /// Retrieves the element at the specified [index] in the set.
  T operator [](int index) => value.elementAt(index);

  /// Returns `true` if the set has no elements.
  bool get isEmpty => value.isEmpty;

  /// Returns `true` if the set has one or more elements.
  bool get isNotEmpty => value.isNotEmpty;

  /// Returns the number of elements in the set.
  int get length => value.length;

  /// Returns the first element in the set.
  T get first => value.first;

  /// Returns the last element in the set.
  T get last => value.last;

  /// Returns the first element in the set, or `null` if the set is empty.
  T? get firstOrNull => isNotEmpty ? value.first : null;

  /// Returns the last element in the set, or `null` if the set is empty.
  T? get lastOrNull => isNotEmpty ? value.last : null;

  /// Adds the given [value] to the set.
  /// Returns `true` if the value was added, `false` if it was already in the set.
  bool add(T value) {
    switch (changeType) {
      case ChangeType.hard:
      case ChangeType.silent:
        return silentAdd(value);
      case ChangeType.smart:
        return smartAdd(value);
    }
  }

  bool silentAdd(T value) => this.value.add(value);

  bool smartAdd(T value) {
    final added = this.value.add(value);
    if (added) {
      notify();
    }
    return added;
  }

  /// Appends all elements from the given [values] to the set.
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

  void silentAddAll(Iterable<T> values) => value.addAll(values);

  void smartAddAll(Iterable<T> values) {
    final oldLength = length;
    addAll(values);
    if (oldLength != length) {
      notify();
    }
  }

  /// Removes the given [value] from the set.
  /// Returns `true` if the element was removed, `false` otherwise.
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

  bool hardRemove(Object? value) {
    final result = this.value.remove(value);
    notify();
    return result;
  }

  bool silentRemove(Object? value) => this.value.remove(value);

  bool smartRemove(Object? value) {
    final result = this.value.remove(value);
    if (result) {
      notify();
    }
    return result;
  }

  /// Removes all elements from the set that satisfy the given predicate [where].
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

  void hardRemoveWhere(bool Function(T) where) {
    value.removeWhere(where);
    notify();
  }

  void silentRemoveWhere(bool Function(T) where) {
    value.removeWhere(where);
  }

  void smartRemoveWhere(bool Function(T) where) {
    final originalLength = value.length;
    value.removeWhere(where);
    if (value.length != originalLength) {
      notify();
    }
  }

  /// Removes all elements from the set.
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

  void hardClear() {
    value.clear();
    notify();
  }

  void silentClear() {
    value.clear();
  }

  void smartClear() {
    if (value.isNotEmpty) {
      value.clear();
      notify();
    }
  }

  /// Transforms the set by applying a function to all its elements.
  Iterable<R> map<R>(R Function(T e) map) => value.map(map);

  /// Returns a new lazy [Iterable] with all elements that satisfy the predicate [function].
  Iterable<T> where(bool Function(T function) function) =>
      value.where(function);

  /// Returns the first element that satisfies the given predicate [function].
  T firstWhere(bool Function(T function) function) =>
      value.firstWhere(function);

  /// Returns the last element that satisfies the given predicate [function].
  T lastWhere(bool Function(T function) function) => value.lastWhere(function);
}
