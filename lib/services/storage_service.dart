import 'dart:async';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Storage Service
/// Handles file uploads to Firebase Storage
class StorageService {
  // Use the storage bucket from firebase_options
  // This ensures we're using the correct bucket even if Storage isn't fully initialized
  final FirebaseStorage _storage = FirebaseStorage.instanceFor(
    bucket: 'student-task-manager-4bc6a.firebasestorage.app',
  );

  /// Upload profile picture to Firebase Storage
  /// Returns the download URL of the uploaded image
  Future<String> uploadProfilePicture(String uid, File imageFile) async {
    UploadTask? uploadTask;
    try {
      debugPrint('📤 Uploading profile picture for UID: $uid');
      debugPrint('   File path: ${imageFile.path}');
      debugPrint('   File size: ${await imageFile.length()} bytes');
      debugPrint('   Storage bucket: ${_storage.app.name}');
      
      // Verify file exists and is readable
      if (!await imageFile.exists()) {
        throw Exception('Image file does not exist: ${imageFile.path}');
      }
      
      final fileSize = await imageFile.length();
      if (fileSize == 0) {
        throw Exception('Image file is empty');
      }
      debugPrint('   File verified: exists=true, size=$fileSize bytes');

      // Create a reference to the location where the image will be stored
      // Format: profile_pictures/{uid}.jpg
      // Note: Overwriting the same file will generate a new download URL with a new token
      // Use root reference and then child() to ensure proper path construction
      final ref = _storage.ref().child('profile_pictures').child('$uid.jpg');
      debugPrint('   Storage path: profile_pictures/$uid.jpg');
      debugPrint('   Full reference path: ${ref.fullPath}');
      debugPrint('   Bucket: ${ref.bucket}');

      // Upload the file with progress tracking
      uploadTask = ref.putFile(
        imageFile,
        SettableMetadata(
          contentType: 'image/jpeg',
          cacheControl: 'public, max-age=31536000', // Cache for 1 year
        ),
      );

      debugPrint('   Upload task created, waiting for completion...');

      // Listen to upload progress (don't await this, just listen)
      final progressSubscription = uploadTask.snapshotEvents.listen(
        (TaskSnapshot snapshot) {
          if (snapshot.totalBytes > 0) {
            final progress = (snapshot.bytesTransferred / snapshot.totalBytes * 100);
            debugPrint('   📊 Upload progress: ${progress.toStringAsFixed(1)}%');
          }
        },
        onError: (error) {
          debugPrint('   ⚠️ Progress listener error: $error');
        },
      );

      // Wait for the upload to complete (with a longer timeout)
      // Don't cancel on timeout - let it finish naturally if possible
      TaskSnapshot snapshot;
      try {
        snapshot = await uploadTask.timeout(
          const Duration(seconds: 120), // Increased timeout to 2 minutes
        );
      } on TimeoutException {
        debugPrint('❌ Upload timeout after 120 seconds');
        progressSubscription.cancel();
        // Check if upload is still running before cancelling
        if (uploadTask.snapshot.state == TaskState.running) {
          debugPrint('   Upload still running, cancelling...');
          uploadTask.cancel();
        }
        throw TimeoutException('Upload timed out after 120 seconds');
      } finally {
        progressSubscription.cancel();
      }

      debugPrint('✅ Upload completed: ${(snapshot.bytesTransferred / snapshot.totalBytes * 100).toStringAsFixed(1)}%');
      debugPrint('   Bytes transferred: ${snapshot.bytesTransferred}/${snapshot.totalBytes}');

      // Check if upload was successful
      if (snapshot.state == TaskState.success) {
        debugPrint('✅ Upload state: SUCCESS');
      } else {
        debugPrint('⚠️ Upload state: ${snapshot.state}');
        throw Exception('Upload did not complete successfully. State: ${snapshot.state}');
      }

      // Get the download URL
      debugPrint('🔗 Getting download URL...');
      final downloadUrl = await ref.getDownloadURL().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          debugPrint('❌ Failed to get download URL: timeout');
          throw TimeoutException('Failed to get download URL');
        },
      );
      
      debugPrint('✅ Profile picture uploaded successfully');
      debugPrint('   Download URL: $downloadUrl');
      debugPrint('   URL length: ${downloadUrl.length}');

      return downloadUrl;
    } on FirebaseException catch (e) {
      debugPrint('❌ Firebase Storage Exception:');
      debugPrint('   Code: ${e.code}');
      debugPrint('   Message: ${e.message}');
      debugPrint('   Plugin: ${e.plugin}');
      
      if (e.code == 'canceled' || e.code == '-13040') {
        debugPrint('❌ Upload was cancelled');
        debugPrint('   Possible causes:');
        debugPrint('   1. Network connection lost');
        debugPrint('   2. Upload timeout');
        debugPrint('   3. Firebase Storage rules preventing upload');
        debugPrint('   4. App was closed or backgrounded');
        throw Exception('Upload was cancelled. Please check your network connection and Firebase Storage rules.');
      } else if (e.code == 'unauthorized' || e.code == 'permission-denied') {
        debugPrint('❌ Permission denied - Check Firebase Storage rules');
        throw Exception('Permission denied. Please check Firebase Storage security rules allow uploads for authenticated users.');
      } else if (e.code == 'object-not-found') {
        debugPrint('❌ Object not found - Storage bucket may not be accessible');
        debugPrint('   This usually means:');
        debugPrint('   1. Firebase Storage is not enabled in Firebase Console');
        debugPrint('   2. Storage bucket does not exist');
        debugPrint('   3. Storage bucket name is incorrect');
        throw Exception('Storage bucket not found. Please enable Firebase Storage in Firebase Console and ensure the bucket exists.');
      } else {
        debugPrint('❌ Unknown Firebase Storage error: ${e.code}');
        throw Exception('Firebase Storage error (${e.code}): ${e.message}');
      }
    } on TimeoutException catch (e) {
      debugPrint('❌ Upload timeout: $e');
      uploadTask?.cancel();
      throw Exception('Upload timed out. Please check your network connection and try again.');
    } catch (e) {
      debugPrint('❌ Error uploading profile picture: $e');
      debugPrint('   Error type: ${e.runtimeType}');
      uploadTask?.cancel();
      throw Exception('Failed to upload profile picture: $e');
    }
  }

  /// Delete profile picture from Firebase Storage
  Future<void> deleteProfilePicture(String uid) async {
    try {
      debugPrint('🗑️ Deleting profile picture for UID: $uid');
      final ref = _storage.ref().child('profile_pictures').child('$uid.jpg');
      await ref.delete();
      debugPrint('✅ Profile picture deleted successfully');
    } catch (e) {
      debugPrint('⚠️ Error deleting profile picture (may not exist): $e');
      // Don't throw - it's okay if the file doesn't exist
    }
  }
}





