## Configuration of the OSCake-Reporter

### Commandline options
In order to keep the output volume in the \*oscc file as concise as possible, the `dependency-granularity`can be set. It defines the tree level of package dependencies and restricts the packages concerning to their level (mainly used for verification reasons).
 
`-O OSCake=dependency-granularity=[level]` 

### Configuration file: OSCake.conf

An example of the `oscake.conf` may be found [here](./examples/versionJan2022_2/oscake.conf).

1. `scopePatterns` are responsible for retrieving the scope of the license information of a file (default, directory, reuse, file)
2. `copyrightScopePatterns` contains glob-patterns to retrieve the scope of the copyright information of a file. It automatically contains the list of `scopePatterns`
3. `scopeIgnorePatterns` exclude files which comply to the `scopePatterns` or `copyrightScopePatterns`
4. `sourceCodesDir` is the path to the directory where the source codes are downloaded and kept, in order to extract original license infos
5. `ortScanResultsDir` denotes the folder where the original ORT scan results are stored
6. `packageRestrictions` - if `enabled` the output is restricted to the packages enumerated in `onlyIncludePackages`. This list contains the package names in IVY-format: e.g.: "Maven:org.yaml:snakeyaml:1.28". This configuration works independently from the commandline parameter `dependency-granularity` (this option will be overruled!).
7. `packageInclusions` contains a list of packages (`forceIncludePackages`). These Packages are integrated into the ouput also if the `dependency-granularity` excludes them. Only works in conjunction with the command line option `dependency-granularity`.
8. `includeIssues` specifies, if log messages (INFO, WARN, ERROR) are included in the oscc-file. The messages are assigned to different levels: Root, Package, Default-Scope and Dir-Scope. The `level` defines the granularity of the messages: 0..ERROR, 1..WARN+ERROR, 2..WARN+ERROR+INFO.
9. `includeJsonPathInLogfile4ErrorsAndWarnings` - when set, WARN- and ERROR-messages have a suffix representing a JsonPath in order to locate the issue in the oscc file more easily.
10. `ignoreNOASSERTION` - when set to *true* license findings with the license indicator "NOASSERTION" are ignored.
11. `ignoreLicenseRefScancodeUnknown` - when set to *true* license findings starting with *LicenseRef-scancode* and containing *unknown* are ignored.
12. `ignoreLicenseRef`- when set to *true*, license findings starting with *LicenseRef* are ignored (consequently, this setting overrules the parameter `ignoreLicenseRefScancodeUnknown`)  
13. `hideSections = []` - contains a list of section names (*"config", "reuselicensings", "dirlicensings", "filelicensings"*) which are removed from the generated output - mostly for verification reasons. If the generated oscc-file has hidden sections no further processing (merging, deduplication, curation) is possible!
14. `lowerCaseComparisonOfScopePatterns` defines if the `scopePatterns`, `scopeIgnorePatterns` and `copyrightScopePatterns` are applied to filenames in lower case (on Windows the comparison is always done on lower case names, whereas on UNIX systems upper and lower case rules are followed; if set to true on UNIX the results are equal to Windows)
15. `licenseScoreThreshold` is the boundary for reporting a warning in the event that a license score is lower or equal  than this threshold. ATTENTION: the ORT-scanner may be configured to skip license findings under a specific threshold. Consequently, the option in the OSCake-Reporter may have no impact.

## Configuration of the OSCake-Applications
The options and parameters are documented in the descriptions of each OSCake-Application.

## Configuration of the ORT-Scanner

### ScanCode-Commandline options
The commandline contains options for the scanner which can be found [here](https://scancode-toolkit.readthedocs.io/en/latest/cli-reference/basic-options.html)
```
ort {
   scanner {
      options {
         ScanCode {
            commandLine = "--copyright --license --license-text --ignore *.ort.yml --info --strip-root --timeout 300 --ignore META-INF/DEPENDENCIES --json [path_to_the_raw_scanner_files]/{rawFileName}.json"
            }
    .....
    }
```
The option `--json` creates a file for each scanned package. These results are copied by the reporter into the `native-scan-results`-folder.

The option `--json-pp` is appended automatically to the commandLine by the ORT tool and cannot be changed.

#### ScanCode Option: --license-score
The scanner classifies license findings based on the application of different matching rules. These scores can be found inside of the file `scan-results_ScanCode.json`.
```
      "licenses": [
        {
          "key": "mit",
          "score": 100.0,
          "name": "MIT License",
		  .....
```
The default value for this option is set to 0. That means, that every license finding with a score of 0 and higher will be taken into account. If the number of these findings should be reduced (in case that the scanner marks texts as a license because it randomly matches a rule), the score can be set to a value between 0 and 100. More information can be found [here](https://scancode-toolkit.readthedocs.io/en/latest/cli-reference/basic-options.html#license-score-options). 

#### ScanCode-License File Patterns
Source files which match the patterns of license files are copied to the ScanCode Archive
```
ort {
  licenseFilePatterns {
	...
    licenseFilenames = [
          "license*",
          "licence*",
          "*.license",
          "*.licence",
          "unlicense",
          "unlicence",
          "copying*",
          "copyright",
          "notice",
          "notice*",
          "**/license*",
          "**/licence*",
          "**/*.license",
          "**/*.licence",
          "**/unlicense",
          "**/unlicence",
          "**/copying*",
          "**/copyright",
          "**/notice",
          "**/notice*",
      ]
  }
```

#### ScanCode-Storages
The storages can be configured as described [here](https://github.com/oss-review-toolkit/ort/blob/master/model/src/main/resources/reference.conf) - e.g.
```
ort {
...
  scanner {
  ...
     storages {
        local {
           backend {
             localFileStorage {
               directory = "........................"
               compression = false
             }
           }
        }
     }
	  
    storageReaders: [
      "local"
    ]

    storageWriters: [
      "local"
    ]
    ...
```
#### ScanCode Archive
Files ("compliance artifacts") which are matching the archive patterns (`glob`-[Patterns](https://www.malikbrowne.com/blog/a-beginners-guide-glob-patterns)) are copied to the localFilestorage
```
    archive {
      fileStorage {
        localFileStorage {
          directory = "........"
		  compression = false
        }
      }
    }
```  
## License categorization in license-classifications.yml
For categorization of licenses, the `license-classifications.yml`-File is used. For OSCake the category "instanced" is needed and has to be assigned to the appropriate license entries (a complete file can be found [here](./examples/versionJan2022_2/license-classifications.yml).   

	categories:
	- name: "instanced"
	- name: "copyleft"
	- name: "strong-copyleft"
	- name: "include-source-code-offer-in-notice-file"
	  description: >-
		A marker category that indicates that the licenses assigned to it require that the source code of the packages
		needs to be provided.

	categorizations:
	- id: "AGPL-1.0"
	  categories:
	  - "copyleft"
	  ....

Attention: in ORT versions before Nov 2020 this file was structured differently and was called `licenses.yml`