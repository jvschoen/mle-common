import jetbrains.buildServer.configs.kotlin.v2019_2.*
import jetbrains.buildServer.configs.kotlin.v2019_2.buildSteps.script
import jetbrains.buildServer.configs.kotlin.v2019_2.triggers.vcs

version = "2023.1"

project {
    buildType {
        id("MyPythonBuild")
        name = "My Python Build"

        vcs {
            root(DslContext.settingsRoot)
        }

        steps {
            // Install from requirements.txt
            script {
                name = "Install dependencies"
                scriptContent = """
                    pip install -r requirements.txt
                """.trimIndent()
            }
            // Run Linter
            script {
                name = "Lint with pylint"
                scriptContent = """
                    make lint
                """.trimIndent()
            }
            // Build the Wheel
            script {
                name = "Build Python Wheel"
                scriptContent = """
                    make whl
                """.trimIndent()
            }
            // Run Pytest
            script {
                name = "Run tests"
                scriptContent = """
                    make test
                """.trimIndent()
            }
        }

        /*
         Trigger when commits pushed to release-* branch
         or release-* tag is pushed
        */
        triggers {
            vcs {
                branchFilter = """
                    +:refs/heads/release-*
                    +:refs/tags/release-*
                """.trimIndent()
            }
        }
    }
}