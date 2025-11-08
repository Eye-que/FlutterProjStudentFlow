import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Local Storage Service
/// Handles saving and loading profile pictures to/from device local storage
class LocalStorageService {
  /// Get the app's documents directory
  Future<Directory> get _appDocumentsDirectory async {
    final directory = await getApplicationDocumentsDirectory();
    final profilePicturesDir = Directory('${directory.path}/profile_pictures');
    if (!await profilePicturesDir.exists()) {
      await profilePicturesDir.create(recursive: true);
    }
    return profilePicturesDir;
  }

  /// Save profile picture to local storage
  /// Returns the local file path
  Future<String> saveProfilePicture(String uid, File imageFile) async {
    try {
      debugPrint('💾 Saving profile picture to local storage for UID: $uid');
      debugPrint('   Source file: ${imageFile.path}');
      debugPrint('   File exists: ${await imageFile.exists()}');

      // Verify source file exists
      if (!await imageFile.exists()) {
        throw Exception('Source image file does not exist: ${imageFile.path}');
      }

      final fileSize = await imageFile.length();
      if (fileSize == 0) {
        throw Exception('Image file is empty');
      }
      debugPrint('   File size: $fileSize bytes');

      // Get the profile pictures directory
      final profilePicturesDir = await _appDocumentsDirectory;
      
      // Create destination file path: profile_pictures/{uid}.jpg
      final destinationFile = File('${profilePicturesDir.path}/$uid.jpg');
      
      debugPrint('   Destination: ${destinationFile.path}');

      // Copy the image file to the destination
      // This replaces any existing file with the same name
      await imageFile.copy(destinationFile.path);
      
      debugPrint('✅ Profile picture saved to local storage');
      debugPrint('   Saved path: ${destinationFile.path}');

      // Save the file path to SharedPreferences for quick access
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_picture_path_$uid', destinationFile.path);
      debugPrint('✅ Profile picture path saved to SharedPreferences');

      return destinationFile.path;
    } catch (e) {
      debugPrint('❌ Error saving profile picture to local storage: $e');
      throw Exception('Failed to save profile picture: $e');
    }
  }

  /// Get profile picture file path from local storage
  /// Returns null if file doesn't exist
  Future<String?> getProfilePicturePath(String uid) async {
    try {
      // First, try to get from SharedPreferences (faster)
      final prefs = await SharedPreferences.getInstance();
      final cachedPath = prefs.getString('profile_picture_path_$uid');
      
      if (cachedPath != null) {
        final file = File(cachedPath);
        if (await file.exists()) {
          debugPrint('📸 Found profile picture in cache: $cachedPath');
          return cachedPath;
        } else {
          // Cached path is invalid, remove it
          debugPrint('⚠️ Cached path invalid, removing: $cachedPath');
          await prefs.remove('profile_picture_path_$uid');
        }
      }

      // Fallback: check the default location
      final profilePicturesDir = await _appDocumentsDirectory;
      final file = File('${profilePicturesDir.path}/$uid.jpg');
      
      if (await file.exists()) {
        debugPrint('📸 Found profile picture in default location: ${file.path}');
        // Update cache
        await prefs.setString('profile_picture_path_$uid', file.path);
        return file.path;
      }

      debugPrint('📸 No profile picture found for UID: $uid');
      return null;
    } catch (e) {
      debugPrint('❌ Error getting profile picture path: $e');
      return null;
    }
  }

  /// Get profile picture file from local storage
  /// Returns null if file doesn't exist
  Future<File?> getProfilePictureFile(String uid) async {
    final path = await getProfilePicturePath(uid);
    if (path != null) {
      final file = File(path);
      if (await file.exists()) {
        return file;
      }
    }
    return null;
  }

  /// Delete profile picture from local storage
  Future<void> deleteProfilePicture(String uid) async {
    try {
      debugPrint('🗑️ Deleting profile picture from local storage for UID: $uid');
      
      // Get file path
      final path = await getProfilePicturePath(uid);
      if (path != null) {
        final file = File(path);
        if (await file.exists()) {
          await file.delete();
          debugPrint('✅ Profile picture deleted: $path');
        }
      }

      // Remove from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('profile_picture_path_$uid');
      debugPrint('✅ Profile picture path removed from SharedPreferences');
    } catch (e) {
      debugPrint('⚠️ Error deleting profile picture (may not exist): $e');
      // Don't throw - it's okay if the file doesn't exist
    }
  }

  /// Check if profile picture exists in local storage
  Future<bool> profilePictureExists(String uid) async {
    final path = await getProfilePicturePath(uid);
    if (path != null) {
      final file = File(path);
      return await file.exists();
    }
    return false;
  }

  /// Get the storage directory path (for debugging)
  Future<String> getStorageDirectoryPath() async {
    final dir = await _appDocumentsDirectory;
    return dir.path;
  }
}

