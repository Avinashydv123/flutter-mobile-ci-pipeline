# Hindus R Us - Environment Setup Guide

## 🏗️ Project Structure

### Firebase Configuration Files
```
lib/firebase/
├── firebase_options_dev.dart     # Development environment
├── firebase_options_qa.dart      # QA environment
├── firebase_options_stage.dart   # Staging environment
└── firebase_options_prod.dart    # Production environment
```

### Main Entry Points
```
lib/
├── main.dart           # Production entry point (default)
├── main_dev.dart       # Development entry point
├── main_qa.dart        # QA entry point
└── main_stage.dart     # Staging entry point
```

### Android Configuration
```
android/app/src/
├── dev/google-services.json      # Development Firebase config
├── qa/google-services.json       # QA Firebase config
├── stage/google-services.json    # Staging Firebase config
└── prod/google-services.json     # Production Firebase config
```

### iOS Configuration
```
ios/Firebase/
├── Dev/GoogleService-Info.plist     # Development Firebase config
├── QA/GoogleService-Info.plist      # QA Firebase config
├── Stage/GoogleService-Info.plist   # Staging Firebase config
└── Prod/GoogleService-Info.plist    # Production Firebase config
```

## 🚀 Environment Details

| Environment | Firebase Project | Package ID | App Name |
|-------------|------------------|------------|----------|
| **Development** | hindus-r-us-dev | com.hindusrus.app.dev | Hindus R Us Dev |
| **QA** | hindus-r-us-qa | com.hindusrus.app.qa | Hindus R Us QA |
| **Staging** | hindus-r-us-stage | com.hindusrus.app.stage | Hindus R Us Stage |
| **Production** | hindus-r-us | com.hindusrus.app | Hindus R Us |

## 🏃‍♂️ How to Run

### Development
```bash
flutter run --flavor dev -t lib/main_dev.dart
```

### QA
```bash
flutter run --flavor qa -t lib/main_qa.dart
```

### Staging
```bash
flutter run --flavor stage -t lib/main_stage.dart
```

### Production
```bash
flutter run --flavor prod -t lib/main.dart
# OR simply
flutter run --flavor prod
```

## 📱 How to Build APKs

### Using Build Scripts (Windows)
```bash
scripts/build_dev.bat     # Build development APK
scripts/build_qa.bat      # Build QA APK
scripts/build_stage.bat   # Build staging APK
scripts/build_prod.bat    # Build production APK
```

### Using Flutter Commands
```bash
flutter build apk --flavor dev -t lib/main_dev.dart
flutter build apk --flavor qa -t lib/main_qa.dart
flutter build apk --flavor stage -t lib/main_stage.dart
flutter build apk --flavor prod -t lib/main.dart
```

## 🔧 Configuration Management

The `AppConfig` class in `lib/config/app_config.dart` automatically manages:
- Environment detection
- App names
- Bundle IDs
- Firebase project IDs

## 📂 Key Features

1. **Separate Firebase Projects**: Each environment connects to its own Firebase project
2. **Unique Package IDs**: All environments can be installed simultaneously on the same device
3. **Environment-specific App Names**: Easy to identify which environment you're using
4. **Organized File Structure**: Clean separation of configuration files
5. **Build Scripts**: Quick build commands for each environment

## 🔍 Verification

To verify your setup is working correctly:

1. **Check Configuration Files**:
   ```bash
   # Verify Firebase configs exist
   ls lib/firebase/
   
   # Verify Android configs exist
   ls android/app/src/*/google-services.json
   
   # Verify iOS configs exist
   ls ios/Firebase/*/GoogleService-Info.plist
   ```

2. **Test Different Environments**:
   ```bash
   # Test development
   flutter run --flavor dev -t lib/main_dev.dart
   
   # Test production
   flutter run --flavor prod
   ```

## 📝 Notes

- **Production Default**: `main.dart` serves as the production entry point
- **No Redundancy**: We removed `main_prod.dart` to avoid confusion
- **Clean Organization**: Firebase options are organized in `lib/firebase/` directory
- **Environment Safety**: Each environment is completely isolated with its own Firebase project
- **Fixed Logic**: Environment-specific main files directly call `runApp(const MyApp())` instead of calling `main.dart` to avoid conflicts
- **Visual Indicators**: Environment banner shows which environment is running (hidden in production)

## 🚨 Important

- Never mix configuration files between environments
- Always use the correct flavor and target when building
- Each environment should have its own Firebase project for data isolation 