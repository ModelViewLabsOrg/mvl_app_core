extension SetExt on Set<String?> {
  bool containsInsensitive(String? value) {
    return any((e) => e?.toLowerCase() == value?.toLowerCase());
  }
}
