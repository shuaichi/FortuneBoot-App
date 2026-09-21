#Requires -Version 5.1
# Confirm versionName + versionCode before DevEco packaging.

[CmdletBinding()]
param(
  [string]$VersionName,
  [string]$BuildNumber,
  [switch]$Yes
)

$ErrorActionPreference = 'Stop'
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
Set-Location $Root

$Pubspec = Join-Path $Root 'pubspec.yaml'
$AppJson = Join-Path $Root 'ohos\AppScope\app.json5'
$LocalProps = Join-Path $Root 'ohos\local.properties'
$VersionDart = Join-Path $Root 'lib\core\app\app_release_version.dart'
$Marker = '#😁😈'
$utf8 = New-Object System.Text.UTF8Encoding $false

function Read-Utf8Text([string]$Path) {
  return [System.IO.File]::ReadAllText($Path, $utf8)
}

function Write-Utf8Text([string]$Path, [string]$Content) {
  [System.IO.File]::WriteAllText($Path, $Content, $utf8)
}

if (-not (Test-Path -LiteralPath $Pubspec)) {
  throw "pubspec.yaml not found: $Pubspec"
}

$pubspecText = Read-Utf8Text $Pubspec
$match = [regex]::Match($pubspecText, '(?m)^version:\s*([0-9]+\.[0-9]+\.[0-9]+)\+([0-9]+)\s*.*$')
if (-not $match.Success) {
  throw 'Cannot parse version from pubspec.yaml (expected: version: x.y.z+build)'
}

$currentName = $match.Groups[1].Value
$currentCode = $match.Groups[2].Value
$suggestedBuild = Get-Date -Format 'yyyyMMddHH'

Write-Host ''
Write-Host 'Current release version:'
Write-Host ("  versionName: {0}" -f $currentName)
Write-Host ("  versionCode: {0}" -f $currentCode)
Write-Host ''

if ([string]::IsNullOrWhiteSpace($VersionName)) {
  $inputName = Read-Host ("Enter versionName (Enter keeps {0})" -f $currentName)
  if ([string]::IsNullOrWhiteSpace($inputName)) {
    $VersionName = $currentName
  } else {
    $VersionName = $inputName.Trim()
  }
}

if ([string]::IsNullOrWhiteSpace($BuildNumber)) {
  $prompt = "Enter versionCode (Enter keeps {0}; tip YYYYMMDDHH: {1}; max 2147483647)" -f $currentCode, $suggestedBuild
  $inputCode = Read-Host $prompt
  if ([string]::IsNullOrWhiteSpace($inputCode)) {
    $BuildNumber = $currentCode
  } else {
    $BuildNumber = $inputCode.Trim()
  }
}

if ($VersionName -notmatch '^[0-9]+\.[0-9]+\.[0-9]+$') {
  throw ("Invalid versionName: {0} (expected x.y.z)" -f $VersionName)
}
if ($BuildNumber -notmatch '^[0-9]+$') {
  throw ("Invalid versionCode: {0} (expected digits only)" -f $BuildNumber)
}
# HarmonyOS schema requires versionCode <= 2147483647 (int32 max).
# Prefer YYYYMMDDHH (10 digits), e.g. 2026091616.
$maxCode = [int64]2147483647
$codeValue = [int64]$BuildNumber
if ($codeValue -gt $maxCode) {
  throw ("versionCode too large: {0} (must be <= {1}; use YYYYMMDDHH, e.g. {2})" -f $BuildNumber, $maxCode, $suggestedBuild)
}
if ($codeValue -lt 1) {
  throw ("versionCode must be >= 1, got: {0}" -f $BuildNumber)
}

Write-Host ''
Write-Host 'Will write:'
Write-Host ("  versionName: {0}" -f $VersionName)
Write-Host ("  versionCode: {0}" -f $BuildNumber)
Write-Host ("  display:     {0}({1})" -f $VersionName, $BuildNumber)
Write-Host ''

