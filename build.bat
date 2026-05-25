@echo off
REM ===================================================================
REM Build NguoiDichGiacMo.exe (Windows desktop)
REM Yeu cau: da cai Export Templates trong Godot 4.6.2
REM     Editor → Manage Export Templates → Download & Install
REM ===================================================================

set GODOT="D:\Godot_v4.6.2-stable_win64.exe\Godot_v4.6.2-stable_win64_console.exe"
set PROJECT=%~dp0
set OUT=%PROJECT%builds\NguoiDichGiacMo.exe

if not exist "%PROJECT%builds" mkdir "%PROJECT%builds"

echo === Importing assets ===
%GODOT% --headless --path "%PROJECT%" --editor --quit-after 30

echo === Building Windows .exe ===
%GODOT% --headless --path "%PROJECT%" --export-release "Windows Desktop" "%OUT%"

if exist "%OUT%" (
    echo.
    echo === SUCCESS ===
    echo Build at: %OUT%
    dir "%PROJECT%builds"
) else (
    echo.
    echo === FAILED ===
    echo Hay vao Godot Editor: Project ^> Export ^> Manage Export Templates ^> Download
    echo Roi chay lai build.bat nay.
)
