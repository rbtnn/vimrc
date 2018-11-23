@echo off
setlocal enabledelayedexpansion
call %~dp0vim-0-setup.bat yes
pushd %VIMDIR%
    pushd .\src
        nmake -f Make_mvc.mak %OPT1% %OPT2% %OPT3% FEATURES=HUGE GUI=no %~1 %~2 %~3 %~4 %~5 %~6 %~7 %~8 %~9
    popd
popd
rem pause
endlocal
