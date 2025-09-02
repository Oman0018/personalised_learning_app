// android/build.gradle.kts

buildscript {
    repositories {
        google()
        mavenCentral()
        maven(url = "https://storage.googleapis.com/download.flutter.io") // <-- Flutter engine repo
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
        maven(url = "https://storage.googleapis.com/download.flutter.io") // <-- Flutter engine repo
        // If Flutter builds a local repo for host artifacts:
        maven(url = uri("$rootDir/../build/host/outputs/repo"))
    }
}

// Provide SDK versions for legacy plugin build.gradle files
ext["compileSdkVersion"] = 35
ext["targetSdkVersion"] = 35
ext["minSdkVersion"] = 21

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
