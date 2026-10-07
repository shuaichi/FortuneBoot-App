# 构建安卓 APK（使用当前鸿蒙修改后的 Dart 代码）
# 用法:
#   .\scripts\build_android.ps1
#   .\scripts\build_android.ps1 -SkipGen
#   .\scripts\build_android.ps1 -SplitPerAbi

param(
    [switch]$SkipGen,
    [switch]$SplitPerAbi,
    [string]$FlutterBin = ""
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $PSScriptRoot
Set-Location $Root

function Resolve-Flutter {
    param([string]$Preferred)

    if ($Preferred -and (Test-Path $Preferred)) {
        return $Preferred
    }
    if ($env:FLUTTER_ROOT -and (Test-Path "$env:FLUTTER_ROOT\bin\flutter.bat")) {
        return "$env:FLUTTER_ROOT\bin\flutter.bat"
    }
    $fromPath = Get-Command flutter -ErrorAction SilentlyContinue
    if ($fromPath) {
        return $fromPath.Source
    }

    $localProps = Join-Path $Root "android\local.properties"
    if (Test-Path $localProps) {
        $line = Get-Content $localProps | Where-Object { $_ -match '^\s*flutter\.sdk=' } | Select-Object -First 1
        if ($line) {
            $sdk = ($line -split '=', 2)[1].Trim()
            $candidate = Join-Path $sdk "bin\flutter.bat"
            if (Test-Path $candidate) { return $candidate }
        }
    }

    throw "未找到 Flutter。请安装 Flutter，或在 android/local.properties 设置 flutter.sdk=..."
}

$flutter = Resolve-Flutter -Preferred $FlutterBin
Write-Host "使用 Flutter: $flutter"

Write-Host "安装依赖..."
& $flutter pub get
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

if (-not $SkipGen) {
    Write-Host "代码生成..."
    & dart run build_runner build --delete-conflicting-outputs
    if ($LASTEXITCODE -ne 0) {
        # 部分环境 dart 不在 PATH，改走 flutter pub run
        & $flutter pub run build_runner build --delete-conflicting-outputs
        if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
    }
    if (Test-Path "tool\generate_l10n.dart") {
        & $flutter pub run tool/generate_l10n.dart
    }
}

$argsList = @("build", "apk", "--release")
if ($SplitPerAbi) {
    $argsList += "--split-per-abi"
}

Write-Host ("开始构建: flutter " + ($argsList -join " "))
& $flutter @argsList
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

$apkDir = Join-Path $Root "build\app\outputs\flutter-apk"
Write-Host ""
Write-Host "构建完成。APK 目录: $apkDir"
if (Test-Path $apkDir) {
    Get-ChildItem $apkDir -Filter *.apk | ForEach-Object { Write-Host ("  - " + $_.FullName) }
}
