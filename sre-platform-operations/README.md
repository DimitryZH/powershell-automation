# SRE Platform Operations

This module contains PowerShell operational automation migrated from the SRE Platform project. The scripts were originally built as practical guardrails and validation helpers for a GitOps-based Kubernetes/SRE platform with Terraform, Helm, Argo CD, GKE, kube-prometheus-stack, and PagerDuty Alertmanager integration.

The module is intentionally presented as SRE platform operations automation, not as a generic one-command product. Most scripts validate a specific platform contract and should be reviewed before being reused in another environment.

## Overview

The scripts support repeatable preflight and safety checks across the SRE Platform lifecycle:

- Terraform foundation and runtime guardrails
- Terraform saved-plan validation
- Isolated Helm rendering and manifest contract checks
- Argo CD / GitOps dependency-order validation
- Ingress bootstrap validation
- Alertmanager / PagerDuty routing validation
- Local-only SecretProviderClass manifest generation for Secret Manager CSI

The source SRE Platform repository is not embedded in this module. Pass its path explicitly with `-SrePlatformRepositoryRoot` or set `SRE_PLATFORM_REPOSITORY_ROOT`.

## Repository Layout

```text
sre-platform-operations/
├── README.md
└── scripts/
    ├── terraform-guardrails/
    │   ├── check-staging-foundation-guardrails.ps1
    │   ├── check-staging-runtime-guardrails.ps1
    │   ├── check-staging-runtime-plan.ps1
    │   └── examples/
    │       └── temporary-capacity/
    │           └── check-staging-temporary-capacity-plan.ps1
    ├── helm-rendering/
    │   ├── render-staging-controllers.ps1
    │   └── render-staging-monitoring.ps1
    ├── gitops-validation/
    │   ├── check-staging-gitops-order.ps1
    │   └── check-staging-ingress-bootstrap.ps1
    └── observability-alerting/
        ├── check-staging-pagerduty-alertmanager.ps1
        └── new-stage-alertmanager-secret-provider-class.ps1
```

## Scripts

| Script | Category | Purpose |
| --- | --- | --- |
| `scripts/terraform-guardrails/check-staging-foundation-guardrails.ps1` | Terraform guardrails | Verifies that the staging foundation Terraform scope remains bounded to low-risk project, API, budget, and state-bucket concerns. |
| `scripts/terraform-guardrails/check-staging-runtime-guardrails.ps1` | Terraform guardrails | Verifies runtime Terraform scope, cost-sensitive exclusions, GKE logging/monitoring constraints, and absence of Git-visible Terraform artifacts. |
| `scripts/terraform-guardrails/check-staging-runtime-plan.ps1` | Terraform guardrails | Reads a saved Terraform plan and allows only the expected initial staging runtime resources. |
| `scripts/terraform-guardrails/examples/temporary-capacity/check-staging-temporary-capacity-plan.ps1` | Scenario example | Validates one temporary staging capacity-change plan. This is intentionally kept under `examples` because it is highly scenario-specific. |
| `scripts/helm-rendering/render-staging-controllers.ps1` | Helm rendering | Renders pinned Argo CD and ingress-nginx charts with isolated Helm config/cache/data paths, then checks the rendered contract. |
| `scripts/helm-rendering/render-staging-monitoring.ps1` | Helm rendering | Renders pinned kube-prometheus-stack configuration and validates Alertmanager and Secret Manager CSI integration without inline routing keys. |
| `scripts/gitops-validation/check-staging-gitops-order.ps1` | GitOps validation | Checks Argo CD sync waves, chart versions, ingress metrics ServiceMonitor contract, monitoring profile constraints, and workload port protocol rendering. |
| `scripts/gitops-validation/check-staging-ingress-bootstrap.ps1` | GitOps validation | Validates constrained ingress-nginx bootstrap values for staging. |
| `scripts/observability-alerting/check-staging-pagerduty-alertmanager.ps1` | Observability and alerting | Validates PagerDuty receiver routing, Alertmanager file-based routing key usage, Secret Manager CSI settings, and alert context annotations. |
| `scripts/observability-alerting/new-stage-alertmanager-secret-provider-class.ps1` | Observability and alerting | Generates a local-only SecretProviderClass manifest under the SRE Platform `.private` directory. |

## Common Prerequisites

Requirements vary by script, but may include:

- Windows PowerShell 5.1 or PowerShell 7
- Access to the SRE Platform repository checkout
- `git` for repository visibility checks
- `terraform` for saved plan inspection
- `helm` for chart linting and rendering
- Network access to Helm repositories when rendering external charts
- Kubernetes/GKE platform knowledge for reviewing generated manifests
- Appropriate local access to ignored/private operator files where applicable

Set the SRE Platform repository path once per session if desired:

```powershell
$env:SRE_PLATFORM_REPOSITORY_ROOT = 'C:\projects\sre\sre-platform'
```

Or pass it per command:

```powershell
.\scripts\terraform-guardrails\check-staging-foundation-guardrails.ps1 `
  -SrePlatformRepositoryRoot 'C:\projects\sre\sre-platform'
```

## Usage Examples

Run foundation guardrails:

```powershell
.\scripts\terraform-guardrails\check-staging-foundation-guardrails.ps1 `
  -SrePlatformRepositoryRoot 'C:\projects\sre\sre-platform'
```

Validate a saved runtime plan:

```powershell
.\scripts\terraform-guardrails\check-staging-runtime-plan.ps1 `
  -SrePlatformRepositoryRoot 'C:\projects\sre\sre-platform' `
  -PlanPath 'C:\path\to\staging-runtime.tfplan'
```

Render controller manifests into a review directory:

```powershell
.\scripts\helm-rendering\render-staging-controllers.ps1 `
  -SrePlatformRepositoryRoot 'C:\projects\sre\sre-platform' `
  -OutputDirectory 'C:\tmp\sre-controller-render'
```

Generate a local-only SecretProviderClass manifest:

```powershell
.\scripts\observability-alerting\new-stage-alertmanager-secret-provider-class.ps1 `
  -SrePlatformRepositoryRoot 'C:\projects\sre\sre-platform' `
  -SecretResourceName 'projects/<project-id>/secrets/<secret-name>/versions/latest'
```

## Safety Notes

- Review scripts before running them against a real platform repository.
- These scripts are validation and rendering helpers, but they call external tools such as `helm`, `terraform`, and `git`.
- The Helm rendering scripts download charts into isolated temporary directories and may require network access.
- The SecretProviderClass script writes only under the SRE Platform `.private` directory by default and validates that the output path remains there.
- Do not commit rendered manifests, Terraform plans, Terraform state, tfvars, private SecretProviderClass files, credentials, routing keys, or local evidence artifacts unless they are intentionally sanitized documentation.
- The scripts encode staging-specific operational contracts from the SRE Platform project. Treat them as portfolio examples and adapt names, versions, paths, and resource addresses before reuse elsewhere.

## Migration Notes

The original scripts lived under the SRE Platform repository `scripts/` directory and assumed that repository as their parent path. During migration, that implicit path coupling was replaced with an explicit `-SrePlatformRepositoryRoot` parameter and optional `SRE_PLATFORM_REPOSITORY_ROOT` environment variable.

The operational checks themselves were intentionally kept close to the source behavior so the module remains a faithful portfolio representation of the SRE Platform automation. Future improvements could further parameterize chart versions, namespaces, environment names, resource addresses, and evidence-file expectations.

## Repository Context

This module is part of the PowerShell Automation collection. For the collection overview and other modules, see the root [`README.md`](../README.md).