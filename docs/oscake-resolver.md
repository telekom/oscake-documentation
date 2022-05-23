# Dual Licensing in OSCake
It is possible that packages in oscc-files fall under a dual license policy. As the reporter simply lists license findings, it is necessary in this case to *define* these findings as compound license (combination of two SPDX-license-identifiers  with "OR"). Otherwise, these file licenses are logically treated as combined with "AND" in the subsequent processes.

## Configuration in ort.conf
The *Resolver* can be configured in the file `ort.conf` in the `oscake`-section:

```ort { {
...
  oscake {
  ...
   resolver {
      directory = "../resolver"
      issueLevel = 2	# -1..not enabled, 0..ERROR, 
         1..WARN + ERROR, 2..INFO + WARN + ERROR
   }
  }}}
``` 

## Commandline Parameters
The definition of resolver actions can be a cumbersome task for big projects. Therefore, it is possible to start the resolver with the parameter `--generateTemplate` in order to write a file which contains resolver actions containing resolver blocks for packages with more than one file license. The file can be found in the configured resolver directory and is named `template.yml.tmp`.


## Resolver Actions - *manually defined*
Generally, every *Resolver* file consists of one or more packages, identified by the project-`id`. The `id` meets the requirements of the class `Identifier` in ORT and consists of: type (=package manager), name space, name and version of the package. This `id` is used as a selector for applying the resolver actions to a specific package contained in the original \*.oscc file. If the version is empty, the action will be applied to every package disregarding the version number. Additionally, the version number can be defined by means of an an IVY-expression - representing a certain range of version numbers ([some IVY-examples](http://ant.apache.org/ivy/history/2.4.0/settings/version-matchers.html)). If  more than one action for a specific package is found, no action will be applied for this package.

```
- id: "Maven:de.tdosca:tdosca-tc08:1.0"
  resolve:
    - licenses:
        - "Apache-2.0"
        - "BSD-3-Clause"
      result: "Apache-2.0 OR BSD-3-Clause"
      scopes: 
        - ""
        - "src/main/java/utils"
- id: "Maven:org.apache:notify:1.8"
  ....
```
The `resolve`-tag may contain multiple `licenses`. The example above instructs the *Resolver* to search for files in the defined `scopes` containing license findings for "Apache-2.0" and "BSD-3-Clause" but no other license. The empty quotes `""` represent the root directory of the package. The *Resolver* replaces the license by the compound license "Apache-2.0 OR BSD-3-Clause" and sets the tags "licenseTextInArchive" and "fileContentInArchive" to null (because the findings in these files may not represent the correct information anymore)

Section of the changed \*.oscc-file:
```
"fileScope": "[file path found in scopes]",
"fileContentInArchive": null
"fileLicenses": [
  {
    "license": "Apache-2.0 OR BSD-3-Clause",
    "licenseTextInArchive": null
  }
],

```

## Resolver Actions based on `analyzer-result.yml` - *automatically generated*
If the commandline parameter `-rA "[path to the analyzer-result.yml]"` is set, a *Resolver* action will be automatically created for a package in the case that the `analyzer-result.yml` contains a compound license (SPDX-license-identifiers combined with "OR") in the tag `declared_licenses_processed.spdx_expression`.


Example in an *analyzer-result.yml*-file:
```
- package:
	id: "Maven:com.h2database:h2:2.1.210"
	purl: "pkg:maven/com.h2database/h2@2.1.210"
	authors:
	- "Thomas Mueller"
	declared_licenses:
	- "EPL 1.0"
	- "MPL 2.0"
	declared_licenses_processed:
	  spdx_expression: "EPL-1.0 OR MPL-2.0"
	  mapped:
		EPL 1.0: "EPL-1.0"
		MPL 2.0: "MPL-2.0"
```

Automatically generated resolver action:
```
- id: "Maven:com.h2database:h2:2.1.210"
  resolve:
    - licenses:
        - "EPL-1.0"
        - "MPL-2.0"
      result: "EPL-1.0 OR MPL-2.0"
      scopes: 
        - ""
```

If an oscc file contains a [DECLARED] license in the default licensings (=when no license findings, in files matching the scopePatterns, are found during the reporter run), this license may already consist of a compound license. For this specific case, a resolver action also will be generated automatically, if no manual action is defined.

## Resolver Actions based on `native-scan-results` - *automatically generated*

If the commandline parameter `-rS "[path to the native-scan-results folder]"` is set, a *Resolver* action will be automatically created for a package in the case that its `scan-results_ScanCode.json` file contains a compound license (with *OR* or *AND*) in the tag `license_expressions`. As the license statement is not SPDX compliant, the single expressions are replaced by `spdx_license_key` based on the `key` of the scanners's license finding. The *Resolver* generates automatically an action for this specific file only (`scope` contains only the file path!)

The sequence of the applied resolver actions is:
1. Manually defined actions
2. Automatically defined actions based on analyzer results
3. Automatically defined actions based on native-scan-results

As soon as an action for a package is found, all others are ignored!


## Run the "Resolver"

The Resolver uses the `directory`-entry from the config file to search for files in yml-syntax (with extension ".yml") which contain the specific *Resolver* actions. The directory may also contain subdirectories. Automatically generated actions are only kept in memory and not stored permanently.

Go to the installation directory of your ORT instance and run the following command:

`cli\build\install\ort\bin\ort -c "[path to your ort.conf]/ort.conf" oscake -a resolver -rI "[path to the oscc-file]/OSCake-Report.oscc" -rO "[path to the results directory]" -rA "[path to the analyzer-result.yml]"`

Depending on the `issueLevel` in `ort.conf` the resulting oscc-file contains a list of issues of different levels.

> Run Resolver from Docker using the unzipped [example file](./examples/versionMay2022/ortExample.zip):  
>
> `docker run -v [localPathTo]/ortExample:/project -w /project ort -c ./conf/ort.conf oscake -a resolver -rI ./results/OSCake-Report_curated.oscc -rO ./results -rA ./results/analyzer-result.yml`
>
> The option -v mounts the local directory into the folder `/project`. The option -w sets the working directory to `/project`. Consequently, every path in the example is relative to the working directory. Maybe you have to use `sudo` to execute the command above on unix systems.

## Output Files
The Resolver produces the following files:

* `OSCake-Report_resolved.oscc`: output file in *.oscc format 
* `[pid]_resolved.zip`: archive containing the license files (`pid` = project identifier in oscc-file)
* `template.yml.tmp`: if the resolver was started with the commandline parameter `--generateTemplate`

The original file is not changed during this process.

