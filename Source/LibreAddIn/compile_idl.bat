@echo off
if not "%~1"=="__DEBUG__" (
    start cmd /k ""%~f0" __DEBUG__"
    exit /b
)

echo ===================================================
echo     IDL Compilation for LibreOffice Extension
echo ===================================================

set "LO_DIR=C:\Program Files\LibreOffice"
set "COMPILER=%LO_DIR%\sdk\bin\unoidl-write.exe"
set "TYPES_1=%LO_DIR%\program\types.rdb"
set "TYPES_2=%LO_DIR%\program\types\offapi.rdb"

echo [1/2] Checking compiler...
if not exist "%COMPILER%" (
    echo [ERROR] Compiler not found at: "%COMPILER%"
    goto end
)

echo [2/2] Compiling IDL to root stelmofire_types.rdb...
set "PATH=%LO_DIR%\program;%PATH%"
"%COMPILER%" "%TYPES_1%" "%TYPES_2%" "idl\XStElmoFire.idl" "stelmofire.rdb"

if %errorlevel% equ 0 (
    echo ---------------------------------------------------
    echo [SUCCESS] stelmofire.rdb was successfully created in root!
    echo ---------------------------------------------------
) else (
    echo ---------------------------------------------------
    echo [ERROR] IDL Compilation failed. Exit code: %errorlevel%
    echo ---------------------------------------------------
)

:end
echo Press any key to close this window...
pause > nul
exit
