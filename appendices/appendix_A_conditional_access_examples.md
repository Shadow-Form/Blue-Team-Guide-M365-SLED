# Appendix A – Conditional Access Policy Examples
This appendix provides production‑ready Conditional Access (CA) patterns tailored for State, Local, and Education (SLED) environments using Microsoft Entra ID. These policies follow Zero Trust principles, least‑privilege access, and SLED‑friendly operational practices such as phased deployment, admin separation, and clear exception handling.

---

# 1. Principles for All Conditional Access Policies

## 1.1 Deployment Stages
Every policy should follow this deployment lifecycle:

1. **Report‑only (1–2 weeks)**  
   Validate impact, check sign‑in logs, confirm no false positives.

2. **Pilot Enforcement**  
   Apply to IT/security staff and a small cohort of business users.

3. **Full Enforcement**  
   Apply to all users except permitted exceptions.

4. **Exception Review**  
   Exceptions must be documented, time‑bound, and reviewed quarterly.

---

## 1.2 Naming Convention
Use a predictable naming style aligned with your governance model.

A good format is:
[CA]-[ACTION]-[CONDITION]-[TARGET]

Examples:  
CA-REQ-MFA-ALL-USERS
CA-BLOCK-LEGACY-AUTH
CA-REQ-COMPLIANT-DEVICE-ADMINS
CA-ALLOWED-BREAKGLASS

---

# 2. Baseline Policies (Recommended for All SLED Tenants)

---

## 2.1 Policy: Block Legacy Authentication  
**Purpose:** Block insecure protocols (POP, IMAP, SMTP AUTH, MAPI over RPC, etc.)  
**Why it matters:** Most credential‑stuffing and password spray attacks target legacy auth.

### Policy Design
- **Users:** All users  
- **Cloud apps:** All  
- **Conditions:** Client apps → “Other clients” (legacy protocols)  
- **Grant:** Block access  
- **Session:** N/A  

### JSON Example
```json
{
  "displayName": "CA-BLOCK-LEGACY-AUTH",
  "state": "enabled",
  "conditions": {
    "clientAppTypes": [ "other" ]
  },
  "grantControls": {
    "operator": "OR",
    "builtInControls": [ "block" ]
  }
}
```

---

## 2.2 Policy: Require MFA for All Users
**Purpose:** Ensure MFA is enforced across all cloud apps.  

**Notes for SLED:**
- Exempt break-glass accounts (2 accounts max).
- Avoid over-exempting service accounts; use workload identities.

### Policy Design
- **Users:** All users
- **Exclude:** Break-glass group
- **Cloud apps:** All
- **Grant:** Require MFA

### JSON Example
```json
{
  "displayName": "CA-REQ-MFA-ALL-USERS",
  "state": "enabled",
  "conditions": {
    "users": {
      "includeUsers": [ "All" ],
      "excludeGroups": [ "BreakGlassAccounts" ]
    }
  },
  "grantControls": {
    "operator": "AND",
    "builtInControls": [ "mfa" ]
  }
}
```

---

## 2.3 Policy: Require MFA for High-Risk Sign-ins
**Purpose:** Enforce step-up authentication when Entra detects risk.  

### Policy Design
- **Users:** All
- **Conditions:** Sign-in risk ≥ Medium
- **Grant:** Require MFA
- **Session:** Default

### JSON Example
```json
{
  "displayName": "CA-REQ-MFA-RISKY-SIGNINS",
  "conditions": {
    "signInRiskLevels": [ "medium", "high" ]
  },
  "grantControls": {
    "builtInControls": [ "mfa" ]
  },
  "state": "enabled"
}
```

---

# 3. Admin & Privileged Access Policies

---
These MUST be enabled after user-level baselines are stable.

---

## 3.1 Policy: Admin Access Requires Compliant or Hybrid-Joined Device
**Purpose:** Require admins to operate from managed devices only.  

**Why it matters:** Reduces exposure from BYOD, kisok, and unmanaged endpoints.

### Policy Design
- **Users:** Directory roles
- **Cloud apps:** All
- **Conditions:** Device → Compliant or hybrid joined
- **Grant:** Require compliant device
- **Session:** Sign-in frequency = 4 hours

###JSON Example
```json
{
  "displayName": "CA-REQ-COMPLIANT-DEVICE-ADMINS",
  "conditions": {
    "users": {
      "includeRoles": [
        # Global Admin
        "62e90394-69f5-4237-9190-012177145e10",
        # Security Admin
        "194ae4cb-b126-40b2-bd5b-6091b380977d"
      ]
    },
    "devices": {
      "deviceFilter": {
        "rule": "device.trustType -in [\"Compliant\",\"HybridAzureADJoined\"]",
        "mode": "include"
      }
    }
  },
  "grantControls": {
    "builtInControls": [ "compliantDevice" ]
  },
  "sessionControls": {
    "signInFrequency": {
      "value": 4,
      "type": "hours"
    }
  },
  "state": "enabled"
}
```

---

## 3.2 Policy: Admin MFA Enforcement (Privileged Roles)
**Purpose:** Provide separate MFA controls for admin roles.  
**Note:** Keep admin MFA seaprate from user MFA to prevent mis-scoped changes.

### Policy Design
- **Users:** Directory roles
- **Grant:** Require MFA
- **Cloud apps:** All
- **Exempt:** Break-glass accounts

### JSON Example
```json
{
  "displayName": "CA-REQ-MFA-ADMINS",
  "conditions": {
    "users": {
      "includeRoles": [ "62e90394-69f5-4237-9190-012177145e10" ]
    }
  },
  "grantControls": {
    "builtInControls": [ "mfa" ]
  },
  "state": "enabled"
}
```

---

#4. Location and Network Policies

---

## 4.1 Policy: Block Access From Certain Countries (High-Risk Regions)
**Purpose:** Restrict sign-ins from regions your organization never expects logins from.  

### Policy Design
- **Users:** All
- **Locations:** Block list *countries not used by your org)
- **Grant:** Block
- **Notes:**
- - Use "named locations" with country lists
  - Avoid blocking U.S. accidentally

### JSON Example
```json
{
  "displayName": "CA-BLOCK-NON-US-LOCATIONS",
  "conditions": {
    "users": {
      "includeUsers": [ "All" ],
      "excludeGroups": [ "BreakGlassAccounts" ]
    },
    "locations": {
      "includeLocations": [ "All" ],
      "excludeLocations": [ "UnitedStates" ]
    }
  },
  "grantControls": {
    "builtInControls": [ "block" ]
  },
  "state": "enabled"
}
```

---

# 5. Break-Glass Protection

---

## 5.1 Policy: Allow Break-Glass Accounts
**Purpose:** Ensure emergency access remains available even when CA policies block administrators.




---

# 6. Recommended Exemption Strategy

---

## 6.1 Service Accounts



---

## 6.2 Vendors/Contractors




---

# 7. Operational Guidance

---

# 8 . Summary

---


