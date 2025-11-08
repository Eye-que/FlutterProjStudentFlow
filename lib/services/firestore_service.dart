import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

/// Firestore Service
/// Handles user data operations in Cloud Firestore
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Save user info to Firestore after registration
  /// If document already exists, this will overwrite it (use createUserProfileIfMissing for non-destructive updates)
  Future<void> saveUserData({
    required String uid,
    required String fullName,
    required String email,
  }) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'fullName': fullName,
        'email': email,
        'uid': uid,
        'createdAt': FieldValue.serverTimestamp(),
        'profilePicture': '', // Empty string initially, can be updated later
      });
      debugPrint('✅ User data saved to Firestore for UID: $uid');
    } catch (e) {
      debugPrint('❌ Failed to save user data: $e');
      throw Exception('Failed to save user data: $e');
    }
  }

  /// Create user profile document if it doesn't exist
  /// This is useful for existing authenticated users who don't have Firestore documents yet
  /// Returns true if document was created, false if it already existed
  Future<bool> createUserProfileIfMissing({
    required String uid,
    required String email,
    String? fullName,
    String? profilePicture,
  }) async {
    try {
      // Check if document exists
      final doc = await _firestore.collection('users').doc(uid).get();
      
      if (doc.exists) {
        debugPrint('📄 User profile already exists for UID: $uid');
        return false;
      }

      // Document doesn't exist, create it
      debugPrint('📝 Creating missing user profile for UID: $uid');
      
      // Determine full name: use provided name, or email username as fallback
      final effectiveFullName = (fullName != null && fullName.trim().isNotEmpty)
          ? fullName.trim()
          : email.split('@').first;

      await _firestore.collection('users').doc(uid).set({
        'fullName': effectiveFullName,
        'email': email,
        'uid': uid,
        'createdAt': FieldValue.serverTimestamp(),
        'profilePicture': profilePicture ?? '',
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      debugPrint('✅ Created user profile for UID: $uid');
      debugPrint('   Full Name: $effectiveFullName');
      debugPrint('   Email: $email');
      return true;
    } catch (e) {
      debugPrint('❌ Failed to create user profile: $e');
      throw Exception('Failed to create user profile: $e');
    }
  }

  /// Get user data from Firestore with retry logic
  /// Retries with exponential backoff on transient errors
  /// [forceRefresh] - If true, forces a server fetch instead of using cache
  Future<Map<String, dynamic>?> getUserData(
    String uid, {
    int maxRetries = 3,
    bool forceRefresh = false,
  }) async {
    int attempt = 0;

    while (attempt < maxRetries) {
      try {
        debugPrint(
          '🔍 Fetching user data from Firestore for UID: $uid (attempt ${attempt + 1}/$maxRetries)',
        );
        debugPrint('   Force refresh: $forceRefresh');
        
        // Use server source if forceRefresh is true (e.g., on app restart)
        // Otherwise use serverAndCache which tries server first, falls back to cache
        final source = forceRefresh ? Source.server : Source.serverAndCache;
        
        final doc = await _firestore
            .collection('users')
            .doc(uid)
            .get(
              GetOptions(source: source),
            );

        if (doc.exists) {
          final data = doc.data();
          debugPrint('📄 Document exists. Data: $data');
          debugPrint('   Profile Picture URL: ${data?['profilePicture'] ?? 'N/A'}');
          debugPrint('   Full Name: ${data?['fullName'] ?? 'N/A'}');
          debugPrint('   Data source: ${doc.metadata.isFromCache ? 'CACHE' : 'SERVER'}');
          return data;
        }
        debugPrint('❌ Document does not exist for UID: $uid');
        return null;
      } catch (e) {
        attempt++;
        final errorString = e.toString().toLowerCase();

        // Check if Firestore API is disabled (PERMISSION_DENIED with specific message)
        final isApiDisabled =
            errorString.contains('permission_denied') &&
            (errorString.contains('api has not been used') ||
                errorString.contains('api is disabled') ||
                errorString.contains('firestore.googleapis.com'));

        if (isApiDisabled) {
          debugPrint('🔴 CRITICAL: Cloud Firestore API is not enabled!');
          debugPrint(
            '   Please enable it at: https://console.developers.google.com/apis/api/firestore.googleapis.com/overview',
          );
          debugPrint(
            '   See FIRESTORE_API_ENABLE_GUIDE.md for detailed instructions',
          );
          throw Exception(
            'Cloud Firestore API is not enabled. '
            'Please enable it in Google Cloud Console. '
            'See FIRESTORE_API_ENABLE_GUIDE.md for instructions.',
          );
        }

        // Check if it's a transient error that should be retried
        final isTransientError =
            errorString.contains('unavailable') ||
            errorString.contains('deadline exceeded') ||
            errorString.contains('timeout') ||
            errorString.contains('transient') ||
            errorString.contains('network');

        if (isTransientError && attempt < maxRetries) {
          // Exponential backoff: wait 1s, 2s, 4s
          final delaySeconds = 1 * (1 << (attempt - 1));
          debugPrint('⚠️ Transient error (attempt $attempt/$maxRetries): $e');
          debugPrint('⏳ Retrying in ${delaySeconds}s...');
          await Future.delayed(Duration(seconds: delaySeconds));
          continue; // Retry
        } else {
          // Not a transient error or max retries reached
          debugPrint('❌ Exception fetching user data: $e');
          throw Exception('Failed to get user data: $e');
        }
      }
    }

    // Should not reach here, but just in case
    throw Exception('Failed to get user data after $maxRetries attempts');
  }

  /// Update user full name
  Future<void> updateUserFullName(String uid, String fullName) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'fullName': fullName,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update user name: $e');
    }
  }

  /// Update user profile picture URL
  Future<void> updateProfilePicture(String uid, String imageUrl) async {
    try {
      debugPrint('📸 Updating profile picture in Firestore for UID: $uid');
      debugPrint('   Image URL: $imageUrl');
      
      await _firestore.collection('users').doc(uid).update({
        'profilePicture': imageUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      debugPrint('✅ Profile picture URL successfully updated in Firestore');
      
      // Verify the update was saved by reading it back
      try {
        final doc = await _firestore.collection('users').doc(uid).get();
        if (doc.exists) {
          final savedUrl = doc.data()?['profilePicture'] as String?;
          debugPrint('🔍 Verification: Profile picture in Firestore: $savedUrl');
          if (savedUrl != imageUrl) {
            debugPrint('⚠️ WARNING: Saved URL does not match uploaded URL!');
            debugPrint('   Expected: $imageUrl');
            debugPrint('   Got: $savedUrl');
          } else {
            debugPrint('✅ Verification successful: Profile picture URL matches');
          }
        }
      } catch (verifyError) {
        debugPrint('⚠️ Could not verify profile picture update: $verifyError');
        // Don't throw - the update may have succeeded even if verification fails
      }
    } catch (e) {
      debugPrint('❌ Failed to update profile picture in Firestore: $e');
      debugPrint('   UID: $uid');
      debugPrint('   Image URL: $imageUrl');
      throw Exception('Failed to update profile picture: $e');
    }
  }

  /// Stream user data for real-time updates
  Stream<DocumentSnapshot> getUserDataStream(String uid) {
    return _firestore.collection('users').doc(uid).snapshots();
  }

  /// Check if email already exists in users collection
  Future<bool> emailExists(String email) async {
    try {
      final query = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      return query.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
