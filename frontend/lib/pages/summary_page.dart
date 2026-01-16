// Voca 语刻 - Summary Page (语境室)
// Interactive story display with popup translation dialogs

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme.dart';
import '../providers/learning_provider.dart';
import '../data/api_client.dart';
import 'learning_page.dart';

class SummaryPage extends ConsumerStatefulWidget {
  const SummaryPage({super.key});

  @override
  ConsumerState<SummaryPage> createState() => _SummaryPageState();
}

class _SummaryPageState extends ConsumerState<SummaryPage> {
  bool _showFullTranslation = false;
  final ApiClient _api = ApiClient();
  
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(learningProvider);
    final story = state.story;
    final session = state.session;
    final isGenerating = state.status == SessionStatus.generating;
    
    final studiedWords = session?.words.map((w) => w.word.text).toList() ?? [];
    
    return Scaffold(
      backgroundColor: VocaTheme.background,
      appBar: AppBar(
        title: const Text('语境室'),
        backgroundColor: VocaTheme.background,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: isGenerating 
            ? _buildGeneratingAnimation(context, studiedWords)
            : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCompletionHeader(context, session),
                const SizedBox(height: 16),
                _buildTranslateButton(),
                const SizedBox(height: 16),
                Expanded(
                  child: _buildStoryContent(context, story, state.errorMessage, studiedWords),
                ),
                const SizedBox(height: 16),
                _buildActionButtons(context, ref),
              ],
            ),
        ),
      ),
    );
  }

  Widget _buildTranslateButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _showFullTranslation 
            ? VocaTheme.cyan.withValues(alpha: 0.2)
            : VocaTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _showFullTranslation ? VocaTheme.cyan : VocaTheme.surfaceLight,
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            setState(() {
              _showFullTranslation = !_showFullTranslation;
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _showFullTranslation ? Icons.abc : Icons.translate,
                  color: _showFullTranslation ? VocaTheme.cyan : VocaTheme.textSecondary,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Text(
                  _showFullTranslation ? '🔤 切换英文原文' : '🌐 显示全文中文翻译',
                  style: TextStyle(
                    color: _showFullTranslation ? VocaTheme.cyan : VocaTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn().slideY(begin: -0.2);
  }

  Widget _buildGeneratingAnimation(BuildContext context, List<String> words) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: VocaTheme.cyan.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.psychology, color: VocaTheme.cyan, size: 50),
          )
          .animate(onPlay: (c) => c.repeat())
          .shimmer(duration: 1500.ms, color: VocaTheme.cyan.withValues(alpha: 0.3))
          .then()
          .shake(hz: 2, curve: Curves.easeInOut),
          
          const SizedBox(height: 32),
          Text(
            '🧠 AI 正在编织语境...',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: VocaTheme.cyan),
          ).animate().fadeIn(),
          const SizedBox(height: 16),
          Text('正在为以下单词创作故事', style: Theme.of(context).textTheme.bodyMedium)
            .animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 24),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: words.asMap().entries.map((entry) {
              return Chip(
                label: Text(entry.value),
                backgroundColor: VocaTheme.surface,
                labelStyle: const TextStyle(color: VocaTheme.cyan, fontSize: 13),
                side: BorderSide(color: VocaTheme.cyan.withValues(alpha: 0.3)),
              ).animate(delay: (entry.key * 100).ms).fadeIn().slideY(begin: 0.3);
            }).toList(),
          ),
          const SizedBox(height: 32),
          const SizedBox(
            width: 200,
            child: LinearProgressIndicator(
              color: VocaTheme.cyan,
              backgroundColor: VocaTheme.surfaceLight,
            ),
          ).animate().fadeIn(delay: 500.ms),
        ],
      ),
    );
  }

  Widget _buildCompletionHeader(BuildContext context, dynamic session) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: VocaTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: VocaTheme.cyan.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: VocaTheme.cyan.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.emoji_events, color: VocaTheme.cyan, size: 24),
          ).animate().scale(begin: const Offset(0, 0), curve: Curves.elasticOut, duration: 600.ms),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🎉 刻印完成！',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(color: VocaTheme.cyan),
                ).animate().fadeIn().slideX(begin: -0.2),
                const SizedBox(height: 2),
                Text(
                  '点击任意单词查看详细释义',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: VocaTheme.textMuted),
                ).animate().fadeIn(delay: 100.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoryContent(BuildContext context, dynamic story, String? error, List<String> studiedWords) {
    if (story == null) {
      if (error != null) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.warning_amber, color: VocaTheme.warning, size: 48),
              const SizedBox(height: 16),
              Text('故事生成失败', style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 8),
              Text(error, style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
            ],
          ),
        );
      }
      return const Center(child: CircularProgressIndicator(color: VocaTheme.cyan));
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: VocaTheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Theme tag
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: VocaTheme.cyan.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text('# ${story.theme}', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: VocaTheme.cyan)),
              ),
              if (_showFullTranslation) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: VocaTheme.success.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('中文翻译', style: TextStyle(color: VocaTheme.success, fontSize: 11)),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          
          // Story content
          Expanded(
            child: SingleChildScrollView(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _showFullTranslation
                  ? _buildChineseTranslation(context, story)
                  : _buildInteractiveEnglishStory(context, story, studiedWords),
              ),
            ),
          ),
          
          const Divider(height: 24),
          
          // Keywords
          Text('本轮刻印:', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: VocaTheme.textMuted)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: studiedWords.map((keyword) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: VocaTheme.cyan.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(keyword, style: const TextStyle(color: VocaTheme.cyan, fontSize: 12)),
              );
            }).toList(),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1);
  }

  Widget _buildInteractiveEnglishStory(BuildContext context, dynamic story, List<String> studiedWords) {
    final text = story.content;
    final studiedWordsLower = studiedWords.map((w) => w.toLowerCase()).toSet();
    
    // Split text into words while preserving spaces and punctuation
    final wordPattern = RegExp(r'(\*\*[^*]+\*\*|\S+|\s+)');
    final matches = wordPattern.allMatches(text);
    
    List<InlineSpan> spans = [];
    
    for (final match in matches) {
      final token = match.group(0)!;
      
      // Check if it's a bold word (studied vocabulary) - show ONLY English
      if (token.startsWith('**') && token.endsWith('**')) {
        final word = token.substring(2, token.length - 2);
        final definition = story.wordDefinitions[word] ?? '';
        
        spans.add(WidgetSpan(
          child: _buildClickableWord(
            word, 
            definition, 
            isStudiedWord: true,
            context: context,
          ),
        ));
      } 
      // Whitespace
      else if (token.trim().isEmpty) {
        spans.add(TextSpan(text: token));
      }
      // Regular word - make it clickable
      else {
        final wordMatch = RegExp(r'([a-zA-Z]+)').firstMatch(token);
        if (wordMatch != null) {
          final word = wordMatch.group(1)!;
          final prefix = token.substring(0, wordMatch.start);
          final suffix = token.substring(wordMatch.end);
          
          if (prefix.isNotEmpty) {
            spans.add(TextSpan(text: prefix, style: const TextStyle(color: VocaTheme.textPrimary)));
          }
          
          spans.add(WidgetSpan(
            child: _buildClickableWord(
              word, 
              null, 
              isStudiedWord: studiedWordsLower.contains(word.toLowerCase()),
              context: context,
            ),
          ));
          
          if (suffix.isNotEmpty) {
            spans.add(TextSpan(text: suffix, style: const TextStyle(color: VocaTheme.textPrimary)));
          }
        } else {
          spans.add(TextSpan(text: token, style: const TextStyle(color: VocaTheme.textPrimary)));
        }
      }
    }
    
    return Text.rich(
      TextSpan(children: spans),
      key: const ValueKey('english'),
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 2.0),
    );
  }

  Widget _buildClickableWord(String word, String? knownDefinition, {required bool isStudiedWord, required BuildContext context}) {
    return GestureDetector(
      onTap: () => _showWordDefinitionDialog(context, word, knownDefinition),
      child: Text(
        word,
        style: TextStyle(
          color: isStudiedWord ? VocaTheme.cyan : VocaTheme.textPrimary,
          fontWeight: isStudiedWord ? FontWeight.w700 : FontWeight.w400,
          decoration: TextDecoration.underline,
          decorationColor: isStudiedWord ? VocaTheme.cyan.withValues(alpha: 0.3) : VocaTheme.textMuted.withValues(alpha: 0.3),
          decorationStyle: TextDecorationStyle.dotted,
        ),
      ),
    );
  }

  Future<void> _showWordDefinitionDialog(BuildContext context, String word, String? knownDefinition) async {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (context) => _WordDefinitionDialog(
        word: word,
        knownDefinition: knownDefinition,
        api: _api,
      ),
    );
  }

  Widget _buildChineseTranslation(BuildContext context, dynamic story) {
    if (story.translation.isEmpty) {
      return Text(
        '翻译未生成',
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: VocaTheme.textSecondary, height: 1.8),
      );
    }
    
    // Parse translation and highlight studied words
    final text = story.translation;
    final keywords = (story.keywords as List<String>);
    
    // Build rich text with highlighted vocabulary
    return _buildHighlightedChineseText(context, text, keywords, story.wordDefinitions);
  }

  Widget _buildHighlightedChineseText(BuildContext context, String text, List<String> keywords, Map<String, String> definitions) {
    // Pattern to match **word** (bold markdown)
    final pattern = RegExp(r'\*\*([^*]+)\*\*');
    List<TextSpan> spans = [];
    int lastEnd = 0;
    
    for (final match in pattern.allMatches(text)) {
      // Add text before match (normal Chinese text)
      if (match.start > lastEnd) {
        spans.add(TextSpan(
          text: text.substring(lastEnd, match.start),
          style: const TextStyle(color: VocaTheme.textSecondary),
        ));
      }
      
      // Add the highlighted word (生词 - special color)
      final word = match.group(1)!;
      spans.add(TextSpan(
        text: word,
        style: const TextStyle(
          color: Color(0xFFFFD700),  // Gold color for vocabulary in Chinese mode
          fontWeight: FontWeight.w700,
          backgroundColor: Color(0x20FFD700),
        ),
      ));
      
      lastEnd = match.end;
    }
    
    // Add remaining text
    if (lastEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastEnd),
        style: const TextStyle(color: VocaTheme.textSecondary),
      ));
    }
    
    return SelectableText.rich(
      TextSpan(children: spans),
      key: const ValueKey('chinese'),
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.8),
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              ref.read(learningProvider.notifier).reset();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LearningPage()),
              );
            },
            icon: const Icon(Icons.replay),
            label: const Text('继续刻印'),
            style: ElevatedButton.styleFrom(
              backgroundColor: VocaTheme.cyan,
              foregroundColor: VocaTheme.background,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2);
  }
}

