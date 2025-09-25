# DNS Verification Script for myintellx.my
# Run this script to check DNS propagation status

Write-Host "=== DNS Verification for myintellx.my ===" -ForegroundColor Green
Write-Host ""

# Function to test DNS resolution
function Test-DNSRecord {
    param($Domain, $Type)
    try {
        $result = Resolve-DnsName -Name $Domain -Type $Type -ErrorAction Stop
        return $result
    } catch {
        return $null
    }
}

# Test CNAME for www subdomain
Write-Host "Testing CNAME for www.myintellx.my..." -ForegroundColor Yellow
$wwwCNAME = Test-DNSRecord -Domain "www.myintellx.my" -Type "CNAME"
if ($wwwCNAME) {
    Write-Host "CNAME found: $($wwwCNAME.NameHost)" -ForegroundColor Green
    if ($wwwCNAME.NameHost -like "*victorious-coast-06ac35700*") {
        Write-Host "CNAME correctly points to Azure Static Web App" -ForegroundColor Green
    } else {
        Write-Host "CNAME does not point to Azure Static Web App" -ForegroundColor Red
    }
} else {
    Write-Host "No CNAME record found for www.myintellx.my" -ForegroundColor Red
}

Write-Host ""

# Test A record for root domain
Write-Host "Testing A record for myintellx.my..." -ForegroundColor Yellow
$rootA = Test-DNSRecord -Domain "myintellx.my" -Type "A"
if ($rootA) {
    Write-Host "A record(s) found:" -ForegroundColor Green
    foreach ($record in $rootA) {
        Write-Host "  - $($record.IPAddress)" -ForegroundColor Cyan
    }
} else {
    Write-Host "No A record found for myintellx.my" -ForegroundColor Red
}

Write-Host ""

# Test TXT record for verification
Write-Host "Testing TXT record for domain verification..." -ForegroundColor Yellow
$txtRecord = Test-DNSRecord -Domain "myintellx.my" -Type "TXT"
if ($txtRecord) {
    Write-Host "TXT record(s) found:" -ForegroundColor Green
    foreach ($record in $txtRecord) {
        Write-Host "  - $($record.Strings)" -ForegroundColor Cyan
    }
} else {
    Write-Host "No TXT record found for myintellx.my" -ForegroundColor Red
}

Write-Host ""

# Test website accessibility
Write-Host "Testing website accessibility..." -ForegroundColor Yellow

# Test Azure URL
try {
    $azureResponse = Invoke-WebRequest -Uri "https://victorious-coast-06ac35700.1.azurestaticapps.net" -UseBasicParsing -TimeoutSec 10
    Write-Host "Azure URL accessible (Status: $($azureResponse.StatusCode))" -ForegroundColor Green
} catch {
    Write-Host "Azure URL not accessible" -ForegroundColor Red
}

# Test custom domains if DNS is configured
if ($wwwCNAME) {
    try {
        $wwwResponse = Invoke-WebRequest -Uri "https://www.myintellx.my" -UseBasicParsing -TimeoutSec 10
        Write-Host "www.myintellx.my accessible (Status: $($wwwResponse.StatusCode))" -ForegroundColor Green
    } catch {
        Write-Host "www.myintellx.my not yet accessible (DNS may still be propagating)" -ForegroundColor Yellow
    }
}

if ($rootA) {
    try {
        $rootResponse = Invoke-WebRequest -Uri "https://myintellx.my" -UseBasicParsing -TimeoutSec 10
        Write-Host "myintellx.my accessible (Status: $($rootResponse.StatusCode))" -ForegroundColor Green
    } catch {
        Write-Host "myintellx.my not yet accessible (DNS may still be propagating)" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "=== Summary ===" -ForegroundColor Green
Write-Host "Next steps:"
Write-Host "1. Configure DNS records in Namecheap as shown in custom-domain-setup.md"
Write-Host "2. Add custom domains in Azure Portal"
Write-Host "3. Wait for DNS propagation (up to 48 hours)"
Write-Host "4. Run this script again to verify changes"