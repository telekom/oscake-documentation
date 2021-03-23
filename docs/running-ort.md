# Running ORT with OSCake-Reporter
The following sections show the use of [ORT](https://github.com/telekom/ort) in order to produce the input files for [OSCake](https://github.com/Open-Source-Compliance/OSCake) ("Open Source Compliance artifact knowledge engine"). The ORT OSCake-Reporter generates the following files:
* *OSCake-Report.oscc*: reporter output in a DSL - [Example](https://github.com/Open-Source-Compliance/OSCake/blob/main/test/a-input.oscc/oscake-reference.oscc)
* *zip-File*: flat zip-archive, containing the license-relevant generated or copied files

## Install ORT

* General information about ORT see https://github.com/telekom/ort
* Installation and verification prerequisites  [see](https://github.com/telekom/ort/blob/dsl-main/docs/getting-started.md#1-prerequisites)
  * `git clone --recurse-submodules https://github.com/telekom/ort.git`
  * `cd ort`
  * `./gradlew installDist`

## OSCake-Configuration
In order to use the OSCake-Reporter, several parameters have to be set using the appropriate ORT commandline style and a specific configuration file has to be provided. 

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
The [configuration file](https://github.com/telekom/ort-dsl-documentation/blob/main/docs/examples/oscake.conf) contains information about default values for OSCake reporter which are project independent: 

`OSCake=configFile=[your_path]/oscake.conf`


#### Used ORT configuration options for the reporter
* option `-c`: ORT uses the file `ort.conf` from the user's directory as default, but can be set also by a commandline parameter: `-c [your_path]/ort.conf`
* option `-i`: path to the scan results: `-i [your_path]/scan-result.yml`
* option `-o`: specifies the output directory: `-o [your_path]`
* option `--license-configuration-file`: path to a a file containing information about licenses and their categories (e.g. *declared* license) `--license-configuration-file=license-classifications.yml`
* option `-f`: name of the report: `-f OScake`

#### Used ORT excludes
ORT has a mechanism ([configuration file](https://github.com/telekom/ort-dsl-documentation/blob/main/docs/examples/.ort.yml)) to control the handling of source code packages in order to exclude them (e.g. because they are only used for testing purposes). Therefore, it is possible to place a file with the name `.ort.yml` directly in the root directory of the source code.

Additional information can be found [here](https://github.com/oss-review-toolkit/ort/blob/master/docs/config-file-ort-yml.md#excluding-scopes)

## Running ORT using TDOSCA [Testcase#5](https://github.com/Open-Source-Compliance/tdosca-tc05-simplhw)

### Preparation 
1. Adapt the ort.conf to your needs - you can use the [example](https://github.com/telekom/ort-dsl-documentation/blob/main/docs/examples/ort.conf) and update the directory entries: `[yourFileStorageDirectory]` and `[yourScannerArchive]`. Specific  information about using commandline options for the scanner can be found [here](https://github.com/telekom/ort-dsl-documentation/blob/main/docs/configuration.md)
2. Be sure that the directory `[yourFileStorageDirectory]` in `ort.conf` is empty. ORT has a mechanism to download only files which were not downloadet yet. As the OSCake-Reporter needs all the source code files, the directory **must be empty** before a new project is processed 
3. Prepare the `license-classifications.yml` [file](https://github.com/telekom/ort-dsl-documentation/blob/main/docs/examples/license-classifications.yml) and adapt it. ORT uses this file to categorize licenses according to the defined categories. The OSCake-Reporter needs the categorization: `instanced`.
4. If you want to exclude some packages from being processed in a default way, create the [file](https://github.com/telekom/ort-dsl-documentation/blob/main/docs/examples/.ort.yml) `.ort.yml`. Depending on the used package manager, ORT can be configured to process the repository according to different scopes; e.g. Maven uses the scope "test" to show which packages are only used for testing the project.
5. Customise the `oscake.conf` [configuration file](https://github.com/telekom/ort-dsl-documentation/blob/main/docs/examples/oscake.conf). Adapt the "scopePatterns" which are responsible to retrieve the scope of the license information of a file (default, directory, file) 
6. Create your [workingDirectory] 
7. Create the [outputDirectory] - it can be a sub directory of your working directory


### Download GIT-Repo
Go to your working directory and clone the repository 

`git clone https://github.com/Open-Source-Compliance/tdosca-tc05-simplhw.git`

A directory `tdosca-tc05-simplhw` containing the requested source code is created.


If you want to exclude some packages copy the file [.ort.yml](https://github.com/telekom/ort-dsl-documentation/blob/main/docs/examples/.ort.yml) to `[workingDirectory]/tdosca-tc05-simplhw/input-sources`

### Analyzer
Go to the installation directory of your ORT instance and run the following command

`cli/build/install/ort/bin/ort -c ort.conf analyze -i [workingDirectory]/tdosca-tc05-simplhw/input-sources -o [outputDirectory]`

ORT will generate the file `analyzer-result.yml` in the [outputDirectory].

### Scanner

Call the following command to start the scan operation

`cli/build/install/ort/bin/ort -c ort.conf scan -i [outputDirectory]/analyzer-result.yml -o [outputDirectory]`

The scanner generates the file `scan-result.yml` and the directories `native-scan-results` and `downloads`. The running time of the scanner depends on the size of the project and the used packages.

### OSCake-Report
Call the following command to create the OSCake input:

`cli/build/install/ort/bin/ort -c ort.conf report -i [outputDirectory]/scan-result.yml -o
[outputDirectory] -f OSCake -O OSCake=nativeScanResultsDir=[outputDirectory]/native-scan-results -O OSCake=sourceCodeDownloadDir=[outputDirectory]/downloads -O OSCake=configFile=oscake.conf
--license-classifications-file=[yourPathTo]/license-classifications.yml`

The reporter combines the different input files and produces the output files:
* [OSCake-Report.oscc](https://github.com/telekom/ort-dsl-documentation/blob/main/docs/examples/OSCake-Report.oscc)
* [tdosca-tc05.zip](https://github.com/telekom/ort-dsl-documentation/blob/main/docs/examples/tdosca-tc05.zip)
