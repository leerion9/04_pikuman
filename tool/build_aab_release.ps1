$ErrorActionPreference = "Stop"

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
Set-Location $repoRoot

$pubspecPath = Join-Path $repoRoot "pubspec.yaml"
if (!(Test-Path $pubspecPath)) {
  throw "pubspec.yaml을 찾을 수 없습니다: $pubspecPath"
}

$pubspec = Get-Content -LiteralPath $pubspecPath -Raw
$m = [regex]::Match($pubspec, "(?m)^\s*version:\s*([0-9]+\.[0-9]+\.[0-9]+)\+([0-9]+)\s*$")
if (!$m.Success) {
  throw "pubspec.yaml에서 version: x.y.z+N 형식을 찾지 못했습니다."
}

$verName = $m.Groups[1].Value
$buildNum = [int]$m.Groups[2].Value
$nextBuildNum = $buildNum + 1
$nextVersionLine = "version: $verName+$nextBuildNum"

$pubspecUpdated = [regex]::Replace(
  $pubspec,
  "(?m)^\s*version:\s*[0-9]+\.[0-9]+\.[0-9]+\+[0-9]+\s*$",
  $nextVersionLine
)
# Windows PowerShell(Set-Content -Encoding UTF8)는 BOM을 붙일 수 있어서,
# YAML/한글 주석이 깨지지 않도록 UTF-8 (BOM 없음)으로 저장합니다.
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($pubspecPath, $pubspecUpdated, $utf8NoBom)

flutter pub get
flutter build appbundle --release

$outDir = Join-Path $repoRoot "build\app\outputs\bundle\release"
$src = Join-Path $outDir "app-release.aab"
if (!(Test-Path $src)) {
  throw "빌드 결과 AAB를 찾지 못했습니다: $src"
}

$dstName = "pikuman_mahjong_v${verName}_${nextBuildNum}.aab"
$dst = Join-Path $outDir $dstName
Copy-Item -LiteralPath $src -Destination $dst -Force

Write-Host ""
Write-Host "완료: $dst"

