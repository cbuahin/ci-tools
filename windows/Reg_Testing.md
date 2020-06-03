<!---
   Reg_Testing.md

   Created: Dec 2, 2019
   Updated: Jun 3, 2020

   Author: Michael E. Tryby
           US EPA - ORD/CESER
--->

## Regression Testing SWMM or EPANET locally on Windows


### Dependencies

Before the project can be built and tested the required dependencies must be installed.

**Summary of Build Dependencies: Windows**

  - Build
      - Build Tools for Visual Studio 2017
      - CMake 3.17

  - Regression Test
      - Python 3.7 64 bit
      - curl
      - git
      - 7z

Once Python is present, the following command installs the required packages for regression testing.
```
\> cd < PROJECT_ROOT >
\>pip install -r tools\requirements-< PROJECT >.txt
```


### Build

EPANET can be built with one simple command.
```
\>tools\make.cmd
```


### Regression Test

This command runs regression tests for the local build and compares them to the latest benchmark.
```
\>tools\before-nrtest.cmd
\>tools\run-nrtest.cmd
```