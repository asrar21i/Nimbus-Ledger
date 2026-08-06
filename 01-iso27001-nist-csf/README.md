# Nimbus Ledger — ISO 27001 & NIST CSF Compliance Project

## Overview

This project demonstrates applied GRC engineering skills — policy-as-code, cloud compliance automation, and framework mapping — using a fictional fintech company, Nimbus Ledger Pvt. Ltd., as a realistic scenario. It includes a Statement of Applicability mapped to ISO 27001, a gap assessment mapped to NIST CSF, and working technical implementations (Terraform, OPA/Rego, Python/boto3) backing each control. The goal is to show how compliance controls are actually implemented and evidenced in a cloud environment, not just documented on paper.

## Environment / Asset Inventory

| Asset | Type | Data Sensitivity | Owner (Role) |
|---|---|---|---|
| Nimbus customer-docs S3 bucket | Object storage | High (customer-uploaded PII documents)                                                           | Engineering Lead |
| Nimbus RDS PostgreSQL instance | Managed database | High (customer PII + transaction data)                                                           | Database Administrator / Engineering Lead |
| Nimbus EC2 app server | Compute | High (processes customer PII + transaction data in transit) | Engineering Lead |
| Nimbus IAM roles & policies | Identity and Access Management     | High (misconfiguration → unauthorized access, breaches, privilege escalation) | Cloud Security Engineer |
| Nimbus GitHub repository | Source code / CI/CD pipeline/IaC | High (infrastructure exposure, deployment credential exposure, malicious infrastructure changes) | DevOps Lead |

## Statement of Applicability (ISO 27001)

| Control ID | Control Name | Applicable? | Implementation |
|---|---|---|---|
| A.8.24 | Use of cryptography | Yes | S3 bucket encryption enforced via Terraform + Rego policy; verified continuously via AWS Config |
| A.8.32 | Change management | Yes | GitHub Actions CI pipeline blocks non-compliant Terraform via Rego/Conftest before merge |
| A.5.15 | Access control | Yes | Production RDS database deletion is restricted using an IAM explicit deny policy, ensuring only the admin role can perform critical administrative actions |
| A.8.9 | Configuration management | Yes | EC2 instances are provisioned through Terraform, validated pre-deployment using Rego/Conftest, and continuously monitored with AWS Config to prevent and detect configuration drift |
| A.5.18 | Access rights | Yes | IAM users, roles, and access key usage are reviewed periodically using boto3 evidence collection and SQL reporting to identify stale or excessive permissions |

## NIST CSF Gap Assessment

| NIST CSF Function | Subcategory | Current State | Gap | Remediation |
|---|---|---|---|---|
| Protect | Data at rest is protected using encryption | S3 buckets enforce server-side encryption through Terraform, validated by Rego, and continuously monitored using AWS Config | No gap | Encryption implemented and continuously verified |
| Protect | Access to critical systems is restricted to authorized users | Production database is protected by an IAM explicit deny policy restricting deletion to the NimbusDBAdmins role; periodic IAM access reviews provide ongoing evidence | No gap | Access restriction and review process implemented |
| Identify | Operating systems and software are kept up to date with security patches | EC2 instances are deployed and monitored for configuration drift, but there is no documented process or automated mechanism for OS patching | Gap identified | Implement AWS Systems Manager Patch Manager; maintain evidence of successful patching |
| Detect | Detect exposure of credentials/secrets | Rego policies check Terraform configuration; AWS Config checks live resource state — neither inspects code content for hardcoded secrets | Gap identified | Add secret-scanning (e.g., Gitleaks or GitHub secret scanning) as a GitHub Actions step |
| Identify | Maintain an accurate and current inventory of assets | Initial asset inventory created manually; no defined process to keep it updated as resources are created/retired | Gap identified | Automate inventory collection via boto3 script (see `scripts/asset_inventory.py`) |
| Respond | Notify responsible personnel when non-compliant resources are detected | AWS Config evaluates and marks resources COMPLIANT/NON_COMPLIANT, but generates no automatic notification | Gap identified | Route AWS Config compliance events through EventBridge → SNS → Slack/email |
| Protect | Backup/versioning protects against accidental or malicious data loss | No versioning or MFA delete is currently enforced on S3 buckets; an object could be permanently deleted or overwritten with no recovery path | Gap identified | Enable S3 versioning and MFA delete on all buckets; add a Rego policy to enforce versioning is enabled at deploy time |

## Cross-Framework Mapping (ISO 27001 ↔ NIST CSF)

| Control Area | ISO 27001 Control | NIST CSF Function/Subcategory | Shared Technical Control |
|---|---|---|---|
| Data protection at rest | A.8.24 — Use of cryptography | Protect — Data-at-rest is protected | S3 encryption via Terraform + Rego + AWS Config |
| Access control | A.5.15 — Access control | Protect — Access restricted to authorized users | IAM explicit deny policy on production RDS |
| Change management | A.8.32 — Change management | Protect / Detect — Configuration & change control | GitHub Actions CI gate blocking non-compliant Terraform |
| Access governance | A.5.18 — Access rights | Protect — Periodic access review | boto3 + SQL IAM access review |

## Key Findings & Remediation Priorities

Four gaps were identified during this assessment. Three remain open and are prioritized below by risk; one has already been addressed with working code included in this repo.

**Open gaps, prioritized by risk:**

1. **No secret-scanning in CI/CD** (Detect) — highest priority, since a leaked credential could lead to direct unauthorized AWS access. Recommended fix: add Gitleaks or GitHub secret scanning to the existing GitHub Actions pipeline.
2. **No automated OS patch management** (Identify) — recommended fix: implement AWS Systems Manager Patch Manager with patch compliance evidence.
3. **No automatic alerting on non-compliant resources** (Respond) — recommended fix: wire AWS Config to EventBridge/SNS for real-time notification.
4. **No S3 versioning/MFA delete** (Protect) — a critical file or compliance record could be permanently deleted or silently overwritten with no recovery path. Recommended fix: enable versioning + MFA delete on all buckets, enforced via Rego policy.

**Gap already remediated:**

5. **Asset inventory staleness** (Identify) — no process previously existed to keep the asset inventory current as resources changed. This has been addressed with a working boto3 script (`scripts/asset_inventory.py`) that programmatically pulls live S3 bucket data, demonstrating a practical remediation path rather than just a recommendation.
