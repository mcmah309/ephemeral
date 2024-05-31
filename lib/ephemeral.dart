typedef WeakKeyMap = Expando;

/// Does not work with value types of numbers, strings, booleans, records, null, dart:ffi pointers, dart:ffi structs, or dart:ffi unions.
/// Like with [Expando], these do not work as these are often cloned internally in dart and there is no assciated object
/// id for these types, so any added here they will be instantly garbage collected, if you want to use these, wrap them in a [Wrapper].
/// 
// Dev Note: Cannot [Map] since iterable methods on map could cause concurrent modification issues.
class WeakValueMap<K, V extends Object> {
  final Map<K, WeakReference<V>> _map = {};
  late final Finalizer<Wrapper<K>> _finalizer;

  WeakValueMap() {
    _finalizer = Finalizer((key) {
      _map.remove(key.val);
    });
  }

  V? operator [](Object? key) {
    return _map[key]?.target;
  }

  void operator []=(K key, V value) {
    // If wrapper is not use then an error is yielded if the key and value are the same type and value //todo check
    _finalizer.attach(value, Wrapper(key));
    _map[key] = WeakReference(value);
  }
  
  @override
  void addAll(Map<K, V> other) {
    // TODO: implement addAll
  }
  
  @override
  void addEntries(Iterable<MapEntry<K, V>> newEntries) {
    // TODO: implement addEntries
  }
  
  @override
  Map<RK, RV> cast<RK, RV>() {
    // TODO: implement cast
    throw UnimplementedError();
  }
  
  @override
  void clear() {
    // TODO: implement clear
  }
  
  @override
  bool containsKey(Object? key) {
    // TODO: implement containsKey
    throw UnimplementedError();
  }
  
  @override
  bool containsValue(Object? value) {
    // TODO: implement containsValue
    throw UnimplementedError();
  }
  
  @override
  void forEach(void Function(K key, V value) action) {
    // TODO: implement forEach
  }
  
  @override
  // TODO: implement isEmpty
  bool get isEmpty => throw UnimplementedError();
  
  @override
  // TODO: implement isNotEmpty
  bool get isNotEmpty => throw UnimplementedError();
  
  @override
  int get length => _map.length;
  
  @override
  Map<K2, V2> map<K2, V2>(MapEntry<K2, V2> Function(K key, V value) convert) {
    // TODO: implement map
    throw UnimplementedError();
  }
  
  @override
  V putIfAbsent(K key, V Function() ifAbsent) {
    // TODO: implement putIfAbsent
    throw UnimplementedError();
  }
  
  @override
  V? remove(Object? key) {
    // TODO: implement remove
    throw UnimplementedError();
  }
  
  @override
  void removeWhere(bool Function(K key, V value) test) {
    // TODO: implement removeWhere
  }
  
  @override
  V update(K key, V Function(V value) update, {V Function()? ifAbsent}) {
    // TODO: implement update
    throw UnimplementedError();
  }
  
  @override
  void updateAll(V Function(K key, V value) update) {
    // TODO: implement updateAll
  }
}

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
