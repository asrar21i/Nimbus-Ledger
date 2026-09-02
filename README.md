# Nimbus Ledger

## GRC Engineering & Cloud Compliance Automation

Nimbus Ledger is a fictional fintech environment designed to demonstrate practical **Governance, Risk and Compliance (GRC) engineering** in an AWS environment.

The project translates selected security and governance requirements into **Infrastructure-as-Code (IaC), Policy-as-Code, automated testing, CI/CD enforcement, and machine-generated evidence**.

The core control flow is:

**Terraform → Terraform Plan → Plan JSON → OPA/Rego → Conftest → GitHub Actions → Required Status Check**

The project currently focuses on preventive controls before infrastructure changes are merged. It also demonstrates how control design, testing, evidence, and operating effectiveness can be reasoned about from a GRC perspective.

> **Scope note:** Nimbus Ledger is a portfolio/demo project. It does not claim complete ISO 27001, NIST CSF, DPDP Act/Rules, or RBI compliance.

---

## Objectives

This project demonstrates how a GRC practitioner can:

- Translate governance requirements into technical controls.
- Prevent non-compliant infrastructure changes before deployment.
- Use Terraform plan JSON as a structured compliance input.
- Evaluate infrastructure with OPA/Rego and Conftest.
- Test policy behavior with positive, negative, and lifecycle edge cases.
- Integrate compliance checks into GitHub Actions.
- Use a required GitHub status check as a merge gate.
- Produce machine-generated compliance evidence.
- Map technical controls to ISO/IEC 27001 and NIST CSF.
- Consider Indian regulatory context, especially the DPDP Act/Rules and applicable RBI requirements.
- Distinguish **control design** from **operating effectiveness**.

---

## Project Structure

```text
01-iso27001-nist-csf/
│
├── terraform/
│   ├── provider.tf
│   ├── variables.tf
│   ├── s3.tf
│   ├── rds.tf
│   ├── ec2.tf
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
│   └── sample_flagged_users_output.csv
│
├── scripts/
│   ├── asset_inventory.py
│   └── IAM_access_review.py
│
└── .github/
    └── workflows/
        └── compliance-check.yml
```

---

# Policy Coverage

| Rego Policy | Terraform Resource | Risk Controlled |
|---|---|---|
| `s3_encryption.rego` | S3 | Prevents storage without the required encryption configuration. |
| `s3_versioning.rego` | S3 | Reduces risk of accidental or malicious object deletion/overwrite by requiring versioning. |
| `s3_public_access_block.rego` | S3 | Prevents public S3 access configuration. |
| `rds_security.rego` | RDS | Prevents insecure database configurations such as unencrypted storage or public accessibility. |
| `security_group_open_ports.rego` | Security Groups | Prevents exposure of administrative/remote-management ports to the internet. |
| `iam_wildcard_check.rego` | IAM | Detects overly broad IAM permissions that can increase privilege-escalation or unauthorized-access risk. |
| `ec2_owner_tag.rego` | EC2 | Requires an accountable owner for EC2 resources. |
| `dataclassification_tag.rego` | S3/RDS/EC2 | Requires an approved `DataClassification` value and distinguishes missing from invalid classification. |

---

# Data Classification Control

The project includes a dedicated `DataClassification` policy.

Allowed values are:

```text
Public
Private
Confidential
Restricted
```

The policy handles three important states:

```text
Missing tag
    ↓
DENY

Tag exists but value is invalid
    ↓
DENY

Tag exists and value is approved
    ↓
PASS
```

Terraform destroy actions are treated separately because Terraform represents the post-change state as:

```text
change.after = null
```

The policy explicitly avoids applying the tagging check to that destroy state.

This demonstrates a basic policy-design principle:

> A compliance control should have a clearly defined scope and should behave predictably across relevant infrastructure lifecycle states.

The policy is tested with missing, valid, invalid, and destroy-action fixtures, including exact-message assertions for the missing and invalid cases (not just pass/fail counts), so the test suite verifies which control fired, not only that something did.

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
PASS / FAIL
        │
        ▼
