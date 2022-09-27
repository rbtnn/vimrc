@echo off
setlocal enabledelayedexpansion

call "%~dp0\vim-common.bat" x86
if "%BUILD_ARCH%"=="" goto :FINISH
if "%BUILD_ARCH%"=="x64" set VIM_CPU=AMD64
if "%BUILD_ARCH%"=="x86" set VIM_CPU=i386

@echo on
pushd %TARGET_VIMDIR%\src
    nmake /nologo /f Make_mvc.mak GUI=yes %VIMOPT% clean
    nmake /nologo /f Make_mvc.mak GUI=yes %VIMOPT%
popd
@echo off

:FINISH
if exist pause ( pause )
