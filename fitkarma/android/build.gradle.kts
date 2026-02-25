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

subprojects {
    val p = this
    val setupNamespace = { proj: Project ->
        proj.extensions.findByName("android")?.let { android ->
            val methods = android.javaClass.methods
            val getNamespace = methods.find { it.name == "getNamespace" }
            val setNamespace = methods.find { it.name == "setNamespace" && it.parameterCount == 1 }
            if (getNamespace != null && setNamespace != null && getNamespace.invoke(android) == null) {
                setNamespace.invoke(android, "com.fitkarma.${proj.name.replace("-", ".")}")
            }
        }
    }
    
    if (p.state.executed) {
        setupNamespace(p)
    } else {
        p.afterEvaluate { setupNamespace(this) }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
