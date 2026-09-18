# PowerShell Automation

A curated collection of PowerShell automation modules for Windows administration, identity operations, platform engineering, and repeatable infrastructure tasks.

## Overview

This repository is organized as a collection of independent PowerShell automation projects. Each module lives in its own directory with dedicated documentation, scripts, prerequisites, usage notes, and safety considerations.

The repository is intended to grow over time without turning every script into one large project. New automation modules should be added as separate directories and linked from this root README.

## Engineering Principles

- Self-contained modules with dedicated documentation
- Clear prerequisites and required permissions
- No credentials, secrets, private keys, or environment-specific tokens stored in the repository
- Review scripts before execution, especially when they change directory services, servers, policies, or user accounts
- Prefer parameterized and reusable automation over hard-coded environments
- Keep module scope focused and avoid unrelated implementation changes during migration

## Modules

| Module | Focus | Key Capabilities |
| --- | --- | --- |
| [Active Directory Automation](active-directory/README.md) | Active Directory and Group Policy administration with PowerShell | User creation, inactive account reporting and disabling, deleted object recovery, AD Recycle Bin enablement, object deletion, domain join helper, and Group Policy creation |
| [SRE Platform Operations](sre-platform-operations/README.md) | SRE platform operational guardrails and validation automation | Terraform plan and scope guardrails, isolated Helm rendering, GitOps dependency checks, ingress bootstrap validation, and Alertmanager/PagerDuty safety checks |

## Getting Started

Clone the repository:

```powershell
git clone https://github.com/DimitryZH/powershell-automation.git
cd powershell-automation
```

Open the README for the module you want to use:

```powershell
cd active-directory
Get-Content .\README.md
```

Most modules contain scripts under a `scripts` directory. Review the module README and the script source before running anything in an administrative environment.

## General Prerequisites

Requirements vary by module, but may include:

- Windows PowerShell 5.1 or later, or PowerShell 7 where supported by the module
- Administrative privileges for server, identity, or policy changes
- RSAT tools and the Active Directory PowerShell module for directory automation
- Appropriate domain, server, cloud, or platform permissions for the target environment
- Platform modules may require tools such as git, terraform, helm, kubectl, or cloud provider CLIs

Each module README defines its exact prerequisites, usage pattern, and operational notes.

## Adding Modules

To add a new automation module:

1. Create a focused directory for the module.
2. Keep scripts and supporting files inside that module directory.
3. Include a module-level `README.md` covering purpose, prerequisites, usage, safety notes, and expected behavior.
4. Avoid committing secrets, credentials, local machine state, or generated output.
5. Update this root README with a link to the new module.
