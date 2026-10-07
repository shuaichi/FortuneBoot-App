@echo off
REM Confirm and write app versionName + versionCode before DevEco packaging.
cd /d "%~dp0.."
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0set_ohos_version.ps1" %*
if errorlevel 1 (
  echo.
  echo Version update failed.
  pause
  exit /b 1
)
echo.
pause