/// Dialog to show word definition with loading state
class _WordDefinitionDialog extends StatefulWidget {
  final String word;
  final String? knownDefinition;
  final ApiClient api;
  
  const _WordDefinitionDialog({
    required this.word,
    this.knownDefinition,
    required this.api,
  });

  @override
  State<_WordDefinitionDialog> createState() => _WordDefinitionDialogState();
}

class _WordDefinitionDialogState extends State<_WordDefinitionDialog> {
  String? _definition;
  bool _isLoading = true;
  String? _error;
  String _source = '';
  
  @override
  void initState() {
    super.initState();
    _loadDefinition();
  }
  
  Future<void> _loadDefinition() async {
    // If we already have a definition, use it
    if (widget.knownDefinition != null && widget.knownDefinition!.isNotEmpty) {
      setState(() {
        _definition = widget.knownDefinition;
        _isLoading = false;
        _source = 'vocabulary';
      });
      return;
    }
    
    // Otherwise, call API
    try {
      final result = await widget.api.translateWord(widget.word);
      setState(() {
        _definition = result['definition'];
        _source = result['source'] ?? 'ai';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: VocaTheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 320),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Word header
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.word,
                    style: const TextStyle(
                      color: VocaTheme.cyan,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: VocaTheme.textMuted, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            
            const SizedBox(height: 4),
            
            // Source indicator
            if (_source.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _source == 'ai' 
                      ? VocaTheme.warning.withValues(alpha: 0.2)
                      : VocaTheme.success.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _source == 'ai' ? '🤖 AI翻译' : '📚 词库',
                  style: TextStyle(
                    color: _source == 'ai' ? VocaTheme.warning : VocaTheme.success,
                    fontSize: 11,
                  ),
                ),
              ),
            
            const SizedBox(height: 16),
            const Divider(color: VocaTheme.surfaceLight),
            const SizedBox(height: 16),
            
            // Definition content
            if (_isLoading)
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(color: VocaTheme.cyan, strokeWidth: 2),
                    SizedBox(height: 12),
                    Text('正在查询...', style: TextStyle(color: VocaTheme.textMuted)),
                  ],
                ),
              )
            else if (_error != null)
              Text(
                '查询失败: $_error',
                style: const TextStyle(color: VocaTheme.error),
              )
            else
              Text(
                _definition ?? '暂无释义',
                style: const TextStyle(
                  color: VocaTheme.textPrimary,
                  fontSize: 16,
                  height: 1.6,
                ),
              ),
            
            const SizedBox(height: 20),
            
            // Close button
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  foregroundColor: VocaTheme.cyan,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('关闭'),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 200.ms).scale(begin: const Offset(0.9, 0.9));
  }
}
