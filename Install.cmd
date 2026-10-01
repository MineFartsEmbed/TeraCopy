@echo off
setlocal enabledelayedexpansion

cd /d "%~dp0"

:: Determine install scope:
:: inside user profile == per-user (no admin), outside == all users (admin).
set "root=%~dp0"
set "rest=!root:%USERPROFILE%=!"
if "!rest!"=="!root!" (set "scope=all") else (set "scope=user")

if "%scope%"=="all" (
    :: All-users registration requires admin rights/elevation
    net file 1>NUL 2>NUL
    if not '!errorlevel!' == '0' (
        powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath '%~f0' -Verb RunAs" >NUL 2>&1
        exit /b
    )
    set "switches=/s"
) else (
    :: Per-user registration via DllInstall() - no elevation needed
    set "switches=/s /n /i:user"
)

:: Detect system architecture to select the correct DLLs.
set "arch="
reg query "HKLM\HARDWARE\DESCRIPTION\System\CentralProcessor\0" /v Identifier 2>NUL | findstr /I "ARM" >NUL && set "arch=.arm"
if not defined arch if /I "%PROCESSOR_ARCHITECTURE%"=="x86" if "%PROCESSOR_ARCHITEW6432%"=="" set "arch=.x86"

:: Register copy handler
regsvr32 %switches% "%~dp0TeraCopy%arch%.dll"
if errorlevel 1 (
    echo Failed to register TeraCopy.dll
) else (
    echo TeraCopy.dll registered.
)

:: Register context menu dll
regsvr32 %switches% "%~dp0Context%arch%.dll"
if errorlevel 1 (
    echo Failed to register Context.dll
) else (
    echo Context.dll registered.
)

:: Register TeraCopy.appx
choice /c YN /n /m "Add TeraCopy entry to modern context menu? [Y,N] "
if errorlevel 2 goto :SkipModernContextMenu

if not exist "%~dp0TeraCopy.appx" (
    echo TeraCopy.appx not found, skipping.
    goto :SkipModernContextMenu
)

:: Unpack the appx file
echo Unpacking TeraCopy.appx...
powershell -NoProfile -ExecutionPolicy Bypass -Command "Add-Type -AssemblyName System.IO.Compression.FileSystem; [System.IO.Compression.ZipFile]::ExtractToDirectory('%~dp0TeraCopy.appx', '%~dp0')"

echo Installing TeraCopy package...
powershell -NoProfile -ExecutionPolicy Bypass -Command "Add-AppxPackage -Path '%~dp0TeraCopy.appx' -ExternalLocation '%~dp0'"

pause

:SkipModernContextMenu
