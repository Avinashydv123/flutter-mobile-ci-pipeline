import 'dart:io' show Platform;
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../common/utilities/color_utility.dart';
import '../../common/utilities/internet_utility.dart';
import '../../common/utilities/logger_utility.dart';
import '../../common/utilities/svg_utility.dart';
import '../../common/utilities/text_style_utility.dart';
import '../../common/utilities/text_utility.dart';
import '../../common/widgets/common_elevated_button.dart';
import '../../common/widgets/common_toast.dart';
import '../../common/utilities/hive_utility.dart';
import '../profile/user_profile.dart';
import '../dashboard/dashboard.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  // Initialize Firebase Auth
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Initialize Google Sign-In with serverClientId (v6.x stable approach)
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId:
        '103450706778-grrekbdo5q1i55hchf3uo77ma0oqtser.apps.googleusercontent.com',
    scopes: ['email', 'profile'],
  );

  @override
  void initState() {
    super.initState();
    LoggerUtility.instance.logNavigation('SignInPage - initState');
    _initializeGoogleSignIn();
  }

  /// Handle potential recovery from sign-in errors
  Future<void> _handleSignInRecovery() async {
    try {
      LoggerUtility.instance.logInfo('Attempting sign-in recovery...');
      await _googleSignIn.disconnect();
      await Future.delayed(const Duration(milliseconds: 500));
      LoggerUtility.instance.logInfo('Sign-in recovery completed');
    } catch (e) {
      LoggerUtility.instance.logWarning('Sign-in recovery failed: $e');
    }
  }

  /// Initialize Google Sign-In (v6.x stable approach)
  Future<void> _initializeGoogleSignIn() async {
    try {
      LoggerUtility.instance.logInfo('Initializing Google Sign-In...');
      // Pre-initialize Google Sign-In to avoid channel errors
      // Use a timeout to prevent blocking
      await _googleSignIn.signInSilently().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          LoggerUtility.instance.logInfo(
            'Google Sign-In silent timeout - continuing',
          );
          return null;
        },
      );
      LoggerUtility.instance.logInfo('Google Sign-In initialization completed');
    } catch (e) {
      LoggerUtility.instance.logWarning(
        'Google Sign-In silent sign-in failed: $e',
      );
      // This is expected if user hasn't signed in before
    }
  }

  /// Check if user profile exists in local Hive storage
  Future<bool> _isExistingUser(String uid) async {
    try {
      final exists = await HiveUtility.instance.hasUserData(uid);
      LoggerUtility.instance.logInfo(
        'User profile check for UID $uid: ${exists ? 'exists' : 'new user'}',
      );
      return exists;
    } catch (error) {
      LoggerUtility.instance.logError(
        'Failed to check user profile existence: $error',
      );
      return false; // Treat as new user if check fails
    }
  }

  /// Navigate user based on profile existence
  Future<void> _navigateUserBasedOnProfile(User user) async {
    try {
      final bool isExisting = await _isExistingUser(user.uid);
      if (mounted) {
        if (isExisting) {
          LoggerUtility.instance.logNavigation('DashboardPage (existing user)');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const DashboardPage()),
          );
          CommonToast.success(context, 'Welcome back!');
        } else {
          LoggerUtility.instance.logNavigation('UserProfilePage (new user)');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  UserProfilePage(initialName: user.displayName),
            ),
          );
          CommonToast.success(
            context,
            'Welcome! Please complete your profile.',
          );
        }
      }
    } catch (error) {
      LoggerUtility.instance.logError('Navigation error: $error');
      if (mounted) {
        CommonToast.error(context, 'Navigation failed. Please try again.');
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    // Check internet connectivity first
    final bool isConnected = await InternetUtility.isInternetAvailable();
    if (!isConnected) {
      LoggerUtility.instance.logWarning(
        'Google Sign-In attempted without internet connection',
      );
      if (mounted) {
        CommonToast.warning(context, 'Please check your internet connection');
      }
      return;
    }

    try {
      LoggerUtility.instance.logAuth('Google Sign-In attempt started');

      // Use the stable signIn() method instead of authenticate()
      final GoogleSignInAccount? account = await _googleSignIn.signIn();

      if (account == null) {
        LoggerUtility.instance.logWarning('Google Sign-In cancelled by user');
        if (mounted) {
          CommonToast.info(context, 'Sign-in cancelled');
        }
        return;
      }

      LoggerUtility.instance.logAuth(
        'Google Sign-In successful: ${account.email}',
      );

      // Get authentication details for Firebase
      final GoogleSignInAuthentication googleAuth =
          await account.authentication;

      // Log the bearer token (access token)
      LoggerUtility.instance.logAuth(
        'Google Sign-In Bearer Token: ${googleAuth.accessToken}',
      );

      // Create Firebase credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      LoggerUtility.instance.logAuth('Google Sign-In credential: $credential');

      // Sign in to Firebase with the Google credential
      final UserCredential userCredential = await _firebaseAuth
          .signInWithCredential(credential);
      final User? user = userCredential.user;

      // Get the Firebase ID token
      final idToken = await userCredential.user?.getIdToken();
      LoggerUtility.instance.logAuth(
        'Use this ID token in Bearer Header: $idToken',
      );

      if (user != null) {
        LoggerUtility.instance.logAuth(
          'Firebase authentication successful: ${user.email} (UID: ${user.uid})',
        );
        await _navigateUserBasedOnProfile(user);
      }
    } catch (error) {
      LoggerUtility.instance.logError('Google Sign-In error: $error');
      if (error.toString().contains('channel-error')) {
        LoggerUtility.instance.logError('Channel communication error detected');
        if (mounted) {
          CommonToast.error(
            context,
            'Google Sign-In service unavailable. Please try again later.',
          );
        }
      } else if (error.toString().contains('PigeonUserDetails')) {
        LoggerUtility.instance.logWarning(
          'Google Sign-In plugin internal error - continuing with authentication',
        );
        return;
      } else if (error.toString().contains('type') &&
          error.toString().contains('subtype')) {
        LoggerUtility.instance.logError('Type casting error in Google Sign-In');
        await _handleSignInRecovery();
        if (mounted) {
          CommonToast.error(
            context,
            'Sign-in service error. Please restart the app and try again.',
          );
        }
      } else {
        if (mounted) {
          CommonToast.error(context, 'Sign-in failed. Please try again.');
        }
      }
    }
  }

  Future<void> _handleAppleSignIn() async {
    // Check internet connectivity first
    final bool isConnected = await InternetUtility.isInternetAvailable();
    if (!isConnected) {
      LoggerUtility.instance.logWarning(
        'Apple Sign-In attempted without internet connection',
      );
      if (mounted) {
        CommonToast.warning(context, 'Please check your internet connection');
      }
      return;
    }

    try {
      LoggerUtility.instance.logAuth('Apple Sign-In attempt started');

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      LoggerUtility.instance.logAuth(
        'Apple Sign-In successful: ${appleCredential.email}',
      );

      // Create Firebase credential
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      // Sign in to Firebase with the Apple credential
      final UserCredential userCredential = await _firebaseAuth
          .signInWithCredential(oauthCredential);
      final User? user = userCredential.user;

      if (user != null) {
        LoggerUtility.instance.logAuth(
          'Firebase authentication successful: ${user.email} (UID: ${user.uid})',
        );

        // Get user's full name from Apple credential or Firebase user
        String? userName = user.displayName;
        if (userName == null &&
            appleCredential.givenName != null &&
            appleCredential.familyName != null) {
          userName =
              '${appleCredential.givenName} ${appleCredential.familyName}';
        } else if (userName == null && appleCredential.givenName != null) {
          userName = appleCredential.givenName;
        }

        // Update user display name if we got a name from Apple
        if (userName != null && userName != user.displayName) {
          await user.updateDisplayName(userName);
        }

        // Navigate based on user profile existence
        await _navigateUserBasedOnProfile(user);
      }
    } catch (error) {
      LoggerUtility.instance.logError('Apple Sign-In error: $error');
      // Handle error
      if (mounted) {
        CommonToast.error(context, 'Sign-in failed: $error');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorUtility.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 42),

              // Logo
              const SvgImage(
                icon: 'assets/images/sign_in_page_logo.svg',
                iconSize: Size(160, 160),
              ),

              const SizedBox(height: 32),

              // Welcome text
              const Text(
                TextUtility.welcomeTitle,
                style: TextStyleUtility.welcomeTitle,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 3),

              // Subtitle
              const Text(
                TextUtility.signInSubtitle,
                style: TextStyleUtility.subtitle,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 62),
              // Google Sign In Button - Primary style
              CommonElevatedButton(
                text: TextUtility.continueWithGoogle,
                onPressed: _handleGoogleSignIn,
                backgroundColor: ColorUtility.buttonBackground,
                foregroundColor: ColorUtility.primaryButtonForeground,
                borderColor: ColorUtility.borderColor,
                textStyle: TextStyleUtility.buttonText.copyWith(
                  color: ColorUtility.primaryText,
                ),
                leadingIcon: const SvgImage(
                  icon: 'assets/logos/google_logo.svg',
                  iconSize: Size(30, 30),
                ),
              ),

              const SizedBox(height: 16),

              // Apple Sign In Button - Only show on iOS/macOS or show custom button on other platforms
              if (Platform.isIOS || Platform.isMacOS)
                SignInWithAppleButton(
                  onPressed: _handleAppleSignIn,
                  style: SignInWithAppleButtonStyle.white,
                  borderRadius: BorderRadius.circular(26),
                  height: 52,
                )
              else
                CommonElevatedButton(
                  text: TextUtility.continueWithApple,
                  onPressed: _handleAppleSignIn,
                  leadingIcon: const SvgImage(
                    icon: 'assets/logos/apple_logo.svg',
                    iconSize: Size(30, 30),
                  ),
                ),

              const SizedBox(height: 62),

              // Terms and Privacy Policy
              Padding(
                padding: const EdgeInsets.only(bottom: 32.0),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: TextStyleUtility.bodyText,
                    children: [
                      const TextSpan(text: TextUtility.termsAgreement),
                      TextSpan(
                        text: TextUtility.termsOfService,
                        style: TextStyleUtility.linkText,
                      ),
                      const TextSpan(text: TextUtility.termsConnector),
                      TextSpan(
                        text: TextUtility.privacyPolicy,
                        style: TextStyleUtility.linkText,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
