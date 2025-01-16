import 'package:better_notifier/core/better_notifier.dart';

/// An extension on `String` to create a value notifier (`VN<String>`).
extension NotifiableString on String {
  /// Returns a value notifier (`VN<String>`) initialized with this String value.
  VN<String> get vn => VN<String>(this);
}

/// An extension on `bool` to create a value notifier (`VN<bool>`).
extension NotifiableBool on bool {
  /// Returns a value notifier (`VN<bool>`) initialized with this bool value.
  VN<bool> get vn => VN<bool>(this);
}

/// An extension on `int` to create a value notifier (`VN<int>`).
extension NotifiableInt on int {
  /// Returns a value notifier (`VN<int>`) initialized with this int value.
  VN<int> get vn => VN<int>(this);
}

/// An extension on `double` to create a value notifier (`VN<double>`).
extension NotifiableDouble on double {
  /// Returns a value notifier (`VN<double>`) initialized with this double value.
  VN<double> get vn => VN<double>(this);
}

/// An extension on `Iterable<T>` to create a value notifier (`VN<Iterable<T>>`).
extension NotifiableIterable<T> on Iterable<T> {
  /// Returns a value notifier (`VN<Iterable<T>>`) initialized with this Iterable value.
  VN<Iterable<T>> get vn => VN<Iterable<T>>(this);
}

/// An extension on `List<T>` to create a value notifier (`VN<List<T>>`).
extension NotifiableList<T> on List<T> {
  /// Returns a value notifier (`VN<List<T>>`) initialized with this List value.
  VN<List<T>> get vn => VN<List<T>>(this);
}

/// An extension on `Set<T>` to create a value notifier (`VN<Set<T>>`).
extension NotifiableSet<T> on Set<T> {
  /// Returns a value notifier (`VN<Set<T>>`) initialized with this Set value.
  VN<Set<T>> get vn => VN<Set<T>>(this);
}

/// An extension on `Map<K, V>` to create a value notifier (`VN<Map<K, V>>`).
extension NotifiableMap<K, V> on Map<K, V> {
  /// Returns a value notifier (`VN<Map<K, V>>`) initialized with this Map value.
  VN<Map<K, V>> get vn => VN<Map<K, V>>(this);
}
