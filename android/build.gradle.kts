buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("commons-lang:commons-lang:2.6")
    }
}
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
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
subprojects {
    afterEvaluate { project ->
        if (project.name == "flutter") {
            project.dependencies {
                add("implementation", "org.codehaus.groovy:groovy:3.0.13")
            }
        }
    }
}