param(
    [Parameter(Mandatory = $true)][string]$Token
)

Write-Host "=== ALTERNATIVE DEPLOYMENT SCRIPT ===" -ForegroundColor Cyan
Write-Host "Target: lemon-mud-09e77df00.1.azurestaticapps.net" -ForegroundColor Cyan

# List current files
Write-Host "`nFiles in directory:" -ForegroundColor Yellow
Get-ChildItem -Name | ForEach-Object { Write-Host "  $_" }

# Show index.html content sample
Write-Host "`nIndex.html content preview:" -ForegroundColor Yellow
Get-Content "index.html" | Select-Object -First 5 | ForEach-Object { Write-Host "  $_" }

# Update build marker with unique timestamp
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$content = Get-Content "index.html" -Raw
$content = $content -replace '<!-- Current build: [^>]+ -->', "<!-- Current build: $timestamp -->"
Set-Content "index.html" -Value $content -Encoding UTF8
Write-Host "`nUpdated build marker to: $timestamp" -ForegroundColor Green

# Try deployment with explicit parameters
Write-Host "`nStarting deployment..." -ForegroundColor Cyan
try {
    $deployArgs = @(
        "--deployment-token", $Token,
        "--env", "production",
        "--app-location", ".",
        "--output-location", ".",
        "--verbose"
    )
    
    Write-Host "Deploy command: npx @azure/static-web-apps-cli deploy $($deployArgs -join ' ')" -ForegroundColor Gray
    
    & npx "@azure/static-web-apps-cli" deploy @deployArgs
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "`n✅ Deployment completed!" -ForegroundColor Green
        
        # Wait and test
        Write-Host "Waiting 10 seconds before verification..." -ForegroundColor Yellow
        Start-Sleep -Seconds 10
        
        $testUrl = "http://lemon-mud-09e77df00.1.azurestaticapps.net"
        Write-Host "Testing: $testUrl" -ForegroundColor Cyan
        
        try {
            $response = Invoke-WebRequest -Uri $testUrl -UseBasicParsing
            if ($response.Content -match $timestamp) {
                Write-Host "✅ SUCCESS: Build marker $timestamp found!" -ForegroundColor Green
            } else {
                Write-Host "❌ Build marker not found - checking for any updates..." -ForegroundColor Red
                if ($response.Content -match "MyIntellX - Intelligent Solutions") {
                    Write-Host "✅ Content appears updated!" -ForegroundColor Green
                } else {
                    Write-Host "❌ Content still appears cached" -ForegroundColor Red
                }
            }
        } catch {
            Write-Host "❌ Error testing site: $($_.Exception.Message)" -ForegroundColor Red
        }
    } else {
        Write-Host "❌ Deployment failed with exit code: $LASTEXITCODE" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Deployment error: $($_.Exception.Message)" -ForegroundColor Red
}