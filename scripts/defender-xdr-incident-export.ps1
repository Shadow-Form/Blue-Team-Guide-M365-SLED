<#
.SYNOPSIS
  Export M365 Defender incidents (Graph Security API) to CSV/JSON.

.PREREQS
  - PowerShell 7+
  - Microsoft Graph SDK
  - Permissions: SecurityEvents.Read.All

.USAGE
  pwsh ./defender-xdr-incident-export.ps1 -DaysBack 30 -OutCsv ./out/incidents.csv
#>

param(
  [int]$DaysBack = 30,
  [string]$OutCsv = "./out/incidents.csv",
  [string]$OutJson = "./out/incidents.json"
)

Import-Module Microsoft.Graph
Select-MgProfile -Name "beta"  # incidents are best supported in beta
Connect-MgGraph -Scopes "SecurityEvents.Read.All" | Out-Null

$start = (Get-Date).AddDays(-$DaysBack).ToString("o")
$filter = "lastUpdateDateTime ge $start"

$uri = "/security/incidents?`$filter=$([uri]::EscapeDataString($filter))&`$top=50"
$resp = Invoke-MgGraphRequest -Method GET -Uri $uri -OutputType PSObject

$all = @()
do {
  if ($resp.value) { $all += $resp.value }
  $next = $resp.'@odata.nextLink'
  if ($next) { $resp = Invoke-MgGraphRequest -Method GET -Uri $next -OutputType PSObject }
} while ($next)

$rows = $all | ForEach-Object {
  [PSCustomObject]@{
    IncidentId        = $_.id
    Title             = $_.title
    Severity          = $_.severity
    Status            = $_.status
    Classification    = $_.classification
    Determination     = $_.determination
    AssignedTo        = $_.assignedTo
    CreatedDateTime   = $_.createdDateTime
    LastUpdateDateTime= $_.lastUpdateDateTime
    Tags              = ($_.tags -join ";")
    ProviderAlertIds  = ($_.providerAlertIds -join ";")
  }
}

New-Item -ItemType Directory -Force -Path (Split-Path $OutCsv) | Out-Null
$rows | Export-Csv -NoTypeInformation -Path $OutCsv
$rows | ConvertTo-Json -Depth 4 | Out-File $OutJson -Encoding utf8

Write-Host "Exported $($rows.Count) incidents to $OutCsv and $OutJson"
