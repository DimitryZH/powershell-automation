# Migrated from the SRE Platform repository. Operates against an explicit SRE Platform repository root.
param(
  [Parameter(Mandatory)]
  [string]$SecretResourceName,
  [string]$SrePlatformRepositoryRoot = $env:SRE_PLATFORM_REPOSITORY_ROOT,
  [string]$OutputPath
)
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if ($SecretResourceName -notmatch '^projects/[^/]+/secrets/[^/]+/versions/(latest|[0-9]+)$') {
  throw "SecretResourceName must be a fully-qualified Secret Manager version resource name."
}

function Resolve-SrePlatformRepositoryRoot {
  param(
    [string]$Path
  )

  if ([string]::IsNullOrWhiteSpace($Path)) {
    throw "Provide -SrePlatformRepositoryRoot or set SRE_PLATFORM_REPOSITORY_ROOT."
  }

  $resolvedPath = (Resolve-Path -LiteralPath $Path).Path
  foreach ($requiredPath in @("README.md", "scripts")) {
    $candidate = Join-Path $resolvedPath $requiredPath
    if (-not (Test-Path -LiteralPath $candidate)) {
      throw "SRE Platform repository root is missing required path: $requiredPath"
    }
  }

  return $resolvedPath
}

$repositoryRoot = Resolve-SrePlatformRepositoryRoot -Path $SrePlatformRepositoryRoot
if ([string]::IsNullOrWhiteSpace($OutputPath)) {
  $OutputPath = Join-Path $repositoryRoot ".private\alertmanager-stage-secret-provider-class.yaml"
}
$privateRoot = [System.IO.Path]::GetFullPath((Join-Path $repositoryRoot ".private"))
$resolvedOutputPath = [System.IO.Path]::GetFullPath($OutputPath)

if (-not $resolvedOutputPath.StartsWith($privateRoot + [System.IO.Path]::DirectorySeparatorChar, [System.StringComparison]::OrdinalIgnoreCase)) {
  throw "OutputPath must remain under the ignored .private directory."
}

New-Item -ItemType Directory -Path (Split-Path -Parent $resolvedOutputPath) -Force | Out-Null

# This manifest is deliberately local-only: it contains the operator-managed
# Secret Manager resource reference and must never be committed or logged.
$manifest = @"
apiVersion: secrets-store.csi.x-k8s.io/v1
kind: SecretProviderClass
metadata:
  name: alertmanager-stage-pagerduty
  namespace: monitoring
spec:
  provider: gke
  parameters:
    secrets: |
      - resourceName: "$SecretResourceName"
        path: "routing-key"
"@

[System.IO.File]::WriteAllText($resolvedOutputPath, $manifest, (New-Object System.Text.UTF8Encoding($false)))
Write-Output "Private Alertmanager SecretProviderClass manifest rendered."
