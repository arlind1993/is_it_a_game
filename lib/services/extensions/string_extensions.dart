extension StringCasingExtension on String {
  String toCapitalized() {
    if (length > 0) {
      return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
    } else {
      return '';
    }
  }
  String toTitleCase() {
    return replaceAll(RegExp(' +'), ' ')
      .split(' ')
      .map((str) {
        return str.toCapitalized();
      })
      .join(' ');
  }
}