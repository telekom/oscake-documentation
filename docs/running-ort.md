# Running ORT with OSCake-Reporter
The following sections show the use of [ORT](https://github.com/telekom/ort) in order to produce the input files for [OSCake](https://github.com/Open-Source-Compliance/OSCake) ("Open Source Compliance artifact knowledge engine"). The ORT OSCake-Reporter generates the following files:
* *OSCake-Report.oscc*: reporter output in a DSL - [Example](./examples/OSCake-Report.oscc)
* *zip-File*: flat zip-archive, containing the license-relevant generated or copied files

> Info: Sections marked with this style refer to instructions on how to run ORT with Docker 

## Install ORT

* General information about ORT see https://github.com/telekom/ort
* Installation and verification prerequisites  [see](https://github.com/telekom/ort/blob/dsl-main/docs/getting-started.md#1-prerequisites)
  * `git clone --recurse-submodules https://github.com/telekom/ort.git`
  * `cd ort`
  * `./gradlew installDist` (Info: If the command fails, the most probable cause is that a specific package dependency is not met. In this case you have to update the file `gradle.properties` and change the version accordingly)

> Steps to create a Docker image for ORT (Docker must be installed on your computer)
> * `docker build -t ort .`
> * run `docker run ort` to verify the image (the ORT start screen should be displayed)
>
> for further information about ORT and Docker see the following links:
> * [ORT: Docker Build](https://github.com/telekom/ort#basic-usage)
> * [ORT: Run with Docker](https://github.com/telekom/ort#run-using-docker)
> * [ORT: Hints for Use with Docker](https://github.com/telekom/ort/blob/oscake-reporter/docs/hints-for-use-with-docker.md)


## OSCake-Configuration
In order to use the OSCake-Reporter, several parameters have to be set using the appropriate ORT commandline style. Additionally, a specific configuration file has to be provided ([ort.conf](./examples/ort.conf)) - see also comment in configuration file for changes between different versions.

### Parameters
ORT handles commandline parameters in several ways:
* General parameters to control the *Analyzer*, *Scanner*, etc. e.g. `-c [your_path]/ort.conf` - a complete list is shown when using the command `[your_install_path]cli/build/install/ort/bin/ort --help`
* Reporter-specific parameters - format: `[reporter name]=[parameter name]=[parameter value]`

#### Path to the directory containing results of the scanning process
Information about licenses (reference, tag, notice, text) is kept deeply in the scanner results and are not provided in the general scan output, therefore, the reporter has to know its path:

`OSCake=nativeScanResultsDir=[your_path]/native-scan-results`

#### Path to the downloaded source code directory
Depending on different criteria (e.g. "declared license") the license text has to be extracted directly from the downloaded source files:

`OSCake=sourceCodeDownloadDir=[your_path]/downloads`

#### Path to a specific OSCake-configuration file
The [configuration file](./examples/oscake.conf) contains information about default values for OSCake reporter which are project independent: 

`OSCake=configFile=[your_path]/oscake.conf`


#### Used ORT configuration options for the reporter
* option `-c`: ORT uses the file `ort.conf` from the user's directory as default, but can be set also by a commandline parameter: `-c [your_path]/ort.conf`
* option `-i`: path to the scan results: `-i [your_path]/scan-result.yml`
* option `-o`: specifies the output directory: `-o [your_path]`
* option `--license-classifications-file`: path to a a file containing information about licenses and their categories (e.g. *declared* license) `--license-classifications-file=license-classifications.yml`
* option `-f`: name of the report: `-f OScake`

#### Used ORT excludes
ORT has a mechanism ([configuration file](./examples/.ort.yml)) to control the handling of source code packages in order to exclude them (e.g. because they are only used for testing purposes). Therefore, it is possible to place a file with the name `.ort.yml` directly in the root directory of the source code.

Additional information can be found [here](https://github.com/oss-review-toolkit/ort/blob/master/docs/config-file-ort-yml.md#excluding-scopes)

## Running ORT using TDOSCA [Testcase#5](https://github.com/Open-Source-Compliance/tdosca-tc05-simplhw)

### Preparation 

A proposal for a complete folder structure including the necessary adapted files - which is used in the Docker examples - can be downloaded [here](./examples/ortExample.zip). 
```
.
|-- conf
|   |-- license-classifications.yml
|   |-- ort.conf
|   `-- oscake.conf
|-- curations
|   |-- packages
|   |   `-- cur.yml
|   `-- store
|       `-- newLicense
|           `-- new_license.txt
|-- results
|-- scanner
|   |-- scannerArchive
|   `-- scannerStorage
`-- tdosca-tc05-simplhw
    |-- README.md
    |-- .....
	| ...
```

If you want to prepare the configuration by yourself, you can follow the steps below: 

1. Adapt the ort.conf to your needs - you can use the [example](./examples/ort.conf) and update the directory entries: `[yourFileStorageDirectory]` and `[yourScannerArchive]`. Specific  information about using commandline options for the scanner can be found [here](./configuration.md).
2. Be sure that the directory `[yourFileStorageDirectory]` in `ort.conf` is empty. ORT has a mechanism to download only files which were not downloadet yet. As the OSCake-Reporter needs all the source code files, the directory **must be empty** before a new project is processed .
3. Prepare the `license-classifications.yml` [file](./examples/license-classifications.yml) and adapt it. ORT uses this file to categorize licenses according to the defined categories. The OSCake-Reporter needs the categorization: `instanced`.
4. If you want to exclude some packages from being processed in a default way, create the [file](./examples/.ort.yml) `.ort.yml` and copy it into the source code folder. Depending on the used package manager, ORT can be configured to process the repository according to different scopes; e.g. Maven uses the scope "test" to show which packages are only used for testing the project.
5. Customise the `oscake.conf` [configuration file](./examples/oscake.conf). Adapt the "scopePatterns" which are responsible to retrieve the scope of the license information of a file (default, directory, reuse, file).
6. Create your [workingDirectory].
7. Create the [outputDirectory] - it can also be a sub directory of your working directory.
8. Clone the GIT-Repo into your working directory - a directory `tdosca-tc05-simplhw` containing the requested source code is created. If you want to exclude some packages (because they are only needed for testing reasons), copy the file [.ort.yml](./examples/.ort.yml) into the directory 
 `[workingDirectory]/tdosca-tc05-simplhw/input-sources`  
   `git clone https://github.com/Open-Source-Compliance/tdosca-tc05-simplhw.git`

### Analyzer
Go to the installation directory of your ORT instance and run the following command

`cli/build/install/ort/bin/ort -c ort.conf analyze -i [workingDirectory]/tdosca-tc05-simplhw/input-sources -o [outputDirectory]`

ORT will generate the file `analyzer-result.yml` in the [outputDirectory].

> Run Analyzer from Docker using the unzipped [example file](./examples/ortExample.zip):  
>
> `docker run -v [localPathTo]/ortExample:/project -w /project ort -c ./conf/ort.conf analyze -i ./tdosca-tc05-simplhw/input-sources -o ./results`  
>
> The option -v mounts the local directory into the folder `/project`. The option -w sets the working directory to `/project`. Consequently, every path in the example is relative to the working directory. ORT will generate the file `analyzer-result.yml` in the subdirectory `./results`


### Scanner

Call the following command to start the scan operation

`cli/build/install/ort/bin/ort -c ort.conf scan -i [outputDirectory]/analyzer-result.yml -o [outputDirectory]`

The scanner generates the file `scan-result.yml` and the directories `native-scan-results` and `downloads`. The running time of the scanner depends on the size of the project and the used packages.

In case of a runtime error, the most probable cause is that the environment variable `LANG` is not set correctly (e.g. LANG="en_US.UTF-8"; export LANG).

> Run Scanner from Docker:
>
> `docker run -v [localPathTo]/ortExample:/project -w /project ort -c ./conf/ort.conf scan -i ./results/analyzer-result.yml -o ./results`

### OSCake-Reporter

Call the following command to create the OSCake input:

`cli/build/install/ort/bin/ort -c ort.conf report -i [outputDirectory]/scan-result.yml -o
[outputDirectory] -f OSCake -O OSCake=nativeScanResultsDir=[outputDirectory]/native-scan-results -O OSCake=sourceCodeDownloadDir=[outputDirectory]/downloads -O OSCake=configFile=oscake.conf
--license-classifications-file=[yourPathTo]/license-classifications.yml`

The reporter combines the different input files and produces the output files:
* [OSCake-Report.oscc](./examples/OSCake-Report.oscc)
* [tdosca-tc05.zip](./examples/tdosca-tc05.zip)

In case of processing errors, the logfile `OSCake.log` is generated (configuration details can be found [here](./architecture-and-code.md))

> Run OSCake-Reporter from Docker (with curations enabled):
>
> `docker run -v [localPathTo]/ortExample:/project -w /project ort -c ./conf/ort.conf report -i ./results/scan-result.yml -o ./results -f OSCake -O OSCake=nativeScanResultsDir=./results/native-scan-results -O OSCake=sourceCodeDownloadDir=./results/downloads -O OSCake=configFile=./conf/oscake.conf --license-classifications-file=./conf/license-classifications.yml`  
>
> The generated files can be found in the folder `./results`. The logfile `OSCake.log` is created directly in the working directory.


### OSCake-Reporter with Curations

If the scanner does not find the correct license or copyright information, it is possible to define curations for specific packages (a complete overview can be found [here](./curations.md)).

1. "Enable" the curation mechanism in the config file `oscake.conf`
```
...
	curations {
		enabled = true
		directory = "[path to the directory, which contains the curation files]"
		fileStore = "[path to the directory, where the corresponding license files are kept]"
	}
...	
```
2. Create a curation file in yml-format - in this example we assume that the scanner did not find the given file (referenced in `file_scope`) and therefore, the copyright, the license and the corresonding file (referenced in `license_text_in_archive`) have to be added. The `license_text_in_archive`- path is relative to the `fileStore` defined in `oscake.conf`.

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


3. Re-run the Reporter - the applied curations are reflected in the files
*  [OSCake-Report_curated.oscc](./examples/OSCake-Report_curated.oscc) 
*  [tdosca-tc05_curated.zip](./examples/tdosca-tc05_curated.zip) 

### Additional information for [Testcase#6](https://github.com/Open-Source-Compliance/tdosca-tc06-plainhw.git)
A complete folder structure to run the Reporter on **tdosca-tc06-plainhw** - after running the Analyzer and the Scanner - can be found [here](./examples/tc06.tar.gz).
