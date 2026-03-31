# 30‑Day Minimum Viable Baseline (MVB) Checklist
A practical, time‑boxed rollout plan for strengthening Microsoft 365 security in SLED (State, Local, Education) environments with limited staff, hybrid architectures, and budget constraints.  
Designed for teams of 1–5 people using Microsoft 365, Intune, Defender, and Sentinel.

This plan balances:
- Fast deployment  
- Audit‑ready security controls  
- Minimal disruption to users  
- Alignment with NIST SP 800‑171 (AC, IA, CM, SI, AU)

---

# 🔵 Week 1 — Identity Hardening (Entra ID)

## 🎯 Objectives
- Strengthen tenant identity protections
- Reduce credential theft risk
- Establish privileged access guardrails

## ✔️ Tasks

### Day 1–2 — Inventory & Foundations
- Inventory all administrative accounts  
- Identify and document emergency (“break-glass”) accounts  
- Rotate break-glass passwords (48+ chars)  
- Require password changes for stale privileged accounts  
- Enable security defaults only if CA policies don’t exist

### Day 3 — Enforce MFA (Step-by-step)
- Enable MFA for **all users**  
- Exclude only break-glass accounts  
- Import users/groups into usage reports  
- Validate MFA app authentication on mobile devices

### Day 4 — Conditional Access Baseline
- CA Policy 1: **Block legacy authentication**  
- CA Policy 2: **Require MFA for all users**  
- CA Policy 3: **Require MFA for risky sign-ins**  
- CA Policy 4: **Require compliant/hybrid-joined device for admins**  
- All policies start in **Report-only mode** (24–48 hours)

### Day 5 — Privileged Access Management
- Enable **Privileged Identity Management (PIM)**  
- Require just‑in‑time (JIT) activation for all roles  
- Add approval workflow for Global Admin and Security Admin  
- Configure PIM notifications (activation, changes, assignments)

---

# 🔵 Week 2 — Device Compliance & Endpoint Security

## 🎯 Objectives
- Establish mandatory device standards
- Onboard endpoints into Defender XDR
- Enforce health and compliance at sign‑in

## ✔️ Tasks

### Day 6–7 — Intune Core Setup
- Create device groups (Windows, macOS, iOS, Android)
- Assign scope tags and admin roles
- Configure enrollment restrictions

### Day 8–9 — Compliance Baseline (All Platforms)
- Windows:
  - BitLocker enabled  
  - Secure Boot required  
  - Defender AV real-time protection, cloud protection  
  - Minimum OS version set  
- macOS:
  - FileVault + Firewall required  
  - SIP enabled  
- iOS/Android:
  - Passcode required  
  - Jailbreak/root detection  
  - Device encryption required  

### Day 10 — Configuration Profiles
- Deploy baseline endpoint profiles:
  - BitLocker/FileVault configuration  
  - Firewall baseline  
  - Attack Surface Reduction (ASR)  
  - LAPS (Windows 11)  
  - System Integrity settings (Windows/macOS)

### Day 11 — Defender for Endpoint Onboarding
- Onboard Windows, macOS, Linux (if present)
- Validate sensors reporting to Defender XDR
- Test alerts: EICAR file, ASR audible notifications

### Day 12 — Conditional Access Device Gate
- Enforce CA policy: **Require compliant/hybrid device for admin sign-in**
- Pilot for IT/security teams first

### Day 13–14 — Reporting & Drift Correction
- Review noncompliant devices
- Remediate top 10 device issues
- Document exceptions and expiration dates

---

# 🔵 Week 3 — Email & Collaboration Security (Defender for Office 365)

## 🎯 Objectives
- Harden email against phishing, spoofing, malware
- Activate safe-by-default policies for URLs and attachments
- Increase visibility for SOC and IT staff

## ✔️ Tasks

### Day 15–16 — Anti-Phish Policies
- Enable Mailbox Intelligence  
- Configure domain & user impersonation protection  
- Turn on Spoof Intelligence  
- Set Phishing Threshold Level = 2 or 3  
- Quarantine all phish + high-confidence phish

### Day 17 — Safe Links
- Enable for:
  - Email  
  - Teams  
  - Office apps  
  - SharePoint/OneDrive links  
- Disable click-through  
- Enable URL tracking for incident correlation

### Day 18 — Safe Attachments
- Set **Dynamic Delivery = On**  
- Set action: **Replace**  
- Enable for email + SharePoint + OneDrive + Teams  
- Verify ZAP (Zero-hour Auto Purge) is active

### Day 19 — Quarantine & Reporting Workflow
- Create admin quarantine review roles  
- Set end-user quarantine notifications  
- Enable “Report Phish” button for users  
- Route submissions to SOC mailbox or Teams channel

### Day 20 — Validation & Simulation
- Run phishing simulations  
- Validate detection in:
  - Explorer  
  - User timeline  
  - Incident queue  

---

# 🔵 Week 4 — Visibility, Detection, and Response (Sentinel + XDR)

## 🎯 Objectives
- Stand up cloud-native SOC capabilities  
- Enable key analytics and automation  
- Establish ongoing operational rhythm

## ✔️ Tasks

### Day 21–22 — Sentinel Workspace & Connectors
- Create Log Analytics Workspace  
- Enable Sentinel  
- Connect:
  - Microsoft 365 Defender  
  - Azure AD Sign-in Logs  
  - Office 365  
  - Azure Activity Logs  

### Day 23–24 — Analytics Rules
Enable built‑in rules:
- Suspicious inbox forwarding  
- Multiple MFA failures → success  
- Impossible travel  
- Defender XDR correlated incidents  
- User reported phishing → incident creation  

### Day 25 — SOAR Playbooks
Deploy at least 3:
1. Disable malicious inbox forwarding  
2. Notify SOC via Teams for high-impact incidents  
3. Auto-block malicious IPs/URLs/domains (with approval or human-in-the-loop)

### Day 26 — Workbooks (Dashboards)
Enable:
- Sentinel Overview  
- Identity Protection Dashboard  
- Defender XDR Incident Analysis  
- Cost Monitoring + Usage  

### Day 27 — Cost Controls
- Move verbose tables to Basic Logs where appropriate  
- Set table-level retention  
- Apply DCR filters to noisy sources  
- Review ingestion costs vs. budget

### Day 28–29 — Incident Response Runbooks
Document repeatable actions:
- Compromised user response  
- Malware on device  
- Phishing campaign  
- Impossible travel  
- OAuth consent attack  

### Day 30 — Final Validation & Handoff
- Run full tenant configuration review  
- Confirm all CA policies → “Enabled”  
- Confirm device compliance baseline stable  
- Confirm Safe Links/Attachments active  
- Review Sentinel incident queue  
- Present MVB outcome summary to leadership

---

# 📘 Summary

At the end of 30 days, your SLED organization will have:

- Mandatory MFA  
- Hardened CA policies for identity and devices  
- A secure, compliant device fleet  
- End-to-end phishing and malware protection  
- Defender XDR integrated with Sentinel  
- Automated response playbooks  
- A basic but functioning cloud-native SOC  
- Audit-ready evidence for NIST SP 800‑171

This checklist forms the foundation for your Good → Better → Best security tiers and supports ongoing operational maturity.
