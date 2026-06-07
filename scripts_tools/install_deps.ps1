# scripts_tools/install_deps.ps1
# Install FFmpeg and create project folder structure on Windows

Write-Host "=== Creating project folder structure ===" -ForegroundColor Cyan
$ProjectRoot = Split-Path -Parent $PSScriptRoot
Set-Location $ProjectRoot

$dirs = @("imagenes", "mp3", "mp4", "scripts_tools")
foreach ($dir in $dirs) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir | Out-Null
        Write-Host "  ✓ $dir/" -ForegroundColor Green
    } else {
        Write-Host "  ✓ $dir/ (already exists)" -ForegroundColor Green
    }
}
Write-Host ""

Write-Host "=== Installing FFmpeg (required for video_editor.py) ===" -ForegroundColor Cyan

# Check if FFmpeg is already available
if (Get-Command ffmpeg -ErrorAction SilentlyContinue) {
    Write-Host "FFmpeg already installed:" (ffmpeg -version | Select-Object -First 1) -ForegroundColor Green
    exit 0
}

# Try winget (Windows 10/11 built-in)
if (Get-Command winget -ErrorAction SilentlyContinue) {
    Write-Host "Installing FFmpeg via winget..." -ForegroundColor Yellow
    winget install "FFmpeg (Essential)" --accept-package-agreements --accept-source-agreements
    if ($LASTEXITCODE -eq 0) {
        Write-Host "FFmpeg installed. You may need to restart your terminal." -ForegroundColor Green
        exit 0
    }
    Write-Host "winget failed, trying chocolatey..." -ForegroundColor Yellow
}

# Try chocolatey
if (Get-Command choco -ErrorAction SilentlyContinue) {
    Write-Host "Installing FFmpeg via chocolatey..." -ForegroundColor Yellow
    choco install ffmpeg -y
    if ($LASTEXITCODE -eq 0) {
        Write-Host "FFmpeg installed. You may need to restart your terminal." -ForegroundColor Green
        exit 0
    }
}

Write-Host "Could not install FFmpeg automatically." -ForegroundColor Red
Write-Host ""
Write-Host "Manual installation:" -ForegroundColor Yellow
Write-Host "  1. Download from: https://ffmpeg.org/download.html" -ForegroundColor White
Write-Host "  2. Extract the zip to C:\ffmpeg" -ForegroundColor White
Write-Host "  3. Add C:\ffmpeg\bin to your PATH environment variable" -ForegroundColor White
Write-Host "  4. Restart your terminal" -ForegroundColor White
exit 1
