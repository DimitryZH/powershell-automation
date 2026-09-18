# Migrated from the SRE Platform repository. Operates against an explicit SRE Platform repository root.
param(
  [string]$SrePlatformRepositoryRoot = $env:SRE_PLATFORM_REPOSITORY_ROOT
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

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
$valuesFile = Join-Path $repositoryRoot "environments\stage\values\ingress-nginx.yaml"
$valuesText = Get-Content -Raw -Path $valuesFile

foreach ($requiredPattern in @(
  '(?ms)scope:\s*\r?\n\s*enabled:\s*true\s*\r?\n\s*namespace:\s*online-shop-stage',
  '(?ms)service:\s*\r?\n\s*enabled:\s*true\s*\r?\n\s*type:\s*ClusterIP\s*\r?\n\s*external:\s*\r?\n(?:\s*#.*\r?\n){0,2}\s*enabled:\s*true',
  '(?ms)extraArgs:\s*\r?\n\s*#.*\r?\n\s*metrics-per-undefined-host:\s*"true"',
  '(?ms)metrics:\s*\r?\n\s*enabled:\s*true',
  '(?ms)serviceMonitor:\s*\r?\n\s*#.*\r?\n\s*enabled:\s*false'
)) {
  if ($valuesText -notmatch $requiredPattern) {
    throw "Staging ingress bootstrap invariant is missing: $requiredPattern"
  }
}

Write-Output "Staging ingress bootstrap guardrails passed."
