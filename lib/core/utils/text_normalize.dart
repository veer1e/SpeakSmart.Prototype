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

/// Common word aliases/synonyms that should be treated as matching
/// Maps normalized word to its canonical form or accepted variants
const Map<String, Set<String>> wordAliases = {
  'okay': {'okay', 'ok', 'k'},
  'alright': {'alright', 'all right', 'aright'},
  'hello': {'hello', 'hi', 'hey', 'halo'},
  'goodbye': {'goodbye', 'good bye', 'bye'},
  'thanks': {'thanks', 'thank', 'thankyou', 'thank you'},
  'please': {'please', 'pls'},
  'yes': {'yes', 'yep', 'yeah', 'yea', 'ya'},
  'no': {'no', 'nope', 'nah'},
  'cannot': {'cannot', 'can not', 'cant'},
  'wont': {'wont', 'won\'t', 'will not'},
};

/// Normalize a word to its canonical form for comparison
/// E.g., "ok" normalizes to "okay" if that's in wordAliases
String normalizeWord(String word) {
  final lower = word.toLowerCase().trim();
  
  // Check if this word has aliases
  for (final entry in wordAliases.entries) {
    if (entry.value.contains(lower)) {
      return entry.key; // Return canonical form
    }
  }
  
  return lower; // Return as-is if no alias found
}

/// Calculate Levenshtein distance (edit distance) between two strings
/// Useful for fuzzy matching similar words
int levenshteinDistance(String s1, String s2) {
  final s1Lower = s1.toLowerCase();
  final s2Lower = s2.toLowerCase();
  
  if (s1Lower == s2Lower) return 0;
  if (s1Lower.isEmpty) return s2Lower.length;
  if (s2Lower.isEmpty) return s1Lower.length;

  final len1 = s1Lower.length;
  final len2 = s2Lower.length;
  final d = List.generate(len1 + 1, (i) => List.filled(len2 + 1, 0));

  for (int i = 0; i <= len1; i++) d[i][0] = i;
  for (int j = 0; j <= len2; j++) d[0][j] = j;

  for (int i = 1; i <= len1; i++) {
    for (int j = 1; j <= len2; j++) {
      final cost = s1Lower[i - 1] == s2Lower[j - 1] ? 0 : 1;
      d[i][j] = [
        d[i - 1][j] + 1,     // deletion
        d[i][j - 1] + 1,     // insertion
        d[i - 1][j - 1] + cost, // substitution
      ].reduce((a, b) => a < b ? a : b);
    }
  }

  return d[len1][len2];
}

/// Check if two words are similar enough to be considered a match
/// Returns true if they are identical, have aliases, or have low edit distance
bool areWordsSimilar(String word1, String word2, {int maxDistance = 1}) {
  final w1 = word1.toLowerCase().trim();
  final w2 = word2.toLowerCase().trim();
  
  // Exact match
  if (w1 == w2) return true;
  
  // Check if they are aliases
  final normalized1 = normalizeWord(w1);
  final normalized2 = normalizeWord(w2);
  if (normalized1 == normalized2) return true;
  
  // Fuzzy match using Levenshtein distance
  // Allow 1 character difference for words longer than 4 chars
  // Allow 0 for shorter words
  final distance = levenshteinDistance(w1, w2);
  final threshold = w1.length > 4 && w2.length > 4 ? maxDistance : 0;
  
  return distance <= threshold;
}
