@echo off
chcp 65001 >nul
setlocal

REM ===================================================================
REM Build NguoiDichGiacMo.exe (Windows desktop)
REM Yeu cau: da cai Export Templates trong Godot 4.6.2
REM     Editor -^> Manage Export Templates -^> Download ^& Install
REM ===================================================================

set "GODOT=D:\Godot_v4.6.2-stable_win64.exe\Godot_v4.6.2-stable_win64_console.exe"
set "PROJECT=%~dp0"
set "OUT=%PROJECT%builds\NguoiDichGiacMo.exe"

if not exist "%GODOT%" (
    echo.
    echo [LOI] Khong tim thay Godot tai:
    echo     %GODOT%
    echo Hay sua bien GODOT trong build.bat cho dung duong dan.
    pause
    exit /b 1
)

if not exist "%PROJECT%builds" mkdir "%PROJECT%builds"

echo.
echo === [1/2] Import assets ===
"%GODOT%" --headless --path "%PROJECT%." --editor --quit-after 30

echo.
echo === [2/2] Build Windows .exe ===
"%GODOT%" --headless --path "%PROJECT%." --export-release "Windows Desktop" "%OUT%"

echo.
if exist "%OUT%" (
    echo === SUCCESS ===
    echo File: %OUT%
    dir "%PROJECT%builds"
) else (
    echo === FAILED ===
    echo Co the do chua cai Export Templates.
    echo Mo Godot Editor: Editor -^> Manage Export Templates -^> Download ^& Install
    echo Roi chay lai build.bat nay.
)

echo.
pause
endlocal
