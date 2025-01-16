import 'package:better_notifier/core/better_notifier.dart';

/// Extension to provide additional methods for `VN<List<T>>`.
///
/// The `BetterListNotifications` extension enhances the functionality of `VN<List<T>>`
/// by adding convenience methods for common list operations, while respecting
/// the [ChangeType] configuration of the parent `VN` instance.
///
/// ### Features:
/// - Index-based element access and modification.
/// - List inspection properties (`isEmpty`, `isNotEmpty`, `length`, etc.).
/// - Methods for adding, removing, and clearing elements, with behavior determined by [ChangeType].
/// - Functional utilities like `map` and `where` for list transformations.
extension BetterListNotifications<T> on VN<List<T>> {
  /// Gets the element at the specified [index] in the list.
  ///
  /// - [index]: The index of the element to retrieve.
  /// - Returns: The element at the specified [index].
  T operator [](int index) => value[index];

  /// Sets the element at the specified [index] in the list to the given [value].
  ///
  /// - [index]: The index of the element to update.
  /// - [value]: The new value for the element.
  ///
  /// The update behavior is determined by the [ChangeType] of the `VN`.
  void operator []=(int index, T value) => _setter(index, value);

  /// Updates the element at the specified [index] in the list.
  ///
  /// - [index]: The index of the element to update.
  /// - [newValue]: The new value for the element.
  ///
  /// The update behavior is determined by the [ChangeType] of the `VN`.
  void _setter(int index, T newValue) {
    switch (changeType) {
      case ChangeType.silent:
        value[index] = newValue;
        return;
      case ChangeType.smart:
        if (newValue == value[index]) return;
      // Fallthrough to ChangeType.hard if the value differs.
      case ChangeType.hard:
        value[index] = newValue;
        notify();
        return;
    }
  }

  /// Adds the given [value] to the list without notifying listeners.
  ///
  /// - [value]: The value to add to the list.
  void silentAdd(T value) => this.value.add(value);

  /// Adds the given [value] to the list and notifies listeners.
  ///
  /// - [value]: The value to add to the list.
  void hardAdd(T value) {
    this.value.add(value);
    notify();
  }

  /// Adds the given [value] to the list, with behavior determined by [ChangeType].
  ///
  /// - [value]: The value to add to the list.
  void smartAdd(T value) => hardAdd(value);

  /// Appends all elements from the given iterable [value] to the list without notifying listeners.
  ///
  /// - [value]: The iterable containing elements to add.
  void silentAddAll(Iterable<T> value) => this.value.addAll(value);

  /// Appends all elements from the given iterable [value] to the list and notifies listeners.
  ///
  /// - [value]: The iterable containing elements to add.
  void hardAddAll(Iterable<T> value) {
    this.value.addAll(value);
    notify();
  }

  /// Appends all elements from the given iterable [value] to the list, with behavior determined by [ChangeType].
  ///
  /// - [value]: The iterable containing elements to add.
  void smartAddAll(Iterable<T> value) => hardAddAll(value);

  /// Removes the first occurrence of the given [value] from the list without notifying listeners.
  ///
  /// - [value]: The element to remove.
  /// - Returns: `true` if the element was removed, `false` otherwise.
  bool silentRemove(Object? value) => this.value.remove(value);

  /// Removes the first occurrence of the given [value] from the list and notifies listeners.
  ///
  /// - [value]: The element to remove.
  /// - Returns: `true` if the element was removed, `false` otherwise.
  bool hardRemove(Object? value) {
    final removeResult = this.value.remove(value);
    notify();
    return removeResult;
  }

  /// Removes the first occurrence of the given [value] from the list, with behavior determined by [ChangeType].
  ///
  /// - [value]: The element to remove.
  /// - Returns: `true` if the element was removed, `false` otherwise.
  bool smartRemove(Object? value) {
    final removeResult = this.value.remove(value);
    if (removeResult) {
      notify();
    }
    return removeResult;
  }

  /// Removes the element at the specified [index] from the list without notifying listeners.
  ///
  /// - [index]: The index of the element to remove.
  /// - Returns: The removed element.
  T silentRemoveAt(int index) => value.removeAt(index);

  /// Removes the element at the specified [index] from the list and notifies listeners.
  ///
  /// - [index]: The index of the element to remove.
  /// - Returns: The removed element.
  T hardRemoveAt(int index) {
    final removedValue = value.removeAt(index);
    notify();
    return removedValue;
  }

  /// Removes the element at the specified [index] from the list, with behavior determined by [ChangeType].
  ///
  /// - [index]: The index of the element to remove.
  /// - Returns: The removed element.
  T smartRemoveAt(int index) {
    final removedValue = value.removeAt(index);
    if (removedValue != null) {
      notify();
    }
    return removedValue;
  }

  /// Removes all elements that satisfy the given predicate [where] without notifying listeners.
  ///
  /// - [where]: A function that returns `true` for elements to remove.
  void silentRemoveWhere(bool Function(T) where) {
    value.removeWhere(where);
  }

  /// Removes all elements that satisfy the given predicate [where] and notifies listeners.
  ///
  /// - [where]: A function that returns `true` for elements to remove.
  void hardRemoveWhere(bool Function(T) where) {
    value.removeWhere(where);
    notify();
  }

  /// Removes all elements that satisfy the given predicate [where], with behavior determined by [ChangeType].
  ///
  /// - [where]: A function that returns `true` for elements to remove.
  void smartRemoveWhere(bool Function(T) where) {
    final originalLength = value.length;
    value.removeWhere(where);
    if (value.length != originalLength) {
      notify();
    }
  }
}
