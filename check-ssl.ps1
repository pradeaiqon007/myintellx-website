# SSL Certificate Monitoring Script
# Run this to check SSL certificate provisioning progress

Write-Host "=== SSL Certificate Status Check ===" -ForegroundColor Green
Write-Host ""

$domain = "www.myintellx.my"

# Test DNS resolution
Write-Host "1. Testing DNS Resolution..." -ForegroundColor Yellow
try {
    $dns = Resolve-DnsName $domain -Type CNAME
    Write-Host "✅ CNAME: $($dns.NameHost)" -ForegroundColor Green
} catch {
    Write-Host "❌ DNS Resolution failed" -ForegroundColor Red
}

Write-Host ""

# Test HTTPS connectivity
Write-Host "2. Testing HTTPS Certificate..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "https://$domain" -UseBasicParsing -TimeoutSec 10
    Write-Host "✅ HTTPS Status: $($response.StatusCode)" -ForegroundColor Green
    
    # Check if MyIntellX content is served
    if ($response.Content -match "MyIntellX") {
        Write-Host "✅ MyIntellX content confirmed!" -ForegroundColor Green
    } else {
        Write-Host "⚠️ Different content served" -ForegroundColor Yellow
    }
} catch {
    if ($_.Exception.Message -match "trust relationship|SSL|certificate") {
        Write-Host "⏳ SSL Certificate still provisioning..." -ForegroundColor Yellow
        Write-Host "   This is normal - Azure is generating the certificate" -ForegroundColor Cyan
    } else {
        Write-Host "❌ HTTPS Error: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host ""

# Test HTTP (should work without SSL)
Write-Host "3. Testing HTTP (fallback)..." -ForegroundColor Yellow
try {
    $httpResponse = Invoke-WebRequest -Uri "http://$domain" -UseBasicParsing -TimeoutSec 10
    Write-Host "✅ HTTP Status: $($httpResponse.StatusCode)" -ForegroundColor Green
} catch {
    Write-Host "❌ HTTP also failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "=== Summary ===" -ForegroundColor Green
Write-Host "- Add custom domain in Azure Portal to trigger SSL certificate"
Write-Host "- SSL certificates take 5-30 minutes to provision"
Write-Host "- Run this script again in 10 minutes to check progress"
Write-Host "- Once SSL is ready, you'll see a green padlock in browser"