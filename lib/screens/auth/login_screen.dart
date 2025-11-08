import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import 'register_screen.dart';
import '../welcome/welcome_back_screen.dart';
import '../home/home_screen.dart';

/// Login Screen
/// Handles user authentication with email and password
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final success = await authProvider.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (success && mounted) {
        // Give a small delay to ensure user data is fully loaded
        // The AuthProvider already loads data, but we wait a bit for UI updates
        await Future.delayed(const Duration(milliseconds: 100));

        // Show welcome back screen (it will display the user's name from AuthProvider)
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const WelcomeBackScreen()),
        );
      } else if (mounted) {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.warning,
          animType: AnimType.bottomSlide,
          title: 'Login Failed',
          desc: authProvider.errorMessage ?? 'Invalid email or password.',
          btnOkOnPress: () {},
        ).show();
      }
    }
  }

  Future<void> _handleForgotPassword() async {
    if (_emailController.text.trim().isEmpty) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.warning,
        animType: AnimType.bottomSlide,
        title: 'Email Required',
        desc: 'Please enter your email address first.',
        btnOkOnPress: () {},
      ).show();
      return;
    }

    final email = _emailController.text.trim();
    if (!email.contains('@')) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.warning,
        animType: AnimType.bottomSlide,
        title: 'Invalid Email',
        desc: 'Please enter a valid email address.',
        btnOkOnPress: () {},
      ).show();
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.forgotPassword(email);

    if (success && mounted) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        animType: AnimType.bottomSlide,
        title: 'Reset Email Sent',
        desc: 'Please check your email for password reset instructions.',
        btnOkOnPress: () {},
      ).show();
    } else if (mounted) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.bottomSlide,
        title: 'Error',
        desc: authProvider.errorMessage ?? 'Failed to send reset email.',
        btnOkOnPress: () {},
      ).show();
    }
  }

  Future<void> _handleGoogleSignIn() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.continueWithGoogle();

    if (success && mounted) {
      // Give a small delay to ensure user data is fully loaded
      await Future.delayed(const Duration(milliseconds: 100));

      // Navigate directly to HomeScreen (not WelcomeBackScreen)
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
    } else if (mounted) {
      // Only show error if user didn't cancel
      if (authProvider.errorMessage != null &&
          !authProvider.errorMessage!.toLowerCase().contains('cancel')) {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.warning,
          animType: AnimType.bottomSlide,
          title: 'Google Sign-In Failed',
          desc: authProvider.errorMessage ?? 'Failed to sign in with Google.',
          btnOkOnPress: () {},
        ).show();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    const Color(0xFF3B82F6).withOpacity(0.2),
                    const Color(0xFF10B981).withOpacity(0.1),
                    colorScheme.surface,
                  ]
                : [
                    const Color(0xFF3B82F6).withOpacity(0.1),
                    const Color(0xFF10B981).withOpacity(0.1),
                    const Color(0xFFF9FAFB),
                  ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 40),
                    // Logo
                    Center(
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF3B82F6).withOpacity(0.3),
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
                    const SizedBox(height: 32),
                    // Modern Card with Blur
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: isDark
                                ? colorScheme.surface.withOpacity(0.9)
                                : Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: isDark
                                  ? colorScheme.outline.withOpacity(0.2)
                                  : Colors.white.withOpacity(0.2),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'StudyFlow',
                                style: GoogleFonts.poppins(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF3B82F6),
                                  letterSpacing: 0.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Stay organized. Study smarter.',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w300,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 32),
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                style: TextStyle(color: colorScheme.onSurface),
                                decoration: InputDecoration(
                                  labelText: 'Email',
                                  labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                                  prefixIcon: Icon(Icons.email_outlined, color: colorScheme.onSurfaceVariant),
                                  filled: true,
                                  fillColor: isDark
                                      ? colorScheme.surfaceContainerHighest
                                      : Colors.grey[50],
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 16,
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your email';
                                  }
                                  if (!value.contains('@')) {
                                    return 'Please enter a valid email';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                style: TextStyle(color: colorScheme.onSurface),
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                                  prefixIcon: Icon(Icons.lock_outline, color: colorScheme.onSurfaceVariant),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                    ),
                                    color: colorScheme.onSurfaceVariant,
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                  filled: true,
                                  fillColor: isDark
                                      ? colorScheme.surfaceContainerHighest
                                      : Colors.grey[50],
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 16,
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your password';
                                  }
                                  if (value.length < 6) {
                                    return 'Password must be at least 6 characters';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: _handleForgotPassword,
                                  child: Text(
                                    'Forgot Password?',
                                    style: GoogleFonts.poppins(
                                      color: colorScheme.primary,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              Consumer<AuthProvider>(
                                builder: (context, authProvider, _) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          const Color(0xFF3B82F6),
                                          const Color(0xFF10B981),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(
                                            0xFF3B82F6,
                                          ).withOpacity(0.4),
                                          blurRadius: 12,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    child: ElevatedButton(
                                      onPressed: authProvider.isLoading
                                          ? null
                                          : _handleLogin,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        shadowColor: Colors.transparent,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 18,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                      ),
                                      child: authProvider.isLoading
                                          ? const SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                      Color
                                                    >(Colors.white),
                                              ),
                                            )
                                          : Text(
                                              'Login',
                                              style: GoogleFonts.poppins(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                              ),
                                            ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 24),
                              // Divider with "OR"
                              Row(
                                children: [
                                  Expanded(
                                    child: Divider(
                                      color: colorScheme.outline.withOpacity(0.3),
                                      thickness: 1,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    child: Text(
                                      'OR',
                                      style: GoogleFonts.poppins(
                                        color: colorScheme.onSurfaceVariant,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Divider(
                                      color: colorScheme.outline.withOpacity(0.3),
                                      thickness: 1,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              // Google Sign-In Button
                              Consumer<AuthProvider>(
                                builder: (context, authProvider, _) {
                                  return OutlinedButton.icon(
                                    onPressed: authProvider.isLoading
                                        ? null
                                        : _handleGoogleSignIn,
                                    icon: Container(
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Icon(
                                        Icons.g_mobiledata,
                                        size: 24,
                                        color: Color(0xFF4285F4),
                                      ),
                                    ),
                                    label: Text(
                                      'Continue with Google',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: colorScheme.onSurface,
                                      ),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 18,
                                      ),
                                      side: BorderSide(
                                        color: colorScheme.outline.withOpacity(0.3),
                                        width: 1.5,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      backgroundColor: isDark
                                          ? colorScheme.surfaceContainerHighest
                                          : Colors.white,
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 24),
                              Wrap(
                                alignment: WrapAlignment.center,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 4,
                                children: [
                                  Text(
                                    "Don't have an account?",
                                    style: GoogleFonts.poppins(
                                      color: colorScheme.onSurfaceVariant,
                                      fontSize: 14,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        PageRouteBuilder(
                                          pageBuilder:
                                              (
                                                context,
                                                animation,
                                                secondaryAnimation,
                                              ) => const RegisterScreen(),
                                          transitionsBuilder:
                                              (
                                                context,
                                                animation,
                                                secondaryAnimation,
                                                child,
                                              ) {
                                                return FadeTransition(
                                                  opacity: animation,
                                                  child: child,
                                                );
                                              },
                                        ),
                                      );
                                    },
                                    child: Text(
                                      'Create Account',
                                      style: GoogleFonts.poppins(
                                        color: colorScheme.primary,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
