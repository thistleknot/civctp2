@echo off
REM ============================================================================
REM  CTP2 Launcher — sets SDL_RENDER_DRIVER=software to prevent Win11 freezing
REM ============================================================================
REM
REM  Place this .bat in your CTP2 install root (next to ctp2_program\)
REM  or edit CTP2_INSTALL below to point at your install.
REM
REM  The GPU-accelerated SDL renderer hangs on Present() on some Win10/11
REM  systems (GitHub issue #432). Software renderer bypasses the GPU entirely.
REM ============================================================================

setlocal

REM --- Edit this if the .bat isn't in the CTP2 install root ---
set "CTP2_INSTALL=%~dp0"
set "CTP2_EXE=%CTP2_INSTALL%ctp2_program\ctp\ctp2.exe"

if not exist "%CTP2_EXE%" (
    echo ERROR: ctp2.exe not found at:
    echo   %CTP2_EXE%
    echo.
    echo Edit CTP2_INSTALL in this script to point at your CTP2 install folder.
    pause
    exit /b 1
)

REM --- Fix for Win11 freezing (GitHub #432) ---
set "SDL_RENDER_DRIVER=software"

REM --- Launch ---
cd /d "%CTP2_INSTALL%"
start "" "%CTP2_EXE%"

endlocal
