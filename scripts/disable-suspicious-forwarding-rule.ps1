<#
.SYNOPSIS
  Disable external forwarding rules in target mailboxes.

.PREREQS
  - Exchange Online PowerShell V3 module (Install-Module ExchangeOnlineManagement)
  - Permissions: Mailbox permissions to read/update inbox rules

.USAGE
  pwsh ./disable-suspicious-forwarding-rule.ps1 -User user@org.gov -Log ./out/forward_rule_actions.csv
#>

param(
  [Parameter(Mandatory=$true)][string]$User,
  [string]$Log = "./out/forward_rule_actions.csv",
  [string]$SuspiciousDomainsPattern = "(gmail\\.com|yahoo\\.com|outlook\\.com|protonmail\\.com)$"
)

Import-Module ExchangeOnlineManagement
Connect-ExchangeOnline -ShowBanner:$false | Out-Null

$rules = Get-InboxRule -Mailbox $User
$suspicious = $rules | Where-Object {
  $_.ForwardTo -or $_.ForwardAsAttachmentTo -or $_.RedirectTo
} | Where-Object {
  ($_.ForwardTo + $_.ForwardAsAttachmentTo + $_.RedirectTo) -match $SuspiciousDomainsPattern
}

New-Item -ItemType Directory -Force -Path (Split-Path $Log) | Out-Null

foreach ($r in $suspicious) {
  Write-Host "Disabling rule '$($r.Name)' for $User"
  Disable-InboxRule -Identity $r.Identity -Mailbox $User
  [PSCustomObject]@{
    Timestamp = (Get-Date).ToString("o")
    User      = $User
    RuleName  = $r.Name
    Action    = "Disabled"
  } | Export-Csv -NoTypeInformation -Append -Path $Log
}

Disconnect-ExchangeOnline -Confirm:$false
