# Nimbus Ledger

## Overview

Nimbus Ledger is a fictional fintech company created to demonstrate practical GRC engineering and cloud compliance automation in a realistic AWS environment. Rather than treating compliance as documentation alone, this project demonstrates how security controls can be implemented as code, validated automatically before deployment, and supported with machine-generated evidence.

The repository combines Infrastructure as Code (Terraform), Policy-as-Code (Open Policy Agent/Rego), automated compliance testing (Conftest), cloud evidence collection (Python/boto3), and framework mapping to **ISO/IEC 27001** and the **NIST Cybersecurity Framework (CSF)**. Together, these components demonstrate how technical security controls can be continuously enforced throughout the infrastructure deployment lifecycle.

---

# Project Structure

```text
01-iso27001-nist-csf/
│
├── terraform/
│   ├── provider.tf
│   ├── variables.tf
│   ├── s3.tf
│   ├── rds.tf
│   ├── security_group.tf
│   └── iam.tf
│
├── policy/
│   ├── s3_encryption.rego
│   ├── s3_encryption_test.rego
│   ├── s3_versioning.rego
│   ├── s3_versioning_test.rego
│   ├── s3_public_access_block.rego
│   ├── s3_public_access_block_test.rego
│   ├── rds_security.rego
│   ├── rds_security_test.rego
│   ├── security_group_open_ports.rego
│   ├── security_group_open_ports_test.rego
│   ├── iam_wildcard_check.rego
│   ├── iam_wildcard_check_test.rego
│   ├── ec2_owner_tag.rego
│   ├── ec2_owner_tag_test.rego
│   ├── dataclassification_tag.rego
│   └── dataclassification_tag_test.rego
│
├── evidence/
│   ├── sample_plan.json
│   ├── asset_inventory.csv
│   └── sample_flagged_users_output.csv   # output of IAM_access_review.py
│
├── scripts/
│   ├── asset_inventory.py
│   └── IAM_access_review.py   # currently runs on sample/mock data, not a live boto3 IAM pull yet
│
├── .github/
│   └── workflows/
│       └── compliance-check.yml
│
└── README.md
```

---

# Policy Coverage

| Rego Policy | Terraform Resource | Risk Controlled |
|-------------|--------------------|-----------------|
| `s3_encryption.rego` | `terraform/s3.tf` | Prevents customer data from being stored in an unencrypted S3 bucket, reducing the risk of unauthorized access if storage is compromised. |
| `s3_versioning.rego` | `terraform/s3.tf` | Prevents accidental or malicious deletion or overwriting of objects by ensuring previous versions can be recovered. |
| `s3_public_access_block.rego` | `terraform/s3.tf` | Prevents accidental exposure of customer documents by ensuring public access to S3 buckets is fully blocked. |
| `rds_security.rego` | `terraform/rds.tf` | Prevents sensitive database data from being stored unencrypted or exposed directly to the public internet. |
| `security_group_open_ports.rego` | `terraform/security_group.tf` | Prevents administrative/remote-management ports (such as SSH and RDP) from being exposed to the internet, reducing the attack surface and risk of unauthorized access. |
| `iam_wildcard_check.rego` | `terraform/iam.tf` | Prevents overly permissive IAM policies that could allow privilege escalation or unrestricted administrative access. |
| `ec2_owner_tag.rego` | *(Future implementation)* | Ensures every EC2 instance has a defined owner so security findings and operational responsibilities can be assigned correctly. |
| `dataclassification_tag.rego` | *(Future implementation)* | Ensures resources containing business or customer data are properly classified to support governance, compliance, and security policies. |

---

# Compliance Automation Workflow

```text
Terraform Configuration
        │
        ▼
terraform plan
        │
        ▼
Terraform Plan JSON
        │
        ▼
Conftest
        │
        ▼
OPA / Rego Policies
        │
        ▼
PASS ✅ / FAIL ❌
        │
        ▼
GitHub Actions
        │
        ▼
Pull Request Approved or Blocked
```

---

# Technologies Used

| Category | Technologies |
|----------|--------------|
| Cloud Platform | AWS |
| Infrastructure as Code | Terraform |
| Policy as Code | Open Policy Agent (OPA), Rego |
| Compliance Testing | Conftest |
| Programming | Python (boto3) |
| Evidence Collection | AWS APIs, CSV Reporting |
| Version Control | Git, GitHub |
| CI/CD | GitHub Actions |
| Compliance Frameworks | ISO/IEC 27001, NIST Cybersecurity Framework (CSF) |

---

# Compliance Framework Mapping

| Technical Control | ISO/IEC 27001 | NIST CSF |
|-------------------|---------------|----------|
| S3 Bucket Encryption | A.8.24 – Use of Cryptography | PR.DS |
| S3 Bucket Versioning | A.8.13 – Information Backup | PR.DS |
| S3 Public Access Block | A.5.15 – Access Control | PR.AC |
| RDS Storage Encryption | A.8.24 – Use of Cryptography | PR.DS |
| RDS Public Accessibility | A.5.15 – Access Control | PR.AC |
| Security Group Validation | A.8.20 – Network Security | PR.AC |
| IAM Wildcard Detection | A.5.18 – Access Rights | PR.AA |
| Resource Tag Validation | A.5.9 – Inventory of Information and Other Associated Assets | ID.AM |

## Statement of Applicability (ISO 27001)

| Control ID | Control Name | Applicable? | Implementation |
|---|---|---|---|
| A.8.24 | Use of cryptography (S3) | Yes | S3 bucket encryption enforced via Terraform + Rego policy (`s3_encryption.rego`); verified continuously via AWS Config |
| A.8.32 | Change management | Yes | GitHub Actions CI pipeline blocks non-compliant Terraform via Rego/Conftest before merge |
| A.5.15 | Access control (RDS) | Yes | Production RDS database deletion is restricted using an IAM explicit deny policy, ensuring only the admin role can perform critical administrative actions |
| A.8.9 | Configuration management | Yes | EC2 instances are provisioned through Terraform, validated pre-deployment using Rego/Conftest, and continuously monitored with AWS Config to prevent and detect configuration drift |
| A.5.18 | Access rights | Yes | IAM users, roles, and access key usage are reviewed periodically using boto3 evidence collection and SQL reporting to identify stale or excessive permissions. `iam_wildcard_check.rego` additionally detects IAM policies granting unrestricted `iam:*` permissions against `Resource = "*"`; the compliant policy is defined in `iam.tf` as `aws_iam_policy.app_read_access`, restricted to `s3:GetObject` and `s3:ListBucket` on the designated bucket. Validated through Rego tests and the Conftest/GitHub Actions pipeline. |
| A.8.13 | Information backup | Yes | `s3_versioning.rego` checks that S3 bucket versioning is enabled and denies non-compliant configurations. The required versioning configuration is defined in `s3.tf` using `aws_s3_bucket_versioning.customer_docs` with `status = "Enabled"`. Compliance is validated through Rego policy tests and the Conftest CI workflow. |
| A.5.15 | Access control (S3 public exposure) | Yes | `s3_public_access_block.rego` denies any S3 bucket where `block_public_acls`, `block_public_policy`, `ignore_public_acls`, or `restrict_public_buckets` is not `true`. Enforced via