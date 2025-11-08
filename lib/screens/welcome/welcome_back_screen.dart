import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../home/home_screen.dart';

/// Welcome Back Screen
/// Shows welcome message and navigates to main screen
class WelcomeBackScreen extends StatefulWidget {
  const WelcomeBackScreen({super.key});

  @override
  State<WelcomeBackScreen> createState() => _WelcomeBackScreenState();
}

class _WelcomeBackScreenState extends State<WelcomeBackScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  Future<void> _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 2)); // Show for 2-3 seconds

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final fullName = authProvider.userFullName ?? 'User';
    // Get first name for greeting
    final firstName = fullName.split(' ').first;
    
    debugPrint('📱 WelcomeBackScreen - Full name from provider: $fullName');
    debugPrint('📱 WelcomeBackScreen - First name: $firstName');
    debugPrint('📱 WelcomeBackScreen - User data: ${authProvider.userData}');

    return Scaffold(
      body: Stack(
        children: [
          // Animated Wave Background
          AnimatedBackground(),
          // Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated Notebook Icon
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 1200),
                  curve: Curves.elasticOut,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Transform.rotate(
                        angle: (1 - value) * 0.3,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Icon(
                                Icons.menu_book_rounded,
                                size: 50,
                                color: const Color(0xFF3B82F6),
                              ),
                              Positioned(
                                right: 18,
                                top: 12,
                                child: Transform.rotate(
                                  angle: -0.3,
                                  child: Icon(
                                    Icons.flash_on,
                                    size: 22,
                                    color: const Color(0xFF10B981),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 40),
                // Welcome Text with Animation
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.easeOut,
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, 20 * (1 - value)),
                        child: Column(
                          children: [
                            Text(
                              'Welcome back,',
                              style: GoogleFonts.poppins(
                                fontSize: 24,
                                color: Colors.white.withOpacity(0.9),
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '$firstName 👋',
                              style: GoogleFonts.poppins(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 60),
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 3,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Animated Wave Background
class AnimatedBackground extends StatefulWidget {
  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF3B82F6), // Deep Blue
                const Color(0xFF10B981), // Mint Green
              ],
            ),
          ),
          child: CustomPaint(
            painter: WavePainter(_controller.value),
            child: Container(),
          ),
        );
      },
    );
  }
}

/// Wave Painter for animated background
class WavePainter extends CustomPainter {
  final double animationValue;

  WavePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final path = Path();
    final waveHeight = 50.0;
    final waveLength = size.width / 2;

    path.moveTo(0, size.height * 0.7);

    for (double x = 0; x < size.width; x++) {
      final y = waveHeight *
          math.sin((x / waveLength + animationValue * 2 * math.pi) * 2 * math.pi);
      path.lineTo(x, size.height * 0.7 + y);
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(WavePainter oldDelegate) => true;
}

