import 'package:flutter/material.dart';
import 'dart:async';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _glowController;
  late AnimationController _textController;
  late Animation<double> _glowAnim;
  late Animation<double> _textAnim;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat(reverse: true);
    _textController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _glowAnim = Tween<double>(begin: 0.3, end: 1.0).animate(CurvedAnimation(parent: _glowController, curve: Curves.easeInOut));
    _textAnim = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _textController, curve: Curves.easeOut));
    Future.delayed(const Duration(milliseconds: 300), () => _textController.forward());
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.pushReplacement(context, PageRouteBuilder(
          pageBuilder: (_, __, ___) => const HomeScreen(),
          transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 800),
        ));
      }
    });
  }

  @override
  void dispose() {
    _glowController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020A02),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _glowAnim,
              builder: (context, child) => Icon(Icons.emoji_events, size: 90, color: Color.fromRGBO(0, 230, 118, _glowAnim.value)),
            ),
            const SizedBox(height: 24),
            FadeTransition(
              opacity: _textAnim,
              child: const Text('KINGS', style: TextStyle(fontSize: 60, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 12)),
            ),
            const SizedBox(height: 8),
            Container(width: 200, height: 2, color: const Color(0xFF00E676)),
            const SizedBox(height: 8),
            FadeTransition(
              opacity: _textAnim,
              child: const Text('N I G E R I A  R P', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF00E676), letterSpacing: 5)),
            ),
            const SizedBox(height: 8),
            FadeTransition(
              opacity: _textAnim,
              child: const Text("Nigeria's #1 Roleplay Server", style: TextStyle(fontSize: 13, color: Colors.white38)),
            ),
          ],
        ),
      ),
    );
  }
}
