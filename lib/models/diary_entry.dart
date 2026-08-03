class DiaryEntry {
  final int? id;
  final String content;
  final DateTime timestamp;
  final bool isEncrypted;
  final bool analyzedForPatterns;
  final String? entryType;
  final String? aiInsight;
  final String? who;
  final String? where;

  DiaryEntry({
    this.id,
    required this.content,
    required this.timestamp,
    this.isEncrypted = false,
    this.analyzedForPatterns = false,
    this.entryType,
    this.aiInsight,
    this.who,
    this.where,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'is_encrypted': isEncrypted ? 1 : 0,
      'analyzed_for_patterns': analyzedForPatterns ? 1 : 0,
      'entry_type': entryType,
      'ai_insight': aiInsight,
      'who': who,
      'where': where,
    };
  }

  factory DiaryEntry.fromMap(Map<String, dynamic> map) {
    return DiaryEntry(
      id: map['id'],
      content: map['content'],
      timestamp: DateTime.parse(map['timestamp']),
      isEncrypted: map['is_encrypted'] == 1,
      analyzedForPatterns: map['analyzed_for_patterns'] == 1,
      entryType: map['entry_type'],
      aiInsight: map['ai_insight'],
      who: map['who'],
      where: map['where'],
    );
  }
}
