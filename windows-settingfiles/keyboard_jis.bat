@echo off
setlocal enabledelayedexpansion

set Keyboard="HKLM\SYSTEM\CurrentControlSet\services\i8042prt\Parameters"
reg add %Keyboard%  /f /v "PollingIterations"           /t REG_DWORD  /d 0x00002ee0
reg add %Keyboard%  /f /v "PollingIterationsMaximum"    /t REG_DWORD  /d 0x00002ee0
reg add %Keyboard%  /f /v "ResendIterations"            /t REG_DWORD  /d 0x00000003
reg add %Keyboard%  /f /v "LayerDriver JPN"             /t REG_SZ     /d "kbd106.dll"
reg add %Keyboard%  /f /v "LayerDriver KOR"             /t REG_SZ     /d "kbd101a.dll"
reg add %Keyboard%  /f /v "OverrideKeyboardIdentifier"  /t REG_SZ     /d "PCAT_106KEY"
reg add %Keyboard%  /f /v "OverrideKeyboardType"        /t REG_DWORD  /d 0x00000007
reg add %Keyboard%  /f /v "OverrideKeyboardSubtype"     /t REG_DWORD  /d 0x00000002

endlocal