GitHub Actions
        │
        ▼
Required policy-check status
        │
        ▼
Merge permitted / blocked
```

The GitHub Actions workflow performs the compliance evaluation before infrastructure changes are merged.

The repository's `main` branch is configured with the compliance status check as a required check. This is important because a CI job reporting failure is not, by itself, the same thing as a merge-control gate.

---

# Control Design vs Operating Effectiveness

This project deliberately distinguishes between the two.

### Control Design

The intended control is:

- Terraform defines the infrastructure configuration.
- Rego defines the compliance requirement.
- Conftest evaluates the Terraform plan.
- GitHub Actions executes the policy check.
- Branch protection requires the compliance status to pass before merge.

### Operating Effectiveness Evidence

Evidence that the control operates includes:

- Rego policy tests, including exact-message assertions.
- Conftest execution.
- GitHub Actions execution results.
- Required-status-check configuration.
- Retained CI artifacts/evidence for historical runs.

This distinction is important in GRC because:

> A well-designed control is not automatically an effectively operating control.

---

# Testing

OPA/Rego tests cover:

- Compliant resources.
- Missing required tags.
- Invalid classification values.
- Multiple AWS resource types.
- Terraform destroy actions where `change.after` is `null`.
- Exact denial output for representative missing/invalid cases.

The test suite is designed to verify not only that a violation occurs, but also that the policy does not produce unintended duplicate violations.

Example:

```text
Missing DataClassification
        ↓
One missing-tag denial

Invalid DataClassification
        ↓
One invalid-value denial

Valid DataClassification
        ↓
No denial

Destroy action
        ↓
