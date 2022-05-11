# Running OSCake-Merger
The ORT-module oscake provides a simple mechanism to combine valid OSCake Reporter (and OSCake validated) output files (`\*.oscc`) into a single package for distribution.

## Commandline parameters
The following commandline parameters are available:

```
Options:
* -mI, --inputDirectory PATH  The path to a folder containing oscc files and
                              their corresponding archives. May also consist
                              of subdirectories.
  -mO, --outputDirectory PATH The path to the output folder.
* -c, --cid TEXT              Id of the new Compliance Artifact Collection.
  -mF, --outputFile PATH      Name of the output file. When -o is also
                              specified, the path to the outputFile is
                              stripped to its name.

* denotes required options.
```

Option "-c": An identifier is a string defined by its type, namespace, name and version (e.g. "Maven:joda-time:joda-time:2.10.8" - IVY-format). If no output file is specified (option -mF) the filename is generated based on the ID, whereas ":" are replaced by ".". If the identifier contains characters which are not allowed in filenames (e.g. "\*") the program is aborted.

## Run the "Merger"

Go to the installation directory of your ORT instance and run the following command:

`cli\build\install\ort\bin\ort -c "[path to your ort.conf]/ort.conf" oscake -a merger -mI "[path to the directory containing oscc-files to merge]" -c "[package name in IVY-format]" -mO [path to output directory]`

> Run Merger from Docker using the unzipped [example file](./examples/versionMay2022/ortExample.zip):  
>
> `docker run -v [localPathTo]/ortExample:/project -w /project ort -c ./conf/ort.conf oscake -a merger -mI [path to oscc files] --cid:"[your package id in IVY format]" -mO [path to output directory]`
>
> The option -v mounts the local directory into the folder `/project`. The option -w sets the working directory to `/project`. Consequently, every path in the example is relative to the working directory.

## Processing, Issues & Error Handling

During the processing of the input files, every package is copied into the output file - if it does not already exist. In order to avoid collisions between file references in the zip archive, a unique identifier is prepended to the reference and also to the name of the archived file. The tag `mergedIds`in the resulting `.oscc`-file contains a list of the `cid`s of the merged compliance artifact collections.

In larger projects it may happen that a specific package is contained in more than one input file. In this case, the first occurrence is imported and the content of the second one is checked against it. If there are some differences concerning the license or copyright information, this is logged - different file paths (references to the files in the archive) are ignored.

The logfile `OSCake.log` may be found in the ORT installation directory.
