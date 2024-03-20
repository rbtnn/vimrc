@echo off
setlocal enabledelayedexpansion

rem http://yakushima-tonbo.com/windows/windows_keymap_change.htm
rem http://exlight.net/devel/windows/keyboard/index.html

set ScancodeMap="HKLM\SYSTEM\CurrentControlSet\Control\Keyboard Layout"

set ScanCodeMapValue=
rem Header(Version)
set ScanCodeMapValue=%ScanCodeMapValue%00000000
rem Header(Flag)
set ScanCodeMapValue=%ScanCodeMapValue%00000000
rem Entry Count
set ScanCodeMapValue=%ScanCodeMapValue%03000000
rem NOP <- Insert
set ScanCodeMapValue=%ScanCodeMapValue%000052e0
rem Left Ctrl <- CapsLock
set ScanCodeMapValue=%ScanCodeMapValue%1d003a00
rem Null Terminator
set ScanCodeMapValue=%ScanCodeMapValue%00000000

reg add %ScancodeMap% /f /v "Scancode Map"                /t REG_BINARY /d %ScanCodeMapValue%

endlocal
