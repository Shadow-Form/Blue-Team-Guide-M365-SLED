<#
.SYNOPSIS
  Find stale accounts using Graph signInActivity; output CSV; optional disable.

.PREREQS
  - PowerShell 7+
  - Microsoft Graph SDK
  - Permissions: AuditLog.Read.All, Directory.Read.All

.USAGE
  pwsh ./list-stale-entra-accounts.ps1 -DaysIdle 90 -Disable:$false
#>

param(
  [int]$DaysIdle = 90,
  [string]$OutCsv = "./out/stale_accounts.csv",
  [switch]$Disable
)

Import-Module Microsoft.Graph
Select-MgProfile -Name "v1.0"
Connect-MgGraph -Scopes "AuditLog.Read.All","Directory.Read.All" | Out-Null

$users = Get-MgUser -All -Property "Id,DisplayName,UserPrincipalName,AccountEnabled,SignInActivity"

$cutoff = (Get-Date).AddDays(-$DaysIdle)
$stale = $users | Where-Object {
  $_.SignInActivity.LastSignInDateTime -eq $null -or
  ([datetime]$_.SignInActivity.LastSignInDateTime) -lt $cutoff
} | Sort-Object DisplayName

# Output
$stale | Select-Object DisplayName,UserPrincipalName,AccountEnabled,@{n="LastSignIn";e={$_.SignInActivity.LastSignInDateTime}} |
  Export-Csv -NoTypeInformation -Path $OutCsv

Write-Host "Found $($stale.Count) stale accounts older than $DaysIdle days."

# Optional disable (use with care; add approval workflow if possible)
if ($Disable -and $stale.Count -gt 0) {
  foreach ($u in $stale) {
    Write-Host "Disabling $($u.UserPrincipalName)"
    Update-MgUser -UserId $u.Id -AccountEnabled:$false
  }
}
