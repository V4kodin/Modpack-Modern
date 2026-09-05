@echo off
rem One-click launcher for the "Release and Deploy" workflow in the fork.
rem --repo is mandatory: this clone also has the upstream remote, and gh would
rem otherwise try to start the workflow in the upstream repository.

setlocal
cd /d "%~dp0"

set REPO=V4kodin/Modpack-Modern
set WORKFLOW=release-and-deploy.yml

where gh >nul 2>&1
if errorlevel 1 (
    echo GitHub CLI is not installed. Get it from https://cli.github.com/
    pause
    exit /b 1
)

gh auth status >nul 2>&1
if errorlevel 1 (
    echo Not logged in to GitHub. Run: gh auth login
    pause
    exit /b 1
)

echo Repository: %REPO%
echo.

set PUBLISH_CLIENT=true
set DEPLOY_SERVER=true
set DRY_RUN=false

choice /c YN /m "Publish a client release (.mrpack)"
if errorlevel 2 set PUBLISH_CLIENT=false

choice /c YN /m "Deploy to the game server"
if errorlevel 2 set DEPLOY_SERVER=false

if "%DEPLOY_SERVER%"=="true" (
    choice /c YN /m "Dry run only, leave the server untouched"
    if errorlevel 2 (set DRY_RUN=false) else (set DRY_RUN=true)
)

echo.
echo publish_client=%PUBLISH_CLIENT%  deploy_server=%DEPLOY_SERVER%  dry_run=%DRY_RUN%
choice /c YN /m "Start the workflow"
if errorlevel 2 (
    echo Cancelled.
    pause
    exit /b 0
)

gh workflow run %WORKFLOW% --repo %REPO% --ref server ^
    -f publish_client=%PUBLISH_CLIENT% ^
    -f deploy_server=%DEPLOY_SERVER% ^
    -f dry_run=%DRY_RUN%
if errorlevel 1 (
    echo Failed to start the workflow.
    pause
    exit /b 1
)

echo.
echo Workflow queued, waiting for the run to appear...
timeout /t 6 /nobreak >nul

for /f "usebackq delims=" %%i in (`gh run list --repo %REPO% --workflow %WORKFLOW% --limit 1 --json databaseId --jq ".[0].databaseId"`) do set RUN_ID=%%i

if "%RUN_ID%"=="" (
    echo Could not find the run, check it here:
    echo https://github.com/%REPO%/actions/workflows/%WORKFLOW%
    pause
    exit /b 0
)

echo Run: https://github.com/%REPO%/actions/runs/%RUN_ID%
choice /c YN /m "Follow the run in this window"
if errorlevel 2 (
    pause
    exit /b 0
)

gh run watch %RUN_ID% --repo %REPO% --exit-status
pause
