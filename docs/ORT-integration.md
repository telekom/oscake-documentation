# ORT-Module: OSCake

The OSCake-applications: Curator, Resolver, Selector, Deduplicator and Merger are implemented in the ORT-Module with the name "oscake" and done by the following steps:

1. Add a new module to the project (in IntelliJ via "Project Structure -> Project Settings -> Modules")
2. Add the file `build.gradle.kts` in the root folder of the module and put the dependencies inside
3. ORT-Module `model`: add property `val oscake: OSCakeConfiguration = OSCakeConfiguration()` at the end of the `data class OrtConfiguration` in the subfolder `config`.
4. ORT-Module `model`: add class `OSCakeConfiguration.kt` containing the config definitions for the oscake applications
5. ORT-Module `cli`:
	- OrtMain.kt: add `OSCakeCommand()` to the `subcommands`- list
	- add `OSCakeCommand.kt` in the subfolder `commands`; this kotlin file contains the logic for the different commandline options. The selection of a specific OSCake application is done via the ORT-option: `--app` or `-a` (also defined in this class file). The `run` method validates the set options and starts the selected application.
6. ORT-Module `oscake`: this module contains a kotlin class for every application (`OSCakeCurator.kt`, `OSCakeResolver.kt`, `OSCakeSelector.kt`,`OSCakeDeduplicator.kt`, `OSCakeMerger.kt`) and the class `OSCakeApplication.kt`, which contains properties and functions used by all of them. Furthermore, every application has its own subfolder where to put the application specific code inside.
7. Due to similar algorithms in `OSCakeCurator.kt`, `OSCakeResolver.kt` and `OSCakeSelector.kt` the common logic is implemented as different base classes, found in the subfolder `common`. 