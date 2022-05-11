# Dual Licensing - Selection of a specific License

After the run of the *Resolver* the oscc-file contains compound licenses (combined with "OR"). The task of the *Selector* is to pick a specific license from the given ones.

## Configuration in ort.conf
The Selector can be configured in the file `ort.conf` in the `oscake`-section:

```ort { {
...
  oscake {
  ...
   selector {
      directory = "../selector"
      issueLevel = 2	# -1..not enabled, 0..ERROR, 
         1..WARN + ERROR, 2..INFO + WARN + ERROR
   }
  }}}
``` 

## Selector Actions
In general, every *Selector* file consists of one or more packages, identified by the project-`id`. The `id` meets the requirements of the class `Identifier` in ORT and consists of: type (=package manager), name space, name and version of the package. This `id` is used as a selector for applying the selector actions to a specific package contained in the processed \*.oscc file. If the version is empty, the action will be applied to every package disregarding the version number. Additionally, the version number can be defined by means of an an IVY-expression - representing a certain range of version numbers ([some IVY-examples](http://ant.apache.org/ivy/history/2.4.0/settings/version-matchers.html)). If more than one action for a specific package is found, none of them will be applied. If a *Selector* action should be applied to the whole project, then the `id` must contain the keyword `[GLOBAL]`.


```
- id: "Maven:de.tdosca:tdosca-tc08:1.0"
  choices:
    - specified: "BSD-3-Clause OR Apache-2.0"
      selected: "Apache-2.0"
    - specified: "MIT OR LGPL-2.1-or-later"
      selected: "MIT"
- id: "[GLOBAL]"
  choices:
    - specified: "EPL-2.0 OR BSD-3-Clause"
      selected: "EPL-2.0"
- id: "Maven:org.apache:notify:1.8"
  ....
```

The *choices*-tag may contain multiple *compound licenses* defined in the tag `specified`. The example above instructs the *Selector* to search for file licensings which contain the `specified` compound license. When found, the license is replaced by the license defined in the `selected`-tag. To keep the original compound license, the tag `originalLicenses` is set.


Section of the changed \*.oscc-file:
```
{
  "fileScope": "src/main/java/utils/NOTICE.MIT",
    "fileLicenses": [
      {
         "license": "MIT",
         "originalLicenses": "MIT OR LGPL-2.1-or-later",
         "licenseTextInArchive": null
      }],
},

```

## Run the "Selector"

The *Selector* uses the `directory`-entry from the config file to search for files in yml-syntax (with extension ".yml") which contain the specific actions. The directory may also contain subdirectories.

Go to the installation directory of your ORT instance and run the following command:

`cli\build\install\ort\bin\ort -c "[path to your ort.conf]/ort.conf" oscake -a selector -sI "[path to the oscc-file]/OSCake-Report.oscc" -sO "[path to the results directory]"`

Depending on the `issueLevel` in `ort.conf` the resulting oscc-file contains a list of issues of different levels.

> Run Resolver from Docker using the unzipped [example file](./examples/versionMay2022/ortExample.zip):  
>
> `docker run -v [localPathTo]/ortExample:/project -w /project ort -c ./conf/ort.conf oscake -a selector -sI ./results/OSCake-Report_curated_resolved.oscc -sO ./results`
>
> The option -v mounts the local directory into the folder `/project`. The option -w sets the working directory to `/project`. Consequently, every path in the example is relative to the working directory. Maybe you have to use `sudo` to execute the command above on unix systems.

## Output Files
The *Selector* generates the following files:

* `OSCake-Report_selected.oscc`: output file in *.oscc format 
* `[pid]_selected.zip`: archive containing the license files (`pid` = project identifier in oscc-file)

The input file is not changed during this process.