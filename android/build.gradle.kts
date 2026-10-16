allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

gradle.beforeProject {
    val buildGradle = file("build.gradle")
    if (buildGradle.exists()) {
        val text = buildGradle.readText()
        if (text.contains("proguard-android.txt")) {
            buildGradle.writeText(text.replace("proguard-android.txt", "proguard-android-optimize.txt"))
        }
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
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
