## Quick Fixes in "Scanner" module
### 1. Archiving Files
Files matching the pattern list in [ort.conf](https://github.com/telekom/ort-dsl-documentation/blob/main/docs/examples/ort.conf) (`scanner.archive.patterns`) are stored in the `scanner.storage.localFileStorage.directory` which is also configured in ort.conf. The sub-path of the file depends on the IDs of the project or packages: e.g.: `./Maven/de.tdosca.tc05/tdosca-tc05/1.0/[hash code]/archive.zip`

The hash code is built upon the [*Provenance*](https://github.com/telekom/ort/blob/dsl-main/model/src/main/kotlin/Provenance.kt) of the package (e.g. [vcsInfo](https://github.com/telekom/ort/blob/dsl-main/model/src/main/kotlin/VcsInfo.kt), originalVcsInfo...) and is calculated in the class [*LocalScanner.kt*](https://github.com/telekom/ort/blob/dsl-main/scanner/src/main/kotlin/LocalScanner.kt#L432) before saving the files. At runtime the path information (stored in properties [vcsInfo](https://github.com/telekom/ort/blob/dsl-main/model/src/main/kotlin/VcsInfo.kt) and originalVcsInfo) is not set yet and therefore, when unarchiving the files in class [*LicenseInfoResolver*](https://github.com/telekom/ort/blob/dsl-main/model/src/main/kotlin/licenses/LicenseInfoResolver.kt#L213), the hash code is different and the files won't be identified.

This issue was fixed by implementing the function `quickFixProvenance` in class [*LicenseInfoResolver*](https://github.com/telekom/ort/blob/dsl-main/model/src/main/kotlin/licenses/LicenseInfoResolver.kt#L257):

```private fun quickFixProvenance(p: Provenance): Provenance```

The method copies the original properties of the instance of the class provenance and sets the path to an empty string.

### 2. Unarchiving Files
When unarchiving the stored files in [*LicenseInfoResolver*](https://github.com/telekom/ort/blob/dsl-main/model/src/main/kotlin/licenses/LicenseInfoResolver.kt#L219), the file names are matched against the pattern list in ort.conf using the class [*FileMatcher*](https://github.com/telekom/ort/blob/dsl-main/utils/src/main/kotlin/FileMatcher.kt). This class implements the function [*matches*](https://github.com/telekom/ort/blob/dsl-main/utils/src/main/kotlin/FileMatcher.kt#L50) which only works with "/" as path separators - this leads to non-matching files on Windows systems. A quick fix was implemented in [line #219]((https://github.com/telekom/ort/blob/dsl-main/model/src/main/kotlin/licenses/LicenseInfoResolver.kt#L219)) replacing backslashes with slashes.

