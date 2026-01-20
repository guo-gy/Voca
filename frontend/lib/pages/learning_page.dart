/// Voca 语刻 - Learning Page (刻印室)
/// Immersive card-based vocabulary learning interface

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme.dart';
import '../providers/learning_provider.dart';
import 'summary_page.dart';

class LearningPage extends ConsumerStatefulWidget {
  final String level;
  const LearningPage({super.key, this.level = 'GRE'});

  @override
  ConsumerState<LearningPage> createState() => _LearningPageState();
}

class _LearningPageState extends ConsumerState<LearningPage> {
  @override
  void initState() {
    super.initState();
    // Start session on page load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(learningProvider.notifier).startSession(level: widget.level);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(learningProvider);
    
    return Scaffold(
      backgroundColor: VocaTheme.background,
      appBar: AppBar(
        title: const Text('刻印室'),
        backgroundColor: VocaTheme.background,
        actions: [
          // Skip button for testing
          if (state.session != null && state.status == SessionStatus.active)
            IconButton(
              onPressed: () => ref.read(learningProvider.notifier).skipToSummary(),
              icon: const Icon(Icons.skip_next, color: VocaTheme.textMuted),
              tooltip: '跳过 (测试用)',
            ),
          if (state.session != null)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Text(
                  '${state.session!.totalMastered}/${state.session!.totalWords}',
                  style: const TextStyle(
                    color: VocaTheme.cyan,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(LearningState state) {
    switch (state.status) {
      case SessionStatus.initial:
      case SessionStatus.loading:
        return _buildLoading();
      case SessionStatus.active:
      case SessionStatus.answering:
        return _buildLearningCard(state);
      case SessionStatus.generating:
      case SessionStatus.complete:
        // Navigate to summary (generating shows loading animation there)
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const SummaryPage()),
          );
        });
        return _buildLoading();
      case SessionStatus.error:
        return _buildError(state.errorMessage ?? 'Unknown error');
    }
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: VocaTheme.cyan),
          const SizedBox(height: 24),
          Text(
            '准备刻印...',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: VocaTheme.error, size: 64),
            const SizedBox(height: 24),
            Text(
              message,
              style: const TextStyle(color: VocaTheme.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => ref.read(learningProvider.notifier).startSession(),
              child: const Text('重试'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLearningCard(LearningState state) {
    final currentWord = state.session?.currentWord;
    if (currentWord == null) return const SizedBox();
    
    final word = currentWord.word;
    final masteryCount = currentWord.masteryCount;
    final isAnswering = state.status == SessionStatus.answering;
    
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Progress indicator (mastery level)
            _buildMasteryProgress(masteryCount),
            const SizedBox(height: 32),
            
            // Word Card
            Expanded(
              flex: 2,
              child: _buildWordCard(word, isAnswering, state.lastAnswerCorrect),
            ),
            
            const SizedBox(height: 24),
            
            // Answer Options
            Expanded(
              flex: 3,
              child: _buildAnswerOptions(
                word.options,
                word.definition,
                isAnswering,
                state.lastAnswerCorrect,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMasteryProgress(int masteryCount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        final isActive = index < masteryCount;
        final color = isActive 
            ? VocaTheme.masteryColors[index.clamp(0, 2)]
            : VocaTheme.surfaceLight;
        
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          width: 60,
          height: 6,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
            boxShadow: isActive ? [
              BoxShadow(
                color: color.withValues(alpha: 0.5),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ] : null,
          ),
        ).animate(
          target: isActive ? 1 : 0,
        ).scaleX(begin: 0.8, end: 1, curve: Curves.easeOut);
      }),
    );
  }

  Widget _buildWordCard(dynamic word, bool isAnswering, bool? lastCorrect) {
    Color borderColor = VocaTheme.surfaceLight;
    if (isAnswering) {
      borderColor = lastCorrect == true ? VocaTheme.success : VocaTheme.error;
    }
    
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: VocaTheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: borderColor,
          width: isAnswering ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: VocaTheme.cyan.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Word text
              Text(
                word.text,
                style: Theme.of(context).textTheme.displayLarge,
              ).animate().fadeIn().slideY(begin: -0.2),
              
              const SizedBox(height: 12),
              
              // Phonetics Row (US / UK)
              if (word.phoneticUs != null || word.phoneticUk != null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (word.phoneticUk != null)
                      _buildPhoneticChip('🇬🇧', word.phoneticUk!),
                    if (word.phoneticUk != null && word.phoneticUs != null)
                      const SizedBox(width: 16),
                    if (word.phoneticUs != null)
                      _buildPhoneticChip('🇺🇸', word.phoneticUs!),
                  ],
                ).animate().fadeIn(delay: 100.ms)
              else if (word.phonetic != null)
                Text(
                  '/${word.phonetic}/',
                  style: Theme.of(context).textTheme.displayMedium,
                ).animate().fadeIn(delay: 100.ms),
              
              // Detailed Definitions (Only shown when answering/feedback)
              if (isAnswering && word.definitions != null && (word.definitions as List).isNotEmpty) ...[
                const SizedBox(height: 24),
                const Divider(color: VocaTheme.surfaceLight),
                const SizedBox(height: 16),
                ...word.definitions!.map<Widget>((def) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: VocaTheme.cyan.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          def.pos,
                          style: const TextStyle(
                            color: VocaTheme.cyan,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          def.meaning,
                          style: const TextStyle(
                            color: VocaTheme.textPrimary,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                )).toList(),
              ],

              // Simple Feedback if no detailed defs
              if (isAnswering && (word.definitions == null || (word.definitions as List).isEmpty)) ...[
                 const SizedBox(height: 24),
                 Text(
                  lastCorrect == true ? '✓ 正确！' : '✗ 记住了：${word.definition}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: lastCorrect == true ? VocaTheme.success : VocaTheme.error,
                    fontSize: 16,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneticChip(String flag, String ipa) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: VocaTheme.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: VocaTheme.surfaceLight),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(flag, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          Text(
            '/$ipa/', 
            style: const TextStyle(
              fontFamily: 'Arial',
              color: VocaTheme.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
    ).animate(
      target: isAnswering ? 1 : 0,
    ).shake(
      duration: 300.ms,
      hz: lastCorrect == true ? 0 : 3,
    );
  }

  Widget _buildAnswerOptions(
    List<String> options,
    String correctAnswer,
    bool isAnswering,
    bool? lastCorrect,
  ) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: options.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final option = options[index];
        final isCorrect = option == correctAnswer;
        
        Color? bgColor;
        Color? borderColor;
        
        if (isAnswering) {
          if (isCorrect) {
            bgColor = VocaTheme.success.withValues(alpha: 0.2);
            borderColor = VocaTheme.success;
          } else if (!lastCorrect! && index == options.indexOf(option)) {
            bgColor = VocaTheme.error.withValues(alpha: 0.1);
            borderColor = VocaTheme.error;
          }
        }
        
        return InkWell(
          onTap: isAnswering 
              ? null 
              : () => ref.read(learningProvider.notifier).submitAnswer(option),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: BoxDecoration(
              color: bgColor ?? VocaTheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: borderColor ?? VocaTheme.surfaceLight,
                width: 1.5,
              ),
            ),
            child: Text(
              option,
              style: TextStyle(
                color: VocaTheme.textPrimary,
                fontSize: 15,
                fontWeight: isAnswering && isCorrect 
                    ? FontWeight.w600 
                    : FontWeight.w400,
              ),
            ),
          ),
        ).animate(delay: (index * 50).ms).fadeIn().slideX(begin: 0.1);
      },
    );
  }
}
