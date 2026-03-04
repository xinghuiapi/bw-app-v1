pluginManagement {
    val flutterSdkPath =
        run {
            val properties = java.util.Properties()
            file("local.properties").inputStream().use { properties.load(it) }
            val sdkPath = properties.getProperty("flutter.sdk")
            if (sdkPath != null && file(sdkPath).exists()) {
                return@run sdkPath
            }

            // Fallback for when local.properties fails to read correctly due to encoding
            val fallbackPath = file("../flutter_sdk").absolutePath
            if (file(fallbackPath).exists()) {
                return@run fallbackPath
            }
            
            throw GradleException("flutter.sdk not found. Checked local.properties and '../flutter_sdk'.")
        }

    // Hardcoded relative path to avoid encoding issues with Chinese characters in absolute path
    includeBuild("../flutter_sdk/packages/flutter_tools/gradle")

    repositories {
        maven { url = uri("https://maven.aliyun.com/repository/google") }
        maven { url = uri("https://maven.aliyun.com/repository/public") }
        maven { url = uri("https://maven.aliyun.com/repository/gradle-plugin") }
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.11.1" apply false
    id("org.jetbrains.kotlin.android") version "2.2.20" apply false
}

include(":app")
