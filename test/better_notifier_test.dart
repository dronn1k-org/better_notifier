import 'package:better_notifier/better_notifier.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Simple value notifier tests', () {
    late VN<int> listenable;
    bool isNotified = false;
    void someListener() => isNotified = true;
    setUp(() {
      listenable = 0.vn;
      isNotified = false;
      listenable.addListener(someListener);
    });
    test('Value changing is correct', () {
      expect(listenable.value, 0);

      listenable.value = 1;

      expect(listenable.value, 1);
    });

    test('Smart value changing is notified', () {
      expect(listenable.value, 0);
      expect(isNotified, false);

      listenable.value = 1;

      expect(listenable.value, 1);
      expect(isNotified, true);
    });

    test(
        'Smart value changing is not notified due to the same value persisting ',
        () {
      expect(listenable.value, 0);
      expect(isNotified, false);

      listenable.value = 0;

      expect(listenable.value, 0);
      expect(isNotified, false);
    });

    test('Hard value changing is notified even when same value persistent', () {
      expect(listenable.value, 0);
      expect(isNotified, false);

      listenable.hardSet(0);

      expect(listenable.value, 0);
      expect(isNotified, true);
    });
    test(
        'Silent value changing is not notified even when a different value persistent',
        () {
      expect(listenable.value, 0);
      expect(isNotified, false);

      listenable.silentSet(1);

      expect(listenable.value, 1);
      expect(isNotified, false);
    });
  });

  group('VN Merging tests', () {
    var leftBool = false.vn;
    var rightBool = false.vn;
    setUp(() {
      leftBool = false.vn;
      rightBool = false.vn;
    });

    test('Merged value is changed when the condition result is changed', () {
      final whenBothTrue = leftBool.merge(
          rightBool, false, (left, right, emitter) => emitter(left && right));

      expect(whenBothTrue.value, false);

      leftBool.value = true;
      expect(whenBothTrue.value, false);

      rightBool.value = true;
      expect(whenBothTrue.value, true);

      leftBool.value = false;
      expect(whenBothTrue.value, false);
    });

    test(
        'Smart merged value is not changed when condition is true and a value is the same',
        () {
      bool isMergedValueChanged = false;
      void listener() {
        print('faskdfn;akndf');
        isMergedValueChanged = true;
      }

      final whenBothTrue = leftBool.merge(
          rightBool, false, (left, right, emitter) => emitter(left && right));
      whenBothTrue.addListener(listener);

      expect(whenBothTrue.value, false);
      expect(isMergedValueChanged, false);

      leftBool.value = true;
      expect(whenBothTrue.value, false);
      expect(isMergedValueChanged, false);

      rightBool.value = true;
      expect(whenBothTrue.value, true);
      expect(isMergedValueChanged, true);

      isMergedValueChanged = false;

      leftBool.hardSet(true);
      expect(whenBothTrue.value, true);
      expect(isMergedValueChanged, false);

      leftBool.value = false;
      expect(whenBothTrue.value, false);
      expect(isMergedValueChanged, true);

      isMergedValueChanged = false;

      leftBool.hardSet(false);
      expect(whenBothTrue.value, false);
      expect(isMergedValueChanged, false);
    });

    test(
        'Hard Merged value is changed even when a previous value is the same as next',
        () {
      bool isMergedValueChanged = false;
      void listener() => isMergedValueChanged = true;

      final whenBothTrue = VN.merged(
        false,
        left: leftBool,
        right: rightBool,
        listener: (left, right, emitter) => emitter(left && right),
        changeType: ChangeType.hard,
      )..addListener(listener);

      expect(whenBothTrue.value, false);

      leftBool.value = true;

      expect(whenBothTrue.value, false);
      expect(isMergedValueChanged, true);
    });

    test(
        'When a Merged Value is disposing that listeners will be removed from the merging values',
        () {
      expect(leftBool.hasListeners, false);
      expect(rightBool.hasListeners, false);

      var whenBothTrue = leftBool.merge(
          rightBool, false, (left, right, emitter) => emitter(left && right));

      expect(leftBool.hasListeners, true);
      expect(rightBool.hasListeners, true);

      whenBothTrue.dispose();

      expect(leftBool.hasListeners, false);
      expect(rightBool.hasListeners, false);
    });
  });
}
