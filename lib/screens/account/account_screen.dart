import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/task_provider.dart';
import 'edit_profile_screen.dart';
import 'change_password_screen.dart';

/// Account Screen
/// Displays user account details and management options
class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  /// Build profile image widget - supports both local files and network URLs
  Widget _buildProfileImage(String? imagePathOrUrl, String imageKey) {
    // If empty, show default icon
    if (imagePathOrUrl == null || imagePathOrUrl.isEmpty) {
      return Container(
        width: 120,
        height: 120,
        color: Colors.white,
        child: const Icon(Icons.person, size: 60, color: Color(0xFF3B82F6)),
      );
    }

    // Check if it's a local file path (starts with /) or network URL (starts with http)
    final isLocalFile =
        imagePathOrUrl.startsWith('/') ||
        imagePathOrUrl.startsWith('file://') ||
        (!imagePathOrUrl.startsWith('http://') &&
            !imagePathOrUrl.startsWith('https://'));

    if (isLocalFile) {
      // Load from local file
      final file = File(imagePathOrUrl);
      return Image.file(
        file,
        key: ValueKey(imageKey),
        fit: BoxFit.cover,
        width: 120,
        height: 120,
        errorBuilder: (context, error, stackTrace) {
          debugPrint('❌ Error loading local profile picture: $error');
          debugPrint('❌ Path that failed: $imagePathOrUrl');
          return Container(
            width: 120,
            height: 120,
            color: Colors.white,
            child: const Icon(Icons.person, size: 60, color: Color(0xFF3B82F6)),
          );
        },
      );
    } else {
      // Load from network URL (for backwards compatibility with Firebase Storage URLs)
      return Image.network(
        imagePathOrUrl,
        key: ValueKey(imageKey),
        fit: BoxFit.cover,
        width: 120,
        height: 120,
        cacheWidth: 240,
        cacheHeight: 240,
        errorBuilder: (context, error, stackTrace) {
          debugPrint('❌ Error loading network profile picture: $error');
          debugPrint('❌ URL that failed: $imagePathOrUrl');
          return Container(
            width: 120,
            height: 120,
            color: Colors.white,
            child: const Icon(Icons.person, size: 60, color: Color(0xFF3B82F6)),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }
          return Container(
            width: 120,
            height: 120,
            color: Colors.white,
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final taskProvider = Provider.of<TaskProvider>(context);
        final user = authProvider.user;
        final userData = authProvider.userData;
        // Use fullName from Firestore, fallback to email username, then 'User'
        final fullName = (authProvider.userFullName?.isNotEmpty ?? false)
            ? authProvider.userFullName!
            : (user?.email != null ? user!.email!.split('@').first : 'User');
        final email =
            userData?['email'] as String? ?? user?.email ?? 'No email';

        // Get task statistics
        final completedTasks = taskProvider.completedTasks;
        final pendingTasks = taskProvider.pendingTasks;

        // Get joined date from Firestore
        DateTime? joinedDate;
        if (userData?['createdAt'] != null) {
          final timestamp = userData!['createdAt'];
          if (timestamp is DateTime) {
            joinedDate = timestamp;
          } else {
            // Firestore Timestamp handling
            joinedDate = DateTime.now();
          }
        }

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 180, // Reduced height to show title better
                floating: false,
                pinned: true,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.only(left: 0, bottom: 16),
                  centerTitle: false,
                  title: Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Text(
                      '',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF3B82F6),
                          const Color(0xFF10B981),
                        ],
                      ),
                    ),
                    child: SafeArea(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 20),
                            // Profile Picture Widget - use userData from outer Consumer
                            // The outer Consumer will rebuild when notifyListeners() is called
                            Builder(
                              builder: (context) {
                                // Get userData from the outer Consumer (authProvider)
                                final currentUserData = userData;
                                final profilePictureUrl =
                                    currentUserData?['profilePicture']
                                        as String?;
                                final updatedAt = currentUserData?['updatedAt'];

                                debugPrint(
                                  '🔄 Profile Picture Widget Build - URL: $profilePictureUrl',
                                );
                                debugPrint('   UpdatedAt: $updatedAt');
                                debugPrint(
                                  '   Full userData: $currentUserData',
                                );

                                // Create a unique key based on URL and timestamp
                                final urlHash =
                                    profilePictureUrl?.hashCode ?? 0;
                                final timestampValue = updatedAt != null
                                    ? (updatedAt is DateTime
                                          ? updatedAt.millisecondsSinceEpoch
                                          : updatedAt.toString().hashCode)
                                    : DateTime.now().millisecondsSinceEpoch;

                                final imageKey =
                                    profilePictureUrl != null &&
                                        profilePictureUrl.isNotEmpty
                                    ? 'profile_${urlHash}_$timestampValue'
                                    : 'no_image_$timestampValue';

                                // Add cache-busting query parameter to URL if it exists
                                String? imageUrlWithCacheBust;
                                if (profilePictureUrl != null &&
                                    profilePictureUrl.isNotEmpty) {
                                  final uri = Uri.parse(profilePictureUrl);
                                  final separator = uri.queryParameters.isEmpty
                                      ? '?'
                                      : '&';
                                  imageUrlWithCacheBust =
                                      '$profilePictureUrl${separator}v=$timestampValue';
                                }

                                debugPrint(
                                  '🖼️ Account Screen Build - Profile Picture URL: $profilePictureUrl',
                                );
                                debugPrint(
                                  '🖼️ Account Screen Build - URL with cache bust: $imageUrlWithCacheBust',
                                );
                                debugPrint(
                                  '🖼️ Account Screen Build - URL is empty: ${profilePictureUrl == null || profilePictureUrl.isEmpty}',
                                );
                                debugPrint(
                                  '🖼️ Account Screen Build - Updated At: $updatedAt',
                                );
                                debugPrint(
                                  '🖼️ Account Screen Build - Image Key: $imageKey',
                                );
                                debugPrint(
                                  '🖼️ Account Screen Build - Full userData: $currentUserData',
                                );

                                return Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 4,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 10,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: ClipOval(
                                    child: _buildProfileImage(
                                      profilePictureUrl,
                                      imageKey,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // User Info
                    Center(
                      child: Column(
                        children: [
                          Text(
                            fullName,
                            style: GoogleFonts.poppins(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            email,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          if (joinedDate != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Joined ${DateFormat('MMM yyyy').format(joinedDate)}',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Task Statistics
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFF3B82F6).withOpacity(0.1),
                            const Color(0xFF10B981).withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF3B82F6).withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Task Statistics',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _StatItem(
                                label: 'Completed',
                                value: completedTasks.toString(),
                                icon: Icons.check_circle,
                                color: const Color(0xFF10B981),
                              ),
                              _StatItem(
                                label: 'Pending',
                                value: pendingTasks.toString(),
                                icon: Icons.pending,
                                color: const Color(0xFFF59E0B),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Account Actions
                    Container(
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: theme.shadowColor.withOpacity(0.1),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 8,
                            ),
                            leading: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: colorScheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.edit,
                                color: colorScheme.primary,
                              ),
                            ),
                            title: Text(
                              'Edit Profile',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            subtitle: Text(
                              'Update your name and profile picture',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            onTap: () async {
                              final authProvider = Provider.of<AuthProvider>(
                                context,
                                listen: false,
                              );
                              final beforeUrl =
                                  authProvider.userData?['profilePicture']
                                      as String?;
                              debugPrint(
                                '📱 Before Edit - Profile Picture URL: $beforeUrl',
                              );

                              final result = await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const EditProfileScreen(),
                                ),
                              );

                              // After returning, check if profile picture changed
                              // The updateUserFullName already updates local userData and calls notifyListeners()
                              // The Consumer widget will automatically rebuild with the new data
                              final afterUrl =
                                  authProvider.userData?['profilePicture']
                                      as String?;
                              debugPrint(
                                '📱 After Edit - Profile Picture URL: $afterUrl',
                              );
                              debugPrint(
                                '📱 URL changed: ${beforeUrl != afterUrl}',
                              );
                              debugPrint(
                                '📱 Current userData: ${authProvider.userData}',
                              );
                              debugPrint('📱 Result from edit screen: $result');

                              // Force a rebuild of the account screen if result is true (success)
                              if (result == true) {
                                debugPrint(
                                  '📱 Edit was successful, Consumer should rebuild automatically',
                                );
                              }
                            },
                          ),
                          Divider(color: colorScheme.outline),
                          ListTile(
                            leading: Icon(
                              Icons.lock,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            title: Text(
                              'Change Password',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            subtitle: Text(
                              'Update your account password',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const ChangePasswordScreen(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Account Info
                    Card(
                      color: theme.cardColor,
                      child: Column(
                        children: [
                          ListTile(
                            leading: Icon(
                              Icons.email,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            title: Text(
                              'Email',
                              style: GoogleFonts.poppins(
                                color: colorScheme.onSurface,
                              ),
                            ),
                            subtitle: Text(
                              email,
                              style: GoogleFonts.poppins(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            trailing: Icon(
                              Icons.lock,
                              size: 16,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          if (joinedDate != null) ...[
                            Divider(color: colorScheme.outline),
                            ListTile(
                              leading: Icon(
                                Icons.calendar_today,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              title: Text(
                                'Joined Date',
                                style: GoogleFonts.poppins(
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              subtitle: Text(
                                DateFormat('MMM dd, yyyy').format(joinedDate),
                                style: GoogleFonts.poppins(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Stat Item Widget
class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Icon(icon, size: 32, color: color),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
