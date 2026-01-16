/// Voca 语刻 - API Client
/// Dio HTTP client for backend communication

import 'package:dio/dio.dart';
import '../models/models.dart';

class ApiClient {
  static const String baseUrl = 'http://localhost:8000/api';
  
  final Dio _dio;
  
  ApiClient() : _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {
      'Content-Type': 'application/json',
    },
  ));
  
  /// Get learning session - 10 random words
  Future<List<Word>> getLearningSession({
    required String userId,
    String level = 'GRE',
    int count = 10,
  }) async {
    try {
      final response = await _dio.get('/session', queryParameters: {
        'user_id': userId,
        'level': level,
        'count': count,
      });
      
      return (response.data as List)
          .map((json) => Word.fromJson(json))
          .toList();
    } catch (e) {
      throw ApiException('Failed to load session: $e');
    }
  }
  
  /// Update progress after answering
  Future<ProgressResponse> updateProgress({
    required String userId,
    required int wordId,
    required bool correct,
  }) async {
    try {
      final response = await _dio.post('/progress', data: {
        'user_id': userId,
        'word_id': wordId,
        'correct': correct,
      });
      
      return ProgressResponse.fromJson(response.data);
    } catch (e) {
      throw ApiException('Failed to update progress: $e');
    }
  }
  
  /// Generate AI story with current words
  Future<StoryResponse> generateStory({
    required List<int> wordIds,
    String theme = '量化投资',
  }) async {
    try {
      final response = await _dio.post('/story', data: {
        'word_ids': wordIds,
        'theme': theme,
      });
      
      return StoryResponse.fromJson(response.data);
    } catch (e) {
      throw ApiException('Failed to generate story: $e');
    }
  }
  
  /// Get user progress statistics
  Future<Map<String, int>> getUserProgress(String userId) async {
    try {
      final response = await _dio.get('/progress/$userId');
      return Map<String, int>.from(response.data);
    } catch (e) {
      throw ApiException('Failed to get progress: $e');
    }
  }
  
  /// Translate a single word (checks DB, falls back to AI)
  Future<Map<String, String>> translateWord(String word) async {
    try {
      final response = await _dio.get('/translate/${Uri.encodeComponent(word)}');
      return {
        'word': response.data['word'] as String,
        'definition': response.data['definition'] as String,
        'source': response.data['source'] as String,
      };
    } catch (e) {
      throw ApiException('Failed to translate: $e');
    }
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  
  @override
  String toString() => message;
}
