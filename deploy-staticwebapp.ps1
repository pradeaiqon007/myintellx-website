<#
.SYNOPSIS
  Automated deployment script for Azure Static Web App (manual / token-based).

.DESCRIPTION
  Updates the build marker in index.html, then deploys using the Static Web Apps CLI via npx.
  Does NOT persist or echo the deployment token. All output sanitized.

.PARAMETER Token
  Deployment token for the target Static Web App (regenerate in Portal > Overview > Manage deployment token).

.PARAMETER AppLocation
  Relative path to application root (default ".").

.PARAMETER OutputLocation
  Relative output folder (default ".") – for simple static sites this is same as AppLocation.

.PARAMETER SiteUrl
  (Optional) Full production URL (e.g. https://<generated>.azurestaticapps.net) for post-deploy verification.

.EXAMPLE
  powershell -ExecutionPolicy Bypass -File .\deploy-staticwebapp.ps1 -Token "<TOKEN>" -SiteUrl "https://example.azurestaticapps.net"

.NOTES
  Requires: Node.js (npx), Internet connectivity.
  Safe: Does not write the token to disk.
#>
param(
    [Parameter(Mandatory = $true)][string]$Token,
    [string]$AppLocation = '.',
    [string]$OutputLocation = '.',
    [string]$SiteUrl
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Write-Info($msg){ Write-Host "[INFO] $msg" -ForegroundColor Cyan }
function Write-Warn($msg){ Write-Host "[WARN] $msg" -ForegroundColor Yellow }
function Write-Err($msg){ Write-Host "[ERROR] $msg" -ForegroundColor Red }

function Update-BuildMarker {
    $indexPath = Join-Path $AppLocation 'index.html'
    if (-not (Test-Path $indexPath)) { Write-Warn "index.html not found – skipping build marker update"; return }
    $content = Get-Content $indexPath -Raw
    $today = (Get-Date).ToString('yyyy-MM-dd')
    $pattern = 'Current build: (?<date>\d{4}-\d{2}-\d{2})-(?<num>\d{2})'
    $newNumber = '01'
    if ($content -match $pattern) {
        $d = $Matches['date']; $n = [int]$Matches['num']
        if ($d -eq $today) { $newNumber = '{0:00}' -f ($n + 1) }
    }
    $newMarker = "Current build: $today-$newNumber"
    if ($content -notmatch $pattern) {
        # Insert build marker before the closing </footer> (first occurrence)
        $insertion = "    <p class='build-info'>$newMarker</p>`n</footer>"
        $content = $content -replace '</footer>', $insertion
    } else {
        $content = [regex]::Replace($content, $pattern, $newMarker)
    }
    Set-Content -Path $indexPath -Value $content -Encoding UTF8
    Write-Info "Updated build marker to '$newMarker'"
}

function Ensure-NpxAvailable {
    if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
        Write-Err "Node.js is required but not found. Install from https://nodejs.org/ and re-run."; exit 1
    }
    Write-Info "Node version: $(node -v)"
}

function Deploy-StaticWebApp {
    Write-Info "Starting deployment via npx Static Web Apps CLI"
    $args = @(
        '@azure/static-web-apps-cli','deploy',
        '--deployment-token', $Token,
        '--env','production',
        '--app-location', $AppLocation,
        '--output-location', $OutputLocation,
        '--verbose'
    )
    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = 'npx'
    $psi.ArgumentList = $args
    $psi.RedirectStandardError = $true
    $psi.RedirectStandardOutput = $true
    $psi.UseShellExecute = $false
    $process = [System.Diagnostics.Process]::Start($psi)
    $stdOut = $process.StandardOutput.ReadToEnd()
    $stdErr = $process.StandardError.ReadToEnd()
    $process.WaitForExit()
    $exit = $process.ExitCode
    if ($stdOut) { Write-Host $stdOut }
    if ($stdErr) { Write-Warn $stdErr }
    if ($exit -ne 0) { Write-Err "Deployment failed with exit code $exit"; exit $exit }
    Write-Info "Deployment command exited successfully"
}

function Verify-Site {
    param([string]$Url)
    if (-not $Url) { Write-Warn "SiteUrl not provided – skipping verification"; return }
    try {
        Start-Sleep -Seconds 5
        $resp = Invoke-WebRequest -Uri ("$Url/?_=" + [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()) -Headers @{ 'Cache-Control'='no-cache'} -UseBasicParsing -TimeoutSec 30
        $body = $resp.Content
        if ($body -match 'Current build:') {
            Write-Info "Found build marker in remote content: " + ([regex]::Match($body,'Current build: .*').Value)
        } else {
            Write-Warn "Remote site content fetched but build marker not detected yet (CDN propagation?)."
        }
    } catch {
        Write-Warn "Verification request failed: $($_.Exception.Message)"
    }
}

Write-Info "=== Azure Static Web App Manual Deployment ==="
Ensure-NpxAvailable
Update-BuildMarker
Deploy-StaticWebApp
Verify-Site -Url $SiteUrl
Write-Info "Done. Review output above for any warnings."
