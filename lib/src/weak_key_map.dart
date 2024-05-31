import 'package:ephemeral/ephemeral.dart';

/// A map where if there are no other references to the key, the entry can be garbage collected.
/// Does not work with value types of numbers, strings, booleans, records, null, dart:ffi pointers, dart:ffi structs, or dart:ffi unions.
/// If you want to use these types, wrap them in a [Wrapper].
//
// Dev Note: Cannot implement something similar to [WeakValueMap] since the key would need to be wrapped in a [WeakReference]
// and if that is so, we cannot retrieve the key, since the hash is the [WeakReference] object. The only other option is fully implement a new map type or use something like
// ```dart
// final Map<int, V> _map = {};
// final Map<int, WeakReference<K>> _keyMap = {};
// ```
// Where [int] is [K]'s hashcode. Either option starts to become inefficient, better use the native [Expando] and lose some functionality.
typedef WeakKeyMap = Expando;
