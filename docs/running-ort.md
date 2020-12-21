# Running ORT with OSCake-Reporter

## Install ORT

* General information about ORT see https://github.com/telekom/ort
* Installation and verification see https://github.com/telekom/ort/blob/dsl-main/docs/getting-started.md#2-download--install-ort

## OSCake-Configuration
In order to use the OSCake-Reporter, several parameters have to be set using the appropriate ORT commandline style. Additionally, a specific configuration file for the reporter is needed. 

### Parameters
ORT handles commandline parameters in several styles:
* General parameters to control the Analyzer, Scanner, etc. e.g. `-c [your_path]/ort.conf` - a complete list can be shown by using the command `[your_install_path]/ort --help`
* Reporter-specific parameters - format: `[name of Reporter]=[name of parameter]=[value of parameter]`

#### Directory path to the result of the scanning process
Information about licenses (reference, tag, notice, text) is kept deeply in the scanner results and are not provided in the general scan output, therefore

`OSCake=nativeScanResultsDir=[your_path]/native-scan-results`

#### Param2

### Files

#### ort.conf

#### license

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