No classification denial
```

---

# Evidence

The project uses machine-generated evidence to support control testing and review.

Examples include:

- Terraform plan JSON.
- Policy evaluation results.
- Asset inventory output.
- IAM access-review output.

For a production implementation, compliance evidence should be retained as distinct CI artifacts rather than repeatedly overwriting a single repository file.

A production implementation should use a unique run identifier such as a GitHub Actions run ID or commit SHA and upload the evidence as a retained artifact.

This allows a reviewer to answer:

> "What evidence demonstrates that this control operated during a particular run?"

rather than only seeing the latest result.

---

# Indian Regulatory Context

Because Nimbus Ledger is modeled as an Indian fintech handling customer information, the project considers relevant Indian regulatory context.

The project does **not** claim that its Terraform/OPA controls constitute complete regulatory compliance.

## Digital Personal Data Protection Act, 2023

The DPDP Act establishes obligations for Data Fiduciaries and includes requirements for appropriate technical and organisational measures and reasonable security safeguards to prevent personal data breaches.

Relevant project controls include:

| DPDP concept | Project relevance |
|---|---|
| Security safeguards | Encryption, IAM, network-security and public-access controls |
| Technical and organisational measures | Preventive IaC and Policy-as-Code controls |
| Personal-data breach prevention | S3 public-access and encryption controls |
| Data classification | `dataclassification_tag.rego` supports governance of classified resources |
| Access control | IAM policy validation |
| Evidence | Terraform plan and automated policy-test evidence |

### Important scope boundary

The project does **not** implement the full DPDP compliance lifecycle.

The following are outside the current technical scope:

- Consent and lawful processing workflows.
- Privacy notices.
- Data Principal rights workflows.
- Retention and erasure workflows.
- Grievance handling.
- Complete personal-data inventory/RoPA-style governance.
- Data breach response and regulatory notification workflow.
- Complete Data Fiduciary/Data Processor contractual governance.

Therefore, the correct claim is:

> **The project demonstrates technical controls that can support selected DPDP security and governance obligations; it does not represent complete DPDP compliance.**

---

# DPDP Act and Rules — Current Context

The Digital Personal Data Protection Act, 2023 was enacted in India.

The **Digital Personal Data Protection Rules, 2025** were notified in November 2025, with phased commencement provisions running through May 2027.

This README therefore treats DPDP as an active regulatory design consideration rather than describing it as merely a future law.

The exact applicability and obligations for a real organisation depend on its role, processing activities, personal-data flows, and other applicable requirements.

---

# RBI / Indian Fintech Context

For a real Indian regulated financial or payment entity, additional RBI requirements may apply depending on the organisation's regulatory status and activities.

For example, RBI's **Master Directions on Cyber Resilience and Digital Payment Security Controls for non-bank Payment System Operators, 2024** cover areas including:

- Governance.
- Risk assessment and monitoring.
- Inventory management.
- Identity and access management.
- Network security.
- Data security.
- Patch and change management.
- Incident response.
- Cloud security.
- Business continuity.

Nimbus Ledger's controls have conceptual overlap with several of these areas, particularly:

- IAM.
- Data security.
- Change management.
- Cloud security.
- Configuration governance.

However:

> **RBI applicability is entity- and activity-specific, and this portfolio project does not claim universal RBI compliance.**

---

# ISO/IEC 27001 Mapping

| Technical Control | ISO/IEC 27001:2022 | Purpose |
|---|---|---|
| S3 Encryption | A.8.24 Use of cryptography | Protect data at rest |
| S3 Versioning | A.8.13 Information backup | Support recoverability |
| S3 Public Access Block | A.5.15 Access control | Reduce unauthorized exposure |
| RDS Encryption | A.8.24 Use of cryptography | Protect database data at rest |
| RDS Public Accessibility | A.5.15 Access control | Reduce direct public exposure |
| Security Group Validation | A.8.20 Network security | Reduce network attack surface |
| IAM Wildcard Detection | A.5.18 Access rights | Reduce excessive permissions |
| Data Classification | A.5.12 Classification of information | Support information-classification governance |
| Asset Inventory | A.5.9 Inventory of information and other associated assets | Support asset accountability |
| CI/CD Compliance Gate | A.8.32 Change management | Govern infrastructure changes |

> The mappings are control-level mappings for this demonstration, not a claim that implementing one technical control establishes compliance with the entire ISO control or standard.

---

# NIST Cybersecurity Framework Mapping

| Technical Control | NIST CSF Area | Security Objective |
|---|---|---|
| Asset inventory | Identify | Maintain awareness of assets |
| IAM controls | Protect | Manage identity and access |
| S3/RDS encryption | Protect | Protect data |
| Public-access prevention | Protect | Reduce unauthorized exposure |
| Security-group validation | Protect | Reduce network exposure |
| OPA/Rego policy checks | Protect | Prevent insecure infrastructure changes |
| GitHub Actions evidence | Detect / Govern | Support monitoring and governance |
| Incident/evidence extensions | Respond | Future enhancement |

---

# Statement of Applicability — Demonstration

| Control | Applicable? | Implementation |
|---|---|---|
| A.8.24 Use of cryptography | Yes | S3/RDS encryption controls validated through Terraform and Rego |
| A.8.32 Change management | Yes | Terraform changes undergo automated policy validation before merge |
| A.5.15 Access control | Yes | IAM, S3 public-access and RDS accessibility controls |
| A.8.9 Configuration management | Yes | Terraform configuration is validated before deployment |
| A.5.18 Access rights | Yes | IAM policy validation and access-review evidence |
| A.8.13 Information backup | Yes | S3 versioning validation |
| A.5.12 Classification of information | Yes | DataClassification policy requires approved classification values |
| A.8.20 Network security | Yes | Security-group policy denies administrative ports (SSH/RDP) open to the internet |
| A.5.9 Inventory of information and other associated assets | Yes | `asset_inventory.py` produces a machine-generated asset inventory as evidence |

This is a **demonstration-level Statement of Applicability**, not an organisational ISO 27001 certification claim.

---

# Preventive vs Detective Controls

The current project primarily demonstrates **preventive controls**.

### Preventive

```text
Terraform change
      ↓
OPA/Rego
      ↓
Non-compliant?
      ↓
FAIL
      ↓
