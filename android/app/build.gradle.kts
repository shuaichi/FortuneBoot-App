import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// 加载 local.properties 文件
val localProperties = Properties().apply {
    val localPropertiesFile = rootProject.file("local.properties")
    if (localPropertiesFile.exists()) {
        load(FileInputStream(localPropertiesFile))
    }
}

val hasReleaseSigning =
    !localProperties.getProperty("sign.key.alias").isNullOrBlank() &&
        !localProperties.getProperty("sign.key.password").isNullOrBlank() &&
        !localProperties.getProperty("sign.store.file").isNullOrBlank() &&
        !localProperties.getProperty("sign.store.password").isNullOrBlank()

android {
    namespace = "com.fortuneboot.intelligent"
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
        applicationId = "com.fortuneboot.intelligent"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasReleaseSigning) {
            create("release") {
                keyAlias = localProperties.getProperty("sign.key.alias")
                keyPassword = localProperties.getProperty("sign.key.password")
                storeFile = file(localProperties.getProperty("sign.store.file")!!)
                storePassword = localProperties.getProperty("sign.store.password")
            }
        }
    }

    buildTypes {
        release {
            // 配置了签名则用正式签名，否则回退 debug，便于本机直接打 APK
            signingConfig =
                if (hasReleaseSigning) {
                    signingConfigs.getByName("release")
                } else {
                    signingConfigs.getByName("debug")
                }
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("androidx.biometric:biometric:1.1.0")
}
