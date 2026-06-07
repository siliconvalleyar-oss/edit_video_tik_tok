# scripts_tools/run_example.ps1
# Example: generate a TikTok-style video with default effects
# Usage: .\scripts_tools\run_example.ps1 [[-Image] <string>] [[-Audio] <string>] [[-Music] <string>] [[-Logo] <string>] [[-Output] <string>]

param(
    [string]$Image = "copo_de_nieve_01.jpeg",
    [string]$Audio = "copo_nieve.mp3",
    [string]$Music = "reggae_2min.mp3",
    [string]$Logo = "grasas.png",
    [string]$Output = "video_final.mp4"
)

$ScriptDir = Split-Path -Parent $PSScriptRoot
Set-Location $ScriptDir

# Check required files
foreach ($file in @($Image, $Audio, $Music)) {
    if (-not (Test-Path $file)) {
        Write-Host "Error: required file not found: $file" -ForegroundColor Red
        exit 1
    }
}

$logoArgs = @()
if (Test-Path $Logo) {
    $logoArgs = @("-l", $Logo)
    Write-Host "Logo: $Logo" -ForegroundColor Green
} else {
    Write-Host "No logo found, proceeding without it" -ForegroundColor Yellow
}

Write-Host "Image: $Image" -ForegroundColor Cyan
Write-Host "Audio: $Audio" -ForegroundColor Cyan
Write-Host "Music: $Music" -ForegroundColor Cyan
Write-Host "Output: $Output" -ForegroundColor Cyan
Write-Host ""

python video_editor.py `
    -i $Image `
    -a $Audio `
    -m $Music `
    @logoArgs `
    -o $Output `
    --zoom 0.25 `
    --rotation 5 `
    --voice-volume 1.5 `
    --music-volume 0.2
