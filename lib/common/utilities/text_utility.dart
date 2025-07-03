class TextUtility {
  // Private constructor
  TextUtility._();

  // Singleton instance
  static final TextUtility _instance = TextUtility._();

  // Getter to access the singleton instance
  static TextUtility get instance => _instance;

  // Sign-in Page Strings
  static const String welcomeTitle = 'Welcome to Hindus R Us';
  static const String signInSubtitle = 'Sign in to continue';
  static const String continueWithGoogle = 'Continue with Google';
  static const String continueWithApple = 'Continue with Apple';
  static const String termsAgreement = 'By continuing, you agree to our\n';
  static const String termsOfService = 'Terms of Service';
  static const String privacyPolicy = 'Privacy Policy';
  static const String termsConnector = ' & ';

  // Error Messages
  static const String signInFailed = 'Sign-in failed';
  static const String googleSignInNotSupported =
      'Google Sign-In not supported on this platform';
  static const String googleSignInSuccessful = 'Google Sign-In successful';
  static const String appleSignInSuccessful = 'Apple Sign-In successful';

  // General App Strings
  static const String appName = 'Hindus R Us';

  // Button Labels
  static const String signIn = 'Sign In';
  static const String signOut = 'Sign Out';
  static const String continueText = 'Continue';
  static const String ok = 'OK';
  static const String cancel = 'Cancel';
  static const String confirm = 'Confirm';
  static const String retry = 'Retry';
  static const String tryAgain = 'Try Again';

  // Empty State Messages
  static const String noDataTitle = 'No Data Available';
  static const String noDataSubtitle = 'There\'s nothing to show here yet.';
  static const String noResultsTitle = 'No Results Found';
  static const String noResultsSubtitle =
      'Try adjusting your search or filters.';
  static const String noConnectionTitle = 'No Connection';
  static const String noConnectionSubtitle =
      'Please check your internet connection and try again.';
  static const String errorTitle = 'Something Went Wrong';
  static const String errorSubtitle =
      'We encountered an error. Please try again.';
  static const String errorStateTitle = 'Oops! Something went wrong';
  static const String errorStateSubtitle =
      'We encountered an unexpected error. Please try again.';

  // Loading Messages
  static const String pleaseWait = 'Please wait...';
  static const String loading = 'Loading...';

  // Profile Creation Strings
  static const String createProfile = 'Create Profile';
  static const String addPhoto = 'Add Photo';
  static const String completeYourProfile = 'Complete Your Profile';
  static const String addPhotoAndNameSubtitle =
      'Add a photo and name to personalise your account';
  static const String userName = 'User Name';
  static const String skip = 'Skip';
  static const String enterYourFullName = 'Enter your full name';
  static const String camera = 'Camera';
  static const String gallery = 'Gallery';
  static const String removePhoto = 'Remove Photo';

  // Toast Messages
  static const String photoSelectedSuccessfully =
      'Photo selected successfully!';
  static const String photoRemoved = 'Photo removed';
  static const String pleaseEnterYourName = 'Please enter your name';
  static const String profileCreatedSuccessfully =
      'Profile created successfully!';
  static const String failedToSaveProfile =
      'Failed to save profile. Please try again.';
  static const String profileCreationSkipped = 'Profile creation skipped';
}
