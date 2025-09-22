// android/app/build.gradle.kts
plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

import java.util.Properties

// Read optional overrides from local.properties (e.g., flutter.ndkVersion)
val localProps = Properties().apply {
    val f = rootProject.file("local.properties")
    if (f.exists()) f.inputStream().use { load(it) }
}

android {
    namespace = "com.example.personalised_learning_app"

    // Use values provided by Flutter/local.properties
    compileSdk = flutter.compileSdkVersion

    defaultConfig {
        applicationId = "com.example.personalised_learning_app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // Set NDK version if specified in local.properties (flutter.ndkVersion)
    localProps.getProperty("flutter.ndkVersion")?.let { ndkVersion = it }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }
    kotlinOptions { jvmTarget = JavaVersion.VERSION_11.toString() }

    buildTypes {
        release {
            // TODO: replace with your real signing config before releasing
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
