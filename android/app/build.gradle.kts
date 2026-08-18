import org.gradle.api.tasks.Copy

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val workEarnGeneratedRes = layout.buildDirectory.dir("generated/res/workearn/main")

val copyWorkEarnIcon by tasks.registering(Copy::class) {
    from(rootProject.file("../assets/branding/workearn_icon.png"))
    into(workEarnGeneratedRes.map { it.dir("drawable-nodpi") })
}

android {
    namespace = "com.example.apk_diary"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    sourceSets.getByName("main") {
        res.srcDir(workEarnGeneratedRes)
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.apk_diary"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

tasks.named("preBuild") {
    dependsOn(copyWorkEarnIcon)
}

flutter {
    source = "../.."
}
