# MetaDataManager
## Update the info about "distribution" and "packageType" in a Package

After creating an oscc-file by the *Reporter* the file contains information about the kind of distribution (*"DISTRIBUTED", "PREINSTALLED", "DEV"*) of a package and also its package type (*"EXECUTABLE", "LIBRARY"*). The task of the *MetadataManager* is to offer a posibility to change this information.

## Configuration in ort.conf
The MetaDataManager can be configured in the file `ort.conf` in the `oscake`-section:

```ort { {
...

  oscake {
  ...
      metadatamanager {
        distribution {
           enabled = false
           directory = "../mmanager/distribution"
        }
        packageType {
           enabled = true
           directory = "../mmanager/packageType"
        }
      issueLevel = 2	# -1..not enabled, 0..ERROR, 1..WARN + ERROR, 2..INFO + WARN + ERROR
    }
  ...
``` 

## MetaDataManager Actions
In general, every *MetaDataManager* file consists of one or more packages, identified by the project-`id`. The `id` meets the requirements of the class `Identifier` in ORT and consists of: type (=package manager), name space, name and version of the package. This `id` is used as a selector for applying the MetaDataManager actions to a specific package contained in the processed \*.oscc file. If the version is empty, the action will be applied to every package disregarding the version number. Additionally, the version number can be defined by means of an an IVY-expression - representing a certain range of version numbers ([some IVY-examples](http://ant.apache.org/ivy/history/2.4.0/settings/version-matchers.html)). If more than one action for a specific package is found, none of them will be applied. If a *MetaDataManager* action should be applied to the whole project, then the `id` must contain the keyword `[GLOBAL]`.

Example to change the **distribution** information:

```
- id: "Maven:de.tdosca:tdosca-tc08:1.0"
  distribution:
    from: "DISTRIBUTED"
    to: "DEV"
- id: "Maven:com.github.peteroupc:numbers:1.8.0"
  distribution:
    from: "DISTRIBUTED"
    to: "PREINSTALLED"
- id: "[GLOBAL]"
  distribution:
    from: "DEV"
    to: "PREINSTALLED"
  ....
```

The *distribution* tag instructs the MetaDataManager to change the kind of distribution. If the `from` information is different to the one found in the oscc-file, a warning is reported and the change is not applied. This check can be overridden by the commandline parameter `--ignoreFromChecks`.

Example to change the **packageType** information:

```
- id: "Maven:de.tdosca:tdosca-tc08:1.0"
  packageType:
    from: "EXECUTABLE"
    to: "LIBRARY"
- id: "Maven:com.github.peteroupc:numbers:1.8.0"
  packageType:
    from: "LIBRARY"
    to: "EXECUTABLE"
- id: "[GLOBAL]"
  packageType:
    from: "LIBRARY"
    to: "EXECUTABLE"
  ....
```

The *packageType* tag instructs the MetaDataManager to change the kind of package type. If the `from` information is different to the one found in the oscc-file, a warning is reported and the change is not applied. This check can be overridden by the commandline parameter `--ignoreFromChecks`.

## Run the "MetaDataManager"

The *MetaDataManager* uses the `directory`-entries from the config file to search for files in yml-syntax (with extension ".yml") which contain the specific actions. The directories may also contain subdirectories.

Go to the installation directory of your ORT instance and run the following command:

`cli\build\install\ort\bin\ort -c "[path to your ort.conf]/ort.conf" oscake -a metadata-manager -iI "[path to the oscc-file]/OSCake-Report.oscc" -iO "[path to the results directory]" --ignoreFromChecks`

Depending on the `issueLevel` in `ort.conf` the resulting oscc-file contains a list of issues of different levels.

> Run MetaDataManager from Docker using the unzipped [example file](./examples/versionMay2022/ortExample.zip):  
>
> `docker run -v [localPathTo]/ortExample:/project -w /project ort -c ./conf/ort.conf oscake -a metadata-manager -iI ./results/OSCake-Report_curated_resolved_selected.oscc -iO ./results --ignoreFromChecks`
>
> The option -v mounts the local directory into the folder `/project`. The option -w sets the working directory to `/project`. Consequently, every path in the example is relative to the working directory. Maybe you have to use `sudo` to execute the command above on unix systems.

## Output Files
The *MetaDataManager* generates the following files:

* `OSCake-Report_injected.oscc`: output file in *.oscc format 
* `[pid]_injected.zip`: archive containing the license files (`pid` = project identifier in oscc-file)

The input file is not changed during this process.