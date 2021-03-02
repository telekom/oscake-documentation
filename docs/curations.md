# Curations for OSCake files (*.oscc)
The OSCakeReporter provides a simple mechanism to adapt information about licenses and copyrights in the generated output file. Due to missing or incomplete data in source files it is possible that relevant information is absent and has to be added manually via "curations".

## Configuration in oscake.conf
Curations may be configured and enabled as follows:

```OSCake {
...
	curations {
		enabled = true
		directory = "curations/packages"
		fileStore = "curations/store"
	}
}
``` 
Curations may generally be enabled or disabled. If enabled, the OSCakeReporter uses the "directory" to search for curation files in yml-syntax (with extension ".yml") and the "fileStore" for license files (simple text files containing license information - referenced in yml-files). Both folders can hold subdirectories to define a structure for the curation logic.

## Output Files
Supplementary files are generated if curations are enbaled:
* `OSCake-Report_curated.oscc`: curated output file in *.oscc format 
* `[pid]_curated.zip`: archive containing curated license files (`pid` = project identifier in oscc-file)

## Structure of Curation Files
Generally, every curation file consists of one or more packages, identified by the project-`id`. The `id` meets the requirements of the class `Identifier` in ORT and consists of: type (=package manager), name space, name and version of the package. This `id` is used as a selector for applying the curation to a specific package contained in the original \*.oscc file. If the version is empty, the curation will be applied to every package disregarding the version number. Additionally, the version number can be defeined by means of an an IVY-expression - definig a certain range of version numbers ([some IVY-examples](http://ant.apache.org/ivy/history/2.4.0/settings/version-matchers.html. If  more than one curation for a specific package will be found, no curation for this package will be applied.

```
- id: "Maven:joda-time:joda-time:2.10.8"
  package_modifier: "insert"
  repository: "https://www.joda.org/joda-time/"
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
    - file_scope: "subdir/LICENSE"
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
For a defined `file_scope` one or more license modifications may be defined. The following examples are discussed below:

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

Depending on the `file_scope` the curation is not only applied to the `fileLicensings`-section in the oscc-file but also to the `defaultLicensings` or `dirLicensings`-section.

If a `defaultLicensing` is via the ORT-Analyzer (e.g. license found in pom.xml file) - happens when the scanner does not find a file with a license text - the license is specified as "declared"-license. In order to make curations in this case, the following example may be applied:

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