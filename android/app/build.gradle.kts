plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.presensigps"
    compileSdk = flutter.compileSdkVersion
    
    // 1. TAMBAHKAN BARIS INI UNTUK PACKAGE ANTI-ROOT:
    ndkVersion = "29.0.14033849" 

    // --- TAMBAHKAN 2 BLOK INI UNTUK MENYAMAKAN VERSI JAVA & KOTLIN ---
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }
    // ----------------------------------------------------------------

    defaultConfig {
        applicationId = "com.example.presensigps"
        minSdk = 24
        targetSdk = flutter.targetSdkVersion

        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}