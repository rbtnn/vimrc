@echo on
setlocal enabledelayedexpansion
call %~dp0vim-0-setup.bat
pushd %VIMDIR%
     git co tabsidebar
     git pull
     git merge vim/master
popd
if exist pause ( pause )
endlocal
