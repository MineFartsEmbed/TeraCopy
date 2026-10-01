@echo off
setlocal enabledelayedexpansion

cd /d "%~dp0"

:: Determine install scope:
:: inside user profile == per-user (no admin), outside == all users (admin).
set "root=%~dp0"
set "rest=!root:%USERPROFILE%=!"
if "!rest!"=="!root!" (set "scope=all") else (set "scope=user")

if "%scope%"=="all" (
    :: All-users unregistration requires admin rights/elevation
    net file 1>NUL 2>NUL
    if not '!errorlevel!' == '0' (
        powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath '%~f0' -Verb RunAs" >NUL 2>&1
        exit /b
    )
    set "switches=/s /u"
) else (
    :: Per-user unregistration via DllInstall() - no elevation needed
    set "switches=/s /n /i:user /u"
)

:: Detect system architecture to select the correct DLLs.
set "arch="
reg query "HKLM\HARDWARE\DESCRIPTION\System\CentralProcessor\0" /v Identifier 2>NUL | findstr /I "ARM" >NUL && set "arch=.arm"
if not defined arch if /I "%PROCESSOR_ARCHITECTURE%"=="x86" if "%PROCESSOR_ARCHITEW6432%"=="" set "arch=.x86"

:: Unregister copy handler
regsvr32 %switches% "%~dp0TeraCopy%arch%.dll"

if errorlevel 1 (
    echo Failed to unregister TeraCopy.dll
) else (
    echo TeraCopy.dll unregistered.
)

:: Unregister context menu dll
regsvr32 %switches% "%~dp0Context%arch%.dll"

if errorlevel 1 (
    echo Failed to unregister Context.dll
) else (
    echo Context.dll unregistered.
)

:: Uninstall TeraCopy package
choice /c YN /n /m "Remove TeraCopy entry from modern context menu? [Y,N] "
if errorlevel 2 goto :SkipModernContextMenu

echo Removing TeraCopy package...
powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-AppxPackage -Name 'TeraCopy' | Remove-AppxPackage"

:: Remove files unpacked from TeraCopy.appx by install.cmd
echo Removing files unpacked from TeraCopy.appx...
del /q "%~dp0AppxManifest.xml" "%~dp0AppxBlockMap.xml" "%~dp0AppxSignature.p7x" "%~dp0priconfig.xml" "%~dp0resources*.pri" "%~dp0[Content_Types].xml" >NUL 2>&1
rmdir /s /q "%~dp0Assets" >NUL 2>&1

pause

:SkipModernContextMenu
