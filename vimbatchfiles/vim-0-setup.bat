@echo off

rem https://www.microsoft.com/en-us/download/details.aspx?id=8279

set VIMDIR=%USERPROFILE%\Desktop\vim
set VIMWINDIR=%USERPROFILE%\vim-on-windows

If "%1"=="yes" (goto SETUPVC) ELSE (goto FINISH)

:SETUPVC
    set VCVARS=%ProgramFiles(x86)%\Microsoft Visual Studio\2017\Professional\VC\Auxiliary\Build\vcvars32.bat
    set USERNAME=rbtnn

    set SDK_INCLUDE_DIR="%ProgramFiles(x86)%\Microsoft SDKs\Windows\v7.1A\Include"

    set OPT1= IME=yes MBYTE=yes ICONV=yes CSCOPE=yes DEBUG=no NETBEANS=no XPM=no USE_MSVCRT=1
    set OPT2= SDK_INCLUDE_DIR=%SDK_INCLUDE_DIR%
    set OPT3= CLPUM=yes
    rem DYNAMIC_PYTHON=yes PYTHON3_VER=37 DYNAMIC_PYTHON3=yes PYTHON3=%USERPROFILE%\AppData\Local\Programs\Python\Python37-32

    set PATH=%SystemRoot%
    set PATH=%PATH%;%SystemRoot%\System32
    set PATH=%PATH%;%SystemRoot%\System32\Wbem
    rem for diff.exe
    set PATH=%PATH%;C:\Program Files\Git\usr\bin

    set INCLUDE=
    set LIBPATH=

    if "%VCVARS%"=="" (
        for /F "usebackq delims==" %%i in (`where /r "%ProgramFiles(x86)%" vcvars32.bat`) do ( if "%VCVARS%"=="" (set VCVARS=%%i) )
        for /F "usebackq delims==" %%i in (`where /r "%ProgramFiles%"      vcvars32.bat`) do ( if "%VCVARS%"=="" (set VCVARS=%%i) )
    )
    if NOT "%VCVARS%"=="" (
        call "%VCVARS%"
    )

:FINISH
