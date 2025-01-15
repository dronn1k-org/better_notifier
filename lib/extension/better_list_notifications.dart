import 'package:better_notifier/core/better_notifier.dart';

/// Extension to provide additional methods for `Rv<List<T>>`.
extension BetterListNotifications<T> on VN<List<T>> {
  /// Gets the element at the specified [index] in the list.
  T operator [](int index) => value[index];

  /// Sets the element at the specified [index] in the list to the given [value].
  void operator []=(int index, T value) => _setter(index, value);

  void _setter(int index, T newValue) {
    switch (changeType) {
      case ChangeType.silent:
        value[index] = newValue;
        return;
      case ChangeType.smart:
        if (newValue == [index]) return;
      case ChangeType.hard:
        value[index] = newValue;
        notify();
        return;
    }
  }

  /// Returns `true` if the list has no elements.
  bool get isEmpty => value.isEmpty;

  /// Returns `true` if the list has one or more elements.
  bool get isNotEmpty => value.isNotEmpty;

  /// Returns the number of elements in the list.
  int get length => value.length;

  /// Returns the first element in the list.
  T get first => value.first;

  /// Returns the last element in the list.
  T get last => value.last;

  /// Returns the first element in the list, or `null` if the list is empty.
  T? get firstOrNull => isNotEmpty ? value.first : null;

  /// Returns the last element in the list, or `null` if the list is empty.
  T? get lastOrNull => isNotEmpty ? value.last : null;

  /// Adds the given [value] to the end of the list.
  void add(T value) => switch (changeType) {
        ChangeType.hard => hardAdd(value),
        ChangeType.silent => silentAdd(value),
        ChangeType.smart => smartAdd(value),
      };

  void hardAdd(T value) {
    this.value.add(value);
    notify();
  }

  void silentAdd(T value) => this.value.add(value);

  void smartAdd(T value) => hardAdd(value);

  /// Appends all elements from the given [value] to the end of the list.
  void addAll(Iterable<T> value) => switch (changeType) {
        ChangeType.hard => hardAddAll(value),
        ChangeType.silent => silentAddAll(value),
        ChangeType.smart => smartAddAll(value),
      };

  void hardAddAll(Iterable<T> value) {
    this.value.addAll(value);
    notify();
  }

  void silentAddAll(Iterable<T> value) => this.value.addAll(value);

  void smartAddAll(Iterable<T> value) => hardAddAll(value);

  /// Removes the first occurrence of the given [value] from the list.
  /// Returns `true` if the element was removed, `false` otherwise.
  bool remove(Object? value) => switch (changeType) {
        ChangeType.hard => hardRemove(value),
        ChangeType.silent => silentRemove(value),
        ChangeType.smart => smartRemove(value),
      };

  bool hardRemove(Object? value) {
    final removeResult = this.value.remove(value);
    notify();
    return removeResult;
  }

  bool silentRemove(Object? value) {
    return this.value.remove(value);
  }

  bool smartRemove(Object? value) {
    final removeResult = this.value.remove(value);
    if (removeResult) {
      notify();
    }
    return removeResult;
  }

  /// Removes the element at the specified [index] from the list.
  /// Returns the removed element.
  T removeAt(int index) => switch (changeType) {
        ChangeType.hard => hardRemoveAt(index),
        ChangeType.silent => silentRemoveAt(index),
        ChangeType.smart => smartRemoveAt(index),
      };

  T hardRemoveAt(int index) {
    final removedValue = value.removeAt(index);
    notify();
    return removedValue;
  }

  T silentRemoveAt(int index) => value.removeAt(index);

  T smartRemoveAt(int index) {
    final removedValue = value.removeAt(index);
    if (removedValue != null) {
      notify();
    }
    return removedValue;
  }

  /// Removes all elements that satisfy the given predicate [where].
  void removeWhere(bool Function(T) where) => switch (changeType) {
        ChangeType.hard => hardRemoveWhere(where),
        ChangeType.silent => silentRemoveWhere(where),
        ChangeType.smart => smartRemoveWhere(where),
      };

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

  /// Removes all elements from the list.
  void clear() => switch (changeType) {
        ChangeType.hard => hardClear(),
        ChangeType.silent => silentClear(),
        ChangeType.smart => smartClear(),
      };

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

  /// Returns a new lazy [Iterable] with elements transformed by the given function [map].
  Iterable<R> map<R>(R Function(T e) map) => value.map(map);

  /// Returns a new lazy [Iterable] with all elements that satisfy the predicate [function].
  Iterable<T> where(bool Function(T) function) => value.where(function);

  /// Returns the first element that satisfies the given predicate [function].
  T firstWhere(bool Function(T) function) => value.firstWhere(function);

  /// Returns the last element that satisfies the given predicate [function].
  T lastWhere(bool Function(T) function) => value.lastWhere(function);
}
