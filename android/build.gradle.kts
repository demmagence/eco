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
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
    val configureAction = Action<Project> {
        if (plugins.hasPlugin("com.android.library") || plugins.hasPlugin("com.android.application")) {
            val android = extensions.findByName("android") as? com.android.build.gradle.BaseExtension
            if (android != null) {
                android.compileSdkVersion(36)
            }
        }
    }
    if (state.executed) {
        configureAction.execute(project)
    } else {
        afterEvaluate(configureAction)
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
