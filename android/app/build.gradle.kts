import java.io.File

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.apk_diary"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.apk_diary"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            val keystoreFile = rootProject.file("workearn-release.jks")
            if (!keystoreFile.exists()) {
                throw GradleException("Missing WorkEarn release keystore. Configure the GitHub Actions signing secrets before building a release APK.")
            }
            storeFile = keystoreFile
            storePassword = System.getenv("WORKEARN_KEYSTORE_PASSWORD")
                ?: throw GradleException("Missing WORKEARN_KEYSTORE_PASSWORD")
            keyAlias = System.getenv("WORKEARN_KEY_ALIAS")
                ?: throw GradleException("Missing WORKEARN_KEY_ALIAS")
            keyPassword = System.getenv("WORKEARN_KEY_PASSWORD")
                ?: throw GradleException("Missing WORKEARN_KEY_PASSWORD")
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}
