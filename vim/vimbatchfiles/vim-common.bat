@echo off

if "%1"=="x86" set BUILD_ARCH=x86
if "%1"=="x64" set BUILD_ARCH=x64
if "%BUILD_ARCH%"==""    goto :FINISH

set TARGET_VIMDIR=%USERPROFILE%\Desktop\vim

set INCLUDE=
set LIBPATH=
set LIB=
set PATH=C:\WINDOWS\system32
set VCVARS=
set CACHE=%~dp0\%BUILD_ARCH%.bat

if exist "%CACHE%" (
    call "%CACHE%"
    goto :FINISH
)

if "%VCVARS%"=="" (
    for /F "usebackq delims==" %%i in (`where /r "%ProgramFiles(x86)%" vcvarsall.bat`) do ( if "%VCVARS%"=="" (set VCVARS=%%i) )
)
if "%VCVARS%"=="" (
    for /F "usebackq delims==" %%i in (`where /r "%ProgramFiles%"      vcvarsall.bat`) do ( if "%VCVARS%"=="" (set VCVARS=%%i) )
)
call "%VCVARS%" %BUILD_ARCH%

echo set INCLUDE=%INCLUDE%> %CACHE%
echo set LIBPATH=%LIBPATH%>> %CACHE%
echo set LIB=%LIB%>> %CACHE%
echo set PATH=%PATH%>> %CACHE%

:FINISH
