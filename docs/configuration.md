## Configuration of the "ScanCode"-Scanner in ort.conf

#### ScanCode-Commandline options
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
The option `--json-pp` is appended automatically to the commandLine by the ORT tool and cannot be changed

### ScanCode-Storages
The storages can be configured as described [here](https://github.com/oss-review-toolkit/ort/blob/master/model/src/test/assets/reference.conf) - e.g.
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
For categorization of licenses, the `license-classifications.yml`-File is used. For OSCake the category "instanced" is needed and has to be assigned to the appropriate license entries (a complete file can be found [here](https://github.com/telekom/ort-dsl-documentation/blob/main/docs/examples/license-classifications.yml).   

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