if (-not $Yes) {
  $confirm = Read-Host 'Confirm write? (Y/N)'
  if ($confirm -notmatch '^[Yy]$') {
    Write-Host 'Cancelled. No files changed.'
    exit 0
  }
}

# 1) pubspec.yaml
$nextLine = "version: $VersionName+$BuildNumber $Marker"
$updatedPubspec = [regex]::Replace($pubspecText, '(?m)^version:\s*.*$', $nextLine, 1)
Write-Utf8Text $Pubspec $updatedPubspec

# 2) app.json5
if (Test-Path -LiteralPath $AppJson) {
  $appText = Read-Utf8Text $AppJson
  $appText = [regex]::Replace(
    $appText,
    '"versionCode"\s*:\s*\d+',
    ('"versionCode": ' + $BuildNumber)
  )
  $appText = [regex]::Replace(
    $appText,
    '"versionName"\s*:\s*"[^"]*"',
    ('"versionName": "' + $VersionName + '"')
  )
  Write-Utf8Text $AppJson $appText
}

# 3) local.properties
if (Test-Path -LiteralPath $LocalProps) {
  $lines = New-Object System.Collections.Generic.List[string]
  $hasName = $false
  $hasCode = $false
  foreach ($line in [System.IO.File]::ReadAllLines($LocalProps, $utf8)) {
    if ($line.StartsWith('flutter.versionName=')) {
      [void]$lines.Add('flutter.versionName=' + $VersionName)
      $hasName = $true
    } elseif ($line.StartsWith('flutter.versionCode=')) {
      [void]$lines.Add('flutter.versionCode=' + $BuildNumber)
      $hasCode = $true
    } else {
      [void]$lines.Add($line)
    }
  }
  if (-not $hasName) { [void]$lines.Add('flutter.versionName=' + $VersionName) }
  if (-not $hasCode) { [void]$lines.Add('flutter.versionCode=' + $BuildNumber) }
  [System.IO.File]::WriteAllLines($LocalProps, $lines.ToArray(), $utf8)
}

# 4) About page Dart constant (ASCII only in script to avoid encoding issues)
$sb = New-Object System.Text.StringBuilder
[void]$sb.AppendLine('/// App release version (aligned with pubspec.yaml / store listing).')
[void]$sb.AppendLine('///')
[void]$sb.AppendLine('/// Run scripts/set_ohos_version.bat before DevEco packaging to refresh this file.')
[void]$sb.AppendLine('/// On HarmonyOS, package_info_plus is unavailable; About page uses this fallback.')
[void]$sb.AppendLine('class AppReleaseVersion {')
[void]$sb.AppendLine('  const AppReleaseVersion._();')
[void]$sb.AppendLine('')
[void]$sb.AppendLine('  /// versionName, e.g. 1.4.3')
[void]$sb.AppendLine(("  static const String name = '{0}';" -f $VersionName))
[void]$sb.AppendLine('')
[void]$sb.AppendLine('  /// versionCode, e.g. 2026082115')
[void]$sb.AppendLine(("  static const String build = '{0}';" -f $BuildNumber))
[void]$sb.AppendLine('')
[void]$sb.AppendLine('  /// About page display: 1.4.3 (2026082115)')
[void]$sb.AppendLine('  static String get display {')
[void]$sb.AppendLine("    if (name.isEmpty) return '';")
[void]$sb.AppendLine('    if (build.isEmpty) return name;')
# Produces Dart: return '$name\uFF08$build\uFF09';
[void]$sb.AppendLine("    return '`$name\uFF08`$build\uFF09';")
[void]$sb.AppendLine('  }')
[void]$sb.AppendLine('}')
[void]$sb.AppendLine('')
Write-Utf8Text $VersionDart $sb.ToString()

Write-Host ''
Write-Host ("Done: {0}+{1}" -f $VersionName, $BuildNumber)
Write-Host 'Next: Build Hap / release in DevEco Studio.'
Write-Host ''
