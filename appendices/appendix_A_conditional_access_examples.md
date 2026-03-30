# Appendix A – Sample Conditional Access Policies

## Policy: Block Legacy Authentication
- Users: All
- Apps: All cloud apps
- Conditions: Client apps → legacy protocols
- Grant: Block access
- Deployment: Report-only 7 days → Enforce

## Policy: Require MFA for Risky Sign-ins
- Sign-in risk: Medium+
- Grant: Require MFA

## Policy: Admin Roles Must Use Compliant Devices
- Roles: Global Admin, Security Admin, Intune Admin, Exchange Admin
- Grant: Require device to be marked compliant
- Session: Sign-in every 4 hours
