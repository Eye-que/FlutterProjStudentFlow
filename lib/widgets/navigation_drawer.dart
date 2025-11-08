import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_provider.dart';
import '../screens/auth/login_screen.dart';
import '../screens/tasks/add_edit_task_screen.dart';
import '../screens/tasks/task_list_screen.dart';
import '../screens/account/account_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/calendar/calendar_screen.dart';
import '../screens/notifications/notifications_screen.dart';

/// Navigation Drawer with Premium UI Design
/// Modern gradient header, rounded menu cards, and smooth animations
class AppNavigationDrawer extends StatelessWidget {
  const AppNavigationDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final user = authProvider.user;
        final userData = authProvider.userData;
        String fullName =
            authProvider.userFullName ?? (user?.email?.split('@')[0] ?? 'User');
        final email = user?.email ?? 'No email';

        return _buildDrawerContent(
          context,
          authProvider,
          fullName,
          email,
          userData,
        );
      },
    );
  }

  Widget _buildDrawerContent(
    BuildContext context,
    AuthProvider authProvider,
    String fullName,
    String email,
    Map<String, dynamic>? userData,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.85,
      child: Container(
        decoration: BoxDecoration(color: colorScheme.surface),
        child: Column(
          children: [
            // Premium Gradient Header with Curved Bottom
            Expanded(
              flex: 0,
              child: ClipPath(
                clipper: _CurvedHeaderClipper(),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(
                    top: 60,
                    bottom: 40,
                    left: 20,
                    right: 20,
                  ),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF3B82F6), Color(0xFF06B6D4)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    children: [
                      // Profile Image with Shadow
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Consumer<AuthProvider>(
                          builder: (context, authProvider, _) {
                            final currentUserData = authProvider.userData;
                            final profilePicturePathOrUrl = currentUserData?['profilePicture'] as String?;
                            
                            return _buildDrawerProfileImage(profilePicturePathOrUrl);
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        fullName,
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Menu Items in Rounded Container
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _buildMenuItem(
                      context,
                      icon: Icons.home,
                      title: 'Home',
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.task,
                      title: 'All Tasks',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const TaskListScreen(),
                          ),
                        );
                      },
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.add_task,
                      title: 'Add Task',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AddEditTaskScreen(),
                          ),
                        );
                      },
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.calendar_today,
                      title: 'Calendar View',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CalendarScreen(),
                          ),
                        );
                      },
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.person,
                      title: 'Account',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AccountScreen(),
                          ),
                        );
                      },
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.settings,
                      title: 'Settings',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SettingsScreen(),
                          ),
                        );
                      },
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.notifications,
                      title: 'Notifications',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const NotificationsScreen(),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 32),
                    _buildMenuItem(
                      context,
                      icon: Icons.logout,
                      title: 'Logout',
                      isLogout: true,
                      onTap: () {
                        Navigator.pop(context);
                        _handleLogout(context);
                      },
                    ),
                    const SizedBox(height: 40),
                    // Footer
                    Center(
                      child: Column(
                        children: [
                          Text(
                            '© 2025 StudyFlow App',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'v1.0.0',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build profile image widget for drawer - supports both local files and network URLs
  Widget _buildDrawerProfileImage(String? imagePathOrUrl) {
    // If empty, show default icon
    if (imagePathOrUrl == null || imagePathOrUrl.isEmpty) {
      return CircleAvatar(
        radius: 50,
        backgroundColor: Colors.white,
        child: const Icon(
          Icons.person,
          size: 50,
          color: Color(0xFF3B82F6),
        ),
      );
    }

    // Check if it's a local file path (starts with /) or network URL (starts with http)
    final isLocalFile = imagePathOrUrl.startsWith('/') ||
        imagePathOrUrl.startsWith('file://') ||
        (!imagePathOrUrl.startsWith('http://') &&
            !imagePathOrUrl.startsWith('https://'));

    if (isLocalFile) {
      // Load from local file
      final file = File(imagePathOrUrl);
      return CircleAvatar(
        radius: 50,
        backgroundColor: Colors.white,
        backgroundImage: FileImage(file),
        onBackgroundImageError: (exception, stackTrace) {
          debugPrint('❌ Error loading local profile picture in drawer: $exception');
          debugPrint('❌ Path that failed: $imagePathOrUrl');
        },
        child: const Icon(
          Icons.person,
          size: 50,
          color: Color(0xFF3B82F6),
        ),
      );
    } else {
      // Load from network URL (for backwards compatibility with Firebase Storage URLs)
      return CircleAvatar(
        radius: 50,
        backgroundColor: Colors.white,
        backgroundImage: NetworkImage(imagePathOrUrl),
        onBackgroundImageError: (exception, stackTrace) {
          debugPrint('❌ Error loading network profile picture in drawer: $exception');
          debugPrint('❌ URL that failed: $imagePathOrUrl');
        },
        child: const Icon(
          Icons.person,
          size: 50,
          color: Color(0xFF3B82F6),
        ),
      );
    }
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (isLogout ? Colors.red : const Color(0xFF3B82F6))
                    .withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isLogout ? Colors.red : const Color(0xFF3B82F6),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isLogout 
                      ? Colors.red 
                      : colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleLogout(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: colorScheme.surface,
          title: Row(
            children: [
              const Icon(Icons.logout, color: Colors.red),
              const SizedBox(width: 8),
              Text(
                'Logout',
                style: TextStyle(color: colorScheme.onSurface),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to logout?',
            style: TextStyle(color: colorScheme.onSurface),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'Cancel',
                style: TextStyle(color: colorScheme.onSurface),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  dialogContext,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              child: const Text('Logout', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}

/// Custom Clipper for Curved Drawer Header
class _CurvedHeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 30);
    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height - 30,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
