import java.io.File

plugins {
    id("com.android.application")
    id("kotlin-android")
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
        // Android 6.0 / API 23 is the compatibility floor.
        minSdk = 23
        // Keep the target SDK modern enough for current Android/Flutter lint.
        // minSdk remains API 23, so Android 6 compatibility is preserved.
        targetSdk = 33
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
            val signingPassword = System.getenv("WORKEARN_KEYSTORE_PASSWORD")
                ?: throw GradleException("Missing WORKEARN_KEYSTORE_PASSWORD")
            storePassword = signingPassword
            keyAlias = "workearn"
            keyPassword = signingPassword

            // Keep both schemes. Android 6 uses v1; newer Android uses v2.
            enableV1Signing = true
            enableV2Signing = true
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
