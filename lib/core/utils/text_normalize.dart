String normalizeToken(String s) {
  final lower = s.toLowerCase().trim();
  final cleaned = lower.replaceAll(RegExp(r"[^a-z' ]"), ' ');
  return cleaned.replaceAll(RegExp(r'\s+'), ' ').trim();
}

List<String> tokenizeWords(String text) {
  final n = normalizeToken(text);
  if (n.isEmpty) return [];
  return n.split(' ').where((e) => e.isNotEmpty).toList();
}
