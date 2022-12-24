@echo on

set LATEST_CMD=curl -L -s -H "Accept: application/json" https://github.com/rbtnn/nightlybuild-tabsidebar-for-windows/releases/latest
set LATEST_OUTPUT=
for /F "usebackq delims==" %%o in (`%LATEST_CMD%`) do (
	set LATEST_OUTPUT=%%o
)
set VIMVER=%LATEST_OUTPUT:~27,8%
set ZIPNAME=nightlybuild-tabsidebar-for-windows-%VIMVER%

if not exist %ZIPNAME%.zip (
	curl -s -L https://github.com/rbtnn/nightlybuild-tabsidebar-for-windows/releases/download/%VIMVER%/nightlybuild-tabsidebar-for-windows.zip --output %ZIPNAME%.zip
)

set TASKLIST_OUTPUT=
for /F "usebackq delims==" %%l in (`tasklist /FI "IMAGENAME eq gvim.exe" /NH`) do (
	set TASKLIST_OUTPUT=%%l
)
set TASKLIST_OUTPUT=%TASKLIST_OUTPUT:~0,8%
if "%TASKLIST_OUTPUT%"=="gvim.exe" (
	echo Could not upgrade Vim because gvim.exe process is running now!
	pause
	exit /b 0
)

if not exist %ZIPNAME% (
	powershell -Command "Expand-Archive %ZIPNAME%.zip"
)

if exist "%USERPROFILE%\nightlybuild-tabsidebar-for-windows" (
	rmdir /Q /S "%USERPROFILE%\nightlybuild-tabsidebar-for-windows"
)

xcopy /S /Q /I "%ZIPNAME%\nightlybuild-tabsidebar-for-windows" "%USERPROFILE%\nightlybuild-tabsidebar-for-windows" > NUL

if exist "%ZIPNAME%" (
	rmdir /Q /S "%ZIPNAME%"
)
if exist "%ZIPNAME%.zip" (
	del /Q "%ZIPNAME%.zip"
)

echo Vim has been upgraded!
pause
exit /b 0
