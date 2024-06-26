import 'package:ephemeral/ephemeral.dart';
import 'package:test/test.dart';

void main() {
  test('Some keys are collected', () async {
    WeakValueMap<int, Wrapper<int>> x = WeakValueMap();
    List<int> allAddedEntries = List.filled(10000, 0);
    for (int index = 0; index < allAddedEntries.length; index++) {
      allAddedEntries[index] = index;
      x[index] = Wrapper(index);
    }
    await Future.delayed(Duration(milliseconds: 100));
    bool haveSomeKeysBeenCollected = allAddedEntries.length != x.length;
    expect(haveSomeKeysBeenCollected, isTrue);
  });

  test('No keys are collected', () async {
    WeakValueMap<int, Wrapper<int>> x = WeakValueMap();
    List<int> allAddedEntries = List.filled(10000, 0);
    // other reference
    List<Wrapper<int>> wrappers = [];
    for (int index = 0; index < allAddedEntries.length; index++) {
      allAddedEntries[index] = index;
      final wrapper = Wrapper(index);
      x[index] = wrapper;
      wrappers.add(wrapper);
    }
    await Future.delayed(Duration(milliseconds: 100));
    bool haveSomeKeysBeenCollected = allAddedEntries.length == x.length;
    expect(haveSomeKeysBeenCollected, isTrue);
  });

  test('Same object keys and values', () async {
    WeakValueMap<Wrapper<int>, Wrapper<int>> x = WeakValueMap();
    List<Wrapper<int>> allAddedEntries = [];
    for (int index = 0; index < allAddedEntries.length; index++) {
      final wrapper = Wrapper(index);
      allAddedEntries[index] = wrapper;
      x[wrapper] = wrapper;
    }
    await Future.delayed(Duration(milliseconds: 100));
    bool haveSomeKeysBeenCollected = allAddedEntries.length == x.length;
    expect(haveSomeKeysBeenCollected, isTrue);
  });

  test('toMap is safe', () async {
    WeakValueMap<int, Wrapper<int>> x = WeakValueMap();
    List<int> allAddedEntries = List.filled(10000, 0);
    for (int index = 0; index < allAddedEntries.length; index++) {
      allAddedEntries[index] = index;
      x[index] = Wrapper(index);
      x.toMap();
    }
    await Future.delayed(Duration(milliseconds: 100));
    bool haveSomeKeysBeenCollected = allAddedEntries.length != x.length;
    expect(haveSomeKeysBeenCollected, isTrue);
  });
}
