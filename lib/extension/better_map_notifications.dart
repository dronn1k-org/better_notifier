import 'package:better_notifier/core/better_notifier.dart';

/// Extension to provide additional methods for `VN<Map<K, V>>`.
///
/// The `BetterMapNotifications` extension enhances the functionality of `VN<Map<K, V>>`
/// by adding convenience methods for common map operations, while respecting
/// the [ChangeType] configuration of the parent `VN` instance.
///
/// ### Features:
/// - Key-based element access and modification.
/// - Map inspection properties (`isEmpty`, `isNotEmpty`, `length`, etc.).
/// - Methods for adding, removing, and clearing key-value pairs.
/// - Functional utilities for map transformations.
extension BetterMapNotifications<K, V> on VN<Map<K, V>> {
  /// Retrieves the value associated with the given [key] in the map.
  ///
  /// - [key]: The key of the element to retrieve.
  /// - Returns: The value associated with the [key], or `null` if the key is not present.
  V? operator [](K key) {
    return value[key];
  }

  /// Associates the given [key] with the given [value] in the map.
  ///
  /// - [key]: The key to associate with the value.
  /// - [value]: The value to store in the map.
  ///
  /// The update behavior is determined by the [ChangeType] of the `VN`.
  void operator []=(K key, V value) {
    _setter(key, value);
  }

  /// Updates the value associated with the given [key] in the map.
  ///
  /// - [key]: The key to associate with the new value.
  /// - [newValue]: The new value to assign.
  ///
  /// The update behavior is determined by the [ChangeType] of the `VN`.
  void _setter(K key, V newValue) {
    switch (changeType) {
      case ChangeType.silent:
        value[key] = newValue;
        return;
      case ChangeType.smart:
        if (newValue == value[key]) return;
      // Fallthrough to ChangeType.hard if the value differs.
      case ChangeType.hard:
        value[key] = newValue;
        notify();
        return;
    }
  }

  /// Returns `true` if the map has no key-value pairs.
  bool get isEmpty => value.isEmpty;

  /// Returns `true` if the map has one or more key-value pairs.
  bool get isNotEmpty => value.isNotEmpty;

  /// Returns the number of key-value pairs in the map.
  int get length => value.length;

  /// Returns an iterable of all keys in the map.
  Iterable<K> get keys => value.keys;

  /// Returns an iterable of all values in the map.
  Iterable<V> get values => value.values;

  /// Removes the key-value pair with the given [key] from the map.
  ///
  /// - [key]: The key of the element to remove.
  /// - Returns: The value associated with the [key], or `null` if the key was not present.
  ///
  /// The update behavior is determined by the [ChangeType] of the `VN`.
  V? remove(K key) => switch (changeType) {
        ChangeType.hard => hardRemove(key),
        ChangeType.silent => silentRemove(key),
        ChangeType.smart => smartRemove(key),
      };

  /// Removes the key-value pair with the given [key] from the map and notifies listeners.
  ///
  /// - [key]: The key of the element to remove.
  /// - Returns: The value associated with the [key], or `null` if the key was not present.
  V? hardRemove(K key) {
    final removedValue = value.remove(key);
    notify();
    return removedValue;
  }

  /// Removes the key-value pair with the given [key] from the map without notifying listeners.
  ///
  /// - [key]: The key of the element to remove.
  /// - Returns: The value associated with the [key], or `null` if the key was not present.
  V? silentRemove(K key) => value.remove(key);

  /// Removes the key-value pair with the given [key] from the map, with behavior determined by [ChangeType].
  ///
  /// - [key]: The key of the element to remove.
  /// - Returns: The value associated with the [key], or `null` if the key was not present.
  V? smartRemove(K key) {
    final removedValue = value.remove(key);
    if (removedValue != null) {
      notify();
    }
    return removedValue;
  }

  /// Removes all key-value pairs from the map that satisfy the given predicate [where].
  ///
  /// - [where]: A function that returns `true` for elements to remove.
  void removeWhere(bool Function(K key, V value) where) {
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

  /// Removes all key-value pairs from the map that satisfy the predicate [where] and notifies listeners.
  ///
  /// - [where]: A function that returns `true` for elements to remove.
  void hardRemoveWhere(bool Function(K key, V value) where) {
    value.removeWhere(where);
    notify();
  }

  /// Removes all key-value pairs from the map that satisfy the predicate [where] without notifying listeners.
  ///
  /// - [where]: A function that returns `true` for elements to remove.
  void silentRemoveWhere(bool Function(K key, V value) where) {
    value.removeWhere(where);
  }

  /// Removes all key-value pairs from the map that satisfy the predicate [where], with behavior determined by [ChangeType].
  ///
  /// - [where]: A function that returns `true` for elements to remove.
  void smartRemoveWhere(bool Function(K key, V value) where) {
    final originalLength = value.length;
    value.removeWhere(where);
    if (value.length != originalLength) {
      notify();
    }
  }

  /// Removes all key-value pairs from the map.
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

  /// Removes all key-value pairs from the map and notifies listeners.
  void hardClear() {
    value.clear();
    notify();
  }

  /// Removes all key-value pairs from the map without notifying listeners.
  void silentClear() {
    value.clear();
  }

  /// Removes all key-value pairs from the map, with behavior determined by [ChangeType].
  void smartClear() {
    if (value.isNotEmpty) {
      value.clear();
      notify();
    }
  }

  /// Transforms the map by applying a function to all its key-value pairs.
  ///
  /// - [converter]: A function that takes a key-value pair and returns a new [MapEntry].
  /// - Returns: A new map with transformed keys and values.
  Map<K2, V2> map<K2, V2>(MapEntry<K2, V2> Function(K k, V v) converter) =>
      value.map<K2, V2>(converter);
}
