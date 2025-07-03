import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../common/utilities/color_utility.dart';
import '../../common/utilities/text_style_utility.dart';
import '../../common/utilities/text_utility.dart';
import '../../common/utilities/logger_utility.dart';
import '../../common/utilities/hive_utility.dart';
import '../../common/widgets/common_elevated_button.dart';
import '../../common/widgets/common_text_field.dart';
import '../../common/widgets/common_toast.dart';
import '../../common/widgets/common_bottom_sheet.dart';
import '../dashboard/dashboard.dart';

class UserProfilePage extends StatefulWidget {
  final String? initialName;

  const UserProfilePage({super.key, this.initialName});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final TextEditingController _usernameController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    LoggerUtility.instance.logNavigation('UserProfilePage - initState');
    if (widget.initialName != null) {
      _usernameController.text = widget.initialName!;
      LoggerUtility.instance.logInfo('Initial name set: ${widget.initialName}');
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
        if (mounted) {
          Navigator.pop(context); // Close bottom sheet
          CommonToast.success(context, TextUtility.photoSelectedSuccessfully);
        }
      }
    } catch (e) {
      if (mounted) {
        CommonToast.error(context, 'Failed to pick image: $e');
      }
    }
  }

  void _showImagePickerBottomSheet() {
    CommonBottomSheet.showActionSheet(
      context,
      title: TextUtility.addPhoto,
      actions: [
        BottomSheetAction(
          title: TextUtility.camera,
          icon: Icons.camera_alt,
          onTap: () => _pickImage(ImageSource.camera),
        ),
        BottomSheetAction(
          title: TextUtility.gallery,
          icon: Icons.photo_library,
          onTap: () => _pickImage(ImageSource.gallery),
        ),
        if (_selectedImage != null)
          BottomSheetAction(
            title: TextUtility.removePhoto,
            icon: Icons.delete,
            iconColor: ColorUtility.errorColor,
            titleColor: ColorUtility.errorColor,
            isDestructive: true,
            onTap: () {
              setState(() {
                _selectedImage = null;
              });
              Navigator.pop(context);
              CommonToast.info(context, TextUtility.photoRemoved);
            },
          ),
      ],
    );
  }

  void _handleContinue() {
    LoggerUtility.instance.logUserAction('Continue button pressed');

    if (_usernameController.text.trim().isEmpty) {
      LoggerUtility.instance.logWarning(
        'Profile creation attempted without name',
      );
      CommonToast.warning(context, TextUtility.pleaseEnterYourName);
      return;
    }

    _saveProfile();
  }

  Future<void> _saveProfile() async {
    try {
      LoggerUtility.instance.logUserAction('Continue button pressed');

      final User? currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) {
        LoggerUtility.instance.logError('No authenticated user found');
        if (mounted) {
          CommonToast.error(
            context,
            'Authentication error. Please sign in again.',
          );
        }
        return;
      }

      // Prepare user profile data
      final profileData = {
        'uid': currentUser.uid,
        'email': currentUser.email,
        'displayName': currentUser.displayName,
        'username': _usernameController.text.trim(),
        'profileImagePath': _selectedImage?.path,
        'createdAt': DateTime.now().toIso8601String(),
        'lastUpdated': DateTime.now().toIso8601String(),
        'isProfileComplete': true,
      };

      LoggerUtility.instance.logInfo(
        'Saving user profile data: ${profileData.toString()}',
      );

      // Use consistent box access to prevent type conflicts
      final userDataBox = HiveUtility.instance.isBoxOpen('user_data')
          ? HiveUtility.instance.getBox('user_data')
          : await HiveUtility.instance.openBox('user_data');

      // Save profile data
      await userDataBox.put('profile_${currentUser.uid}', profileData);

      // Use consistent box access for string data
      final stringBox = HiveUtility.instance.isBoxOpen('user_data_strings')
          ? HiveUtility.instance.getBox<String>('user_data_strings')
          : await HiveUtility.instance.openBox<String>('user_data_strings');
      await stringBox.put('current_user_uid', currentUser.uid);

      LoggerUtility.instance.logInfo(
        'Profile saved successfully for user: ${currentUser.uid}',
      );

      // Navigate to dashboard
      if (mounted) {
        LoggerUtility.instance.logNavigation('DashboardPage');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DashboardPage()),
        );
      }
    } catch (error) {
      LoggerUtility.instance.logError('Failed to save profile: $error');
      if (mounted) {
        CommonToast.error(context, 'Failed to save profile. Please try again.');
      }
    }
  }

  void _handleSkip() {
    LoggerUtility.instance.logUserAction('Skip button pressed');
    LoggerUtility.instance.logInfo('Profile creation skipped');

    _skipProfile();
  }

  Future<void> _skipProfile() async {
    try {
      LoggerUtility.instance.logUserAction('Skip button pressed');
      LoggerUtility.instance.logInfo('Profile creation skipped');

      final User? currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) {
        LoggerUtility.instance.logError('No authenticated user found');
        if (mounted) {
          CommonToast.error(
            context,
            'Authentication error. Please sign in again.',
          );
        }
        return;
      }

      // Save minimal profile data
      final profileData = {
        'uid': currentUser.uid,
        'email': currentUser.email,
        'displayName': currentUser.displayName,
        'username': '',
        'profileImagePath': null,
        'createdAt': DateTime.now().toIso8601String(),
        'lastUpdated': DateTime.now().toIso8601String(),
        'isProfileComplete': false,
      };

      LoggerUtility.instance.logInfo(
        'Saving minimal profile data: ${profileData.toString()}',
      );

      // Use consistent box access to prevent type conflicts
      final userDataBox = HiveUtility.instance.isBoxOpen('user_data')
          ? HiveUtility.instance.getBox('user_data')
          : await HiveUtility.instance.openBox('user_data');

      // Save minimal profile data
      await userDataBox.put('profile_${currentUser.uid}', profileData);

      // Use consistent box access for string data
      final stringBox = HiveUtility.instance.isBoxOpen('user_data_strings')
          ? HiveUtility.instance.getBox<String>('user_data_strings')
          : await HiveUtility.instance.openBox<String>('user_data_strings');
      await stringBox.put('current_user_uid', currentUser.uid);

      LoggerUtility.instance.logInfo(
        'Minimal profile saved for user: ${currentUser.uid}',
      );

      // Navigate to dashboard
      if (mounted) {
        LoggerUtility.instance.logNavigation('DashboardPage');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DashboardPage()),
        );
      }
    } catch (error) {
      LoggerUtility.instance.logError('Failed to skip profile: $error');
      if (mounted) {
        CommonToast.error(context, 'Failed to proceed. Please try again.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorUtility.backgroundColor,
      appBar: AppBar(
        backgroundColor: ColorUtility.backgroundColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          TextUtility.createProfile,
          style: TextStyleUtility.appBarTitle,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: ColorUtility.primaryText),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 32),

                      // Profile Photo Section
                      GestureDetector(
                        onTap: _showImagePickerBottomSheet,
                        child: Stack(
                          children: [
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: ColorUtility.borderColor.withValues(
                                  alpha: 0.3,
                                ),
                                border: Border.all(
                                  color: ColorUtility.borderColor,
                                  width: 2,
                                ),
                              ),
                              child: _selectedImage != null
                                  ? ClipOval(
                                      child: Image.file(
                                        _selectedImage!,
                                        width: 120,
                                        height: 120,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Icon(
                                      Icons.person,
                                      size: 60,
                                      color: ColorUtility.secondaryText,
                                    ),
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: ColorUtility.primaryColor,
                                  border: Border.all(
                                    color: ColorUtility.whiteColor,
                                    width: 2,
                                  ),
                                ),
                                child: Icon(
                                  Icons.camera_alt,
                                  size: 18,
                                  color: ColorUtility.whiteColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Add Photo Text
                      Text(
                        TextUtility.addPhoto,
                        style: TextStyleUtility.actionText,
                      ),

                      const SizedBox(height: 48),

                      // Title
                      Text(
                        TextUtility.completeYourProfile,
                        style: TextStyleUtility.sectionTitle,
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 8),

                      // Subtitle
                      Text(
                        TextUtility.addPhotoAndNameSubtitle,
                        style: TextStyleUtility.subtitle,
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 48),

                      // User Name Field
                      CommonTextField(
                        controller: _usernameController,
                        labelText: TextUtility.userName,
                        hintText: TextUtility.enterYourFullName,
                        keyboardType: TextInputType.name,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _handleContinue(),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              // Bottom Buttons
              Padding(
                padding: const EdgeInsets.only(bottom: 32.0),
                child: Column(
                  children: [
                    // Continue Button
                    CommonElevatedButton(
                      text: TextUtility.continueText,
                      onPressed: _handleContinue,
                    ),

                    const SizedBox(height: 16),

                    // Skip Button
                    TextButton(
                      onPressed: _handleSkip,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: Text(
                        TextUtility.skip,
                        style: TextStyleUtility.buttonText.copyWith(
                          color: ColorUtility.secondaryText,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
