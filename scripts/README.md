# 📁 README – Scripts & Hunting Library
This directory contains the automation, investigation, and detection scripts that support the Blue Team Guide for securing Microsoft 365 in SLED (State, Local, Education) environments. All scripts were designed for small teams needing fast, repeatable, and auditable operations.
Each script aligns with Microsoft best practices for Entra ID, Intune, Defender XDR, and Sentinel, and supports NIST SP 800‑171 control areas—particularly AC, AU, CM, IR, and SI families.

# 📚 Directory Overview
/scripts
│
├── PowerShell/
│   ├── get-risky-signins.ps1
│   ├── list-stale-entra-accounts.ps1
│   ├── defender-xdr-incident-export.ps1
│   └── disable-suspicious-forwarding-rule.ps1
│
└── KQL/
    ├── sentinel-hunt-impossible-travel.kql
    ├── sentinel-hunt-multiple-mfa-fail-then-success.kql
    ├── sentinel-hunt-suspicious-forwarding.kql
    ├── sentinel-hunt-oauth-consent-anomaly.kql
    └── sentinel-hunt-sharepoint-exfil-spike.kql


# 🛠 Purpose of These Scripts
These scripts provide:
1. Identity Monitoring & Cleanup

Detect risky sign-ins
Identify stale or dormant accounts
Flag anomalous MFA behavior
Support conditional access investigations

2. Email & Collaboration Security

Detect and auto-remove malicious inbox forwarding rules
Strengthen anti-phish and anti-spoof posture

3. Endpoint & Incident Response

Export Microsoft Defender XDR incidents
Provide standardized evidence for audits
Feed incident data into Sentinel custom logs

4. Threat Hunting in Sentinel

Investigate identity anomalies
Detect token theft patterns
Identify suspicious OAuth consent
Find large-scale SharePoint/OneDrive exfiltration
Uncover MFA brute-force success chains


# ⚙️ PowerShell Scripts Summary
get-risky-signins.ps1

Pulls risky Entra sign-in events from Graph
Outputs CSV + JSON
Optional: ingest into Sentinel custom table
Ideal for daily/weekly reviews or automated reporting


list-stale-entra-accounts.ps1

Finds users with no sign-in activity for N days
Optionally disables the account
Helps enforce least-privilege, reduces risk exposure


defender-xdr-incident-export.ps1

Exports Defender incidents (Graph Security API)
Includes severity, status, classification, determination
Supports audit, review, incident trending


disable-suspicious-forwarding-rule.ps1

Identifies forwarding rules targeting external domains (gmail, protonmail, etc.)
Removes them and logs actions to CSV
Supports phishing remediation and lateral movement prevention


# 🔍 KQL Hunting Queries Summary
sentinel-hunt-impossible-travel.kql
Detects suspicious geographic jumps between sign-ins.
sentinel-hunt-multiple-mfa-fail-then-success.kql
Identifies successful compromise after MFA failures.
sentinel-hunt-suspicious-forwarding.kql
Finds inbox rule modifications matching exfiltration patterns.
sentinel-hunt-oauth-consent-anomaly.kql
Detects unusual or malicious OAuth grant activity.
sentinel-hunt-sharepoint-exfil-spike.kql
Flags abnormal SharePoint/OneDrive downloads.

# 🔐 Required Permissions
To use these scripts safely and effectively:
Graph Permissions

AuditLog.Read.All
Directory.Read.All
SecurityEvents.Read.All

Exchange Online

Mailbox read/update permissions for inbox rules

Sentinel (optional ingestion)

Data Collection Endpoint + Data Collection Rule
Permission to write custom logs


# 🚀 Recommended Automation
For SLED teams with limited time:
Use Azure Automation or GitHub Actions to schedule:

Daily: risky sign-in pulls
Weekly: stale account review
Hourly: forwarding rule enforcement
Continuous: incident export to Sentinel

Feed outputs into:

Sentinel analytics
Power BI workbooks
Change-management reports
Compliance evidence folders


# 📝 Operational Best Practices

Always run scripts in PowerShell 7+ for Graph compatibility
Validate script behavior in a test environment first
Use least-privilege service principals for automation
Store secrets in Key Vault or GitHub encrypted variables
Log and timestamp all automated actions
Pair script outputs with Conditional Access enforcement
