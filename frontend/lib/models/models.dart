/// Voca 语刻 - Data Models

/// Word model for vocabulary items
/// Word definition entry
class WordDefinition {
  final String pos; // Part of speech (n., v., etc.)
  final String meaning;
  final String tags;

  WordDefinition({required this.pos, required this.meaning, required this.tags});

  factory WordDefinition.fromJson(Map<String, dynamic> json) {
    return WordDefinition(
      pos: json['pos'] as String? ?? 'unk.',
      meaning: json['meaning'] as String? ?? '',
      tags: json['tags'] as String? ?? '',
    );
  }
}

class Word {
  final int id;
  final String text;
  final String definition;
  final String? phonetic;
  final String? phoneticUs;
  final String? phoneticUk;
  final List<WordDefinition>? definitions;
  final List<String> options;

  Word({
    required this.id,
    required this.text,
    required this.definition,
    this.phonetic,
    this.phoneticUs,
    this.phoneticUk,
    this.definitions,
    this.options = const [],
  });

  factory Word.fromJson(Map<String, dynamic> json) {
    return Word(
      id: json['id'] as int,
      text: json['text'] as String,
      definition: json['definition'] as String,
      phonetic: json['phonetic'] as String?,
      phoneticUs: json['phonetic_us'] as String?,
      phoneticUk: json['phonetic_uk'] as String?,
      definitions: (json['definition_json'] as List<dynamic>?)
          ?.map((e) => WordDefinition.fromJson(e as Map<String, dynamic>))
          .toList(),
      options: (json['options'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'text': text,
    'definition': definition,
    'phonetic': phonetic,
    'options': options,
  };
}

/// Progress for a single word in current session
class WordProgress {
  final Word word;
  int masteryCount; // 0, 1, 2, or 3
  bool get isMastered => masteryCount >= 3;
  
  WordProgress({
    required this.word,
    this.masteryCount = 0,
  });
  
  void incrementMastery() {
    if (masteryCount < 3) {
      masteryCount++;
    }
  }
}

/// Learning session state
class LearningSession {
  final List<WordProgress> words;
  int currentIndex;
  
  LearningSession({
    required this.words,
    this.currentIndex = 0,
  });
  
  WordProgress? get currentWord => 
      currentIndex < words.length ? words[currentIndex] : null;
  
  bool get isComplete => 
      words.every((w) => w.isMastered);
  
  int get totalMastered => 
      words.where((w) => w.isMastered).length;
  
  int get totalWords => words.length;
  
  /// Get next word that needs practice (not yet mastered)
  void moveToNext() {
    // Find next unmastered word
    for (int i = 0; i < words.length; i++) {
      int idx = (currentIndex + 1 + i) % words.length;
      if (!words[idx].isMastered) {
        currentIndex = idx;
        return;
      }
    }
    // All mastered
    currentIndex = words.length;
  }
}

/// API response for progress update
class ProgressResponse {
  final int wordId;
  final int masteryCount;
  final bool isMastered;
  
  ProgressResponse({
    required this.wordId,
    required this.masteryCount,
    required this.isMastered,
  });
  
  factory ProgressResponse.fromJson(Map<String, dynamic> json) {
    return ProgressResponse(
      wordId: json['word_id'] as int,
      masteryCount: json['mastery_count'] as int,
      isMastered: json['is_mastered'] as bool,
    );
  }
}

/// AI Story response with translation
class StoryResponse {
  final String content;  // English story
  final String translation;  // Chinese translation
  final List<String> keywords;  // Studied words
  final Map<String, String> wordDefinitions;  // word -> Chinese definition
  final String theme;
  
  StoryResponse({
    required this.content,
    this.translation = "",
    required this.keywords,
    this.wordDefinitions = const {},
    required this.theme,
  });
  
  factory StoryResponse.fromJson(Map<String, dynamic> json) {
    return StoryResponse(
      content: json['content'] as String,
      translation: json['translation'] as String? ?? '',
      keywords: (json['keywords'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      wordDefinitions: (json['word_definitions'] as Map<String, dynamic>?)
          ?.map((k, v) => MapEntry(k, v as String)) ?? {},
      theme: json['theme'] as String,
    );
  }
}

