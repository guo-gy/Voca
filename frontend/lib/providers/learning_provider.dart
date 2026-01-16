/// Voca 语刻 - Learning State Provider
/// Riverpod StateNotifier for managing learning session

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../data/api_client.dart';

/// API Client provider
final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

/// User ID provider (simplified - in production use auth)
final userIdProvider = Provider<String>((ref) => 'demo_user_001');

/// Learning Session State
enum SessionStatus { initial, loading, active, answering, generating, complete, error }

class LearningState {
  final SessionStatus status;
  final LearningSession? session;
  final String? errorMessage;
  final bool? lastAnswerCorrect; // For feedback animation
  final StoryResponse? story;
  
  const LearningState({
    this.status = SessionStatus.initial,
    this.session,
    this.errorMessage,
    this.lastAnswerCorrect,
    this.story,
  });
  
  LearningState copyWith({
    SessionStatus? status,
    LearningSession? session,
    String? errorMessage,
    bool? lastAnswerCorrect,
    StoryResponse? story,
  }) {
    return LearningState(
      status: status ?? this.status,
      session: session ?? this.session,
      errorMessage: errorMessage,
      lastAnswerCorrect: lastAnswerCorrect,
      story: story ?? this.story,
    );
  }
}

/// Learning Session Notifier
class LearningNotifier extends StateNotifier<LearningState> {
  final ApiClient _api;
  final String _userId;
  
  LearningNotifier(this._api, this._userId) : super(const LearningState());
  
  /// Start a new learning session
  Future<void> startSession({String level = 'GRE'}) async {
    state = state.copyWith(status: SessionStatus.loading);
    
    try {
      final words = await _api.getLearningSession(
        userId: _userId,
        level: level,
      );
      
      final session = LearningSession(
        words: words.map((w) => WordProgress(word: w)).toList(),
      );
      
      state = state.copyWith(
        status: SessionStatus.active,
        session: session,
      );
    } catch (e) {
      state = state.copyWith(
        status: SessionStatus.error,
        errorMessage: e.toString(),
      );
    }
  }
  
  /// Submit an answer for the current word
  Future<void> submitAnswer(String selectedDefinition) async {
    final session = state.session;
    if (session == null || session.currentWord == null) return;
    
    final currentWord = session.currentWord!;
    final isCorrect = selectedDefinition == currentWord.word.definition;
    
    state = state.copyWith(
      status: SessionStatus.answering,
      lastAnswerCorrect: isCorrect,
    );
    
    try {
      // Update backend
      await _api.updateProgress(
        userId: _userId,
        wordId: currentWord.word.id,
        correct: isCorrect,
      );
      
      // Update local state if correct
      if (isCorrect) {
        currentWord.incrementMastery();
      }
      
      // Short delay for feedback animation
      await Future.delayed(const Duration(milliseconds: 800));
      
      // Check if session complete
      if (session.isComplete) {
        await _generateStory();
      } else {
        // Move to next word
        session.moveToNext();
        state = state.copyWith(
          status: SessionStatus.active,
          session: session,
        );
      }
    } catch (e) {
      state = state.copyWith(
        status: SessionStatus.error,
        errorMessage: e.toString(),
      );
    }
  }
  
  /// Generate AI story after completing session
  Future<void> _generateStory() async {
    final session = state.session;
    if (session == null) return;
    
    // Set generating state for loading animation
    state = state.copyWith(status: SessionStatus.generating);
    
    try {
      // Debug: Print all word IDs
      final wordIds = session.words.map((w) => w.word.id).toList();
      print('[Frontend] Session has ${session.words.length} words');
      print('[Frontend] Word IDs to send: $wordIds');
      print('[Frontend] Words: ${session.words.map((w) => w.word.text).toList()}');
      
      final story = await _api.generateStory(wordIds: wordIds);
      
      print('[Frontend] Story received, length: ${story.content.length}');
      
      state = state.copyWith(
        status: SessionStatus.complete,
        story: story,
      );
    } catch (e) {
      print('[Frontend] Error generating story: $e');
      // Still mark as complete even if story fails
      state = state.copyWith(
        status: SessionStatus.complete,
        errorMessage: 'Story generation failed: $e',
      );
    }
  }
  
  /// Skip to summary (for testing purposes)
  Future<void> skipToSummary() async {
    final session = state.session;
    if (session == null) return;
    
    // Mark all words as mastered locally
    for (var wordProgress in session.words) {
      wordProgress.masteryCount = 3;
    }
    
    // Generate story
    await _generateStory();
  }
  
  /// Reset and start new session
  void reset() {
    state = const LearningState();
  }
}

/// Provider for learning state
final learningProvider = StateNotifierProvider<LearningNotifier, LearningState>((ref) {
  final api = ref.watch(apiClientProvider);
  final userId = ref.watch(userIdProvider);
  return LearningNotifier(api, userId);
});
