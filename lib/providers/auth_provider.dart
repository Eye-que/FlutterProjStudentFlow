import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';
import '../services/local_storage_service.dart';

/// Helper function to explicitly mark futures as unawaited (fire-and-forget)
void unawaited<T>(Future<T> future) {
  // Intentionally not awaiting - fire and forget
}

/// Auth Provider
/// Manages authentication state using Provider pattern
class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  final StorageService _storageService = StorageService();
  final LocalStorageService _localStorageService = LocalStorageService();
  User? _user;
  Map<String, dynamic>?
  _userData; // Full Name and other user data from Firestore
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  Map<String, dynamic>? get userData => _userData;
  String? get userFullName => _userData?['fullName'] as String?;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _initializeAuth();
  }

  /// Initialize auth state listener
  void _initializeAuth() {
    // Listen to auth state changes (fires on login, logout, token refresh)
    _authService.authStateChanges.listen((User? user) async {
      debugPrint(
        '🔄 Auth state changed: ${user != null ? "User logged in (${user.uid})" : "User logged out"}',
      );
      _user = user;
      if (user != null) {
        // User is logged in - fetch their data from Firestore
        debugPrint(
          '📥 Loading user data on auth state change for UID: ${user.uid}',
        );
        await _loadUserData(user.uid);
      } else {
        // User logged out - clear data
        _userData = null;
        debugPrint('🧹 User data cleared (logged out)');
      }
      notifyListeners();
    });

    // Check if user is already logged in (app restart scenario)
    _user = _authService.currentUser;
    if (_user != null) {
      debugPrint(
        '🔄 App restart detected - user already logged in: ${_user!.uid}',
      );
      debugPrint('📥 Loading user data on app restart...');
      // Load user data immediately when user is already logged in
      // Use forceRefresh=true to ensure we get the latest data from server
      _loadUserData(_user!.uid, forceRefresh: true).then((_) {
        notifyListeners(); // Ensure UI updates with loaded data
        debugPrint('✅ User data loaded on app restart');
      });
    } else {
      debugPrint('ℹ️ No user logged in on app start');
    }
  }

  /// Initialize auth state listener with callback
  /// Used to reload data after login
  Future<void> initializeAuthWithCallback() async {
    final currentUser = _authService.currentUser;
    if (currentUser != null) {
      await _loadUserData(currentUser.uid);
      notifyListeners();
    }
  }

  /// Load user data from Firestore
  /// Fetches fullName, email, and profilePicture (photoUrl) from Firestore
  /// Optionally caches data in SharedPreferences for faster access
  /// Preserves existing local data if Firestore is unavailable
  /// [forceRefresh] - If true, forces a server fetch instead of using cache
  Future<void> _loadUserData(String uid, {bool forceRefresh = false}) async {
    // Save existing local data before attempting to load from Firestore
    // This prevents overwriting user's recent updates when Firestore is unavailable
    final existingLocalData = _userData;
    final existingFullName = existingLocalData?['fullName'] as String?;

    try {
      debugPrint('📥 Loading user data from Firestore for UID: $uid');

      // Try to load from cache first (optional optimization)
      String? cachedName;
      try {
        final prefs = await SharedPreferences.getInstance();
        cachedName = prefs.getString('user_fullName_$uid');
        if (cachedName != null && cachedName.isNotEmpty) {
          debugPrint('📦 Found cached user name: $cachedName');
        }
      } catch (e) {
        debugPrint('⚠️ Could not read cache: $e');
      }

      // Fetch from Firestore
      // Use forceRefresh to ensure we get the latest data (important for profile pictures)
      _userData = await _firestoreService.getUserData(
        uid,
        forceRefresh: forceRefresh,
      );

      if (_userData != null) {
        debugPrint('✅ User data loaded successfully from Firestore');
        debugPrint('   Full Name: ${_userData!['fullName']}');
        debugPrint('   Email: ${_userData!['email'] ?? 'N/A'}');
        debugPrint(
          '   Profile Picture: ${_userData!['profilePicture'] ?? 'N/A'}',
        );
        debugPrint('   Complete user data: $_userData');

        // Cache the full name in SharedPreferences (optional, non-blocking)
        try {
          final prefs = await SharedPreferences.getInstance();
          if (_userData!['fullName'] != null) {
            await prefs
                .setString(
                  'user_fullName_$uid',
                  _userData!['fullName'] as String,
                )
                .timeout(const Duration(seconds: 2));
            debugPrint('✅ User name cached');
          }
        } catch (e) {
          debugPrint('⚠️ Could not cache user data: $e');
          // Don't fail the operation if caching fails
        }
      } else {
        debugPrint('⚠️ Warning: No user data found for uid: $uid');
        debugPrint('   Firestore document does not exist for this user');
        debugPrint('   Attempting to create missing profile document...');

        // Try to create the missing profile document if user is authenticated
        if (_user != null && _user!.uid == uid) {
          try {
            final created = await _firestoreService.createUserProfileIfMissing(
              uid: uid,
              email: _user!.email ?? '',
              fullName: _user!.displayName,
              profilePicture: _user!.photoURL,
            );

            if (created) {
              debugPrint('✅ Created missing user profile');
              // Reload the data after creating
              final newData = await _firestoreService.getUserData(
                uid,
                forceRefresh: true,
              );
              if (newData != null) {
                _userData = newData;
                debugPrint('✅ User data loaded after creating profile');
                notifyListeners();
                return; // Exit early since we successfully created and loaded
              }
            } else {
              debugPrint('   Profile document already exists (race condition)');
              // Try loading again in case it was just created
              final newData = await _firestoreService.getUserData(
                uid,
                forceRefresh: true,
              );
              if (newData != null) {
                _userData = newData;
                debugPrint('✅ User data loaded after race condition resolved');
                notifyListeners();
                return;
              }
            }
          } catch (e) {
            debugPrint('❌ Failed to create user profile: $e');
            // Continue with fallback below
          }
        }

        // Only use fallback if we don't have existing local data
        if (existingLocalData == null) {
          debugPrint('   Using fallback: email username or cached name');

          // Prefer cached name over email username
          if (cachedName != null && cachedName.isNotEmpty) {
            _userData = {
              'fullName': cachedName,
              'email': _user?.email ?? '',
              'profilePicture': '', // No existing local data to preserve
            };
            debugPrint('   Using cached name as fallback: $cachedName');
          } else if (_user?.email != null) {
            final emailUsername = _user!.email!.split('@').first;
            _userData = {
              'fullName': emailUsername,
              'email': _user!.email!,
              'profilePicture': '',
            };
            debugPrint('   Using email username as fallback: $emailUsername');
          }
        } else {
          // Preserve existing local data instead of overwriting
          _userData = existingLocalData;
          debugPrint(
            '   Preserving existing local data (Firestore unavailable)',
          );
          debugPrint('   Keeping full name: $existingFullName');
        }
      }

      // Notify listeners to update UI
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error loading user data: $e');

      // Don't clear existing data on error - preserve local updates
      // Only use fallback if we don't have existing local data
      if (existingLocalData == null) {
        // Try to use cached name first
        String? cachedName;
        try {
          final prefs = await SharedPreferences.getInstance();
          cachedName = prefs.getString('user_fullName_$uid');
        } catch (e) {
          debugPrint('⚠️ Could not read cache for fallback: $e');
        }

        if (cachedName != null && cachedName.isNotEmpty) {
          // Use cached name
          _userData = {
            'fullName': cachedName,
            'email': _user?.email ?? '',
            'profilePicture': '',
          };
          debugPrint('   Using cached name as error fallback: $cachedName');
        } else if (_user?.email != null) {
          // Last resort: use email username
          final emailUsername = _user!.email!.split('@').first;
          _userData = {
            'fullName': emailUsername,
            'email': _user!.email!,
            'profilePicture': '',
          };
          debugPrint(
            '   Using email username as error fallback: $emailUsername',
          );
        }
      } else {
        // Preserve existing local data - don't overwrite user's updates
        _userData = existingLocalData;
        debugPrint('   Preserving existing local data (Firestore error)');
        debugPrint('   Keeping full name: $existingFullName');
        debugPrint('   Local data will be used until Firestore is available');
      }

      notifyListeners();
    }
  }

  /// Refresh user data from Firestore
  /// Preserves local updates that might not be in Firestore yet
  /// [forceRefresh] - If true, forces a server fetch instead of using cache
  Future<void> refreshUserData({bool forceRefresh = true}) async {
    if (_user != null) {
      // Save current local data before refresh (to preserve recent updates)
      final currentProfilePicture = _userData?['profilePicture'] as String?;
      final currentUpdatedAt = _userData?['updatedAt'];
      final currentFullName = _userData?['fullName'] as String?;

      debugPrint('🔄 Refreshing user data...');
      debugPrint('   Force refresh: $forceRefresh');
      debugPrint('   Current profile picture: $currentProfilePicture');
      debugPrint('   Current updatedAt: $currentUpdatedAt');
      debugPrint('   Current fullName: $currentFullName');

      await _loadUserData(_user!.uid, forceRefresh: forceRefresh);

      // Preserve local updates if Firestore data is missing or empty
      // This handles cases where Firestore hasn't synced yet or has stale data
      final firestoreProfilePicture = _userData?['profilePicture'] as String?;
      final firestorePicIsEmpty =
          firestoreProfilePicture == null ||
          firestoreProfilePicture.toString().trim().isEmpty;

      final firestoreUpdatedAt = _userData?['updatedAt'];
      final localIsNewer =
          currentUpdatedAt != null &&
          (firestoreUpdatedAt == null ||
              (currentUpdatedAt is DateTime &&
                  firestoreUpdatedAt is DateTime &&
                  currentUpdatedAt.isAfter(firestoreUpdatedAt)));

      // If we had a local profile picture and Firestore doesn't have one, preserve local
      // OR if local data is newer than Firestore data, prefer local
      if (currentProfilePicture != null && currentProfilePicture.isNotEmpty) {
        if (firestorePicIsEmpty || localIsNewer) {
          debugPrint(
            '⚠️ Preserving local profile picture (Firestore ${firestorePicIsEmpty ? "missing" : "stale"}): $currentProfilePicture',
          );
          if (_userData != null) {
            _userData!['profilePicture'] = currentProfilePicture;
            if (currentUpdatedAt != null) {
              _userData!['updatedAt'] = currentUpdatedAt;
            }
            // Also preserve fullName if local is newer
            if (localIsNewer && currentFullName != null) {
              _userData!['fullName'] = currentFullName;
            }
          }
        }
      }

      debugPrint(
        '✅ Refresh complete. Profile picture: ${_userData?['profilePicture']}',
      );
      debugPrint('   UpdatedAt: ${_userData?['updatedAt']}');
      notifyListeners();
    }
  }

  /// Register new user
  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Try to register - Firebase will throw 'email-already-in-use' if email exists
      _user = await _authService.registerWithEmailPassword(
        email: email,
        password: password,
      );

      if (_user != null) {
        // Save user data to Firestore
        try {
          await _firestoreService
              .saveUserData(uid: _user!.uid, fullName: fullName, email: email)
              .timeout(
                const Duration(seconds: 10),
                onTimeout: () {
                  throw Exception(
                    'Firestore connection timeout. Please check your internet connection and Firebase setup.',
                  );
                },
              );
          await _loadUserData(_user!.uid);
        } catch (firestoreError) {
          // Firestore save failed but user is registered
          debugPrint('Firestore save failed: $firestoreError');
          // Don't fail registration if Firestore save fails
          // User can update their profile later
        }
      }

      _isLoading = false;
      notifyListeners();
      return _user != null;
    } catch (e) {
      // Handle Firebase exceptions with user-friendly messages
      final errorString = e.toString().toLowerCase();

      // Check for specific error patterns
      if (errorString.contains('email-already-in-use') ||
          errorString.contains('an account already exists') ||
          errorString.contains('account already exists')) {
        _errorMessage = 'An account already exists for that email.';
      } else if (errorString.contains('weak-password')) {
        _errorMessage = 'The password provided is too weak.';
      } else if (errorString.contains('invalid-email')) {
        _errorMessage = 'The email address is invalid.';
      } else if (errorString.contains('pigeonuserdetails') ||
          errorString.contains('type cast') ||
          errorString.contains('list<object?>')) {
        // Handle Firebase plugin type casting errors
        _errorMessage =
            'Registration failed. This email may already be registered. Please try logging in instead.';
      } else {
        // Extract message from Exception if it's wrapped
        String message = e.toString().replaceFirst('Exception: ', '');
        // Clean up any technical details
        if (message.contains('Registration failed:')) {
          // Keep the user-friendly part only
          message = message.split('Registration failed:').last.trim();
          // If it's still technical, provide a generic message
          if (message.contains('type') && message.contains('cast')) {
            message =
                'Registration failed. This email may already be registered. Please try logging in instead.';
          }
        }
        _errorMessage = message.isNotEmpty
            ? message
            : 'Registration failed. Please try again.';
      }

      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Login user
  Future<bool> login({required String email, required String password}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Step 1: Authenticate with Firebase Auth
      _user = await _authService.loginWithEmailPassword(
        email: email,
        password: password,
      );

      if (_user != null) {
        // Step 2: Fetch user data from Firestore using the uid
        try {
          debugPrint('🔐 Login successful for UID: ${_user!.uid}');
          debugPrint('📥 Fetching user data from Firestore...');

          // Explicitly fetch user data from Firestore
          await _loadUserData(_user!.uid);

          // Verify data was loaded
          if (_userData != null) {
            debugPrint('✅ User data loaded successfully');
            debugPrint('   Full Name: ${_userData!['fullName']}');
            debugPrint('   Email: ${_userData!['email']}');
            debugPrint('   Profile Picture: ${_userData!['profilePicture']}');
          } else {
            debugPrint(
              '⚠️ Warning: User data not found in Firestore for user ${_user!.uid}',
            );
            debugPrint(
              '   This may happen if the user was created before Firestore was set up.',
            );
            debugPrint('   Attempting to create missing profile document...');

            // Try to create the missing profile document
            try {
              final created = await _firestoreService
                  .createUserProfileIfMissing(
                    uid: _user!.uid,
                    email: _user!.email ?? '',
                    fullName: _user!.displayName,
                    profilePicture: _user!.photoURL,
                  );

              if (created) {
                debugPrint('✅ Created missing user profile');
                // Reload the data after creating
                await _loadUserData(_user!.uid);
              } else {
                debugPrint(
                  '   Profile document already exists (race condition)',
                );
              }
            } catch (e) {
              debugPrint('❌ Failed to create user profile: $e');
              debugPrint(
                '   User can update their profile in Account settings.',
              );
            }
          }
        } catch (e) {
          debugPrint('❌ Error loading user data after login: $e');
          // Don't fail login if data loading fails - user can still access app
          // The authStateChanges listener will retry loading data
        }
      }

      _isLoading = false;
      notifyListeners();
      return _user != null;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Continue with Google Sign-In
  Future<bool> continueWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      debugPrint('🔐 Starting Google Sign-In...');

      // Step 1: Authenticate with Google
      _user = await _authService.signInWithGoogle();

      if (_user != null) {
        // Get the current user (might have been updated after reload in signInWithGoogle)
        _user = _authService.currentUser;

        debugPrint('✅ Google Sign-In successful for UID: ${_user!.uid}');
        debugPrint('📧 Email: ${_user!.email}');
        debugPrint('👤 Display Name: ${_user!.displayName ?? 'NOT SET'}');
        debugPrint('📸 Photo URL: ${_user!.photoURL ?? 'NOT SET'}');

        // Step 2: Check if user data exists in Firestore, if not create it
        // Use timeout to prevent hanging if Firestore API is disabled
        try {
          debugPrint('📥 Checking user data in Firestore...');

          // Try to load existing user data with timeout
          await _loadUserData(_user!.uid).timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              debugPrint(
                '⚠️ Timeout loading user data - continuing without Firestore data',
              );
              // Don't throw - continue with fallback data
            },
          );

          // If user data doesn't exist, create it with Google account info
          if (_userData == null) {
            debugPrint('📝 Creating new user document in Firestore...');

            // Use display name from Firebase user (should be set from Google account)
            // If still null, fall back to email username
            final fullName = _user!.displayName?.trim();
            final effectiveFullName = (fullName != null && fullName.isNotEmpty)
                ? fullName
                : _user!.email!.split('@').first;

            debugPrint('💾 Saving full name to Firestore: $effectiveFullName');

            final email = _user!.email ?? '';
            final profilePicture = _user!.photoURL ?? '';

            // Save user data with timeout
            await _firestoreService
                .saveUserData(
                  uid: _user!.uid,
                  fullName: effectiveFullName,
                  email: email,
                )
                .timeout(
                  const Duration(seconds: 10),
                  onTimeout: () {
                    debugPrint(
                      '⚠️ Timeout saving user data - continuing anyway',
                    );
                  },
                )
                .catchError((e) {
                  debugPrint('⚠️ Error saving user data (non-blocking): $e');
                });

            // Update profile picture if available from Google (non-blocking)
            if (profilePicture.isNotEmpty) {
              debugPrint('📸 Updating profile picture from Google account...');
              _firestoreService
                  .updateProfilePicture(_user!.uid, profilePicture)
                  .timeout(
                    const Duration(seconds: 10),
                    onTimeout: () {
                      debugPrint('⚠️ Timeout updating profile picture');
                    },
                  )
                  .catchError((e) {
                    debugPrint(
                      '⚠️ Error updating profile picture (non-blocking): $e',
                    );
                  });
            }

            // Try to reload the data after saving (non-blocking)
            _loadUserData(_user!.uid)
                .timeout(
                  const Duration(seconds: 5),
                  onTimeout: () {
                    debugPrint('⚠️ Timeout reloading user data');
                  },
                )
                .catchError((e) {
                  debugPrint('⚠️ Error reloading user data (non-blocking): $e');
                });
            debugPrint(
              '✅ User data save initiated (Firestore may be processing)',
            );
          } else {
            debugPrint('✅ User data already exists in Firestore');

            // Update full name in Firestore if Firebase user has it but Firestore doesn't (non-blocking)
            if (_user!.displayName != null &&
                _user!.displayName!.trim().isNotEmpty &&
                (_userData!['fullName'] == null ||
                    _userData!['fullName'].toString().trim().isEmpty ||
                    _userData!['fullName'].toString().contains('@'))) {
              debugPrint(
                '📝 Updating full name in Firestore from Google account...',
              );
              _firestoreService
                  .updateUserFullName(_user!.uid, _user!.displayName!.trim())
                  .timeout(
                    const Duration(seconds: 10),
                    onTimeout: () {
                      debugPrint('⚠️ Timeout updating full name');
                    },
                  )
                  .catchError((e) {
                    debugPrint(
                      '⚠️ Error updating full name (non-blocking): $e',
                    );
                  });
            }

            // Update profile picture if it's missing but available from Google (non-blocking)
            if ((_userData!['profilePicture'] == null ||
                    _userData!['profilePicture'].toString().isEmpty) &&
                _user!.photoURL != null &&
                _user!.photoURL!.isNotEmpty) {
              debugPrint('📸 Updating profile picture from Google account...');
              _firestoreService
                  .updateProfilePicture(_user!.uid, _user!.photoURL!)
                  .timeout(
                    const Duration(seconds: 10),
                    onTimeout: () {
                      debugPrint('⚠️ Timeout updating profile picture');
                    },
                  )
                  .catchError((e) {
                    debugPrint(
                      '⚠️ Error updating profile picture (non-blocking): $e',
                    );
                  });
            }
          }

          debugPrint('✅ Google Sign-In completed successfully');
        } catch (e) {
          debugPrint(
            '⚠️ Warning: Error handling user data after Google Sign-In: $e',
          );
          // Don't fail login if Firestore operation fails
          // User can still access app and update profile later

          // Use fallback data from Google account
          if (_userData == null && _user != null) {
            final fullName = _user!.displayName?.trim();
            final effectiveFullName = (fullName != null && fullName.isNotEmpty)
                ? fullName
                : _user!.email!.split('@').first;

            _userData = {
              'fullName': effectiveFullName,
              'email': _user!.email ?? '',
              'profilePicture': _user!.photoURL ?? '',
            };
            debugPrint('📋 Using fallback user data from Google account');
          }
        }
      } else {
        // User is null - this shouldn't happen but handle it gracefully
        debugPrint('⚠️ Warning: Google Sign-In returned null user');
      }

      // Always clear loading state and notify listeners
      _isLoading = false;
      notifyListeners();

      // Return success if user is not null (even if Firestore operations failed)
      return _user != null;
    } catch (e) {
      debugPrint('❌ Google Sign-In failed: $e');
      _errorMessage = e.toString().replaceFirst('Exception: ', '');

      // Always clear loading state, even on error
      _isLoading = false;
      notifyListeners();
      return false;
    } finally {
      // Ensure loading state is always cleared
      if (_isLoading) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  /// Send password reset email
  Future<bool> forgotPassword(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.sendPasswordResetEmail(email);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Update user password
  Future<bool> updatePassword(
    String currentPassword,
    String newPassword,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (_user == null || _user!.email == null) {
        throw Exception('No user is currently signed in.');
      }

      await _authService.updatePassword(
        currentPassword,
        newPassword,
        _user!.email!,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Update user full name
  /// Optionally updates profile picture if provided (saves to local storage)
  Future<bool> updateUserFullName(
    String fullName, {
    File? profilePicture,
  }) async {
    if (_user == null) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      debugPrint('📝 Updating user full name to: $fullName');

      // Step 1: Update in Firestore first
      try {
        await _firestoreService
            .updateUserFullName(_user!.uid, fullName)
            .timeout(const Duration(seconds: 10));
        debugPrint('✅ Full name updated in Firestore');
      } on TimeoutException {
        debugPrint('⚠️ Firestore update timed out - will use local data');
      } catch (e) {
        debugPrint('⚠️ Firestore update failed: $e');
        // Will still update local data for immediate feedback
      }

      // Step 1.5: Handle profile picture if provided (save to local storage)
      String? profilePicturePath;
      if (profilePicture != null) {
        debugPrint('📤 Starting profile picture save process...');
        debugPrint('   File path: ${profilePicture.path}');
        debugPrint('   File exists: ${await profilePicture.exists()}');
        debugPrint('   File size: ${await profilePicture.length()} bytes');

        try {
          debugPrint('💾 Saving profile picture to local storage...');
          profilePicturePath = await _localStorageService.saveProfilePicture(
            _user!.uid,
            profilePicture,
          );

          if (profilePicturePath.isEmpty) {
            debugPrint('❌ ERROR: Profile picture save returned empty path!');
            throw Exception('Save returned empty path');
          }

          debugPrint('✅ Profile picture saved to local storage');
          debugPrint('   Path: $profilePicturePath');

          // Save the local file path to Firestore (so it persists)
          try {
            debugPrint('💾 Saving profile picture path to Firestore...');
            await _firestoreService
                .updateProfilePicture(_user!.uid, profilePicturePath)
                .timeout(const Duration(seconds: 10));
            debugPrint('✅ Profile picture path saved to Firestore');

            // Small delay to ensure Firestore has processed the update
            await Future.delayed(const Duration(milliseconds: 500));
          } catch (e) {
            debugPrint(
              '❌ Failed to save profile picture path to Firestore: $e',
            );
            debugPrint('   Path that failed to save: $profilePicturePath');
            // Don't re-throw - we still want to update local data with the path
            // The path is valid even if Firestore save fails temporarily
            debugPrint(
              '⚠️ Continuing with local update despite Firestore error',
            );
          }
        } catch (e) {
          debugPrint('❌ Failed to save profile picture: $e');
          debugPrint('   Error type: ${e.runtimeType}');
          debugPrint('   Error details: ${e.toString()}');
          profilePicturePath = null; // Ensure it's null on error
          _errorMessage =
              'Name was updated but profile picture save failed: ${e.toString().replaceFirst('Exception: ', '')}';
        }

        debugPrint('📊 Profile picture save result:');
        debugPrint(
          '   profilePicturePath is null: ${profilePicturePath == null}',
        );
        debugPrint(
          '   profilePicturePath is empty: ${profilePicturePath?.isEmpty ?? true}',
        );
        debugPrint('   profilePicturePath value: $profilePicturePath');
      } else {
        debugPrint('ℹ️ No profile picture provided (profilePicture is null)');
      }

      // Step 2: Update local data immediately for instant UI feedback
      // Create a NEW map instance to ensure Flutter's change detection works
      // Only update if Firestore succeeded OR if we want to show the change anyway
      final now = DateTime.now();

      // Determine the profile picture path to use
      String? finalProfilePicturePath;
      debugPrint('🔍 Determining final profile picture path...');
      debugPrint('   profilePicturePath: $profilePicturePath');
      debugPrint('   profilePicture provided: ${profilePicture != null}');
      debugPrint('   existing profilePicture: ${_userData?['profilePicture']}');

      if (profilePicturePath != null && profilePicturePath.isNotEmpty) {
        // New image was saved successfully
        finalProfilePicturePath = profilePicturePath;
        debugPrint(
          '✅ Using newly saved profile picture path: $profilePicturePath',
        );
      } else if (profilePicture == null) {
        // No new image selected, keep existing
        finalProfilePicturePath = _userData?['profilePicture'] as String?;
        debugPrint(
          'ℹ️ No new profile picture selected, keeping existing: $finalProfilePicturePath',
        );
      } else {
        // Save failed - keep existing if available, otherwise empty
        finalProfilePicturePath = _userData?['profilePicture'] as String?;
        debugPrint('⚠️ Save failed - profilePicturePath is null/empty');
        debugPrint(
          '   Keeping existing profile picture: $finalProfilePicturePath',
        );
        debugPrint('   Error message: $_errorMessage');
      }

      debugPrint(
        '📋 Final profile picture path decision: $finalProfilePicturePath',
      );

      // Create a NEW map instance to trigger change detection
      // This ensures Flutter's change detection picks up the update
      final Map<String, dynamic> newUserData = {
        // Preserve existing fields first
        if (_userData != null) ..._userData!,
        // Then override with new/updated values
        'fullName': fullName,
        'email': _userData?['email'] ?? _user!.email ?? '',
        // Only set profilePicture if we have a valid path, otherwise keep existing
        if (finalProfilePicturePath != null &&
            finalProfilePicturePath.isNotEmpty)
          'profilePicture': finalProfilePicturePath
        else if (_userData?['profilePicture'] != null)
          'profilePicture': _userData!['profilePicture']
        else
          'profilePicture': '',
        'updatedAt': now,
      };
      _userData = newUserData;

      debugPrint('📝 Created NEW userData map: $_userData');
      if (_userData != null) {
        debugPrint('   Full Name: ${_userData!['fullName']}');
        debugPrint('   Profile Picture URL: ${_userData!['profilePicture']}');
        debugPrint(
          '   Profile Picture is empty: ${(_userData!['profilePicture'] as String? ?? '').isEmpty}',
        );
        debugPrint('   UpdatedAt: ${_userData!['updatedAt']}');
      }
      debugPrint('📢 Calling notifyListeners() to update UI...');
      debugPrint('📊 Current userData before notifyListeners: $_userData');
      debugPrint(
        '   Profile Picture URL in userData: ${_userData?['profilePicture']}',
      );
      debugPrint('   UpdatedAt in userData: ${_userData?['updatedAt']}');
      notifyListeners(); // Update UI immediately
      debugPrint('✅ notifyListeners() called - UI should update now');
      debugPrint('📊 Current userData after notifyListeners: $_userData');

      // Step 3: Update cache immediately (non-blocking, fire-and-forget)
      unawaited(
        SharedPreferences.getInstance()
            .then((prefs) {
              return prefs
                  .setString('user_fullName_${_user!.uid}', fullName)
                  .timeout(const Duration(seconds: 2))
                  .catchError((e) {
                    debugPrint('⚠️ Could not update cache: $e');
                    return false; // Return bool to satisfy type checker
                  });
            })
            .catchError((e) {
              debugPrint('⚠️ Could not get SharedPreferences: $e');
              return false; // Return bool to satisfy type checker
            }),
      );

      // Step 4: DON'T reload from Firestore - we've already updated local data
      // Reloading would risk overwriting with stale/cached data
      // The local data is correct since we just wrote it to Firestore

      _isLoading = false;
      notifyListeners();
      debugPrint('✅ Update completed successfully');

      // Return true even if Firestore failed - local data is updated
      return true;
    } catch (e) {
      debugPrint('❌ Error updating user full name: $e');
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Logout user
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    // Clear cached data
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_user != null) {
        await prefs.remove('user_fullName_${_user!.uid}');
      }
    } catch (e) {
      debugPrint('⚠️ Could not clear cache: $e');
    }

    await _authService.logout();
    _user = null;
    _userData = null;
    _isLoading = false;
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
