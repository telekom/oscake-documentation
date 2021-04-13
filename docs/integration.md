# Steps to integrate the "OSCakeReporter" into a new master branch

1. Make a new branch "newBranch" out of "master"
2. Checkout "newBranch"
3. Adapt the code
    1. Go to source folder "ort/reporter/src/main/kotlin/reporters"
	2. Copy OSCakeReporter.kt into the folder
	3. Create a subdirectory "osCakeReporterModel" in the folder
	4. Copy the files into the subirectory
	5. Go to source folder "ort/reporter" and edit "build.gradle.kts"
		1. Add `val hopliteVersion: String by project` at the top
		2. Add the following lines to the `dependencies` section
		
			*implementation("com.sksamuel.hoplite:hoplite-core:$hopliteVersion")*
			
			*implementation("com.sksamuel.hoplite:hoplite-hocon:$hopliteVersion")*
	6. Go to source folder "ort/reporter/src/main/resources/META-INF/services" and append the following line to the file "org.ossreviewtoolkit.reporter.Reporter"
	
		*org.ossreviewtoolkit.reporter.reporters.OSCakeReporter*

	7. Apply Quick-Fixes as described [here](./ort-quick-fixes.md)
4. Execute gradle task "instDist" from command line or IntelliJ: Task/distribution/instDist
5. Hope for the best :)
