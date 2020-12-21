# Running ORT with OSCake-Reporter
specific settings for the OSCake


## Install ORT

* General information about ORT see https://github.com/telekom/ort
* Installation and verification see https://github.com/telekom/ort/blob/dsl-main/docs/getting-started.md#2-download--install-ort

## OSCake-Configuration
In order to use the OSCake-Reporter, several parameters have to be set using the appropriate ORT commandline style. Additionally, a specific configuration file for the reporter is needed. 

### Parameters
ORT handles commandline parameters in several styles:
* General parameters to control the Analyzer, Scanner, etc. e.g. `-c [your_path]/ort.conf` - a complete list can be shown by using the command `[your_install_path]/ort --help`
* Reporter-specific parameters - format: `[name of Reporter]=[name of parameter]=[value of parameter]`

#### Path to the directory containing results of the scanning process
Information about licenses (reference, tag, notice, text) is kept deeply in the scanner results and are not provided in the general scan output, therefore

`OSCake=nativeScanResultsDir=[your_path]/native-scan-results`

#### Path to the downloaded source code directory
Depending on different criteria (e.g. "declared license") the license text has to be extracted directly from the source files

`OSCake=sourceCodeDownloadDir=[your_path]/downloads`

#### ort.conf


#### Used ORT configuration options
* option `-c`: ORT uses the file `ort.conf` from the user's directory as default but can be set also by a commandline parameter: `-c [your_path]/ort.conf`
* option `-i`: path to the scan results: `-i [your_path]/scan-result.yml`
* option `-o`: specifies the output directory: `-o [your_path]`
* option `--license-configuration-file`: path to a a file containing information about licenses (different categories) `--license-configuration-file=license-classifications.yml`
* option `-f`: name of the report: `-f OScake`

## Running ORT using TDOSCA Testcas#5

### Preparation 

#### IMPORTANT delete storage
 `storages {
      local {
        backend {
          localFileStorage {
            directory = "[your_path]/scannerStorage"
            compression = false
          }
        }
      }
	}`


#### Download GIT-Repo

#### Configuring .ort.conf

### Analyzer

### Scanner

### OSCake-Report

### Example Output: *.oscc
