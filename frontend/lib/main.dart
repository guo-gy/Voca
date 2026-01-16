// Voca 语刻 (Voca Engrave)
// AI-powered vocabulary learning with "3次刻印" mastery system
// 
// 背单词不是浮光掠影，而是通过3次精准反馈将记忆刻入脑海

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
      home: const SplashScreen(),
    );
  }
}

/// Splash Screen with animated logo
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to home after animation
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const HomePage(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VocaTheme.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated Logo
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: VocaTheme.surface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: VocaTheme.cyan.withValues(alpha: 0.5),
                  width: 3,
                ),
              ),
              child: const Center(
                child: Text(
                  '刻',
                  style: TextStyle(
                    color: VocaTheme.cyan,
                    fontSize: 56,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            )
            .animate()
            .scale(
              begin: const Offset(0, 0),
              end: const Offset(1, 1),
              duration: 600.ms,
              curve: Curves.elasticOut,
            )
            .then()
            .shimmer(
              duration: 1200.ms,
              color: VocaTheme.cyan.withValues(alpha: 0.4),
            ),
            
            const SizedBox(height: 40),
            
            // App Name
            Text(
              'Voca 语刻',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontSize: 32,
                letterSpacing: 4,
              ),
            )
            .animate()
            .fadeIn(delay: 400.ms, duration: 500.ms)
            .slideY(begin: 0.3, end: 0),
            
            const SizedBox(height: 12),
            
            // Subtitle
            Text(
              'ENGRAVE YOUR VOCABULARY',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: VocaTheme.textMuted,
                letterSpacing: 3,
                fontSize: 11,
              ),
            )
            .animate()
            .fadeIn(delay: 700.ms, duration: 500.ms),
            
            const SizedBox(height: 60),
            
            // Loading indicator
            SizedBox(
              width: 150,
              child: LinearProgressIndicator(
                color: VocaTheme.cyan,
                backgroundColor: VocaTheme.surfaceLight,
                minHeight: 3,
              ),
            )
            .animate()
            .fadeIn(delay: 1000.ms)
            .then()
            .shimmer(duration: 1500.ms),
          ],
        ),
      ),
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
              ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2),
              const SizedBox(height: 8),
              Text(
                '而是通过 3 次精准反馈',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: VocaTheme.textSecondary,
                ),
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
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
              ).animate().fadeIn(delay: 300.ms).scale(begin: const Offset(0.9, 0.9)),
              
              const Spacer(flex: 2),
              
              // Start Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) => const LearningPage(),
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                          return SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(1, 0),
                              end: Offset.zero,
                            ).animate(CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeOutCubic,
                            )),
                            child: child,
                          );
                        },
                        transitionDuration: const Duration(milliseconds: 300),
                      ),
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
              ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.3),
              
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
              ).animate().fadeIn(delay: 600.ms),
              
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
        ).animate().scale(begin: const Offset(0.8, 0.8), curve: Curves.easeOut),
        
        const SizedBox(height: 24),
        
        // Title
        Text(
          'Voca 语刻',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
            fontSize: 36,
            letterSpacing: 2,
          ),
        ).animate().fadeIn(delay: 200.ms),
        
        const SizedBox(height: 8),
        
        // Subtitle
        Text(
          'ENGRAVE YOUR VOCABULARY',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: VocaTheme.textMuted,
            letterSpacing: 3,
            fontSize: 12,
          ),
        ).animate().fadeIn(delay: 300.ms),
      ],
    );
  }
}
