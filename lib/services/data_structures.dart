class StackDS<E>{
  final List<E> _storage;
  StackDS(): _storage = [];
  StackDS.of(Iterable<E> elements) : _storage = List<E>.of(elements);

  void push(E element) => _storage.add(element);
  E pop() => _storage.removeLast();
  List<E> get elementsCopied => List<E>.of(_storage);
  void clear() => _storage.clear();
  E get peek => _storage.last;
  bool get isEmpty => _storage.isEmpty;
  bool get isNotEmpty => !isEmpty;
  int get length => _storage.length;

  @override int get hashCode => Object.hashAll(_storage);
  @override String toString() => "⇆${_storage.reversed}";
}

class QueryDS<E>{
  final List<E> _storage;
  QueryDS(): _storage = [];
  QueryDS.of(Iterable<E> elements) : _storage = List<E>.of(elements);

  void push(E element) => _storage.add(element);
  E pop() => _storage.removeAt(0);
  List<E> get elementsCopied => List<E>.of(_storage);
  void clear() => _storage.clear();
  E get peek => _storage.first;
  bool get isEmpty => _storage.isEmpty;
  bool get isNotEmpty => !isEmpty;
  int get length => _storage.length;

  @override int get hashCode => Object.hashAll(_storage);
  @override String toString() => "←${_storage}←";
}