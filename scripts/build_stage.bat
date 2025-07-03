@echo off
echo Building Hindus R Us - Staging Environment
flutter build apk --flavor stage -t lib/main_stage.dart
echo Staging build completed! 