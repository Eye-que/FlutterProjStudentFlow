import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../welcome/welcome_back_screen.dart';

/// Register Screen
/// Handles new user registration with email and password
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_agreeToTerms) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.warning,
        animType: AnimType.bottomSlide,
        title: 'Terms Required',
        desc: 'Please agree to the Terms and Privacy Policy to continue.',
        btnOkOnPress: () {},
      ).show();
      return;
    }

    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final fullName = _fullNameController.text.trim();
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      final success = await authProvider.register(
        fullName: fullName,
        email: email,
        password: password,
      );

      if (success && mounted) {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.success,
          animType: AnimType.bottomSlide,
          title: 'Welcome!',
          desc:
              'Welcome, $fullName! Your account has been created successfully.',
          btnOkOnPress: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const WelcomeBackScreen()),
            );
          },
        ).show();
      } else if (mounted) {
        final errorMessage = authProvider.errorMessage ?? 'Registration failed';
        final lowerMessage = errorMessage.toLowerCase();

        if (lowerMessage.contains('already exists') ||
            lowerMessage.contains('email-already-in-use') ||
            lowerMessage.contains('already registered')) {
          AwesomeDialog(
            context: context,
            dialogType: DialogType.error,
            animType: AnimType.bottomSlide,
            title: 'Account Already Exists',
            desc:
                'This email is already registered. Please try logging in instead.',
            btnOkOnPress: () {
              // Navigate to login screen
              Navigator.of(context).pop();
            },
          ).show();
        } else if (lowerMessage.contains('pigeonuserdetails') ||
            lowerMessage.contains('type cast') ||
            (lowerMessage.contains('registration failed') &&
                lowerMessage.contains('may already be registered'))) {
          // Handle type casting error - account might have been created
          AwesomeDialog(
            context: context,
            dialogType: DialogType.warning,
            animType: AnimType.bottomSlide,
            title: 'Registration Issue',
            desc:
                'There was an issue completing registration. Your account may have been created. Please try logging in with your email and password.',
            btnOkOnPress: () {
              // Navigate to login screen
              Navigator.of(context).pop();
            },
          ).show();
        } else {
          AwesomeDialog(
            context: context,
            dialogType: DialogType.error,
            animType: AnimType.bottomSlide,
            title: 'Registration Failed',
            desc: errorMessage,
            btnOkOnPress: () {},
          ).show();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Register',
          style: TextStyle(color: colorScheme.onSurface),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
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
                    const SizedBox(height: 20),
                    // Logo
                    Center(
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: isDark ? colorScheme.surface : Colors.white,
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
                          padding: const EdgeInsets.all(24),
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
                                'Create Account',
                                style: GoogleFonts.poppins(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF3B82F6),
                                  letterSpacing: 0.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Start organizing your tasks',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w300,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),
                              TextFormField(
                                controller: _fullNameController,
                                keyboardType: TextInputType.name,
                                textCapitalization: TextCapitalization.words,
                                style: TextStyle(color: colorScheme.onSurface),
                                decoration: InputDecoration(
                                  labelText: 'Full Name',
                                  labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                                  prefixIcon: Icon(Icons.person_outline, color: colorScheme.onSurfaceVariant),
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
                                    vertical: 14,
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your full name';
                                  }
                                  if (value.trim().length < 3) {
                                    return 'Name must be at least 3 characters';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
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
                                    vertical: 14,
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your email';
                                  }
                                  final emailRegex = RegExp(
                                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                  );
                                  if (!emailRegex.hasMatch(value)) {
                                    return 'Please enter a valid email';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
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
                                    vertical: 14,
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a password';
                                  }
                                  if (value.length < 6) {
                                    return 'Password must be at least 6 characters';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _confirmPasswordController,
                                obscureText: _obscureConfirmPassword,
                                style: TextStyle(color: colorScheme.onSurface),
                                decoration: InputDecoration(
                                  labelText: 'Confirm Password',
                                  labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                                  prefixIcon: Icon(Icons.lock_outline, color: colorScheme.onSurfaceVariant),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscureConfirmPassword
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                    ),
                                    color: colorScheme.onSurfaceVariant,
                                    onPressed: () {
                                      setState(() {
                                        _obscureConfirmPassword =
                                            !_obscureConfirmPassword;
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
                                    vertical: 14,
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please confirm your password';
                                  }
                                  if (value != _passwordController.text) {
                                    return 'Passwords do not match';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              // Terms Checkbox
                              Row(
                                children: [
                                  Checkbox(
                                    value: _agreeToTerms,
                                    onChanged: (value) {
                                      setState(() {
                                        _agreeToTerms = value ?? false;
                                      });
                                    },
                                    activeColor: colorScheme.primary,
                                  ),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _agreeToTerms = !_agreeToTerms;
                                        });
                                      },
                                      child: Text(
                                        'I agree to the Terms and Privacy Policy',
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
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
                                          : _handleRegister,
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
                                              'Create Account',
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
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Already have an account? ',
                                    style: GoogleFonts.poppins(
                                      color: colorScheme.onSurfaceVariant,
                                      fontSize: 14,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text(
                                      'Login',
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
                    const SizedBox(height: 20),
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
