@echo off
setlocal EnableExtensions EnableDelayedExpansion
cd /d "%~dp0"

title Screen Workflow Teacher - Easy Launcher
set "LOG=%CD%\launcher.log"
set "CORE_REQ=requirements-core.txt"
set "APP_MODULE=overlay_teacher.app"

> "%LOG%" echo ==================================================
>> "%LOG%" echo Screen Workflow Teacher launcher started %DATE% %TIME%
>> "%LOG%" echo Working directory: %CD%
>> "%LOG%" echo ==================================================

echo.
echo ========================================
echo  Screen Workflow Teacher
echo ========================================
echo.
echo This launcher installs only the core app by default.
echo Controller packages are optional and work best with Python 3.12.
echo.

call :find_python
if errorlevel 1 goto END

call :check_python_version
if errorlevel 1 goto END

if not exist "%CORE_REQ%" (
  echo ERROR: %CORE_REQ% was not found in this folder.
  echo Make sure you extracted the full zip before running this file.
  >> "%LOG%" echo ERROR: Missing %CORE_REQ%.
  goto END
)

if not exist "src\overlay_teacher\app.py" (
  echo ERROR: App source files were not found.
  echo Expected: src\overlay_teacher\app.py
  echo Make sure you extracted the full zip before running this file.
  >> "%LOG%" echo ERROR: Missing src\overlay_teacher\app.py.
  goto END
)

if not exist ".venv\Scripts\python.exe" (
  echo [1/4] Creating virtual environment...
  >> "%LOG%" echo Creating virtual environment with %PY_CMD%.
  %PY_CMD% -m venv .venv >> "%LOG%" 2>&1
  if errorlevel 1 (
    echo ERROR: Failed to create virtual environment.
    echo Open launcher.log for details.
    goto END
  )
) else (
  echo [1/4] Virtual environment already exists.
)

echo [2/4] Activating virtual environment...
call ".venv\Scripts\activate.bat" >> "%LOG%" 2>&1
if errorlevel 1 (
  echo ERROR: Failed to activate virtual environment.
  echo Open launcher.log for details.
  goto END
)

echo [3/4] Installing/updating core dependencies...
python -m pip install --upgrade pip >> "%LOG%" 2>&1
python -m pip install -r "%CORE_REQ%" >> "%LOG%" 2>&1
if errorlevel 1 (
  echo.
  echo ERROR: Core dependency install failed.
  echo Common fix: install Python 3.12, then delete the .venv folder and run this again.
  echo Open launcher.log for details.
  goto END
)

if /I "%~1"=="--controller" (
  call :install_controller
) else (
  echo       Skipping optional controller packages.
  echo       To try controller support, run: run.bat --controller
)

set "PYTHONPATH=%CD%\src"

echo [4/4] Launching app...
>> "%LOG%" echo Launching: python -m %APP_MODULE%
python -m %APP_MODULE% >> "%LOG%" 2>&1
if errorlevel 1 (
  echo.
  echo ========================================
  echo  ERROR: Application failed to start
  echo ========================================
  echo.
  echo Most common fixes:
  echo  - Run from the extracted folder, not inside the zip preview.
  echo  - Install Python 3.12 if you are on a newer preview version.
  echo  - Delete the .venv folder and run this launcher again.
  echo.
  echo Last launcher log output:
  echo --------------------------------------------------
  type "%LOG%"
  echo --------------------------------------------------
  goto END
)

echo.
echo Application closed normally.
goto END

:find_python
where py >nul 2>nul
if not errorlevel 1 (
  py -3.12 --version >nul 2>nul
  if not errorlevel 1 (
    set "PY_CMD=py -3.12"
  ) else (
    py -3 --version >nul 2>nul
    if not errorlevel 1 set "PY_CMD=py -3"
  )
) else (
  where python >nul 2>nul
  if not errorlevel 1 set "PY_CMD=python"
)

if not defined PY_CMD (
  echo ERROR: Python was not found.
  echo Install Python 3.12 from python.org and check "Add Python to PATH".
  >> "%LOG%" echo ERROR: Python was not found.
  exit /b 1
)

echo Using Python command: %PY_CMD%
>> "%LOG%" echo Using Python command: %PY_CMD%
%PY_CMD% --version
%PY_CMD% --version >> "%LOG%" 2>&1
exit /b 0

:check_python_version
for /f "tokens=2 delims= " %%V in ('%PY_CMD% --version 2^>^&1') do set "PY_VER=%%V"
for /f "tokens=1,2 delims=." %%A in ("%PY_VER%") do (
  set "PY_MAJOR=%%A"
  set "PY_MINOR=%%B"
)

if "%PY_MAJOR%"=="3" (
  if %PY_MINOR% GEQ 14 (
    echo.
    echo WARNING: Python %PY_VER% detected.
    echo The core app may run, but controller packages like pygame may fail.
    echo Python 3.12 is recommended.
    echo.
    >> "%LOG%" echo WARNING: Python %PY_VER% detected. Python 3.12 recommended.
  )
  exit /b 0
)

echo ERROR: Python 3.10 or newer is required. Detected: %PY_VER%
>> "%LOG%" echo ERROR: Unsupported Python version %PY_VER%.
exit /b 1

:install_controller
if not exist "requirements-controller.txt" (
  echo       Controller requirements file not found. Skipping.
  >> "%LOG%" echo Controller requirements file not found. Skipping.
  exit /b 0
)
echo       Installing optional controller packages...
python -m pip install -r requirements-controller.txt >> "%LOG%" 2>&1
if errorlevel 1 (
  echo       Controller package install failed, but the core app can still run.
  echo       For controller support, use Python 3.12 and run this again with --controller.
  >> "%LOG%" echo WARNING: Controller package install failed.
)
exit /b 0

:END
echo.
if /I not "%~1"=="--no-pause" (
  echo Press any key to close this window.
  pause >nul
)
