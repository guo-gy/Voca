/// Voca 语刻 (Voca Engrave)
/// AI-powered vocabulary learning with "3次刻印" mastery system
/// 
/// 背单词不是浮光掠影，而是通过3次精准反馈将记忆刻入脑海

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme.dart';
import 'pages/learning_page.dart';

void main() {
  runApp(const ProviderScope(child: VocaApp()));
}

class VocaApp extends StatelessWidget {
  const VocaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Voca 语刻',
      debugShowCheckedModeBanner: false,
      theme: VocaTheme.darkTheme,
      home: const HomePage(),
    );
  }
}

/// Home Page - Entry point with branding
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VocaTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              const Spacer(flex: 2),
              
              // Logo / Brand
              _buildBranding(context),
              
              const Spacer(flex: 1),
              
              // Tagline
              Text(
                '背单词不是浮光掠影',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: VocaTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '而是通过 3 次精准反馈',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: VocaTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [VocaTheme.cyan, VocaTheme.cyanGlow],
                ).createShader(bounds),
                child: Text(
                  '将记忆刻入脑海',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              
              const Spacer(flex: 2),
              
              // Start Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const LearningPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.play_arrow_rounded, size: 24),
                      SizedBox(width: 8),
                      Text('开始刻印', style: TextStyle(fontSize: 18)),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Secondary action
              TextButton(
                onPressed: () {
                  // TODO: Level selection
                },
                child: const Text(
                  '选择词库: GRE / 考研',
                  style: TextStyle(color: VocaTheme.textMuted),
                ),
              ),
              
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBranding(BuildContext context) {
    return Column(
      children: [
        // Icon
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: VocaTheme.surface,
            shape: BoxShape.circle,
            border: Border.all(
              color: VocaTheme.cyan.withValues(alpha: 0.5),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: VocaTheme.cyan.withValues(alpha: 0.3),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: const Center(
            child: Text(
              '刻',
              style: TextStyle(
                color: VocaTheme.cyan,
                fontSize: 48,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Title
        Text(
          'Voca 语刻',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
            fontSize: 36,
            letterSpacing: 2,
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Subtitle
        Text(
          'ENGRAVE YOUR VOCABULARY',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: VocaTheme.textMuted,
            letterSpacing: 3,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
