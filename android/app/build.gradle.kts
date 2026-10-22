import org.jetbrains.kotlin.gradle.dsl.JvmTarget

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val opcReleaseKeystore = System.getenv("OPC_ANDROID_RELEASE_KEYSTORE")
val opcReleasePassword = System.getenv("OPC_ANDROID_RELEASE_PASSWORD")
val opcReleaseAlias = System.getenv("OPC_ANDROID_RELEASE_ALIAS")
val opcReleaseSigningReady = !opcReleaseKeystore.isNullOrBlank() &&
    !opcReleasePassword.isNullOrBlank() && !opcReleaseAlias.isNullOrBlank()
val opcReleaseTaskRequested = gradle.startParameter.taskNames.any {
    it.contains("Release", ignoreCase = true)
}

if (opcReleaseTaskRequested && !opcReleaseSigningReady) {
    throw GradleException("OPC release signing environment is required; refusing unsigned or debug-signed release build")
}

android {
    namespace = "com.tale.opc_v4"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.tale.opc_v4"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
    }

    // Keep the production package identity as the default, while providing an
    // explicitly co-installable Android structural-test lane. The Dart lane
    // is selected separately with BUILD_VARIANT=ANDROID_TEST; both flags are
    // required together for a test build.
    flavorDimensions += "opcLane"
    productFlavors {
        create("production") {
            dimension = "opcLane"
            applicationId = "com.tale.opc_v4"
        }
        create("opcTest") {
            dimension = "opcLane"
            applicationIdSuffix = ".androidtest"
        }
    }

    signingConfigs {
        if (opcReleaseSigningReady) {
            create("opcRelease") {
                storeFile = file(opcReleaseKeystore!!)
                storePassword = opcReleasePassword
                keyAlias = opcReleaseAlias
                keyPassword = opcReleasePassword
            }
        }
    }

    buildTypes {
        release {
            if (opcReleaseSigningReady) {
                signingConfig = signingConfigs.getByName("opcRelease")
            }
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget.set(JvmTarget.JVM_17)
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

flutter {
    source = "../.."
}
