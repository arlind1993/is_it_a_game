extension IterableExtension<E> on Iterable<E>{

  E? firstWhereIfThere(bool test(E element), {E orElse()?}) {
    for (E element in this) {
      if (test(element)) return element;
    }
    if (orElse != null) return orElse();
    return null;
  }
}