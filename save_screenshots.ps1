# PowerShell Script to Help Organize Screenshots
# Run this script after taking screenshots from your emulator

Write-Host "==================================" -ForegroundColor Cyan
Write-Host "MechResQ Screenshot Organizer" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

# Create screenshots directory if it doesn't exist
$screenshotsDir = "screenshots"
if (-not (Test-Path $screenshotsDir)) {
    New-Item -ItemType Directory -Path $screenshotsDir | Out-Null
    Write-Host "Created $screenshotsDir directory" -ForegroundColor Green
}

# Required screenshot names
$requiredScreenshots = @(
    "login_screen.png",
    "home_screen.png",
    "emergency_sos.png",
    "create_request.png",
    "filters.png",
    "side_drawer.png"
)

Write-Host "Required Screenshots:" -ForegroundColor Yellow
foreach ($screenshot in $requiredScreenshots) {
    $path = Join-Path $screenshotsDir $screenshot
    if (Test-Path $path) {
        Write-Host "  ✓ $screenshot" -ForegroundColor Green
    } else {
        Write-Host "  ✗ $screenshot (missing)" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "Instructions:" -ForegroundColor Cyan
Write-Host "1. Take screenshots from your emulator/device" -ForegroundColor White
Write-Host "2. Save/copy them to the 'screenshots' folder" -ForegroundColor White
Write-Host "3. Rename them according to the list above" -ForegroundColor White
Write-Host "4. Run this script again to verify" -ForegroundColor White
Write-Host ""

# Check if user wants to open the screenshots folder
$response = Read-Host "Open screenshots folder? (Y/N)"
if ($response -eq "Y" -or $response -eq "y") {
    Start-Process explorer.exe $screenshotsDir
}

Write-Host ""
Write-Host "Android Emulator Screenshots Location:" -ForegroundColor Yellow
$emulatorScreenshots = "$env:USERPROFILE\.android\avd"
if (Test-Path $emulatorScreenshots) {
    Write-Host $emulatorScreenshots -ForegroundColor Gray
}

Write-Host ""
Write-Host "Done! Check screenshots/README.md for more details." -ForegroundColor Green
