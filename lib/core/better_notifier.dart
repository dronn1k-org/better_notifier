import 'package:flutter/foundation.dart';

typedef ValueChanger<T> = void Function(T newValue);

/// Specifies the behavior for updating the value of a [VN].
///
/// The [ChangeType] determines how changes to the value are handled, affecting
/// whether listeners are notified and under what conditions.
enum ChangeType {
  /// Updates the value and always notifies listeners, regardless of its current state.
  ///
  /// Use this type when every update, even if redundant, needs to trigger listeners.
  hard,

  /// Updates the value without notifying listeners.
  ///
  /// This type is useful for silent updates where notification is unnecessary.
  silent,

  /// Updates the value only if it differs from the current value, and notifies listeners.
  ///
  /// This is the default behavior and is useful for avoiding redundant notifications.
  smart;
}

/// A simplified and enhanced abstraction for working with [ValueNotifier].
///
/// The `VN` class streamlines the use of [ValueNotifier], adding flexibility
/// through custom change types and advanced features such as merging multiple
/// `VN` instances.
///
/// ### Features:
/// - Customizable change behaviors via [ChangeType].
/// - Built-in listener management.
/// - Easy merging of two `VN` instances into a single, derived `VN`.
/// - Utility methods for notifying listeners, silent updates, and conditional updates.
///
/// ### Parameters:
/// - `T` - The type of the value managed by this `VN` instance.
class VN<T> with ChangeNotifier implements ValueListenable<T> {
  /// The current value of this [VN].
  late T _value;

  /// The change behavior applied to this [VN].
  ///
  /// See [ChangeType] for available options.
  final ChangeType changeType;

  /// Creates a `VN` instance with an initial value and optional change behavior.
  ///
  /// - [initialValue]: The initial value of this `VN`.
  /// - [changeType]: Determines the behavior of updates. Defaults to [ChangeType.smart].
  ///
  /// If [kFlutterMemoryAllocationsEnabled] is enabled, the instance is tracked.
  VN(T initialValue, [this.changeType = ChangeType.smart])
      : _value = initialValue {
    _valueSetter = switch (changeType) {
      ChangeType.hard => hardSet,
      ChangeType.silent => silentSet,
      ChangeType.smart => smartSet,
    };
    if (kFlutterMemoryAllocationsEnabled) {
      ChangeNotifier.maybeDispatchObjectCreation(this);
    }
  }

  /// Factory method for creating a merged [VN].
  ///
  /// Combines two `VN` instances (`left` and `right`) into a single `VN` that
  /// derives its value based on the provided [listener] function.
  ///
  /// - [initialValue]: The initial value of the merged `VN`.
  /// - [left]: The first `VN` to merge.
  /// - [right]: The second `VN` to merge.
  /// - [listener]: A function that receives the values of [left], [right], and
  ///   an emitter to update the derived value.
  /// - [changeType]: Optional change behavior for the merged `VN`.
  /// - [whenDispose]: A callback invoked when the merged `VN` is disposed.
  static VN<T> merged<T, L, R>(
    T initialValue, {
    required VN<L> left,
    required VN<R> right,
    required void Function(L left, R right, void Function(T value) emitter)
        listener,
    ChangeType? changeType,
    void Function()? whenDispose,
  }) =>
      _MergedVN(
        initialValue,
        left: left,
        right: right,
        listener: listener,
        changeType: changeType,
        whenDispose: whenDispose,
      );

  /// Sets the current value based on the configured [ChangeType].
  late final ValueChanger<T> _valueSetter;

  /// Gets the current value of this `VN`.
  @override
  T get value => _value;

  /// Sets a new value for this `VN` using the configured change behavior.
  ///
  /// The behavior is determined by the [ChangeType] specified during initialization.
  set value(T newValue) => _valueSetter(newValue);

  /// Indicates whether this `VN` has active listeners.
  ///
  /// This method is visible for testing purposes.
  @override
  @protected
  @visibleForTesting
  bool get hasListeners => super.hasListeners;

  /// Notifies all listeners about a change in value.
  void notify() => notifyListeners();

  /// Updates the value and notifies listeners unconditionally.
  void hardSet(T newValue) {
    silentSet(newValue);
    notify();
  }

  /// Updates the value without notifying listeners.
  void silentSet(T newValue) {
    _value = newValue;
  }

  /// Updates the value if it differs from the current value, and notifies listeners.
  void smartSet(T newValue) {
    if (_value == newValue) return;

    hardSet(newValue);
  }

  /// Merges this `VN` with another `VN` into a derived `VN`.
  ///
  /// - [other]: The other `VN` to merge with.
  /// - [initialValue]: The initial value of the derived `VN`.
  /// - [listener]: A function that derives the value from the two `VN` instances.
  VN<K> merge<K, R>(
    VN<R> other,
    K initialValue,
    void Function(T left, R right, void Function(K value) emitter) listener,
  ) =>
      VN.merged(
        initialValue,
        left: this,
        right: other,
        listener: listener,
        changeType: changeType,
      );

  /// Returns a string representation of this `VN`.
  @override
  String toString() => '${describeIdentity(this)}($value)';
}

/// A specialized implementation of [VN] for merged `VN` instances.
class _MergedVN<T, L, R> extends VN<T> {
  late final void Function() _listener;
  late final void Function() _whenMergedDispose;

  static final _finalizer = Finalizer((VoidCallback cb) => cb);

  _MergedVN(
    T initialValue, {
    required VN<L> left,
    required VN<R> right,
    required void Function(L left, R right, void Function(T value) emitter)
        listener,
    ChangeType? changeType,
    void Function()? whenDispose,
  }) : super(initialValue, changeType ?? ChangeType.smart) {
    _listener = () => listener(
          left.value,
          right.value,
          (value) => this.value = value,
        );
    left.addListener(_listener);
    right.addListener(_listener);
    _whenMergedDispose = () {
      whenDispose?.call();
      left.removeListener(_listener);
      right.removeListener(_listener);
    };
    _finalizer.attach(this, _whenMergedDispose, detach: this);
  }

  /// Disposes the merged `VN` and cleans up listeners.
  @override
  void dispose() {
    _whenMergedDispose();
    _finalizer.detach(this);
    super.dispose();
  }
}
