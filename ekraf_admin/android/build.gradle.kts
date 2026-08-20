allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    // Only redirect :app build dir so Flutter can find the APK
    // Do NOT redirect plugin subprojects — they live in pub cache on C:\
    // and Kotlin compiler can't create relative paths across different drives
    if (project.name == "app") {
        val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
        project.layout.buildDirectory.value(newSubprojectBuildDir)
    }

    // Only call evaluationDependsOn for non-app subprojects — calling it
    // on :app itself causes "project already evaluated" when afterEvaluate runs.
    if (project.name != "app") {
        project.evaluationDependsOn(":app")
    }

    // Force compileSdkVersion=36 and NDK on ALL Android subprojects (app + plugins).
    // If the project is already evaluated (e.g. :app, due to dependency ordering),
    // we configure it immediately to avoid "Project already evaluated" errors.
    if (state.executed) {
        val androidExt = extensions.findByName("android")
        if (androidExt is com.android.build.gradle.BaseExtension) {
            androidExt.compileSdkVersion(36)
            androidExt.ndkVersion = "28.2.13676358"
        }
    } else {
        afterEvaluate {
            val androidExt = extensions.findByName("android")
            if (androidExt is com.android.build.gradle.BaseExtension) {
                androidExt.compileSdkVersion(36)
                androidExt.ndkVersion = "28.2.13676358"
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
