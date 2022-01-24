# Curations for OSCake files (*.oscc)
The ORT-module `oscake` provides a simple mechanism to adapt information about licenses and copyrights in a generated oscc-file (created by the OSCake-Reporter). Due to missing or incomplete data in source files or emerged issues (errors or warnings), it is possible that relevant information is absent and has to be added manually via "curations".

## Curation of Errors or Warnings
The oscc-file contains the tag `hasIssues` on the root, the package, the default-scope and the dir-scope. If `enabled`is set to true, errors, warnings and infos, which occurred during the generation of the oscc-file (OSCakeReporter), are reported directly in the oscc-file depending on the `level` - set in `oscake.conf`.

```
	includeIssues {
		enabled = true
		level = 2	# 0..ERROR, 1..WARN + ERROR, 2..INFO + WARN + ERROR
	}
```

If enabled, and the level is set to 2, the oscc-file contains the following block after the tag `hasIssues` (on root, package, default-scope and dir-scope level). If one of the lists is empty, it will not be shown. If all the lists are empty, the tag `issues` is absent:

```
	"issues": {
		"errors": [
			{
				"id": "E01",
				"message": "Problem occurred ..."
			}
		],
		"warnings": [
			{
				"id": "W01",
				"message": "Issue in ORT-SCANNER - please check ORT-logfile or console output or scan-result.yml"
			},
			{
				"id": "W_Maven:org.springframework.boot:spring-boot-starter:2.5.3",
				"message": "packageRestrictions are enabled, but the package [Identifier(type=Maven, namespace=org.springframework.boot, name=spring-boot-starter, version=2.5.3)] was not found"
			}
		],
		"infos": [
			{
				"id": "I02",
				"message": "commandline parameter \"dependency-granularity\" is overruled due to packageRestrictions"
			}
		]
	},
```

