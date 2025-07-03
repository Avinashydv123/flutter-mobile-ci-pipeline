import 'package:flutter/material.dart';
import '../../config/app_config.dart';

class EnvironmentBanner extends StatelessWidget {
  const EnvironmentBanner({super.key});

  @override
  Widget build(BuildContext context) {
    if (AppConfig.isProduction) {
      return const SizedBox.shrink(); // Don't show banner in production
    }

    Color bannerColor;
    switch (AppConfig.environment) {
      case Environment.development:
        bannerColor = Colors.green;
        break;
      case Environment.qa:
        bannerColor = Colors.orange;
        break;
      case Environment.staging:
        bannerColor = Colors.blue;
        break;
      case Environment.production:
        bannerColor = Colors.red;
        break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8.0),
      color: bannerColor,
      child: SafeArea(
        child: Text(
          '🚀 ${AppConfig.environmentName.toUpperCase()} ENVIRONMENT',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
