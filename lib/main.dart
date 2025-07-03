import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'config/app_config.dart';
import 'firebase/firebase_options_prod.dart';
import 'common/utilities/logger_utility.dart';
import 'common/utilities/hive_utility.dart';
import 'modules/sign_in/sign_in.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set environment to production
  AppConfig.setEnvironment(Environment.production);

  try {
    // Initialize Logger
    LoggerUtility.instance.logInfo('App starting in production environment');

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

  // This widget is the root of your application.
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
