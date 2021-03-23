## OSCake-Reporter

The reporter is implemented in the file [`OSCakeReporter.kt`](https://github.com/telekom/ort/blob/dsl-main/reporter/src/main/kotlin/reporters/OSCakeReporter.kt). In order to be loaded by the tool, the reporter has to be defined in the file [`org.ossreviewtoolkit.reporter.Reporter`](https://github.com/telekom/ort/blob/dsl-main/reporter/src/main/resources/META-INF/services/org.ossreviewtoolkit.reporter.Reporter) and has to implement the interface [`Reporter`](https://github.com/telekom/ort/blob/dsl-main/reporter/src/main/kotlin/Reporter.kt).

## Logging and Error Handling
In general, ORT returns an integer value after program termination. A value of 0 shows that no program relevant errors happened. Logic or semantic problems/errors during the "Analyzer" and "Scan"-steps are directly reported in the output file: `scan_result.yml`:
```
analyzer:
    ...
    has_issues: true|false
scanner:
    ...
    has_issues: true|false
```

Configuration errors concerning the OSCakeReporter lead to the termination of the program with an error message and a return value greater than 0.

Issues of the `OSCakeReporter` are reported in the oscc-file either at the package-level or at the top-level (at the very beginning of the file):
```
{
	"hasIssues": true|false,
	...
```
The occurrence of issues during analyzing or scanning is also propagated to the oscc-file. Detailed information about an issue of the OSCakeReporter is logged in the configured logfile and/or on the console with as much as information possible to determine the origin of the problem.

```
08:42:05.168 INFO OSCakeReporter: [Identifier(type=Maven, namespace=de.tdosca.tc06, name=tdosca-tc06, version=1.0) - ......
```

Different log-levels ("INFO", "WARN", "ERROR") are used to indicate the severity of the problem (according to the definition of levels in [Apache log4j2](https://logging.apache.org/log4j/2.x/). Only problems of severity "WARN" and "ERROR" are reported as `hasIssues` in the oscc-file. A warning or an error on the package-level, automatically leads to the setting of `hasIssues` at the top level.

## Apache log4j2.xml configuration
In order to separate log information from ORT in general and the OSCake-Reporter specifically, the log4j2.xml configuration file is used (found in folder: `cli/src/main/resources`)
The OSCake-Reporter uses the class `org.ossreviewtoolkit.reporter.reporters.osCakeReporterModel.OSCakeLoggerManager` and therefore, the follwing configuration is used (see section "Loggers"):

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
