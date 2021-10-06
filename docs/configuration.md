## Configuration of the "OSCake"-Reporter

Detailed infos may be found [here](./running-ort.md#oscake-configuration) and [here](./running-ort.md#preparation)

## Configuration of the "ScanCode"-Scanner in ort.conf

### ScanCode-Commandline options
The commandline contains options for the scanner which can be found [here](https://scancode-toolkit.readthedocs.io/en/latest/cli-reference/basic-options.html)
```
ort {
   scanner {
      options {
         ScanCode {
            commandLine = "--copyright --license --license-text --ignore *.ort.yml --info --strip-root --timeout 300 --ignore META-INF/DEPENDENCIES"
            }
    .....
    }
```
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


### ScanCode-Storages
The storages can be configured as described [here](https://github.com/oss-review-toolkit/ort/blob/master/model/src/main/resources/reference.conf) - e.g.
```
ort {
  scanner {
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

    archive {
      patterns = [
          "license*",
          "licence*",
          "*.license",
		.....
		  ]
      storage {
        localFileStorage {
          directory = "................."
		  compression = false
        }
    }
  
## License categorization in license-classifications.yml
For categorization of licenses, the `license-classifications.yml`-File is used. For OSCake the category "instanced" is needed and has to be assigned to the appropriate license entries (a complete file can be found [here](./examples/license-classifications.yml).   

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