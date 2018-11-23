@echo on
setlocal enabledelayedexpansion
call %~dp0vim-0-setup.bat
pushd %VIMDIR%
    pushd .\src
        if "%USERPROFILE%" NEQ "" (
            copy /Y "vim.exe" "%VIMWINDIR%"
            copy /Y "gvim.exe" "%VIMWINDIR%"
            rmdir /S /Q "%VIMWINDIR%\runtime"
            mkdir "%VIMWINDIR%\runtime"
            xcopy /S "..\runtime" "%VIMWINDIR%\runtime"
            "%VIMWINDIR%\vim.exe" --noplugin -N -c "helptags ALL | quit!"
        )
    popd
popd
pause
endlocal
