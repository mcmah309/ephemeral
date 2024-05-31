typedef WeakKeyMap = Expando;

/// Does not work with value types of numbers, strings, booleans, records, null, dart:ffi pointers, dart:ffi structs, or dart:ffi unions.
/// Like with [Expando], these do not work as these are often cloned internally in dart and there is no assciated object
/// id for these types, so any added here they will be instantly garbage collected, if you want to use these, wrap them in a [Wrapper].
///
// Dev Note: Cannot extend [Map] since iterable methods or methods passing functions on map could cause concurrent modification
// if an entry is garbage collected during the operation.
class WeakValueMap<K, V extends Object> {
  final Map<K, WeakReference<V>> _map = {};
  late final Finalizer<K> _finalizer;

  WeakValueMap() {
    _finalizer = Finalizer((key) {
      _map.remove(key);
    });
  }

  /// Creates a new concrete map from this [WeakValueMap].
  Map<K, V> toMap() => _map.entries.fold({}, (previousValue, element) {
        final target = element.value.target;
        if (target == null) {
          return previousValue;
        }
        previousValue[element.key] = target;
        return previousValue;
      });

  V? operator [](K key) {
    return _map[key]?.target;
  }

  void operator []=(K key, V value) {
    _finalizer.attach(value, key);
    _map[key] = WeakReference(value);
  }

  /// Adds all key-value pairs of [other] to this map.
  void addAll(Map<K, V> other) {
    other.forEach((key, value) {
      this[key] = value;
    });
  }

  /// Adds all key-value pairs of [newEntries] to this map.
  void addEntries(Iterable<MapEntry<K, V>> newEntries) {
    for (final element in newEntries) {
      this[element.key] = element.value;
    }
  }

  /// Clears the map
  void clear() {
    _map.clear();
  }

  /// Checks if the map contains the [key].
  bool containsKey(K key) {
    return _map.containsKey(key);
  }

  /// Checks if the map contains the [value].
  bool containsValue(V value) {
    return _map.values.any((e) => e.target == value);
  }

  bool get isEmpty => _map.isEmpty;

  bool get isNotEmpty => _map.isNotEmpty;

  int get length => _map.length;

  /// Puts the [key] and [value] in the map if the [key] is not already in the map. Returns the value that is in the map
  /// after being called.
  V putIfAbsent(K key, V Function() ifAbsent) {
    final existing = this[key];
    if (existing == null) {
      final value = ifAbsent();
      this[key] = value;
      return value;
    }
    return existing;
  }

  /// Removes the [key] from the map and returns the value associated with the [key].
  V? remove(K key) {
    return _map.remove(key)?.target;
  }
}

/// A wrapper class.
class Wrapper<T> {
  T val;

  Wrapper(this.val);

  @override
  bool operator ==(Object other) {
    return other is Wrapper<T> && other.val == val;
  }

  @override
  int get hashCode => val.hashCode;
}
