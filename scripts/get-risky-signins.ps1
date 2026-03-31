<#
.SYNOPSIS
  Export risky sign-ins to CSV/JSON and (optionally) push to Sentinel.

.PREREQS
  - PowerShell 7+
  - Microsoft Graph PowerShell SDK (Install-Module Microsoft.Graph)
  - Permissions: AuditLog.Read.All, Directory.Read.All (app or delegated)
  - For Sentinel ingestion (optional): Data Collection Endpoint + DCR

.USAGE
  pwsh ./get-risky-signins.ps1 -DaysBack 7 -OutCsv ./out/risky_signins.csv -PushToSentinel:$false
#>

param(
  [int]$DaysBack = 7,
  [string]$OutCsv = "./out/risky_signins.csv",
  [string]$OutJson = "./out/risky_signins.json",
  [switch]$PushToSentinel,
  [string]$SentinelDceUrl,        # e.g., https://<dce-id>.<region>.ingest.monitor.azure.com
  [string]$SentinelDcrImmutableId # e.g., dcr-<guid>
)

# --- Connect to Graph (prompt if no token) ---
Import-Module Microsoft.Graph
Select-MgProfile -Name "v1.0"
Connect-MgGraph -Scopes "AuditLog.Read.All","Directory.Read.All" | Out-Null

# --- Query sign-ins (risky only) ---
$start = (Get-Date).AddDays(-$DaysBack).ToString("o")
$filter = "createdDateTime ge $start and riskLevelDuringSignIn ne 'none'"
$signins = Invoke-MgGraphRequest -Method GET -Uri "/auditLogs/signIns?`$filter=$([uri]::EscapeDataString($filter))&`$top=100" -OutputType PSObject

# Handle paging
$all = @()
do {
  if ($signins.value) { $all += $signins.value }
  $next = $signins.'@odata.nextLink'
  if ($next) { $signins = Invoke-MgGraphRequest -Method GET -Uri $next -OutputType PSObject }
} while ($next)

# --- Shape records ---
$rows = $all | ForEach-Object {
  [PSCustomObject]@{
    Timestamp                = $_.createdDateTime
    UserPrincipalName        = $_.userPrincipalName
    AppDisplayName           = $_.appDisplayName
    IPAddress                = $_.ipAddress
    RiskLevelDuringSignIn    = $_.riskLevelDuringSignIn
    ConditionalAccessStatus  = $_.conditionalAccessStatus
    StatusErrorCode          = $_.status.errorCode
    Location                 = ($_.location.city + ", " + $_.location.countryOrRegion)
  }
}

# --- Export locally ---
New-Item -ItemType Directory -Force -Path (Split-Path $OutCsv) | Out-Null
$rows | Export-Csv -NoTypeInformation -Path $OutCsv
$rows | ConvertTo-Json -Depth 4 | Out-File $OutJson -Encoding utf8

Write-Host "Exported $($rows.Count) risky sign-ins to $OutCsv and $OutJson"

# --- Optional: push to Sentinel custom log ---
if ($PushToSentinel) {
  if (-not $SentinelDceUrl -or -not $SentinelDcrImmutableId) {
    throw "When -PushToSentinel is set, you must specify -SentinelDceUrl and -SentinelDcrImmutableId."
  }

  $body = $rows | ConvertTo-Json -Depth 4
  $headers = @{
    "Content-Type"  = "application/json; charset=utf-8"
    "x-ms-dcr-immutable-id" = $SentinelDcrImmutableId
    "x-ms-client-request-id" = [guid]::NewGuid().Guid
    "x-ms-date" = (Get-Date).ToUniversalTime().ToString("r")
  }

  $ingestUrl = "$SentinelDceUrl/dataCollectionRules/$SentinelDcrImmutableId/streams/Custom-RiskySignins?api-version=2023-01-01"
  $resp = Invoke-RestMethod -Method POST -Uri $ingestUrl -Headers $headers -Body $body
  Write-Host "Sentinel ingest response:" ($resp | ConvertTo-Json -Depth 3)
}
