param(
    [Parameter(Mandatory = $true)][string]$Token,
    [string]$SiteUrl = "https://lemon-mud-09e77df00.1.azurestaticapps.net"
)

# Remove the file swapping - deploy the correct MyIntellX content
Write-Host "[INFO] Deploying to correct Static Web App: lemon-mud-09e77df00" -ForegroundColor Cyan

Write-Host "[INFO] Starting Azure Static Web App deployment..." -ForegroundColor Cyan

# Update build marker in index.html
$indexPath = "index.html"
if (Test-Path $indexPath) {
    $content = Get-Content $indexPath -Raw
    $today = (Get-Date).ToString('yyyy-MM-dd')
    $newBuild = "$today-" + (Get-Date).ToString('HHmm')
    
    # Simple string replacement - avoid regex complications
    if ($content -match 'Current build: [\d\-]+') {
        $content = $content -replace 'Current build: [\d\-]+', "Current build: $newBuild"
    } else {
        # Add before closing body tag if not found
        $buildLine = "    <p style='text-align:center;font-size:small;color:#666;'>Build: $newBuild</p>"
        $content = $content -replace '</body>', "$buildLine`n</body>"
    }
    
    Set-Content -Path $indexPath -Value $content -Encoding UTF8
    Write-Host "[INFO] Updated build marker to: $newBuild" -ForegroundColor Green
}

# Deploy using SWA CLI
Write-Host "[INFO] Deploying via Static Web Apps CLI..." -ForegroundColor Cyan
Write-Host "[INFO] App location: $(Get-Location)" -ForegroundColor Cyan
Write-Host "[INFO] Files to deploy:" -ForegroundColor Cyan
Get-ChildItem -Name "*.html", "*.css", "*.js", "*.json" | ForEach-Object { Write-Host "  - $_" }

try {
    & npx "@azure/static-web-apps-cli" deploy --deployment-token $Token --env production --app-location . --output-location . --verbose
    if ($LASTEXITCODE -eq 0) {
        Write-Host "[SUCCESS] Deployment completed successfully!" -ForegroundColor Green
        
        # Quick verification
        Start-Sleep -Seconds 3
        try {
            $response = Invoke-WebRequest -Uri "$SiteUrl/?nocache=$(Get-Random)" -UseBasicParsing -TimeoutSec 15
            if ($response.Content -match "Current build: $newBuild" -or $response.Content -match "MyIntellX") {
                Write-Host "[SUCCESS] Website is live and updated!" -ForegroundColor Green
            } else {
                Write-Host "[WARNING] Site accessible but content may be cached. Try hard refresh." -ForegroundColor Yellow
            }
        } catch {
            Write-Host "[WARNING] Could not verify deployment: $($_.Exception.Message)" -ForegroundColor Yellow
        }
    } else {
        Write-Host "[ERROR] Deployment failed with exit code: $LASTEXITCODE" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "[ERROR] Deployment failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host "[INFO] Deployment process complete. Check: $SiteUrl" -ForegroundColor Cyan