Merge blocked
```

This prevents a known non-compliant infrastructure configuration from being merged.

### Detective — planned extension

AWS Config can be introduced as a post-deployment detective control to identify configuration drift.

For example:

```text
Infrastructure deployed
        ↓
Configuration changes outside Terraform
        ↓
AWS Config evaluates resource
        ↓
Non-compliance detected
        ↓
Alert / remediation workflow
```

AWS Config is therefore **not represented as an already-implemented control in this repository**.

---

# Shared Responsibility Model

Nimbus Ledger also follows the cloud shared-responsibility concept:

> **AWS is responsible for security of the cloud, while the customer remains responsible for security in the cloud, including appropriate configuration, access control, data protection, and workload security.**

The Terraform and Policy-as-Code controls in this project primarily address the **customer's responsibilities in the cloud**.

---

# Known Limitations

This is a portfolio project rather than a production compliance platform.

Current limitations include:

- AWS Config continuous drift monitoring is not implemented.
- IAM access review currently uses sample/mock data rather than a complete live IAM data collection process.
- DPDP consent, notice, Data Principal rights, retention/erasure, grievance, and breach-notification workflows are not implemented.
- RBI controls are represented as regulatory context rather than a complete RBI compliance implementation.
- Historical evidence retention should be implemented through CI artifacts rather than relying on a single repository evidence file.
- The project does not implement a complete enterprise risk-management, privacy-management, or compliance-management system.
- ISO/NIST mappings are illustrative control mappings, not certification claims.
- All current Terraform resources are configured to be compliant; a deliberately non-compliant fixture branch is recommended to demonstrate the CI gate actually blocking a real plan, not only the Rego unit tests.

---

# Technologies Used

| Category | Technology |
|---|---|
| Cloud | AWS |
| Infrastructure as Code | Terraform |
| Policy as Code | Open Policy Agent / Rego |
| Compliance Testing | Conftest |
| Programming | Python / boto3 |
| Evidence | Terraform plan JSON, CSV, CI artifacts |
| Version Control | Git / GitHub |
| CI/CD | GitHub Actions |
| Frameworks | ISO/IEC 27001, NIST CSF |
| Indian Regulatory Context | DPDP Act 2023, DPDP Rules 2025, applicable RBI cyber/security requirements |

---

# GRC Concepts Demonstrated

This project is intended to demonstrate practical understanding of:

- Risk-based control design.
- Preventive vs detective controls.
- Control design vs operating effectiveness.
- Least privilege.
- IAM governance.
- Data classification.
- Encryption at rest vs encryption in transit.
- Configuration compliance.
- Configuration drift.
- Policy-as-Code.
- Infrastructure-as-Code governance.
- CI/CD compliance gates.
- Evidence collection and retention.
- Test fixture design.
- Positive and negative testing.
- Control exceptions and scope.
- Audit evidence quality.
- Regulatory-to-technical control translation.
- Shared responsibility in cloud environments.

---

# Future Enhancements

Potential next steps include:

1. Add AWS Config rules for post-deployment drift detection.
2. Retain compliance evidence using GitHub Actions artifacts.
3. Replace sample IAM data with a controlled live AWS evidence-collection workflow.
4. Add automated evidence metadata such as commit SHA, workflow run ID and timestamp.
5. Add alerting for detected configuration drift.
6. Add a formal risk/control register linking risks → controls → tests → evidence.
7. Extend the Indian regulatory mapping based on the actual regulated-entity profile.
8. Add privacy-specific workflows if the project is extended beyond infrastructure security.

---

# Disclaimer

Nimbus Ledger is a fictional portfolio project created for educational and professional demonstration purposes.

It is **not legal advice, regulatory advice, an ISO 27001 certification, an RBI compliance assessment, or a determination of compliance with the DPDP Act or DPDP Rules**.

Actual regulatory applicability and compliance requirements should be assessed against the organisation's legal entity, business model, processing activities, regulatory status, contracts, data flows, and current regulatory requirements.
