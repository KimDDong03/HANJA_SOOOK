$ErrorActionPreference = "Stop"

$projectRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$envFile = Join-Path $projectRoot ".env"
$apkSource = Join-Path $projectRoot "build\app\outputs\flutter-apk\app-debug.apk"
$outputDir = Join-Path $projectRoot "output"
$apkTarget = Join-Path $outputDir "hanja_soook-debug.apk"

if (-not (Test-Path -LiteralPath $envFile)) {
    throw "Missing .env. Create it from .env.example before building an installable APK."
}

Push-Location $projectRoot
try {
    flutter build apk --debug --dart-define-from-file=.env
    New-Item -ItemType Directory -Force -Path $outputDir | Out-Null
    Copy-Item -LiteralPath $apkSource -Destination $apkTarget -Force
    Write-Output "Built $apkTarget"
} finally {
    Pop-Location
}
