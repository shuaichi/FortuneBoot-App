pluginManagement {
    val flutterSdkPath = run {
        val properties = java.util.Properties()
        file("local.properties").inputStream().use { properties.load(it) }
        val flutterSdkPath = properties.getProperty("flutter.sdk")
        require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
        flutterSdkPath
    }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        // 本地已手动下载的依赖（如 kotlin-compiler-embeddable）
        mavenLocal()
        // 仅用国内镜像，避免连接 google()/mavenCentral() 超时
        maven { url = uri("https://maven.aliyun.com/repository/google") }
        maven { url = uri("https://maven.aliyun.com/repository/central") }
        maven { url = uri("https://maven.aliyun.com/repository/gradle-plugin") }
        maven { url = uri("https://maven.aliyun.com/repository/public") }
        maven { url = uri("https://mirrors.cloud.tencent.com/nexus/repository/maven-public/") }
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    // Flutter 3.47 最低要求 AGP 8.11.1
    id("com.android.application") version "8.11.1" apply false
    // 与手动下载的 kotlin-compiler-embeddable-2.2.20.jar 对齐
    id("org.jetbrains.kotlin.android") version "2.2.20" apply false
}

include(":app")
