@echo off
chcp 65001 >nul
setlocal EnableExtensions

rem 调休补丁生成器：编辑源文件 → 写入安装包 assets
rem
rem 用法：
rem   tool\build_holiday_patch.bat              用默认源文件生成
rem   tool\build_holiday_patch.bat --init       生成示例源文件
rem   tool\build_holiday_patch.bat 源.txt       指定源文件

cd /d "%~dp0\.."

set "PY="
where py >nul 2>&1 && set "PY=py -3"
if not defined PY where python >nul 2>&1 && set "PY=python"
if not defined PY (
  echo [错误] 未找到 Python。请安装 Python 3 并加入 PATH。
  pause
  exit /b 1
)

if "%~1"=="" (
  if not exist "tool\holiday-patch.source.txt" (
    echo 首次运行：正在生成示例源文件...
    %PY% tool\build_holiday_patch.py --init
    if errorlevel 1 (
      pause
      exit /b 1
    )
    echo.
    echo 请编辑 tool\holiday-patch.source.txt 后，再运行本 bat。
    echo 也可以直接按任意键，用示例内容先生成一份 JSON。
    pause
  )
)

echo.
echo 正在编译 assets\calendar\holiday-patch.json ...
%PY% tool\build_holiday_patch.py %*
set "ERR=%ERRORLEVEL%"
echo.
if not "%ERR%"=="0" (
  echo [失败] 退出码 %ERR%
  pause
  exit /b %ERR%
)

echo 完成。请重新打包 App，补丁会随安装包生效。
echo   输出: assets\calendar\holiday-patch.json
echo.
pause
exit /b 0
