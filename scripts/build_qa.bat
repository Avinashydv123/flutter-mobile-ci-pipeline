@echo off
echo Building Hindus R Us - QA Environment
flutter build apk --flavor qa -t lib/main_qa.dart
echo QA build completed! 