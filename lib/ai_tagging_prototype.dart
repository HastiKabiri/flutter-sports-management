class Tagger {
  // Simple rule-based analyzer used by the demo AI tab.
  // Returns a list of derived events or annotations for given input events.
  static List<Map<String, dynamic>> analyzeEvents(
    List<Map<String, dynamic>> events,
  ) {
    final out = <Map<String, dynamic>>[];
    for (final e in events) {
      final tag = e['tag']?.toString() ?? 'Unknown';
      final minute = e['minute'] ?? 0;
      // Simple example rules: if Goal and Assist share minute -> mark as 'Goal+Assist'
      out.add({
        'tag': tag,
        'minute': minute,
        'note': 'Detected by rule-based tagger',
      });
    }
    return out;
  }
}
