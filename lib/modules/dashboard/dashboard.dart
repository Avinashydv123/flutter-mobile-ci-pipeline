import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../common/utilities/color_utility.dart';
import '../../common/utilities/hive_utility.dart';
import '../../common/utilities/text_style_utility.dart';
import '../../common/utilities/logger_utility.dart';
import '../../common/widgets/common_elevated_button.dart';
import '../../common/widgets/common_toast.dart';
import '../sign_in/sign_in.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  Map<String, dynamic>? _userProfile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    LoggerUtility.instance.logNavigation('DashboardPage - initState');
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final User? currentUser = _firebaseAuth.currentUser;
      if (currentUser != null) {
        LoggerUtility.instance.logInfo(
          'Loading profile for user: ${currentUser.uid}',
        );

        // Use consistent box access to prevent type conflicts
        final userDataBox = HiveUtility.instance.isBoxOpen('user_data')
            ? HiveUtility.instance.getBox('user_data')
            : await HiveUtility.instance.openBox('user_data');
        final profileData = userDataBox.get('profile_${currentUser.uid}');

        if (profileData != null) {
          LoggerUtility.instance.logInfo(
            'User profile loaded: ${profileData.toString()}',
          );
          setState(() {
            _userProfile = Map<String, dynamic>.from(profileData);
            _isLoading = false;
          });
        } else {
          LoggerUtility.instance.logWarning(
            'No profile data found for user: ${currentUser.uid}',
          );
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        LoggerUtility.instance.logError(
          'No authenticated user found in dashboard',
        );
        setState(() {
          _isLoading = false;
        });
      }
    } catch (error) {
      LoggerUtility.instance.logError('Failed to load user profile: $error');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleLogout() async {
    try {
      LoggerUtility.instance.logUserAction('Logout button pressed');

      final User? currentUser = _firebaseAuth.currentUser;

      // Clean up local Hive data first
      if (currentUser != null) {
        await HiveUtility.instance.cleanupUserData(currentUser.uid);
      }

      // Sign out from Google and Firebase
      await GoogleSignIn().disconnect(); // Ensures chooser will show next time
      await _firebaseAuth.signOut();

      LoggerUtility.instance.logAuth('User signed out successfully');

      // Navigate back to sign-in page
      if (mounted) {
        LoggerUtility.instance.logNavigation('SignInPage (logout)');
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const SignInPage()),
          (route) => false,
        );
        CommonToast.success(context, 'Logged out successfully');
      }
    } catch (error) {
      LoggerUtility.instance.logError('Logout error: $error');
      if (mounted) {
        CommonToast.error(context, 'Failed to logout. Please try again.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: ColorUtility.backgroundColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: ColorUtility.backgroundColor,
      appBar: AppBar(
        backgroundColor: ColorUtility.backgroundColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Dashboard',
          style: TextStyleUtility.welcomeTitle.copyWith(
            fontSize: 18,
            color: ColorUtility.primaryText,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _handleLogout,
            icon: Icon(Icons.logout, color: ColorUtility.primaryColor),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User profile section
              if (_userProfile != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: ColorUtility.whiteColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: ColorUtility.borderColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: ColorUtility.primaryColor,
                            child: Icon(
                              Icons.person,
                              size: 30,
                              color: ColorUtility.whiteColor,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _userProfile!['displayName'] ??
                                      _userProfile!['username'] ??
                                      'User',
                                  style: TextStyleUtility.welcomeTitle.copyWith(
                                    fontSize: 18,
                                    color: ColorUtility.primaryText,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _userProfile!['email'] ?? 'No email',
                                  style: TextStyleUtility.bodyText.copyWith(
                                    color: ColorUtility.secondaryText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Profile Status: ${_userProfile!['isProfileComplete'] == true ? 'Complete' : 'Incomplete'}',
                        style: TextStyleUtility.bodyText.copyWith(
                          color: _userProfile!['isProfileComplete'] == true
                              ? ColorUtility.successColor
                              : ColorUtility.warningColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Welcome section
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.dashboard,
                      size: 80,
                      color: ColorUtility.primaryColor,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Welcome to Hindus R Us!',
                      style: TextStyleUtility.welcomeTitle.copyWith(
                        color: ColorUtility.primaryText,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Your profile has been set up successfully. This is your main dashboard.',
                      style: TextStyleUtility.bodyText.copyWith(
                        color: ColorUtility.secondaryText,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 48),

              // Placeholder for future dashboard content
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: ColorUtility.whiteColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: ColorUtility.borderColor),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.construction,
                      size: 48,
                      color: ColorUtility.secondaryText,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Dashboard features coming soon!',
                      style: TextStyleUtility.bodyText.copyWith(
                        color: ColorUtility.secondaryText,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Logout button
              CommonElevatedButton(
                onPressed: _handleLogout,
                text: 'Logout',
                backgroundColor: ColorUtility.errorColor,
                foregroundColor: ColorUtility.whiteColor,
                leadingIcon: Icon(Icons.logout, color: ColorUtility.whiteColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
