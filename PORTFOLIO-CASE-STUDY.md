# David O'Neal: A GRC Engineering Pipeline, Built in Public

## What this is

I built an end-to-end compliance pipeline that takes a cloud resource from working code to audit-defensible infrastructure and proves every control along the way. Starting with a compliant Terraform configuration and ending with a machine-readable OSCAL control mapping, each stage builds on the last. Controls are defined in code, verified by policy, enforced by a CI gate, signed with a cryptographic chain of custody, monitored by native cloud services, and formally documented in a format auditors can traverse without asking anyone for screenshots.

## The pipeline

Week 1: Compliant infrastructure as code enforcing SC-28 encryption, AC-3 public access blocking, CM-6 required tags, and AU-3 access logging on AWS S3 buckets using Terraform with machine-readable plan evidence.

Week 2: Policy as code using Open Policy Agent and Rego that reads the Terraform plan in JSON and returns a pass or fail verdict on each control in milliseconds, using reference matching to evaluate resources at plan time before any infrastructure exists.

Week 3: A GitHub Actions CI gate that runs all three Rego policies on every pull request and blocks merges when a control fails. A compliant PR passes and merges. A non-compliant PR is blocked at the platform level by branch protection rules until the control is fixed.

Week 4: Cosign keyless signing of the evidence bundle produced by each pipeline run. The signing identity is the GitHub Actions workflow itself, not a stored key. A tamper test proves one appended byte breaks the cryptographic chain immediately.

Week 5: Native AWS cloud monitoring controls. CloudTrail deployed via Terraform for multi-region audit logging and Security Hub configured with NIST 800-53 Rev 5 alongside FSBP and CIS standards. 50 real findings captured as evidence before infrastructure teardown.

Week 6: An OSCAL component definition and profile that formally map the four implemented controls to the NIST 800-53 Rev 5 catalog and link each control to its signed evidence bundle. Validated with trestle validate returning VALID on both documents.

## Proof

All code is public and version controlled.

GitLab portfolio: https://gitlab.com/doneal78-group/grc-engineering-portfolio

GitHub CI gate and signing pipeline: https://github.com/doneal78/grc-club-week3

Green PR (all controls passing, merged): https://github.com/doneal78/grc-club-week3/pull/1

Red PR (CM-6 tag violation, blocked by branch protection): https://github.com/doneal78/grc-club-week3/pull/2

OPA policy tests 6/6 passing: https://gitlab.com/doneal78-group/grc-engineering-portfolio/grc-club-week2

Signed evidence with CHAIN INTACT verification: https://github.com/doneal78/grc-club-week3/actions

OSCAL validation VALID: https://gitlab.com/doneal78-group/grc-engineering-portfolio/grc-club-week6

## What I would do next

The most valuable immediate extension is generating the Terraform plan in CI rather than committing it, using GitHub OIDC to assume an AWS role with no stored credentials. This closes the gap between what the pipeline demonstrates today and what a production DevSecOps team would actually run. Beyond that, connecting the OSCAL component definition to a running AWS Config rule set would allow the evidence links to point at live API responses instead of static artifacts, making the chain of custody continuous rather than point-in-time.

## What I learned

The non-obvious lesson from the reference matching problem in Week 2: at Terraform plan time, resource names built from random suffixes do not exist yet, so policies cannot compare final bucket names. Matching by reference in the configuration section rather than by value in the planned values section is what makes Policy as Code work against real infrastructure. Keyless signing in Week 4 reinforced a similar principle: the identity that signs the evidence should be the pipeline run itself, not a credential a human manages, because the chain of custody is only as trustworthy as the weakest link in it.
