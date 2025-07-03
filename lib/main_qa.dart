import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hindus_r_us/common/utilities/hive_utility.dart';
import 'package:hindus_r_us/common/utilities/logger_utility.dart';
import 'config/app_config.dart';
import 'firebase/firebase_options_qa.dart';
import 'modules/sign_in/sign_in.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set environment
  AppConfig.setEnvironment(Environment.qa);

  try {
    // Initialize Logger
    LoggerUtility.instance.logInfo('App starting in QA environment');

    // Initialize Hive database
    await HiveUtility.instance.initialize();
    await HiveUtility.instance.initializeCommonBoxes();
    LoggerUtility.instance.logInfo('Hive database initialized');

    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    LoggerUtility.instance.logInfo('Firebase initialized successfully');
  } catch (error) {
    // Log initialization errors but don't crash the app
    LoggerUtility.instance.logError('Initialization error: $error');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.appName,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const SignInPage(),
    );
  }
}
