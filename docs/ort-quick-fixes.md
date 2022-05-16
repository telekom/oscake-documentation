# Branch: "oscake-reporter"
### Version of May 22
The gradle task "installDist" may lead to errors on Windows systems for the reporter-web-app. Remove  the module in build.gradle.kts (reporter + reporter-web-app)

# Branch: "oscake-reporter"
since October 2021 - only necessary when creating a new fork or when merging with an incompatible ORT version!

since March 2021

### Windows - Path-Compatibility
* Windows - Path-Compatibility
When unarchiving the files in class [*LicenseInfoResolver*](https://github.com/telekom/ort/blob/oscake-reporter/model/src/main/kotlin/licenses/LicenseInfoResolver.kt#L226) on Windows-based systems correctly, the backslash has to be changed to slash (otherwise the glob pattern-matching won't work)

### ./gradlew installDist
* This gradle task leads to an error, because the version of the ` sw360ClientVersion` library is set to a value, which is not downloadable anymore. In order to change the version, go to the file `gradle.properties` and set the value for the key `sw360ClientVersion` to `13.1.0-64`. 

# Branch: "oscake-reporter"
till end of February 2021

## Quick Fixes in "Scanner" module
### 1. Archiving Files
Files matching the pattern list in [ort.conf](./examples/versionMay2022/ort.conf) (`scanner.archive.patterns`) are stored in the `scanner.storage.localFileStorage.directory` which is also configured in ort.conf. The sub-path of the file depends on the IDs of the project or packages: e.g.: `./Maven/de.tdosca.tc05/tdosca-tc05/1.0/[hash code]/archive.zip`

The hash code is built upon the [*Provenance*](https://github.com/telekom/ort/blob/oscake-reporter/model/src/main/kotlin/Provenance.kt) of the package (e.g. [vcsInfo](https://github.com/telekom/ort/blob/oscake-reporter/model/src/main/kotlin/VcsInfo.kt), originalVcsInfo...) and is calculated in the class [*LocalScanner.kt*](https://github.com/telekom/ort/blob/oscake-reporter/scanner/src/main/kotlin/LocalScanner.kt#L428) before saving the files. At runtime the path information (stored in properties [vcsInfo](https://github.com/telekom/ort/blob/oscake-reporter/model/src/main/kotlin/VcsInfo.kt) and originalVcsInfo) is not set yet and therefore, when unarchiving the files in class [*LicenseInfoResolver*](https://github.com/telekom/ort/blob/oscake-reporter/model/src/main/kotlin/licenses/LicenseInfoResolver.kt#L213), the hash code is different and the files won't be identified.

This issue was fixed by implementing the function `quickFixProvenance` in class [*LicenseInfoResolver*](https://github.com/telekom/ort/blob/oscake-reporter/model/src/main/kotlin/licenses/LicenseInfoResolver.kt#L257):

```private fun quickFixProvenance(p: Provenance): Provenance```

The method copies the original properties of the instance of the class provenance and sets the path to an empty string and by changing the function in LocalScanner.kt to

```
private fun archiveFiles(directory: File, id: Identifier, provenance: Provenance) {
        log.info { "Archiving files for ${id.toCoordinates()}." }
        val path = "${id.toPath()}/${provenance.hash()}"
        val duration = measureTime { archiver.archive(directory, path) }
        log.perf { "Archived files for '${id.toCoordinates()}' in ${duration.inMilliseconds}ms." }
    }
```

### 2. Unarchiving Files
When unarchiving the stored files in [*LicenseInfoResolver*](https://github.com/telekom/ort/blob/oscake-reporter/model/src/main/kotlin/licenses/LicenseInfoResolver.kt#L254), the file names are matched against the pattern list in ort.conf using the class [*FileMatcher*](https://github.com/telekom/ort/blob/oscake-reporter/utils/src/main/kotlin/FileMatcher.kt). This class implements the function [*matches*](https://github.com/telekom/ort/blob/oscake-reporter/utils/src/main/kotlin/FileMatcher.kt#L50) which only works with "/" as path separators - this leads to non-matching files on Windows systems. A quick fix was implemented in [line #254](https://github.com/telekom/ort/blob/oscake-reporter/model/src/main/kotlin/licenses/LicenseInfoResolver.kt#L254) replacing backslashes with slashes.

