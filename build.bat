@echo off
REM ============================================================================
REM  CTP2 Final-SDL Build Script
REM  Builds the Call To Power 2 engine with SDL renderer (fixes Win11 freezing)
REM ============================================================================
REM
REM  PREREQUISITES:
REM    1. Visual Studio 2017+ with C++ Desktop workload
REM       (v141 toolset, or retarget to your installed version)
REM    2. Windows SDK 10.0.19041.0 or later
REM    3. Git clone of https://github.com/civctp2/civctp2
REM
REM  USAGE:
REM    build.bat              -- builds Final-SDL|Win32 (default)
REM    build.bat x64          -- builds Final-SDL|x64
REM    build.bat Debug-SDL    -- builds Debug-SDL|Win32
REM
REM  OUTPUT:
REM    ctp2_code\ctp\Final-SDL\ctp2.exe   (Win32)
REM    ctp2_code\ctp\x64\Final-SDL\ctp2.exe (x64)
REM
REM  AFTER BUILD:
REM    Copy ctp2.exe to your CTP2 install: ctp2_program\ctp\ctp2.exe
REM    Set environment variable: SDL_RENDER_DRIVER=software
REM    (This fixes the Win11 freezing issue -- GPU renderer hangs on present)
REM ============================================================================

setlocal

REM --- Configuration (edit these to match your system) ---
set "SRC_ROOT=%~dp0"
set "SOLUTION=%SRC_ROOT%ctp2_code\ctp\civctp.sln"
set "CONFIGURATION=Final-SDL"
set "PLATFORM=Win32"

REM --- Parse arguments ---
if /i "%~1"=="x64"       set "PLATFORM=x64"
if /i "%~1"=="Debug-SDL" set "CONFIGURATION=Debug-SDL"
if /i "%~1"=="debug"     set "CONFIGURATION=Debug-SDL"

REM --- Find MSBuild ---
set "MSBUILD="

REM Try VS2022/2025 (vswhere)
set "VSWHERE=%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe"
if exist "%VSWHERE%" (
    for /f "usebackq tokens=*" %%i in (`"%VSWHERE%" -latest -requires Microsoft.Component.MSBuild -find MSBuild\**\Bin\MSBuild.exe`) do (
        set "MSBUILD=%%i"
    )
)

REM Fallback: well-known VS paths
if "%MSBUILD%"=="" if exist "C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe" (
    set "MSBUILD=C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe"
)
if "%MSBUILD%"=="" if exist "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\MSBuild\Current\Bin\MSBuild.exe" (
    set "MSBUILD=C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\MSBuild\Current\Bin\MSBuild.exe"
)

if "%MSBUILD%"=="" (
    echo ERROR: MSBuild not found. Install Visual Studio with C++ Desktop workload.
    exit /b 1
)

echo.
echo  CTP2 Build Configuration
echo  ========================
echo  Source:        %SRC_ROOT%
echo  Solution:      %SOLUTION%
echo  Configuration: %CONFIGURATION%
echo  Platform:      %PLATFORM%
echo  MSBuild:       %MSBUILD%
echo.

REM --- Build ---
"%MSBUILD%" "%SOLUTION%" /p:Configuration="%CONFIGURATION%" /p:Platform="%PLATFORM%" /m /v:minimal

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo  BUILD FAILED (exit code %ERRORLEVEL%)
    echo.
    echo  Common fixes:
    echo    - Install v141 toolset: VS Installer ^> Individual Components ^> "MSVC v141"
    echo    - Or retarget: right-click solution in VS ^> Retarget Projects
    echo    - Missing Windows SDK: install via VS Installer
    exit /b %ERRORLEVEL%
)

echo.
echo  BUILD SUCCEEDED
echo.
echo  Output: %SRC_ROOT%ctp2_code\ctp\%CONFIGURATION%\ctp2.exe
echo.
echo  To install:
echo    copy "%SRC_ROOT%ctp2_code\ctp\%CONFIGURATION%\ctp2.exe" "YOUR_CTP2_INSTALL\ctp2_program\ctp\ctp2.exe"
echo.
echo  To fix Win11 freezing, set before launch:
echo    set SDL_RENDER_DRIVER=software
echo.

endlocal
