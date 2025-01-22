# `better_notifier`

`Better Notifier` is a Dart package that simplifies state management by enhancing the capabilities of `ValueNotifier`. This package introduces powerful abstractions and extensions for managing `ValueNotifier` instances, making them more flexible, efficient, and developer-friendly. It is particularly suited for applications requiring advanced state management and reactive programming.

---

## Features

- **Enhanced `ValueNotifier`:** A custom `VN` class with additional capabilities for managing value changes.
- **Change Behaviors:** Configurable change types (`hard`, `silent`, `smart`) to control how updates are processed and listeners are notified.
- **Specialized Extensions:**
  - `BetterListNotifications`: Convenient methods for working with `VN<List<T>>`.
  - `BetterMapNotifications`: Additional utilities for managing `VN<Map<K, V>>`.
  - `BetterSetNotifications`: Simplifies operations on `VN<Set<T>>`.
- **Merging Notifiers:** Ability to combine multiple `VN` instances into a single `VN`, enabling derived state management.

---

## Installation

Add `better_notifier` to your project's `pubspec.yaml`:

```yaml
dependencies:
  better_notifier: ^0.0.1
```

Then, install it using the `flutter pub get` command.

---

## Usage

### Basic Usage

The `VN` class extends `ValueNotifier` with enhanced features:

```dart
import 'package:better_notifier/core/better_notifier.dart';

void main() {
  final counter = VN<int>(0);

  counter.addListener(() {
    print('Counter updated: ${counter.value}');
  });

  counter.value = 1; // Notifies listeners
}
```

---

### Change Types

Control how value updates are processed using `ChangeType`:

- **`ChangeType.hard`:** Always updates the value and notifies listeners.
- **`ChangeType.silent`:** Updates the value without notifying listeners.
- **`ChangeType.smart`:** Only updates the value if it differs from the current value and notifies listeners.

Example:

```dart
final notifier = VN<int>(0, ChangeType.smart);
notifier.value = 0; // No notification (smart behavior)
notifier.value = 1; // Notifies listeners
```

---

### Extensions

#### `BetterListNotifications`

Enhance `VN<List<T>>` with intuitive methods for list manipulation:

```dart
final listNotifier = VN<List<int>>([]);
listNotifier.add(5);       // Adds an element to the list
listNotifier.remove(5);    // Removes an element
print(listNotifier.length); // Get the list length
```

#### `BetterMapNotifications`

Simplify working with `VN<Map<K, V>>`:

```dart
final mapNotifier = VN<Map<String, int>>({});
mapNotifier['key'] = 42;   // Add or update a key-value pair
mapNotifier.remove('key'); // Remove a key-value pair
print(mapNotifier.keys);   // Access keys
```

#### `BetterSetNotifications`

Add utilities for `VN<Set<T>>`:

```dart
final setNotifier = VN<Set<int>>({});
setNotifier.add(10);       // Add an element to the set
setNotifier.remove(10);    // Remove an element
print(setNotifier.isEmpty); // Check if the set is empty
```

---

### Merging Notifiers

Combine multiple `VN` instances into a single derived `VN`:

```dart
final leftNotifier = VN<int>(0);
final rightNotifier = VN<int>(0);

final sumNotifier = VN.merged<int, int, int>(
  0,
  left: leftNotifier,
  right: rightNotifier,
  listener: (left, right, emit) {
    emit(left + right);
  },
);

sumNotifier.addListener(() {
  print('Sum updated: ${sumNotifier.value}');
});

leftNotifier.value = 5; // Prints: Sum updated: 5
rightNotifier.value = 3; // Prints: Sum updated: 8
```

---

## Why `better_notifier`?

`better_notifier` is designed to provide:
- **Cleaner Code:** Minimized boilerplate with intuitive methods and extensions.
- **Enhanced Flexibility:** Fine-grained control over state updates and notifications.
- **Efficiency:** Smart change behaviors to avoid unnecessary notifications.

---

## License

This package is licensed under the MIT License. See the `LICENSE` file for more details.