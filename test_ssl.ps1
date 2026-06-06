# Test SSL connection to Google Maven
Write-Host "Testing SSL connection to Google Maven..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "https://dl.google.com/dl/android/maven2/" -UseBasicParsing -TimeoutSec 10
    Write-Host "SUCCESS: Can connect to Google Maven!" -ForegroundColor Green
    Write-Host "Status Code: $($response.StatusCode)" -ForegroundColor Green
} catch {
    Write-Host "FAILED: Cannot connect to Google Maven" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`nChecking Java version..." -ForegroundColor Yellow
$javaPath = "C:\Program Files\Android\Android Studio\jbr\bin\java.exe"
if (Test-Path $javaPath) {
    & $javaPath -version
} else {
    Write-Host "Java not found at expected location" -ForegroundColor Red
}

Write-Host "`nTo fix this SSL issue, try these steps:" -ForegroundColor Cyan
Write-Host "1. Disable antivirus HTTPS/SSL scanning temporarily" -ForegroundColor White
Write-Host "2. Check if you're behind a corporate proxy" -ForegroundColor White  
Write-Host "3. Try connecting to a different network (mobile hotspot)" -ForegroundColor White
