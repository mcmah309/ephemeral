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