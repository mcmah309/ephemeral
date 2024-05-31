typedef WeakKeyMap = Expando;

/// A map where if there are no other references to the value, the entry can be garbage collected.
/// Like with [Expando], does not work with value types of numbers, strings, booleans, records, null, dart:ffi pointers, dart:ffi structs, or dart:ffi unions.
/// If you want to use these types, wrap them in a [Wrapper].
///
// Dev Note:
// The types that do not work, do not work since these are often cloned internally in dart and there is no assciated object
// id for these types, so any added here they will be instantly garbage collected.
//
// Cannot extend [Map] since iterable methods on map could cause concurrent modification
// if an entry is garbage collected during the operation (since [Finalizer] runs on the same thread, this can only occur
// if `await` is called).
class WeakValueMap<K extends Object, V extends Object> {
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
    final oldValue = _map[key];
    // Don't want the finalizer to later be called for an old value of this key.
    final detach = Wrapper(key);
    if (oldValue != null) {
      _finalizer.detach(detach);
    }
    _finalizer.attach(value, key, detach: detach);
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
    return this[key] != null;
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

  /// Apply the [action] function to each key-value pair of the map.
  void forEach(void Function(K key, V value) action) {
    _map.forEach((key, value) {
      final target = value.target;
      if (target == null) return;
      action(key, target);
    });
  }

  /// Returns a new map with the same keys and values as this map, but with the [convert] function applied to each key and value.
  WeakValueMap<K2, V2> map<K2 extends Object, V2 extends Object>(
      MapEntry<K2, V2> Function(K key, V value) convert) {
    final map = WeakValueMap<K2, V2>();
    _map.forEach((key, value) {
      final target = value.target;
      if (target == null) return;
      final entry = convert(key, target);
      map[entry.key] = entry.value;
    });
    return map;
  }

  void removeWhere(bool Function(K key, V value) test) {
    _map.removeWhere((key, value) {
      final target = value.target;
      if (target == null) return false;
      return test(key, target);
    });
  }

  /// Updates the value of the [key] with the [update] function. If the [key] is not in the map,
  /// the [ifAbsent] function is used instead.
  V? update(K key, V Function(V value) update, {V Function()? ifAbsent}) {
    final value = this[key];
    if (value == null) {
      if (ifAbsent == null) return null;
      final newValue = ifAbsent();
      this[key] = newValue;
      return newValue;
    }
    final newValue = update(value);
    this[key] = newValue;
    return newValue;
  }

  /// Updates all values in the map with the [update] function.
  void updateAll(V Function(K key, V value) update) {
    _map.forEach((key, value) {
      final target = value.target;
      if (target == null) return;
      this[key] = update(key, target);
    });
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
