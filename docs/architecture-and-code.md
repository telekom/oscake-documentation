# OSCake-Reporter

The reporter is implemented in the file [`OSCakeReporter.kt`](https://github.com/telekom/ort/blob/oscake-reporter/reporter/src/main/kotlin/reporters/OSCakeReporter.kt). In order to be loaded by the tool, the reporter has to be defined in the file [`org.ossreviewtoolkit.reporter.Reporter`](https://github.com/telekom/ort/blob/oscake-reporter/reporter/src/main/resources/META-INF/services/org.ossreviewtoolkit.reporter.Reporter) and has to implement the interface [`Reporter`](https://github.com/telekom/ort/blob/oscake-reporter/reporter/src/main/kotlin/Reporter.kt).

### Logging and Error Handling
In general, ORT returns an integer value after program termination. A value of 0 shows that no program relevant errors happened. Logical or semantic problems/errors during the "Analyzer" and "Scan"-steps are directly reported in the output file: `scan_result.yml`:
```
analyzer:
    ...
    has_issues: true|false
scanner:
    ...
    has_issues: true|false
```

Configuration errors concerning the OSCakeReporter lead to the termination of the program with an error message and a return value greater than 0.

Issues of the `OSCakeReporter` are reported in the oscc-file either at the root-level, the package-level, the default-scope-level or at the directory-scope-level:
```
{
	"hasIssues": true|false,
	...
```
The occurrence of issues during analyzing or scanning is also propagated to the oscc-file. Detailed information about an issue of the OSCakeReporter is logged in the configured logfile and/or on the console with as much as information possible to determine the origin of the problem.

```
11:07:30.607 WARN  OSCakeReporter: <<POST>> [Identifier(type=Maven, namespace=com.sun.activation, name=jakarta.activation, version=1.2.2)]: Declared license: <BSD-3-Clause> is instanced license - no license text provided! - jsonPath: "$.complianceArtifactPackages[?(@.pid=='jakarta.activation')]"
```

The messages are structured as follows:
- actual DateTimeStamp
- log level: INFO, WARN, ERROR
- name of the originator
- processing phase: in double angular brackets
- message text
- path to the package, where the error occured as jsonPath-expression (only reported when the `includeJsonPathInLogfile4ErrorsAndWarnings` in `oscake.conf` is set 

Different log-levels ("INFO", "WARN", "ERROR") are used to indicate the severity of the problem (according to the definition of levels in [Apache log4j2](https://logging.apache.org/log4j/2.x/) ). Only problems of severity "WARN" and "ERROR" are reported as `hasIssues` in the oscc-file. A warning or an error on the package-level or below (default-scope, dir-scope), automatically leads to the setting of `hasIssues` at the top level.

### Apache log4j2.xml configuration
In order to separate log information from ORT in general and the OSCake-Reporter specifically, the log4j2.xml configuration file is used (found in folder: `cli/src/main/resources`)
The OSCake-Reporter uses the class `org.ossreviewtoolkit.reporter.reporters.osCakeReporterModel.OSCakeLoggerManager` and therefore, the following configuration is applied (see section "Loggers"):

```
<?xml version="1.0" encoding="UTF-8"?>
<Configuration status="WARN">
  <Appenders>
    <Console name="Console" target="SYSTEM_OUT">
      <PatternLayout pattern="%d{HH:mm:ss.SSS} [%t] %-5level %logger{36} - %msg%n"/>
    </Console>
    <Console name="Console2" target="SYSTEM_OUT">
      <PatternLayout pattern="%d{HH:mm:ss.SSS} %-5level %msg%n"/>
    </Console>
    <File name="LogFile" fileName="OSCake.log" append="false">
      <PatternLayout pattern="%d{HH:mm:ss.SSS} %-5level %msg%n"/>
    </File>
  </Appenders>
  <Loggers>
    <Logger name="org.ossreviewtoolkit.reporter.reporters.osCakeReporterModel.OSCakeLoggerManager" level="info" additivity="false">
      <AppenderRef ref="Console2"/>
      <AppenderRef ref="LogFile"/>
    </Logger>
    <Root level="warn">
      <AppenderRef ref="Console"/>
    </Root>
  </Loggers>
</Configuration>
```
The issues are documented in the file `OSCake.log` and on the `Console2`, too. The logfile can be found in the current working directory.

#### Alternative log4j2.xml configuration file
In case that a specific configuration file for log4j2 should be used, a JVM parameter may be passed: `-Dlog4j.configurationFile=[path to the configuration file]`.
As the ORT tool is started by means of a script - found in `ort/cli/build/scripts` - this parameter can be passed in the following way (example for Windows-based systems):
```
set ORT_OPTS="-Dlog4j.configurationFile=[path to the configuration file]"

cli\build\install\ort\bin\ort [all your parameters]
```

#### Alternative path in log4j2.xml for the output file
Another way to pass a value to the default log4j2.xml file is to pass it as an environment variable (example for Windows-based systems):

`set log4jOutputFolder=[path to the output folder]`

This variable can then be used in the log4j2.xml in the following way:

```
<File name="LogFile" fileName="${sys:log4jOutputFolder}OSCake.log" append="false">
```

# ORT-Module: OSCake

The OSCake-applications: Curator, Deduplicator and Merger are implemented in the ORT-Module with the name "oscake" and done by the following steps:

1. Add a new module to the project (in IntelliJ via "Project Structure -> Project Settings -> Modules")
2. Add the file `build.gradle.kts` in the root folder of the module and put the dependencies inside
3. ORT-Module `model`: add property `val oscake: OSCakeConfiguration = OSCakeConfiguration()` at the end of the `data class OrtConfiguration` in the subfolder `config`.
4. ORT-Module `model`: add class `OSCakeConfiguration.kt` containing the config definitions for the oscake applications
5. ORT-Module `cli`:
	- OrtMain.kt: add `OSCakeCommand()` to the `subcommands`- list
	- add `OSCakeCommand.kt` in the subfolder `commands`; this kotlin file contains the logic for the different commandline options. The selection of a specific OSCake application is done via the ORT-option: `--app` or `-a` (also defined in this class file). The `run` method validates the set options and starts the selected application.
6. ORT-Module `oscake`: this module contains a kotlin class for every application (`OSCakeCurator.kt`, `OSCakeDeduplicator.kt`, `OSCakeMerger.kt`) and the class `OSCakeApplication.kt`, which contains properties and functions used by all of them. Furthermore, every application has its own subfolder where to put the application specific code inside.