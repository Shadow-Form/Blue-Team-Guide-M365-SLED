# Appendix D – Microsoft Sentinel Quickstart

This appendix provides a practical, SLED-focused quickstart for deploying and operationalizing Microsoft Sentinel. It covers data connectors, analytics rules, automation (SOAR), hunting queries, cost controls, and operational rhythms tuned for organizations with small teams, hybrid environments, and limited budgets. It also aligns with NIST SP 800‑171 (AU, IR, SI) logging and monitoring requirements.

---

# 1. Sentinel Purpose & Value for SLED

Microsoft Sentinel provides:
- **Cloud-native SIEM/SOAR** with low operational overhead  
- **Integrated signals** from Entra, Microsoft 365 Defender, Azure AD Identity Protection, and endpoints  
- **Scalable ingestion** across cloud, on-premises, and legacy systems  
- **Automated response** (disable accounts, block URLs, notify security teams)  
- **Audit-ready logging** mapped to regulatory controls  

SLED teams benefit because Sentinel:
- Reduces infrastructure burden  
- Supports complex hybrid networks  
- Allows incremental deployments to manage cost  
- Integrates tightly with Defender XDR  

---

# 2. Deployment Architecture Overview

## 2.1 Core Components
- **Log Analytics Workspace (LAW)** – storage + query engine  
- **Sentinel Layer** – analytics rules, incidents, automation  
- **Data connectors** – pipelines for logs and events  
- **Playbooks** – Logic Apps used for automated response  
- **Workbooks** – visual dashboards  

---

## 2.2 Quickstart Architecture (Text Diagram)

[Microsoft 365] ──
[Azure AD / Entra] ── Data Connectors ──> [Log Analytics Workspace] ──> Analytics Rules
[Defender XDR] ────/                                   │
▼
[Sentinel Incidents]
│
▼
[SOAR Playbooks]
│
▼
[Alerts / Ticketing / Auto-Remediation]

---

# 3. Data Connectors (Enable First)

> These should be enabled immediately in all SLED deployments

## 3.1 Microsoft 365 Defender Connector  
Provides unified incidents, device alerts, email events, identity events.

**Settings:**
- Enable bi-directional sync  
- Allow incident ingestion  
- Stream advanced hunting events if available  

---

## 3.2 Azure AD / Entra ID Sign-in Logs  
Includes MFA failures, risky sign-ins, token anomalies.

**Use cases:**
- Impossible travel  
- Brute force detection  
- Token theft / replay  

---

## 3.3 Office 365 Connector  
Includes message trace, mailflow, DLP metadata.

**Use cases:**
- Exfiltration investigations  
- Phishing campaign analysis  

---

## 3.4 Defender for Cloud Apps (optional but recommended)  
Recommended for:
- App governance  
- OAuth threats  
- Shadow IT  

---

# 4. Baseline Analytics Rules

> Enable these built-in rules on day one

## 4.1 Suspicious Inbox Forwarding  
Detects rules forwarding mail to external accounts.

## 4.2 Multiple MFA Failures Followed by Success  
Indicates possible password-spray success.

## 4.3 Impossible Travel  
Matches sign-in location deltas exceeding expected movement.

## 4.4 Email Reported as Phish  
Generates an incident when users report phishing messages.

## 4.5 Defender XDR Correlated Incident  
Ingests and tracks incident root cause + lateral movement chain.

---

# 5. Custom KQL Queries (Ready for Hunting)

## 5.1 Impossible Travel (Enriched)
```kql
let thresholdKm = 5000;
SigninLogs
| extend Previous = lag(LocationDetails, 1)
| where Previous.Country != Country
| extend DistanceKm = geo_distance_2points(
    todouble(LocationDetails.Latitude),
    todouble(LocationDetails.Longitude),
    todouble(Previous.Latitude),
    todouble(Previous.Longitude))
| where DistanceKm > thresholdKm
| project UserPrincipalName, IPAddress, Country, Previous, DistanceKm, Timestamp
```

---

## 5.2 High-Risk Users with Recent MFA Failures
```kql
SigninLogs
| where RiskLevelDuringSignIn in ("medium", "high")
| join kind=leftouter (
    SigninLogs
    | where ResultType != 0
    | where ConditionalAccessStatus == "failure"
) on UserPrincipalName
| project UserPrincipalName, RiskLevelDuringSignIn, ResultType, AppDisplayName, IPAddress, Timestamp
```

---

## 5.3 Suspicious OAuth App Consent
```kql
AADNonInteractiveUserSignInLogs
| where AppDisplayName has "Consent"
| summarize count() by AppDisplayName, UserPrincipalName, IPAddress
```

---

# 6. SOAR Playbooks (Automation)

## 6.1 Playbook: Auto-disable Forwarding Rule
When Sentinel triggers an incident about suspicious forwarding:
Actions:
1. Remove inbox rule
2. Notify SOC
3. Require user sign-in reauthentication
4. Log remediation outcome

JSON example (documentation format):
```json
{
  "playbookName": "Disable-Forwarding-Rule",
  "trigger": "SentinelIncident",
  "actions": [
    "Remove-InboxRule",
    "Send-TeamsNotification",
    "Trigger-Reauth",
    "Write-LogEntry"
  ]
}
```

---

# 7. Cost Management for SLED

## 7.1 Enable Basic Logs Where Appropriate

Storage tier for verbose, low-value logs:
- AuditLogs
- SignInLogs (older than 30 days)
- DefenderAlerts (non-critical)

---

## 7.2 Use Data Collection Rules (DCRs)

- Filter noisy sources
- Tokenize logs before ingestion
- Route only critical logs to Analytics tier

---

## 7.3 Set Table-Level Retention

Examples:
- 30 days for SigninLogs
- 60–90 days for DefenderAlerts
- 180+ days for SecurityEvent

---

## 7.4 Use Workbooks for Cost Visualization
Standard workbook: “Usage and Estimated Costs” in Sentinel.

---

# 8. Operational Rhythm for Small SLED Teams

**Daily**
- Review new Sentinel incidents
- Validate auto-remediation outcomes
- Check Identity Protection risky users

**Weekly**
- Review custom analytics rule hits
- Patch drift reports (via Defender / Intune)
- Review Active Incidents dashboard

**Monthly**
- Run full threat hunting queries
- Review data ingestion spend
- Validate connector health

**Quarterly**
- Review access logs against privileged roles
- Update geolocation allow/block lists
- Review automation failures and fix

---

# 9. Mapping to NIST SP 800‑171

| Control | Sentinel Capability |
|---------|---------------------|
| AU-2 | Centralized log collection |
| AU-6 | Automated analysis of anomalies |
| IR-4 | Automated response playbooks |
| SI-4 | Correlated alerting + incident fusion |
| SI-7 | Verification of integrity via analytics rules |

These controls work together to provide “ongoing security monitoring,” a phrase echoed in OSC security documentation (malicious content detection, system scanning, continuous monitoring).

---

# 10. Summary
This Microsoft Sentinel quickstart delivers:
- A fully deployable SLED-friendly SIEM/SOAR baseline
- Essential connectors for identity, email, endpoint, and cloud activity
- Practical analytics rules and hunting queries
- Automated response mechanisms for high-risk events
- Cost controls for budget-limited environments
- NIST-aligned operational practices
