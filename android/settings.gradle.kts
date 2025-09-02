// android/settings.gradle.kts

pluginManagement {
    // Load Flutter SDK path from local.properties (or FLUTTER_SDK env var)
    val props = java.util.Properties()
    val lp = file("local.properties")
    if (lp.exists()) lp.inputStream().use { props.load(it) }
    val flutterSdkPath = props.getProperty("flutter.sdk")
        ?: System.getenv("FLUTTER_SDK")
        ?: error("Flutter SDK not found. Set flutter.sdk in android/local.properties or FLUTTER_SDK env var.")

    // Let Flutter inject its Gradle tooling
    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.7.0" apply false
    id("org.jetbrains.kotlin.android") version "1.9.24" apply false
}

dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.PREFER_SETTINGS)
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.name = "personalised_learning_app"
include(":app")
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.PREFER_SETTINGS)
    repositories {
        google()
        mavenCentral()
        maven(url = "https://storage.googleapis.com/download.flutter.io") // <-- add this
    }
}
