# Appendix B – Intune Compliance Baseline (Enriched)
This appendix provides a production-ready Intune device compliance baseline for SLED (State, Local, and Education) organizations. It focuses on rapid deployment, strong security defaults, observability, and operational simplicity for small teams. The controls map cleanly to NIST SP 800‑171 and CJIS–aligned environments.

---

# 1. Purpose of This Baseline
This compliance baseline establishes:
- Minimum security requirements for Windows, macOS, iOS, and Android devices  
- Enforcement of encryption, OS health, Defender integration, and secure configurations  
- Inputs to Conditional Access (CA) so only secure devices can access Microsoft 365  
- Audit‑ready evidence for NIST SP 800‑171 (CM, AC, IA, SI families)

This baseline is intentionally:
- Lightweight — deployable within 1–3 days  
- Modular — can expand into Good → Better → Best tiers  
- Vendor‑neutral — works for GCC, A5/E5, G3/E3, and mixed environments  

---

# 2. General Baseline Requirements

## 2.1 Mandatory Controls Across All Platforms
All managed devices must meet the following:
- **Encryption enabled** (BitLocker, FileVault, OS‑native mobile crypto)  
- **Screen lock** with organization‑defined timeout  
- **OS version ≥ minimum supported level**  
- **Defender for Endpoint or equivalent agent installed**  
- **Jailbreak/root detection** (mobile)  
- **Secure boot (Windows) or System Integrity Protection (macOS)**  
- **Device health attestation** (platform supports)  
- **No high‑risk or untrusted state** via Microsoft Threat Protection  

---

# 3. Windows 10/11 Compliance Policy (Detailed)

## 3.1 Required Settings
- **Require BitLocker** with XTS‑AES 128+  
- **Require Secure Boot enabled**  
- **Require TPM available & functioning**  
- **Defender Antivirus real‑time protection = On**  
- **Defender Antivirus cloud protection = On**  
- **Firewall = Enabled for all profiles**  
- **Require Code Integrity / Memory Integrity**  
- **Minimum OS version:**  
  - Windows 10 = 22H2  
  - Windows 11 = 23H2  
- **Block devices with any MDM compliance errors**  

---

## 3.2 Recommended Optional Settings
- Require “Smart App Control = On” (Windows 11)  
- Require “Local admin password solution (LAPS)” configured  
- Disallow installation of unsigned drivers  

---

## 3.3 Intune JSON Example (Windows)
> Note: This JSON is for documentation, not directly importable.

```json
{
  "platform": "windows10AndLater",
  "encryption": {
    "requireBitLocker": true,
    "bitLockerEncryptionMethod": "xtsAes256"
  },
  "defender": {
    "realTimeProtection": "enabled",
    "cloudDeliveredProtection": "enabled"
  },
  "firewall": {
    "firewallEnabled": true
  },
  "osMinimumVersion": "10.0.19045.0",
  "secureBootEnabled": true,
  "tpmRequired": true,
  "deviceHealthAttestationRequired": true
}
```

---

# 4. macOS Compliance Policy

## 4.1 Required Controls
- **FileVault enabled**
- **Firewall enabled**
- **Minimum OS:** macOS 13 Ventura
- System Integrity Protection (SIP) enabled
- Defender for Endpoint installed and healthy
- Password complexity enforced (min length, expiration optional)

---

## 4.2 Recommended

- Kernel extension (KEXT) approvals defined
- MDM‑supervised Apple Silicon devices
- Disable “Allow apps from anywhere”

---

# 5. iOS/iPadOS Compliance Policy

## 5.1 Required
- Passcode required
- Minimum OS version: iOS/iPadOS 16
- Jailbreak detection: block compromised devices
- No blocked apps installed
- Device encryption enabled (automatic)
- App Protection Policies (APP) enforced for MAM‑only devices

---

## 5.2 Recommended
- Block iCloud backup for corporate data
- Require managed apps for saving files
- Require Microsoft Defender Mobile

---

# 6. Android Compliance Policy

## 6.1 Required
- Strong screen lock
- Minimum OS version: Android 11
- Root detection → block
- SafetyNet/Play Integrity attestation required
- Device encryption required
- Defender Mobile deployed

---

##6.2 Recommended
- Block installation of apps from unknown sources
- Require Work Profile Separation (Android Enterprise)

---

# 7. Integration with Conditional Access
> Compliance policies become meaningful only when enforced with CA.
### Mandatory Pairings:
- CA Policy: Require compliant device for admin roles
- CA Policy: Require compliant or hybrid‑joined device for all cloud apps on high‑risk users
- CA Policy: Block access from devices not meeting MDM compliance

---

# 8. Compliance Reporting (Audit & NIST Evidence)

## 8.1 Evidence to Generate
- Device compliance export (CSV via Intune)
- Defender for Endpoint exposure score reports
- List of devices failing health attestation
- List of non‑encrypted devices
- OS version distribution (per platform)

---

## 8.2 Mapped Control Families
- CM (Configuration Management): CM‑2, CM‑6
- AC (Access Control): AC‑17, AC‑19
- SI (System Integrity): SI‑3, SI‑7
- IA (Identification and Authentication): IA‑2

---

# 9. Exceptions Handling

##9.1 Temporary Exceptions

Allowed only for:
- Lab machines
- Kiosk or shared devices
- Legacy hardware pending refresh

Must include:
- Business justification
- Expiration date (≤ 90 days)
- Monitoring plan

---

## 9.2 Permanent Exceptions
>Not recommended.
If required:
- Must be documented
- Must be segmented by CA
- Must not have administrative privileges

---

# 10. Summary
This Intune compliance baseline delivers:
- Strong, enforceable security defaults
- Clear alignment to NIST 800‑171 and OSC’s internal architecture
- Cross‑platform support for Windows, macOS, iOS, and Android
- A foundation for Conditional Access, Defender, and Sentinel integration

The baseline is designed for small SLED teams who need security that works immediately, requires minimal tuning, and generates audit‑ready evidence.
