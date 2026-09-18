# Migrated from the SRE Platform repository. Operates against an explicit SRE Platform repository root.
param(
  [string]$SrePlatformRepositoryRoot = $env:SRE_PLATFORM_REPOSITORY_ROOT,
  [Parameter(Mandatory = $true)]
  [ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf })]
  [string]$PlanPath
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
$runtimeDirectory = Join-Path $repositoryRoot "terraform\runtime"
$resolvedPlanPath = (Resolve-Path -LiteralPath $PlanPath).Path
$planJson = & terraform "-chdir=$runtimeDirectory" show -json $resolvedPlanPath
if ($LASTEXITCODE -ne 0) {
  throw "Unable to read the saved temporary-capacity plan."
}

$plan = $planJson | ConvertFrom-Json
$changes = @($plan.resource_changes)
$clusterChange = $changes | Where-Object { $_.address -eq "google_container_cluster.staging" }

if (($clusterChange | Measure-Object).Count -ne 1 -or $clusterChange.change.actions -ne @("update")) {
  throw "The plan must contain one in-place staging cluster update."
}

foreach ($change in $changes) {
  if ($change.address -eq "google_container_cluster.staging") {
    continue
  }
  if ($change.address -notmatch '^google_project_service\.runtime\[' -or $change.change.actions -ne @("no-op")) {
    throw "Unexpected temporary-capacity plan change: $($change.address)"
  }
}

$beforeType = $clusterChange.change.before.node_config[0].machine_type
$afterType = $clusterChange.change.after.node_config[0].machine_type
if ($beforeType -ne "e2-medium" -or $afterType -ne "e2-standard-4") {
  throw "The plan must change only from e2-medium to e2-standard-4."
}

Write-Output "Staging temporary-capacity plan guardrails passed."
