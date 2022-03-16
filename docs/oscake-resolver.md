# Managing dual licenses in OSCake files (*.oscc)
Sometimes packages in oscc-files fall under a dual license policy. As the reporter simply lists license findings, it is necessary in this case to *define* these findings as compound license (combination of SPDX-license-identifiers  with "OR"). Otherwise, these file licenses are logically treated as combined with "AND" in the subsequent process.

## Configuration in ort.conf
The Resolver can be configured in the file `ort.conf` in the `oscake`-section:

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

## Resolver Actions - manually defined
Generally, every resolver file consists of one or more packages, identified by the project-`id`. The `id` meets the requirements of the class `Identifier` in ORT and consists of: type (=package manager), name space, name and version of the package. This `id` is used as a selector for applying the resolver actions to a specific package contained in the original \*.oscc file. If the version is empty, the action will be applied to every package disregarding the version number. Additionally, the version number can be defined by means of an an IVY-expression - representing a certain range of version numbers ([some IVY-examples](http://ant.apache.org/ivy/history/2.4.0/settings/version-matchers.html)). If  more than one action for a specific package will be found, no action for this package will be applied.

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
The *resolve*-tag may contain multiple *licenses*. The example above orders the resolver to search for files in the defined *scopes* containing license findings for "Apache-2.0" and "BSD-3-Clause" but no other license. The empty quotes `""` represents the root directory of the package. The resolver exchanges the license by the compound license "Apache-2.0 OR BSD-3-Clause" and sets the tags "licenseTextInArchive" and "fileContentInArchive" to null (because the findings in the files may not represent the correct information anymore)

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

## Resolver Actions - automatically generated
If the parameter `-rA "[path to the analyzer-result.yml]"` is set, a resolver action will be automatically created for a package in the case that the `analyzer-result.yml` contains a compound license (SPDX-license-identifiers combined with "OR") in the tag `declared_licenses_processed.spdx_expression`


analyzer-result.yml:
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

automatically generated resolver action:
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

If an oscc file contains a [DECLARED] license in the default licensings (=when no license finding in files matching the scopePatterns are found during the reporter run), this license may already consist of a compound license. For this specific case a resolver action is also generated automatically if no manuel action is defined.

## Run the "Resolver"

The Resolver uses the `directory`-entry from the config file to search for files in yml-syntax (with extension ".yml") which contain the specific resolver actions. The directory may also contain subdirectories. Automatically generated actions are not stored permanently.

Go to the installation directory of your ORT instance and run the following command:

`cli\build\install\ort\bin\ort -c "[path to your ort.conf]/ort.conf" oscake -a resolver -rI "[path to the oscc-file]/OSCake-Report.oscc" -rO "[path to the results directory]" -rA "[path to the analyzer-result.yml]"`

Depending on the `issueLevel` in `ort.conf` the resulting oscc-file contains a list of issues of different levels.

## Output Files
The Resolver produces the following files:

* `OSCake-Report_resolved.oscc`: output file in *.oscc format 
* `[pid]_resolved.zip`: archive containing the license files (`pid` = project identifier in oscc-file)

The original file is not changed during this process.

