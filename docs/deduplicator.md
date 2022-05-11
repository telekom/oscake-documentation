# Deduplication of OSCake Packages

>**Please note:** 
>1. Packages with licenses defined in REUSE style cannot be deduplicated and stay unchanged during the process!
>2. Due to the goal of information reduction, this process may lead to obfuscate warnings and errors. To get rid of these issues use the Curator first!

The general task of the deduplicator is to consolidate license and copyright definitions in order to reduce the size of the oscc file without losing important information. This is achieved by exploiting the hierarchy of the scope levels: *default-, dir- and file-scope*.

If a file ("file-scope") contains one or more licenses (found in `fileLicenses` list) which matches exactly the license(s) of the next higher scope (dir- or default-scope), the `fileLicenses` and their corresponding archived files are deleted. In other words, the licenses of the dir- or default-scope are valid for all files which are subordinated except for the files which define different file license(s). The hierarchy (superordinated or subordinated) is based on a comparison of the paths found in the different scopes. The same mechanism is applied between different "dir-scopes" and between "dir-scopes" and the "default-scope". The deduplication of copyrights follows the same logic. As a result, dir- and file-scopes may contain empty license lists (`fileLicenses`) and empty copyrights list (`fileCopyrights`) and are removed completely.

### Configuration

The deduplication configuration is defined in the `ort.conf` file:

```
oscake {
	deduplicator {
		hideSections = [] #["config", "reuselicensings", "dirlicensings", "filelicensings"]
		processPackagesWithIssues = true
		createUnifiedCopyrights = false
		keepEmptyScopes = false
		preserveFileScopes = true
		compareOnlyDistinctLicensesCopyrights = false
	}
}

```

1. Specific sections of the oscc-file can be removed when setting "hideSections":

	`hideSections = ["config", "reuselicensings", "dirlicensings", "filelicensings"]`
	
	default value: `[]` = empty list

2. Packages in oscc-files will be processed even if they contain issues on "WARN"- or "ERROR"-level. In order to exclude them, the setting of "processPackagesWithIssues" can be used:

	`processPackagesWithIssues = false`
	
	default value: `true`

3. The amount of copyright statements, which cannot be deduplicated, often leads to a large oscc output file. By using the setting "createUnifiedCopyrights" the size can be reduced substantially, because all copyrights of a package are collected and assigned to the json tag: `unifiedCopyrights`. Every other occurrence of a copyright (default-, dir- and file scope) is deleted. Every resulting "FileLicensing" or "DirLicensing" with empty licenses and copyrights are deleted, too.

	`createUnifiedCopyrights = true`
	
	default value: `false`

4. When deduplicating `fileLicensing` or `dirLicensing`, empty licenses and copyrights are removed. These entries can be preserved by setting "keepEmptyScopes" 

	`keepEmptyScopes = true`
	
	default value: `false`

5. The deduplication process often leads to `fileLicensing`s with empty licenses or copyrights and are removed. By setting "preserveFileScopes", files which are also contained in `defaultLicenses`, `defaultCopyrights`, `dirLicenses` or `dirCopyrights` will be preserved.

	`preserveFileScopes = false`
	
	default value: `true`

6. Sometimes `defaultLicenses` or `dirLicenses` contain multiple equal entries (e.g. when the same license is found in different files, where each of them opens a "defaultLicense" or "dirLicense"). Consequently, if a file contains only one of them it will not be deduplicated. In order to enable the deduplication for such entries the follwing configuration can be set:

	`compareOnlyDistinctLicensesCopyrights = true`

	default value: `false`
	
## Run the Deduplicator

The Deduplicator uses the commandline option `-if` to get the oscc-file to work on. After checking the existence of the oscc-file and its corresponding archive file (.zip), the deduplication process is started.

Go to the installation directory of your ORT instance and run the following command:

`cli\build\install\ort\bin\ort -c "[path to your ort.conf]/ort.conf" oscake -a deduplicator -dI "[path to the oscc-file]"`

