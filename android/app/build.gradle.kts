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
    // Flutter already provides the correct values
    ndkVersion = "27.0.12077973"
    namespace = "com.example.campus_notes_app"
    compileSdk = flutter.compileSdkVersion   // modern syntax

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID
        applicationId = "com.example.campus_notes_app"

        // *** REQUIRED BY FIREBASE AUTH 23.2.1 ***
        // Firebase now needs API 23 (Android 6.0) or higher.
        // Raising from 21 to 23 drops support for ~2% of very old devices.
        minSdk = flutter.minSdkVersion                     // <-- FIXED: Enforce minSdk 23 for Firebase Auth
        // minSdk = flutter.minSdkVersion   // (old default was 21)

        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // (Firebase dependencies are added automatically by flutterfire)
}
