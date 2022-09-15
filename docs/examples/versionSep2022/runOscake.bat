@ECHO OFF
SET CASE=tdosca-tc10

SET ORT_DIR=<path>\ort
SET ORT_BINARY=%ORT_DIR%\cli\build\install\ort\bin\ort
SET REPO_DIR=<path>\ort-workspace\%CASE%\input-sources
SET WORKSPACE_DIR=<path>\2022.09 - testcases\%CASE%
SET RESULTS_DIR=%WORKSPACE_DIR%\results
SET CONF_DIR=%WORKSPACE_DIR%\conf

cd %WORKSPACE_DIR%

del "%RESULTS_DIR%\*.oscc"
del "%RESULTS_DIR%\*.zip"

mkdir ".\sources" 
call %ORT_BINARY% -c "%CONF_DIR%\ortPipeline.yml" report ^
    -i .\results\scan-result.yml ^
    -o .\results ^
    -f OSCake ^
    -O OSCake=configFile="%CONF_DIR%\oscakePipeline.yml" ^
    -O OSCake=--license-classifications-file="%CONF_DIR%\license-classifications.yml"

mkdir ".\curations" 
call %ORT_BINARY% -c "%CONF_DIR%\ortPipeline.yml" oscake -a curator ^
    -cI ".\results\OSCake-Report.oscc"  ^
    -cO ".\results" ^
    --ignoreRootWarnings ^

:: SET JAVA_OPTS=-agentlib:jdwp=transport=dt_socket,server=y,suspend=y,address=*:5005 
mkdir ".\resolver" 
call %ORT_BINARY% --info -c "%CONF_DIR%\ortPipeline.yml" oscake -a resolver ^
    -rI ".\results\OSCake-Report_curated.oscc"  ^
    -rO ".\results" ^
    -rA ".\results\analyzer-result.yml" ^
    -rS ".\results\native-scan-results" ^
    --generateTemplate

mkdir ".\selector" 
call %ORT_BINARY% -c "%CONF_DIR%\ortPipeline.yml" oscake -a selector ^
    -sI ".\results\OSCake-Report_curated_resolved.oscc" ^
    -sO ".\results" ^
    --generateSelectorTemplate

mkdir ".\metadatamanager" 
mkdir ".\metadatamanager\distribution" 
mkdir ".\metadatamanager\packageType" 
call %ORT_BINARY% -c "%CONF_DIR%\ortPipeline.yml" oscake -a metadata-manager ^
    -iI ".\results\OSCake-Report_curated_resolved_selected.oscc" ^
    -iO ".\results" ^
    --ignoreFromChecks

call %ORT_BINARY% -c "%CONF_DIR%\ortPipeline.yml" oscake -a deduplicator ^
    -dI ".\results\OSCake-Report_curated_resolved_selected_metadata.oscc"

cd %WORKSPACE_DIR%