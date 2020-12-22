## Configuration of the "ScanCode"-Scanner in ort.conf

### ScanCode-Commandline options
The commandline contains options for the scanner which can be found at https://scancode-toolkit.readthedocs.io/en/latest/cli-reference/basic-options.html
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
The storages can be configured as described in https://github.com/oss-review-toolkit/ort/blob/master/model/src/test/assets/reference.conf - e.g.
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
### ScanCode Archive
Files ("compliance artifacts") which are matching the archive patterns are copied to the localFilestorage
```
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
      }```
	  
	  