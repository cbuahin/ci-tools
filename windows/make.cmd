::
::  make.cmd - builds project
::
::  Created: Oct 15, 2019
::  Updated: May 29, 2020
::
::  Author: Michael E. Tryby
::          US EPA - ORD/CESER
::
::  Requires:
::    Build Tools for Visual Studio download:
::      https://visualstudio.microsoft.com/downloads/
::
::    CMake download:
::      https://cmake.org/download/
::
::  Optional Arguments:
::    /g ("GENERATOR") defaults to "Visual Studio 15 2017"
::    /t builds and runs unit tests (requires Boost)
::


::echo off


:: set global defaults
set "BUILD_HOME=build"
set "PLATFORM=win32"


:: determine project directory
set "CUR_DIR=%CD%"
set "SCRIPT_HOME=%~dp0"
cd %SCRIPT_HOME%
pushd ..
pushd ..
set "PROJ_DIR=%CD%"
popd

:: check for requirements
where cmake > nul
if %ERRORLEVEL% NEQ 0 ( echo "ERROR: cmake not installed" & exit /B 1 )


:: determine project
if not defined PROJECT (
  for %%i in (%PROJ_DIR%) do set PROJECT=%%~ni
  set PROJECT=%PROJECT:~0,-8%
  if not defined PROJECT (
    echo "ERROR: PROJECT could not be determined" & exit /B 1
  )
)

:: GitHub Actions
echo ::set-env name=PROJECT::%PROJECT%


setlocal EnableDelayedExpansion


echo INFO: Building %PROJECT%  ...


:: set local defaults
set "GENERATOR=Visual Studio 15 2017"
set "TESTING=0"

:: process arguments
:loop
if NOT [%1]==[] (
  if "%1"=="/g" (
    set "GENERATOR=%~2"
    shift
  )
  if "%1"=="/t" (
    set "TESTING=1"
  )
  shift
  goto :loop
)


:: if generator has changed delete the build folder
if exist %BUILD_HOME% (
  for /F "tokens=*" %%f in ( 'findstr CMAKE_GENERATOR:INTERNAL %BUILD_HOME%\CmakeCache.txt' ) do (
    for /F "delims=:= tokens=3" %%m in ( 'echo %%f' ) do (
      set CACHE_GEN=%%m
      if not "!CACHE_GEN!" == "!GENERATOR!" ( rmdir /s /q %BUILD_HOME% )
    )
  )
)

:: perform the build
cmake -E make_directory %BUILD_HOME%


if %TESTING% EQU 1 (
  cmake -E chdir ./%BUILD_HOME% cmake -G"%GENERATOR%" -DBUILD_TESTS=ON ..^
  && cmake --build ./%BUILD_HOME% --config Debug^
  & echo. && cmake -E chdir ./%BUILD_HOME% ctest -C Debug --output-on-failure
) else (
  cmake -E chdir ./%BUILD_HOME% cmake -G"%GENERATOR%" -DBUILD_TESTS=OFF ..^
  && cmake --build ./%BUILD_HOME% --config Release --target package
)


endlocal


:: determine platform from CmakeCache.txt file
for /F "tokens=*" %%f in ( 'findstr CMAKE_SHARED_LINKER_FLAGS:STRING %BUILD_HOME%\CmakeCache.txt' ) do (
  for /F "delims=: tokens=3" %%m in ( 'echo %%f' ) do (
    if "%%m" == "X86" ( set "PLATFORM=win32" ) else if "%%m" == "x64" ( set "PLATFORM=win64" )
  )
)
if not defined PLATFORM ( echo "ERROR: PLATFORM could not be determined" & exit /B 1 )


:: GitHub Actions
echo ::set-env name=PLATFORM::%PLATFORM%


:: return to users current dir
cd %CUR_DIR%