The id of an issue depends on the type ('E', 'W', 'I') and gets a two-digit number as suffix (consecutively numbered for each type on root level and on package level). Therefore, it is possible to curate specific issues by the "Curator". If an issue occurs for a specific package, which is not contained in the `complianceArtifactPackages`, the id consists of the type and the identifier of the package (e.g. `"W_Maven:org.springframework.boot:spring-boot-starter:2.5.3")`. 

A curation always contains the package-`id` at the very beginning, followed by the `packageModifier` (more details see below). The `resolved_issues` tag lists the issues which are treated by this curation. The Curator processes the curation and removes the listed issue-ids from the oscc-issues lists. At the end, the curated oscc-file only contains the issues, which are still open.

```
- id: "Maven:org.springframework.boot:spring-boot-starter:2.5.3"
  package_modifier: "update"
  resolved_issues: [W01, E01]
```

Issues with ids like `"W_Maven:org.springframework.boot:spring-boot-starter:2.5.3"` are removed from the lists only by means of a `package_modifier: insert`. The package will be included and the issue automatically removed, without naming it in the `resolved_issues` list.


## Configuration in ort.conf
Curations may be configured and enabled as follows:

```ort { {
...
  oscake {
  ...
	curator {
		directory = "[path to the directory, which contains the curation files]"
		fileStore = "[path to the directory, where the corresponding license files are kept]"
		issueLevel = 2	# -1..not enabled, 0..ERROR, 1..WARN + ERROR, 2..INFO + WARN + ERROR
	}
  }
}
``` 

## Run the "Curator"

The Curator uses the `directory` to search for curation files in yml-syntax (with extension ".yml") and the `fileStore` for license files (simple text files containing license information - referenced in yml-files). Both folders can hold subdirectories to define a structure for the curation logic.

Go to the installation directory of your ORT instance and run the following command:

`cli\build\install\ort\bin\ort -c "[path to your ort.conf]/ort.conf" oscake -a curator -i "[path to the oscc-file]/OSCake-Report.oscc" -o "[path to the results directory]"`

Depending on the `issueLevel`in `ort.conf` the curated oscc-file contains a list of issues of different levels.

## Additional commandline parameters
Reported warnings in the oscc-file with origin other than from "Reporter" (e.g. Scanner issues) cannot be curated with a yml-file (because there is no package reference). Therefore, the commandline parameter: `--ignoreRootWarnings` can be used. This parameter eliminates every issue with the structure "W??" (? = any digit) from the root-warnings-list.

## Output Files
The Curator produces the follwoing files:

* `OSCake-Report_curated.oscc`: curated output file in *.oscc format 
* `[pid]_curated.zip`: archive containing curated license files (`pid` = project identifier in oscc-file)

The original file `OSCake-Report.oscc` is not changed during the curation.

## Structure of Curation Files
Generally, every curation file consists of one or more packages, identified by the project-`id`. The `id` meets the requirements of the class `Identifier` in ORT and consists of: type (=package manager), name space, name and version of the package. This `id` is used as a selector for applying the curation to a specific package contained in the original \*.oscc file. If the version is empty, the curation will be applied to every package disregarding the version number. Additionally, the version number can be defined by means of an an IVY-expression - defining a certain range of version numbers ([some IVY-examples](http://ant.apache.org/ivy/history/2.4.0/settings/version-matchers.html)). If  more than one curation for a specific package will be found, no curation for this package will be applied.

```
- id: "Maven:joda-time:joda-time:2.10.8"
  package_modifier: "insert"
  repository: "https://www.joda.org/joda-time/"
  resolved_issues: ["W01", "I01", "I02", "W12", "W13", "E11"]
  source_root: "input-sources"
  comment: "example for an additional package - optional"
  curations:
    - file_scope: "LICENSE"
      file_licenses:
        - modifier: "insert"
          reason: "explanation text - optional"
          license: "Apache-2.0"
          license_text_in_archive: "apache/LICENSE.Apache-2.0"
        - modifier: "insert"
          license: "NOASSERTION"
          license_text_in_archive: null
      file_copyrights:
        - modifier: "insert"
          reason: "explanation text - optional"
          copyright: "Copyright 2001-2013 Stephen Colebourne"
- id: "Maven:org.apache:notify:1.8"
  package_modifier: "delete"
```
The `package_modifier` describes different action modes: 
* **insert**: a complete new package (defined by `id`) will be inserted into the output file. The `repository` has to be specified (mandatory) and all the following `modifier`s must be of type "insert"
* **delete**: all packages matching the `id` are removed from the output file. Only the `id` and the `package_modifier` have to be specified.
* **update**: this mode has to be selected in order to apply the different `modifier`s for licenses ("insert", "update", "delete") and copyrights ("insert", "delete", "delete-all")


The curations are performed in a defined sequence:
1. `package_modifier`: "delete"
2. `package_modifier`: "insert"
3. `package_modifier`: "update"
    1. `file_licenses/modifier`: "delete", "insert", "update"
	2. `file_copyrights/modifier`: "delete-all", "delete", "insert"
	
A curation is always defined for a specific `file_scope`. This definition may contain a concrete file path or a `glob`-pattern (the latter is only allowed for "update" and "delete")
	
### Curations for Licenses
For a defined `file_scope` one or more license modifications may be defined. If the tag `source_root` is set to a specific directory, and the path of the file_scope starts with this directory, it will be removed in the curated oscc-file.

The following examples are discussed below:

``` ...
    file_licenses:
        - modifier: "insert"
          reason: "explanation text - optional"
          license: "Apache-2.0"
          license_text_in_archive: "apache/LICENSE.Apache-2.0"
        - modifier: "delete"
          license: "*"
          license_text_in_archive: null
        - modifier: "delete"
          license: "Apache-1.1"
          license_text_in_archive: "*"
        - modifier: "update"
          license: "MIT"
          license_text_in_archive: null

```
1. Example "insert": a new file license named "Apache-2.0" with the corresponding file (`license_text_in_archive`) is inserted under the specified `file_scope`. The referenced file must exist in the directory `fileStore` defined in oscake.conf. No asterisk (\*) or null-value is allowed.
2. Example "delete": every license in the `file_scope` with no `license_text_in_archive` specified ("null") will be deleted
3. Example "delete": every license in the given `file_scope` with the name "Apache-1.1" and a `license_text_in_archive` with either a specified path or "null" will be deleted
4. Example "update": `license_text_in_archive` will be set to "null" for all  licenses with the name "MIT" in the given `file_scope`

Depending on the `file_scope` the curation is not only applied to the `fileLicensings`-section in the oscc-file but also to the `defaultLicensings` or `dirLicensings`-section. For REUSE-compliant software packages the `reuseLicensings` are set instead of the `defaultLicensings` and `dirLicensings`.

If a `defaultLicensing` is set via the ORT-Analyzer (e.g. license found in pom.xml file) - happens when the scanner does not find a file with a license text - the license is specified as "declared"-license. In order to make curations in this case, the following example may be applied:

```
  curations:
    - file_scope: "<DEFAULT_LICENSING>"
      file_licenses:
        - modifier: "insert"
          reason: "explanation"
          license: "Apache-2.0"
          license_text_in_archive: "apache/LICENSE.Apache-2.0"

```

Instead of a specific `file_scope` the string "<DEFAULT_LICENSING>" may be used. The curations defined by the `modifier` will only be applied for "default"-licenses marked as "declared"-licenses.

### Curations for Licenses found in REUSE compliant packages
For a defined `file_scope` one or more license modifications may be defined. The following example is discussed below:

```
- id: "Unmanaged::example:3a3dc3011b4e20b3e143656527905c0cbc7d91f1"
  package_modifier: "update"
  curations:
    - file_scope: "LICENSES/CC-BY-4.02.txt"
      file_licenses:
        - modifier: "insert"
          reason: "explanation"
          license: "Apache-2.0"
          license_text_in_archive: "packages/CC_BY.txt"
   - file_scope: "img/cat.jpg"
     file_licenses:
       - modifier: "insert"
         license: "BSD-3"
         license_text_in_archive: null
```
1. Example for file_scope: `LICENSES/CC-BY-4.02.txt`: if the path to the file starts with "LICENSES" and the package with the id is categorized as REUSE-compliant, a file has to be specified for `license_text_in_archive`. This example creates a license entry in the "fileLicensings" section and due to the specific path an entry in the "reuseLicensings" list.
2. Example for file_scope: `img/cat.jpg`: in REUSE-compliant packages every binary file has an additional text file attached with the name of the binary file and a suffix ".license", containing license information about the binary file (e.g. `img/cat.jpg.license`). If a binary files has to be curated, the name of the binary file has to be used for the file scope - not the ".license" file.

### Curations for Copyrights
For a defined `file_scope` one or more copyright modifications may be defined. The following examples are discussed below:

``` ...
      file_copyrights:
        - modifier: "insert"
          reason: "explanation text - optional"
          copyright: "Copyright 2001-2013 Stephen Colebourne"
        - modifier: "delete-all"
        - modifier: "delete"
          copyright: "*2001*"
```
1. Example: "insert": a new copyright statement is inserted to the given `file_scope`
2. Example: "delete-all": all copyright statements for this `file_scope` are removed
3. Example: "delete": the `copyright` for a "delete" may contain the wildcards "\*" and/or "?". In this example every copyright statement containing the text "2001" will be deleted. If the wildcards are part of the text to be matched, then they have to be double-escaped: e.g.: \\\\*

## Example: Run the "Curator" for Testcase#5
If the scanner does not find the correct license or copyright information, the oscc-file is not completely correct. Therefore, it is possible to define curations for specific packages.

1. Configure the curation mechanism in the file `ort.conf`
```
...
  oscake {
	oscakeCurations {
		directory = "[path to the curation files]"
		fileStore = "[path to the license files, referenced in the curation files]"
		issueLevel = 2	# -1..not enabled, 0..ERROR, 1..WARN + ERROR, 2..INFO + WARN + ERROR
	}
  }
...	
```

2. Create a curation file in yml-format - in this example we assume that the scanner did not find the given file (referenced in `file_scope`) and therefore, the copyright, the license and the corresonding file (referenced in `license_text_in_archive`) have to be added. The `license_text_in_archive`- path is relative to the `fileStore` defined in `ort.conf`.

```
- id: "Maven:de.tdosca.tc05:tdosca-tc05:1.0"
  package_modifier: "update"
  curations:
    - file_scope: "src/main/java/de/tdosca/common/LICENSE"
      file_licenses:
        - modifier: "insert"
          reason: "file was not found by scanner"
          license: "NEW_LICENSE"
          license_text_in_archive: "newLicense/new_license.txt"
      file_copyrights:
        - modifier: "insert"
          copyright: "Copyright 2010 by Konrad"		  
```

3. Run the Curator

`cli/build/install/ort/bin/ort -c ort.conf oscake -a curator -i [inputDirectory]/OSCake-Report.oscc -o
[outputDirectory]`

The Curator applies all defined curations to the oscc-file and produces the following output files:

*  [OSCake-Report_curated.oscc](./examples/versionJan2022_2/tc05_curated/OSCake-Report_curated.oscc) 
*  [tdosca-tc05_curated.zip](./examples/versionJan2022_2/tc05_curated/tdosca-tc05_curated.zip) 