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
$stageValuesPath = Join-Path $repositoryRoot "environments\stage\values\kube-prometheus-stack.yaml"
$alertTemplatePath = Join-Path $repositoryRoot "charts\platform\templates\burn-rate-alerts.yaml"
$stageValues = Get-Content -Raw -Path $stageValuesPath
$alertTemplate = Get-Content -Raw -Path $alertTemplatePath

foreach ($requiredPattern in @(
  '(?ms)^alertmanager:\s*\r?\n\s*enabled:\s*true',
  '(?ms)serviceAccount:\s*\r?\n\s*create:\s*false\s*\r?\n\s*name:\s*alertmanager-stage',
  '(?m)^\s*(?:-\s*)?routing_key_file:\s*/var/run/secrets/pagerduty/routing-key',
  '(?m)^\s*send_resolved:\s*true',
  '(?m)^\s*severity:\s*critical',
  '(?ms)send_resolved:\s*true\s*\r?\n\s*(?:#.*\r?\n\s*){0,2}severity:\s*critical',
  '(?m)^\s*driver:\s*secrets-store-gke\.csi\.k8s\.io',
  '(?m)^\s*secretProviderClass:\s*alertmanager-stage-pagerduty',
  'alertname="OnlineShopSLOFastBurnRatePage"',
  'environment="staging"',
  'severity="page"'
)) {
  if ($stageValues -notmatch $requiredPattern) {
    throw "PagerDuty Alertmanager configuration is missing a required constrained setting."
  }
}

if (($stageValues | Select-String -AllMatches 'receiver:\s*pagerduty-staging').Matches.Count -ne 1) {
  throw "Exactly one PagerDuty receiver route is required."
}

if ($stageValues -match '(?m)^\s*routing_key:\s*') {
  throw "The PagerDuty routing key must be referenced only through a mounted file."
}

foreach ($requiredAnnotation in @('dashboard:', 'runbook:', 'deployment_revision:')) {
  if ($alertTemplate -notmatch [regex]::Escape($requiredAnnotation)) {
    throw "The fast-burn alert is missing required PagerDuty context: $requiredAnnotation"
  }
}

if ($alertTemplate -notmatch 'environment:' -or $alertTemplate -notmatch 'alertRouting') {
  throw "The staging route requires an explicit environment label from the stage overlay."
}

Write-Output "Staging PagerDuty Alertmanager guardrails passed."
