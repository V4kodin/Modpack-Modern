# One-click launcher for the "Release and Deploy" workflow in the fork.
# PowerShell rather than a batch file on purpose: cmd.exe resolves external
# commands only through PATH, and an over-long system PATH silently breaks that
# lookup for everything including where, choice and gh. PowerShell is unaffected.
# Kept ASCII-only so powershell.exe 5.1, which reads scripts in the system code
# page rather than UTF-8, parses it the same as PowerShell 7 does.

$ErrorActionPreference = 'Stop'

$Repo = 'V4kodin/Modpack-Modern'
$Workflow = 'release-and-deploy.yml'
$Branch = 'server'

function Read-YesNo {
    param(
        [Parameter(Mandatory)][string]$Question,
        [bool]$Default = $true
    )
    $hint = if ($Default) { '[Y/n]' } else { '[y/N]' }
    while ($true) {
        $answer = (Read-Host "$Question $hint").Trim().ToLower()
        if ($answer -eq '') { return $Default }
        if ($answer -in @('y', 'yes')) { return $true }
        if ($answer -in @('n', 'no')) { return $false }
        Write-Host 'Answer y or n.' -ForegroundColor DarkYellow
    }
}

function Get-Flag {
    param([bool]$Value)
    if ($Value) { return 'true' } else { return 'false' }
}

if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-Host 'GitHub CLI is not installed. Get it from https://cli.github.com/' -ForegroundColor Red
    exit 1
}

# gh auth status writes to stderr even on success, so judge it by the exit code
gh auth status *> $null
if ($LASTEXITCODE -ne 0) {
    Write-Host 'Not logged in to GitHub. Run: gh auth login' -ForegroundColor Red
    exit 1
}

Write-Host "Repository: $Repo" -ForegroundColor Cyan
Write-Host ''

$publishClient = Read-YesNo 'Publish a client release (.mrpack)'
$deployServer = Read-YesNo 'Deploy to the game server'

$dryRun = $false
if ($deployServer) {
    $dryRun = Read-YesNo 'Dry run only, leave the server untouched' $false
}

if (-not $publishClient -and -not $deployServer) {
    Write-Host 'Both actions are off, nothing to do.' -ForegroundColor DarkYellow
    exit 0
}

Write-Host ''
Write-Host ("publish_client={0}  deploy_server={1}  dry_run={2}" -f `
    (Get-Flag $publishClient), (Get-Flag $deployServer), (Get-Flag $dryRun)) -ForegroundColor Cyan

if (-not (Read-YesNo 'Start the workflow')) {
    Write-Host 'Cancelled.'
    exit 0
}

# --repo is mandatory: this clone also has the upstream remote, and gh would
# otherwise try to start the workflow in the upstream repository
gh workflow run $Workflow --repo $Repo --ref $Branch `
    -f "publish_client=$(Get-Flag $publishClient)" `
    -f "deploy_server=$(Get-Flag $deployServer)" `
    -f "dry_run=$(Get-Flag $dryRun)"

if ($LASTEXITCODE -ne 0) {
    Write-Host 'Failed to start the workflow.' -ForegroundColor Red
    exit 1
}

Write-Host ''
Write-Host 'Workflow queued, waiting for the run to appear...'

# the run is not listed the instant the dispatch returns, so poll for it briefly
$runId = $null
foreach ($attempt in 1..10) {
    Start-Sleep -Seconds 3
    $runId = gh run list --repo $Repo --workflow $Workflow --limit 1 --json databaseId --jq '.[0].databaseId'
    if ($runId) { break }
}

if (-not $runId) {
    Write-Host "Could not find the run, check it here:"
    Write-Host "https://github.com/$Repo/actions/workflows/$Workflow"
    exit 0
}

Write-Host "Run: https://github.com/$Repo/actions/runs/$runId" -ForegroundColor Cyan

if (Read-YesNo 'Follow the run in this window') {
    gh run watch $runId --repo $Repo --exit-status
}
