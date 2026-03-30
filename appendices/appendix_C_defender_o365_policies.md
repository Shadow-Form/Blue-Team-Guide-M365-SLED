# Appendix C – Defender for Office 365 Policies

This appendix provides a complete Defender for Office 365 (MDO) configuration baseline for SLED (State, Local, Education) environments. The policies here support phishing protection, anti-malware enforcement, URL and attachment detonation, user reporting, and SOC operations. They map to NIST SP 800‑171 (SI-3, SI-4, SI-7).

---

# 1. Purpose of This Policy Set

These policies ensure:
- Phishing, spoofing, and malware are actively blocked  
- URL clicks and attachments are detonated in real time  
- User‑reported messages flow cleanly into the SOC triage process  
- Security enforcement is consistent across Exchange Online, SharePoint, OneDrive, and Teams  
- Incident response teams receive usable metadata and alert context  
- SLED teams can deploy this baseline in days, not months  

This baseline assumes:
- Exchange Online Protection (EOP) defaults  
- Defender for Office 365 Plan 1 or Plan 2  
- PowerShell, Microsoft 365 Defender portal, and Exchange Admin Center (modern) are available  

---

# 2. Core Policy Families

## Policy Family Overview
| Policy Area | Goal | Enforcement Level |
|-------------|------|------------------|
| Anti-malware | Prevent malware delivery & execution | Mandatory |
| Anti-phish | Stop credential theft, business email compromise | Mandatory |
| Safe Links | Real-time URL detonation | Mandatory |
| Safe Attachments | Real-time file detonation | Mandatory |
| Reporting & Quarantine | User reporting + automated SOC routing | Strongly recommended |
| Post-delivery review | Retroactive ZAP cleanup | Mandatory |

---

# 3. Anti-Malware Baseline Policy

## 3.1 Required Settings
- Enable **zero-hour auto purge (ZAP)** for malware & phishing  
- Enable **common attachments filter** (e.g., `.exe`, `.jar`, `.scr`, `.vbs`, `.ps1`, `.hta`)  
- Enable **Real-time scanning** across all Microsoft 365 workloads  
- Enable **Dynamic Delivery** integration (with Safe Attachments)  
- Block file types known for scripting abuse  
- Enable **anti-virus engine updates hourly**  

---

## 3.2 Example PowerShell Configuration (Anti-Malware Policy)

```powershell
Set-MalwareFilterPolicy -Identity "Default" `
  -EnableFileFilter $true `
  -FileTypes exe,js,vbs,ps1,scr,jar,wsf,hta `
  -Action Block `
  -ZapEnabled $true `
```

---

# 4. Anti-Phish Baseline Policy

## 4.1 Required Settings
- Enable Mailbox intelligence
- Enable User impersonation protection
- Enable Domain impersonation protection
- Enable Spoof Intelligence
- Priority allow list for validated senders
- Configure advanced phishing threshold = 2 or 3
- Set message actions:
  - High confidence phish → Quarantine
  - Regular phish → Quarantine
  - Spoofed sender → Quarantine

---

## 4.2 Phish Simulation Allow Lists
**Recommended:**
- Scope allow lists only to simulation vendors
- Avoid using allow lists for normal business email

---

## 4.3 Example Anti-Phish JSON
```json
{
  "policyName": "AntiPhish-Baseline",
  "mailboxIntelligence": true,
  "userImpersonationProtection": {
    "enabled": true,
    "protectedUsers": ["executive@org.gov", "finance@org.gov"]
  },
  "domainImpersonationProtection": {
    "enabled": true,
    "protectedDomains": ["org.gov"]
  },
  "phishThresholdLevel": 3,
  "spoofIntelligence": "enabled",
  "actions": {
    "highConfidencePhish": "quarantine",
    "phish": "quarantine"
  }
```

---

# 5. Safe Links Policy

## 5.1 Scope
-Email
- Teams
- Office apps (Word, Excel, PowerPoint)
- SharePoint & OneDrive links

---

## 5.2 Required Settings
- Enable real-time URL scanning
- Enable URL rewriting
- Enable click-time protection
- Do NOT allow users to bypass
- Track user clicks for incident response correlation

---

## 5.3 Example Safe Links PowerShell
```powershell
Set-SafeLinksPolicy -Identity "Baseline" `
  -EnableForTeams $true `
  -EnableForEmail $true `
  -EnableForOffice $true `
  -TrackUserClicks $true `
  -AllowClickThrough $false
```

---

# 6. Safe Attachments Policy

## 6.1 Required Settings
- Dynamic Delivery: ON
  - Ensures email arrives fast while attachments detonate in sandbox
- Replace malicious attachments
- Apply to all recipients
- Enable ZAP (Zero-hour Auto Purge) cleanup
- Enable for SharePoint, OneDrive, and Teams

Dynamic Delivery is a strong fit for SLED because:
- It reduces help desk complaints about "missing mail"
- It ensures malicious files still get blocked before execution

---

## 6.2 Example Safe Attachments JSON 
```json
{
  "policyName": "SafeAttachments-Baseline",
  "dynamicDelivery": true,
  "malwareAction": "replace",
  "zapEnabled": true,
  "scope": ["ExchangeOnline", "SharePoint", "OneDrive", "Teams"]
}
```

---

#7. Quarantine & User Reporting

## 7.1 Quarantine Configuration
- Phish → Admin review required
- Malware → Admin review required
- Bulk / junk → Auto-delete after 30 days
- High-confidence malware/phish → Keep for forensics (30 days)
- SOC notification channel → Teams webhook or email

---

## 7.2 User-Reported Messages
Enable:
- User Report Phish add-in
- Route submissions → Security Operations mailbox
- Enable automatic triage in Defender
- SOC uses “Submissions” dashboard for training inbound models

---

# 8. Post-Delivery Protection (ZAP)
ZAP actions:
- Removes messages post-delivery when threat intelligence updates
- Applies to:
  - Malware
  - Phishing
  - Spam
  - Malicious URLs and attachments

---

# 9. SOC Operations & Incident Response

## 9.1 Required SOC Dashboards
- Explorer (Threat Explorer)
- Submissions
- Campaigns
- User tags (VIP, priority accounts)

---

## 9.2 Incident Handling Playbook

1. Review alert in Defender portal
2. Check “User timeline”
3. Check previous phishing attempts
4. Review any inbox rules (often signs of compromise)
5. Check message trace
6. Remediate via:
  - ZAP
  - Block sender
  - Block URL
  - Reset user session token
  - Require password change

---

## 9.3 Recommended Automation
- Auto-investigation & remediation (AIR)
- Auto-quarantine for malware, high-confidence phish
- Auto-block for malicious URLs/domains

---

# 10. Mapping to NIST SP 800-171

| NIST Control | Defender for O365 Capability |
|--------------|------------------------------|
| SI-3 | Malware scanning & blocking (Safe Attachments, Anti-malware) |
| SI-4 | ZAP, URL detonation, mailbox intelligence |
| SI-7 | Real-time scanning, spoof intelligence |
| AC-2 | Conditional Access pairings (Safe Links + compliance gating) |
| AU-6 | SOC visibility, Explorer logs |
