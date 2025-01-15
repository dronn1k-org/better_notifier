import 'package:flutter/foundation.dart';

typedef ValueChanger<T> = void Function(T newValue);

enum ChangeType {
  hard,
  silent,
  smart;
}

class VN<T> with ChangeNotifier implements ValueListenable<T> {
  late T _value;

  final ChangeType changeType;

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

  late final ValueChanger<T> _valueSetter;

  @override
  T get value => _value;

  set value(T newValue) => _valueSetter(newValue);

  @override
  @protected
  @visibleForTesting
  bool get hasListeners => super.hasListeners;

  void notify() => notifyListeners();

  void hardSet(T newValue) {
    silentSet(newValue);
    notify();
  }

  void silentSet(T newValue) {
    _value = newValue;
  }

  void smartSet(T newValue) {
    if (_value == newValue) return;

    hardSet(newValue);
  }

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

  @override
  String toString() => '${describeIdentity(this)}($value)';
}

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

  @override
  void dispose() {
    _whenMergedDispose();
    _finalizer.detach(this);
    super.dispose();
  }
}
