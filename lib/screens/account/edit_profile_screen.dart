import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/auth_provider.dart';

/// Edit Profile Screen
/// Allows users to update their name and profile picture
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _imagePicker = ImagePicker();
  File? _selectedImage;
  String? _imageUrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    // Listen to auth provider changes to update image URL if changed elsewhere
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.addListener(_onAuthProviderChanged);
  }

  void _onAuthProviderChanged() {
    if (mounted) {
      _loadUserData();
      setState(() {}); // Force rebuild to show updated image
    }
  }

  void _loadUserData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userData = authProvider.userData;

    _nameController.text = authProvider.userFullName ?? '';
    final newImageUrl = userData?['profilePicture'] as String?;
    if (newImageUrl != _imageUrl) {
      _imageUrl = newImageUrl;
      debugPrint('🔄 Edit Profile - Image URL updated: $_imageUrl');
    }
  }

  @override
  void dispose() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.removeListener(_onAuthProviderChanged);
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
          // In a real app, you'd upload this to Firebase Storage
          // For now, we'll just store the local path
        });
      }
    } catch (e) {
      if (mounted) {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          animType: AnimType.bottomSlide,
          title: 'Error',
          desc: 'Failed to pick image: $e',
          btnOkOnPress: () {},
        ).show();
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final newName = _nameController.text.trim();
      final oldName = authProvider.userFullName ?? '';
      final hasNewImage = _selectedImage != null;

      // ✅ Skip only if literally nothing changed
      if (newName == oldName && !hasNewImage) {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          AwesomeDialog(
            context: context,
            dialogType: DialogType.info,
            animType: AnimType.bottomSlide,
            title: 'No Changes',
            desc: 'No updates made to your profile.',
            btnOkOnPress: () {},
          ).show();
        }
        return;
      }

      // ✅ Update both name and/or image
      final success = await authProvider
          .updateUserFullName(newName, profilePicture: _selectedImage)
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              debugPrint('❌ Update operation timed out');
              return false;
            },
          );

      setState(() {
        _isLoading = false;
      });

      if (success && mounted) {
        // Update local _imageUrl to reflect the saved URL
        // This ensures the edit screen shows the correct image if user opens it again
        final updatedUserData = authProvider.userData;
        final savedImageUrl = updatedUserData?['profilePicture'] as String?;
        final hasImage = savedImageUrl != null && savedImageUrl.isNotEmpty;

        debugPrint('🖼️ Edit Profile - Save result:');
        debugPrint('   Success: $success');
        debugPrint('   Saved Image URL: $savedImageUrl');
        debugPrint('   Has Image: $hasImage');
        debugPrint('   Error Message: ${authProvider.errorMessage}');

        if (hasImage) {
          setState(() {
            _imageUrl = savedImageUrl;
            _selectedImage = null; // Clear selected image since it's now saved
          });
          debugPrint(
            '🖼️ Edit Profile - Updated local _imageUrl to: $_imageUrl',
          );

          AwesomeDialog(
            context: context,
            dialogType: DialogType.success,
            animType: AnimType.bottomSlide,
            title: 'Success',
            desc: 'Profile updated successfully!',
            btnOkOnPress: () {
              debugPrint(
                '🖼️ Edit Profile - Navigating back, saved URL: $savedImageUrl',
              );
              Navigator.of(context).pop(true);
            },
          ).show();
        } else if (_selectedImage != null) {
          // Image was selected but upload failed
          final errorMsg =
              authProvider.errorMessage ?? 'Profile picture upload failed';
          debugPrint('⚠️ Image upload failed: $errorMsg');

          AwesomeDialog(
            context: context,
            dialogType: DialogType.warning,
            animType: AnimType.bottomSlide,
            title: 'Partial Success',
            desc:
                'Name updated successfully, but profile picture upload failed.\n\n'
                'Possible causes:\n'
                '• Firebase Storage not enabled\n'
                '• Network connection issues\n'
                '• Storage rules not configured\n\n'
                'Error: ${errorMsg.contains("StorageException") || errorMsg.contains("cancelled") || errorMsg.contains("object-not-found") || errorMsg.contains("bucket not found") ? "Please enable Firebase Storage in Firebase Console:\n1. Go to Firebase Console → Storage\n2. Click 'Get Started'\n3. Choose 'Start in test mode'\n4. Configure security rules\n\nSee FIREBASE_STORAGE_SETUP.md for details." : errorMsg}',
            btnOkOnPress: () {
              Navigator.of(context).pop(true);
            },
          ).show();
        } else {
          // No image selected, just name updated
          AwesomeDialog(
            context: context,
            dialogType: DialogType.success,
            animType: AnimType.bottomSlide,
            title: 'Success',
            desc: 'Profile updated successfully!',
            btnOkOnPress: () {
              Navigator.of(context).pop(true);
            },
          ).show();
        }
      } else if (mounted) {
        final errorMsg =
            authProvider.errorMessage ??
            'Failed to update profile. Please try again.';
        debugPrint('❌ Profile update failed: $errorMsg');

        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          animType: AnimType.bottomSlide,
          title: 'Error',
          desc:
              errorMsg.contains("StorageException") ||
                  errorMsg.contains("cancelled") ||
                  errorMsg.contains("object-not-found") ||
                  errorMsg.contains("bucket not found")
              ? 'Profile picture upload failed.\n\n'
                    'The error "object-not-found" means Firebase Storage is not enabled.\n\n'
                    'Please:\n'
                    '1. Go to Firebase Console → Storage\n'
                    '2. Click "Get Started"\n'
                    '3. Choose "Start in test mode"\n'
                    '4. Select a storage location\n'
                    '5. Configure security rules (see FIREBASE_STORAGE_SETUP.md)\n\n'
                    'After enabling, wait 1-2 minutes and try again.'
              : errorMsg,
          btnOkOnPress: () {},
        ).show();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          animType: AnimType.bottomSlide,
          title: 'Error',
          desc:
              'Failed to update profile: ${e.toString().replaceAll('Exception: ', '')}',
          btnOkOnPress: () {},
        ).show();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            TextButton(onPressed: _saveProfile, child: const Text('Save')),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Profile Picture
              GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      backgroundImage: _selectedImage != null
                          ? FileImage(_selectedImage!)
                          : (_imageUrl != null && _imageUrl!.isNotEmpty
                                ? NetworkImage(_imageUrl!)
                                : null),
                      child:
                          _selectedImage == null &&
                              (_imageUrl == null || _imageUrl!.isEmpty)
                          ? Icon(Icons.person, size: 60, color: Colors.white)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Full Name Field
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your full name';
                  }
                  if (value.trim().length < 3) {
                    return 'Name must be at least 3 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
