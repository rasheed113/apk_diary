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
        // API 25 keeps the release compatible with Android 6 while allowing
        // legacy v1 signing. Newer target SDKs require v2+ signing and cannot
        // produce an Android-6-installable v1-only APK.
        targetSdk = 25
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
