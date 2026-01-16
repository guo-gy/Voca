/// Voca 语刻 - Summary Page (语境室)
/// Display AI-generated story with highlighted keywords

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../core/theme.dart';
import '../providers/learning_provider.dart';
import 'learning_page.dart';

class SummaryPage extends ConsumerWidget {
  const SummaryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(learningProvider);
    final story = state.story;
    final session = state.session;
    
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Completion Header
              _buildCompletionHeader(context, session),
              const SizedBox(height: 32),
              
              // AI Story Content
              Expanded(
                child: _buildStoryContent(context, story, state.errorMessage),
              ),
              
              const SizedBox(height: 24),
              
              // Action Buttons
              _buildActionButtons(context, ref),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompletionHeader(BuildContext context, dynamic session) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: VocaTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: VocaTheme.cyan.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Trophy Icon
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: VocaTheme.cyan.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.emoji_events,
              color: VocaTheme.cyan,
              size: 28,
            ),
          ).animate().scale(
            begin: const Offset(0, 0),
            curve: Curves.elasticOut,
            duration: 600.ms,
          ),
          
          const SizedBox(width: 20),
          
          // Stats
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🎉 刻印完成！',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: VocaTheme.cyan,
                  ),
                ).animate().fadeIn().slideX(begin: -0.2),
                const SizedBox(height: 4),
                Text(
                  '已掌握 ${session?.totalWords ?? 10} 个单词',
                  style: Theme.of(context).textTheme.bodyMedium,
                ).animate().fadeIn(delay: 100.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoryContent(BuildContext context, dynamic story, String? error) {
    if (story == null) {
      if (error != null) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.warning_amber, color: VocaTheme.warning, size: 48),
              const SizedBox(height: 16),
              Text(
                '故事生成失败',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 8),
              Text(
                error,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }
      
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: VocaTheme.cyan),
            SizedBox(height: 16),
            Text('AI 正在编织语境...'),
          ],
        ),
      );
    }
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: VocaTheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Theme tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: VocaTheme.cyan.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '# ${story.theme}',
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ).animate().fadeIn().slideY(begin: -0.5),
          
          const SizedBox(height: 16),
          
          // Story content with markdown
          Expanded(
            child: Markdown(
              data: story.content,
              shrinkWrap: true,
              styleSheet: MarkdownStyleSheet(
                p: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  height: 1.8,
                ),
                strong: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: VocaTheme.cyan,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ).animate().fadeIn(delay: 200.ms),
          ),
          
          const Divider(height: 32),
          
          // Keywords list
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: (story.keywords as List<String>).map((keyword) {
              return Chip(
                label: Text(keyword),
                backgroundColor: VocaTheme.surfaceLight,
                labelStyle: const TextStyle(
                  color: VocaTheme.cyan,
                  fontSize: 13,
                ),
                side: BorderSide.none,
              ).animate().fadeIn().scale(begin: const Offset(0.8, 0.8));
            }).toList(),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1);
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        // Back to Home
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              ref.read(learningProvider.notifier).reset();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LearningPage()),
              );
            },
            icon: const Icon(Icons.replay),
            label: const Text('继续刻印'),
            style: OutlinedButton.styleFrom(
              foregroundColor: VocaTheme.cyan,
              side: const BorderSide(color: VocaTheme.cyan),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2);
  }
}