The output files are stored in the same directory as the input files (e.g. if the oscc file is called `OSCake-Report.oscc` the resulting file is called `OSCake-Report_dedup.oscc`; the archive file also gets the suffix `_dedup`).

> Run Deduplicator from Docker using the unzipped [example file](./examples/versionMay2022/ortExample.zip):  
>
> `docker run -v [localPathTo]/ortExample:/project -w /project ort -c ./conf/ort.conf oscake -a deduplicator -dI ./results/OSCake-Report_curated_resolved_selected_metadata.oscc`
>
> The option -v mounts the local directory into the folder `/project`. The option -w sets the working directory to `/project`. Consequently, every path in the example is relative to the working directory. ORT will generate the file `analyzer-result.yml` in the subdirectory `./results`


## Examples
The examples show selected sections of the oscc-file based on [Testcase#6](https://github.com/Open-Source-Compliance/tdosca-tc06-plainhw.git)

### Example with default configuration settings - license deduplication via default-scope
Part of the original oscc-file:

```
...
{
	"pid": "joda-time",
...
	"defaultLicenses": [
		{
			"foundInFileScope": "LICENSE.txt",
			"license": "Apache-2.0",
			"licenseTextInArchive": "Maven%joda-time%joda-time%2.10.8%LICENSE.txt.Apache-2.0",
			"hasIssues": false
		},
		{
			"foundInFileScope": "NOTICE.txt",
			"license": "Apache-2.0",
			"hasIssues": false
		}
	],
...
	"fileLicensings": [
...	
		{
			"fileScope": "src/main/java/org/joda/time/overview.html",
			"fileLicenses": [
				{
					"license": "Apache-2.0",
					"licenseTextInArchive": null
				},
				{
					"license": "Apache-2.0",
					"licenseTextInArchive": null
				}
			],
			"fileCopyrights": [
				{
					"copyright": "Copyright 2001-2010 Stephen Colebourne"
				}
			]
		},
...
```
The file `overview.html` contains two licenses - exactly the same count of licenses and exactly the same licenses as in `defaultLicenses`, therefore, the `fileLicenses` are removed during deduplication (the list is empty):
```
...
	"fileLicensings": [
		{
			"fileScope": "src/main/java/org/joda/time/overview.html",
			"fileLicenses": [],
			"fileCopyrights": [
				{
					"copyright": "Copyright 2001-2010 Stephen Colebourne"
				}
			]
		},
```
### Example with default configuration settings - copyright deduplication (via dir scope)
Part of the original oscc-file:

```
	"pid": "tdosca-tc06",
...
	"defaultLicenses": [
...
	],
	"defaultCopyrights": [
...
	],
	"dirLicensings": [
		{
			"dirScope": "src/main/java/de/tdosca/common",
			"dirLicenses": [
				{
					"foundInFileScope": "src/main/java/de/tdosca/common/LICENSE",
					"license": "BSD-3-Clause",
					"licenseTextInArchive": "Maven%de.tdosca.tc06%tdosca-tc06%1.0%input-sources%src%main%java%de%tdosca%common%LICENSE.BSD-3-Clause",
					"hasIssues": false
				}
			],
			"dirCopyrights": [
				{
					"foundInFileScope": "src/main/java/de/tdosca/common/LICENSE",
					"copyright": "Copyright (c) 2020 kreincke / Deutsche Telekom AG"
				}
			]
		}
	],
	"fileLicensings": [
...
		{
			"fileScope": "src/main/java/de/tdosca/common/Tipster.java",
			"fileLicenses": [
				{
					"license": "BSD-3-Clause",
					"licenseTextInArchive": null
				},
				{
					"license": "NOASSERTION",
					"licenseTextInArchive": null
				}
			],
			"fileCopyrights": [
				{
					"copyright": "Copyright (c) 2020 kreincke / Deutsche Telekom AG"
				}
			]
		},
...		
```
The file `Tipster.java` contains the licenses "BSD-3-Clause" and "NOASSERTION". Based on the file-path `src/main/java/de/tdosca/common` the deduplicator finds a corresponding `dirLicensing` for it. As the licenses do not match, they are not deduplicated. On the contrary the `fileCopyrights` of the `Tipster.java` file matches exactly the `dirCopyrights` and therefore, the entry is removed.
```
...
		{
			"fileScope": "src/main/java/de/tdosca/common/Tipster.java",
			"fileLicenses": [
				{
					"license": "BSD-3-Clause",
					"licenseTextInArchive": null
				},
				{
					"license": "NOASSERTION",
					"licenseTextInArchive": null
				}
			],
			"fileCopyrights": []
		},
...
```

### Example with default configuration settings, but "preserveFileScopes = false" - license deduplication (via dir scope)
Part of the original oscc-file:

```
	"pid": "tdosca-tc06",
...
	"defaultLicenses": [
	],
...
	"defaultCopyrights": [
	],
...
	"dirLicensings": [
		{
			"dirScope": "src/main/java/de/tdosca/common",
			"dirLicenses": [
				{
					"foundInFileScope": "src/main/java/de/tdosca/common/LICENSE",
					"license": "BSD-3-Clause",
					"licenseTextInArchive": "Maven%de.tdosca.tc06%tdosca-tc06%1.0%input-sources%src%main%java%de%tdosca%common%LICENSE.BSD-3-Clause",
					"hasIssues": false
				}
			],
			"dirCopyrights": [
				{
					"foundInFileScope": "src/main/java/de/tdosca/common/LICENSE",
					"copyright": "Copyright (c) 2020 kreincke / Deutsche Telekom AG"
				}
			]
		}
	],
	"fileLicensings": [
...
		{
			"fileScope": "src/main/java/de/tdosca/common/LICENSE",
			"fileContentInArchive": "Maven%de.tdosca.tc06%tdosca-tc06%1.0%input-sources%src%main%java%de%tdosca%common%LICENSE",
			"fileLicenses": [
				{
					"license": "BSD-3-Clause",
					"licenseTextInArchive": "Maven%de.tdosca.tc06%tdosca-tc06%1.0%input-sources%src%main%java%de%tdosca%common%LICENSE.BSD-3-Clause"
				}
			],
			"fileCopyrights": [
				{
					"copyright": "Copyright (c) 2020 kreincke / Deutsche Telekom AG"
				}
			]
		},
...
```
When set `preserveFileScopes = true` nothing would be changed in the above example, but when set to `false` the whole `fileScope` for the file `src/main/java/de/tdosca/common/LICENSE` is removed, because this `fileScope` belongs - based on path comparison - to the `dirLicensings` entry for `"dirScope": "src/main/java/de/tdosca/common"`. The configuration `preserveFileScopes` affects only files which are responsible for a default-scope- or dir-scope-entry.

### Example with default configuration settings, but "createUnifiedCopyrights = true"
Part of the original oscc-file:
```
...
	"pid": "log4j-core",
	"defaultLicenses": [
...
	],
	"defaultCopyrights": [
		{
			"foundInFileScope": "LICENSE.txt",
			"copyright": "Copyright 1999-2005 The Apache Software Foundation"
		},
		{
			"foundInFileScope": "NOTICE.txt",
			"copyright": "Copyright 1999-2017 Apache Software Foundation"
		},
		{
			"foundInFileScope": "NOTICE.txt",
			"copyright": "Copyright 2002-2012 Ramnivas Laddad, Juergen Hoeller, Chris Beams"
		},
		{
			"foundInFileScope": "NOTICE.txt",
			"copyright": "Copyright 2004 Jason Paul Kitchen"
		},
		{
			"foundInFileScope": "NOTICE.txt",
			"copyright": "Copyright 2005-2006 Tim Fennell"
		},
		{
			"foundInFileScope": "NOTICE.txt",
			"copyright": "Copyright 2017 Remko Popma"
		}
	],
	"dirLicensings": [
		{
			"dirScope": "log4j-core/src/test/resources/META-INF",
			"dirLicenses": [
...
			],
			"dirCopyrights": [
				{
					"foundInFileScope": "log4j-core/src/test/resources/META-INF/LICENSE",
					"copyright": "Copyright 1999-2005 The Apache Software Foundation"
				},
				{
					"foundInFileScope": "log4j-core/src/test/resources/META-INF/NOTICE",
					"copyright": "Copyright 1999-2012 Apache Software Foundation"
				},
				{
					"foundInFileScope": "log4j-core/src/test/resources/META-INF/NOTICE",
					"copyright": "Copyright 2004 Jason Paul Kitchen"
				}
			]
		},
		{
			"dirScope": "log4j-core/src/main/resources/META-INF",
			"dirLicenses": [
	...
			],
			"dirCopyrights": [
				{
					"foundInFileScope": "log4j-core/src/main/resources/META-INF/NOTICE",
					"copyright": "Copyright 1999-2012 Apache Software Foundation"
				},
				{
					"foundInFileScope": "log4j-core/src/main/resources/META-INF/NOTICE",
					"copyright": "Copyright 2005-2006 Tim Fennell"
				},
				{
					"foundInFileScope": "log4j-core/src/main/resources/META-INF/LICENSE",
					"copyright": "Copyright 1999-2005 The Apache Software Foundation"
				}
			]
		},
		{
			"dirScope": "log4j-core/src/test/java/org/apache/logging/dumbster/smtp/readme.txt",
			"dirLicenses": [],
			"dirCopyrights": [
				{
					"foundInFileScope": "log4j-core/src/test/java/org/apache/logging/dumbster/smtp/readme.txt",
					"copyright": "Copyright 2004 Jason Paul Kitchen"
				}
			]
		}
	],
	"fileLicensings": [
		{
			"fileScope": "log4j-core/src/test/resources/META-INF/LICENSE",
			"fileContentInArchive": "Maven%org.apache.logging.log4j%log4j-core%2.14.0%log4j-core%src%test%resources%META-INF%LICENSE",
			"fileLicenses": [
				{
					"license": "Apache-2.0",
					"licenseTextInArchive": "Maven%org.apache.logging.log4j%log4j-core%2.14.0%log4j-core%src%test%resources%META-INF%LICENSE.Apache-2.0"
				}
			],
			"fileCopyrights": [
				{
					"copyright": "Copyright 1999-2005 The Apache Software Foundation"
				}
			]
		},
```

The setting of this parameter results in a new section called `unifiedCopyrights` for every package and the deletion of all copyright entries in default-, dir- and file-scope.
```
...
	"pid": "log4j-core",
...
	"defaultLicenses": [],
	"defaultCopyrights": [],
	"unifiedCopyrights": [
		"Copyright (c) 2017 public",
		"Copyright 1999-2005 The Apache Software Foundation",
		"Copyright 1999-2012 Apache Software Foundation",
		"Copyright 1999-2017 Apache Software Foundation",
		"Copyright 2002-2012 Ramnivas Laddad, Juergen Hoeller, Chris Beams",
		"Copyright 2004 Jason Paul Kitchen",
		"Copyright 2005-2006 Tim Fennell",
		"Copyright 2007-present the original author or authors",
		"Copyright 2011 LMAX Ltd.",
		"Copyright 2015 Apache Software Foundation",
		"Copyright 2017 Remko Popma",
		"Copyright Terracotta, Inc."
	],
	"fileLicensings": [
		{
			"fileScope": "log4j-core/src/test/resources/META-INF/LICENSE",
			"fileContentInArchive": "Maven%org.apache.logging.log4j%log4j-core%2.14.0%log4j-core%src%test%resources%META-INF%LICENSE",
			"fileLicenses": [
				{
					"license": "Apache-2.0",
					"licenseTextInArchive": "Maven%org.apache.logging.log4j%log4j-core%2.14.0%log4j-core%src%test%resources%META-INF%LICENSE.Apache-2.0"
				}
			],
			"fileCopyrights": []
		},
...
```
