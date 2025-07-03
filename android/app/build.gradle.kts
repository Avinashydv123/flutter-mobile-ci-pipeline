plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.hindusrus.app"
    compileSdk = 35
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.hindusrus.app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 23
        targetSdk = 34
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    flavorDimensions += "environment"
    
    productFlavors {
        create("dev") {
            dimension = "environment"
            applicationId = "com.hindusrus.app.dev"
            versionNameSuffix = "-dev"
            resValue("string", "app_name", "Hindus R Us Dev")
        }
        
        create("qa") {
            dimension = "environment"
            applicationId = "com.hindusrus.app.qa"
            versionNameSuffix = "-qa"
            resValue("string", "app_name", "Hindus R Us QA")
        }
        
        create("stage") {
            dimension = "environment"
            applicationId = "com.hindusrus.app.stage"
            versionNameSuffix = "-stage"
            resValue("string", "app_name", "Hindus R Us Stage")
        }
        
        create("prod") {
            dimension = "environment"
            applicationId = "com.hindusrus.app"
            resValue("string", "app_name", "Hindus R Us")
        }
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
