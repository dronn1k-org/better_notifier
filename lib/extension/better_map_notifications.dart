import 'package:better_notifier/core/better_notifier.dart';

/// Extension to provide additional methods for `Rv<Map<K, V>>`.
extension BetterMapNotifications<K, V> on VN<Map<K, V>> {
  /// Retrieves the value associated with the given [key] in the map.
  V? operator [](K key) {
    return value[key];
  }

  /// Associates the given [key] with the given [value] in the map.
  void operator []=(K key, V value) {
    _setter(key, value);
  }

  void _setter(K key, V newValue) {
    switch (changeType) {
      case ChangeType.silent:
        value[key] = newValue;
        return;
      case ChangeType.smart:
        if (newValue == [key]) return;
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
  /// Returns the value associated with the [key], or `null` if the key was not present in the map.
  V? remove(K key) => switch (changeType) {
        ChangeType.hard => hardRemove(key),
        ChangeType.silent => silentRemove(key),
        ChangeType.smart => smartRemove(key),
      };

  V? hardRemove(K key) {
    final removedValue = value.remove(key);
    notify();
    return removedValue;
  }

  V? silentRemove(K key) => value.remove(key);

  V? smartRemove(K key) {
    final removedValue = value.remove(key);
    if (removedValue != null) {
      notify();
    }
    return removedValue;
  }

  /// Removes all key-value pairs from the map that satisfy the given predicate [where].
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

  void hardRemoveWhere(bool Function(K key, V value) where) {
    value.removeWhere(where);
    notify();
  }

  void silentRemoveWhere(bool Function(K key, V value) where) {
    value.removeWhere(where);
  }

  void smartRemoveWhere(bool Function(K key, V value) where) {
    final originalLength = value.length;
    value.removeWhere(where);
    if (value.length != originalLength) {
      notify();
    }
  }

  /// Removes all key-value pairs from the map.
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

  /// Transforms the map by applying a function to all its key-value pairs.
  Map<K2, V2> map<K2, V2>(MapEntry<K2, V2> Function(K k, V v) converter) =>
      value.map<K2, V2>(converter);
}
