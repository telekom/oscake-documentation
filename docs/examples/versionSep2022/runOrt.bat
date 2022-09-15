@ECHO OFF
SET CASE=tdosca-tc11

SET ORT_DIR=<path>\ort
SET ORT_BINARY=%ORT_DIR%\cli\build\install\ort\bin\ort
SET REPO_DIR=<path>\ort-workspace\%CASE%\input-sources
SET WORKSPACE_DIR=<path>\2022.09 - testcases\%CASE%
SET RESULTS_DIR=%WORKSPACE_DIR%\results
SET CONF_DIR=%WORKSPACE_DIR%\conf

cd %WORKSPACE_DIR%

::ensure scannerRaw dir exists so files are cached
mkdir ".\scanner\scannerRaw" 

del "%RESULTS_DIR%\analyzer-result.yml"
call %ORT_BINARY% --info -c "%CONF_DIR%\ortPipeline.yml" analyze -i "%REPO_DIR%" -o .\results\
del "%RESULTS_DIR%\scan-result.yml"
call %ORT_BINARY% --info -c "%CONF_DIR%\ortPipeline.yml" scan -i .\results\analyzer-result.yml -o .\results\ --skip-excluded

cd %WORKSPACE_DIR%