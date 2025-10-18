<#
.SYNOPSIS
  Run common project tasks on Windows without GNU make.

USAGE
  .\run.ps1 validate
  .\run.ps1 build
  .\run.ps1 run
  .\run.ps1 compose
  .\run.ps1 clean
  .\run.ps1 help
#>

param(
    [string]$Action = 'help'
)

Set-StrictMode -Version Latest

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$ImageName = 'debian-trixie-installer'
$OutputDir = Join-Path $ScriptDir 'output'

function Invoke-Validate {
    Write-Host 'Running validate-preseed.sh using WSL or Bash...'
    if (Get-Command wsl -ErrorAction SilentlyContinue) {
        $winPath = (Get-Item $ScriptDir).FullName
        $wslPath = & wsl bash -lc "wslpath -a '$winPath'" 2>$null
        if ($LASTEXITCODE -ne 0 -or -not $wslPath) { Write-Error 'Failed to convert path with wslpath'; exit 1 }
        & wsl bash -lc "cd '$wslPath' && ./validate-preseed.sh"
        return $LASTEXITCODE
    }

    if (Get-Command bash -ErrorAction SilentlyContinue) {
        # Attempt to convert Windows path to POSIX (/c/Users/...)
        $winPath = (Get-Item $ScriptDir).FullName
        $drive = $winPath.Substring(0,1).ToLower()
        $posix = '/' + $drive + $winPath.Substring(2) -replace '\\','/'
        & bash -lc "cd '$posix' && ./validate-preseed.sh"
        return $LASTEXITCODE
    }

    Write-Error 'Neither WSL nor bash (Git Bash) found. Install WSL or Git for Windows (Git Bash) to run validation.'
    return 1
}

function Invoke-Build {
    Write-Host "Building Docker image: $ImageName"
    docker build -t $ImageName $ScriptDir
    return $LASTEXITCODE
}

function Invoke-Run {
    if (-not (Test-Path $OutputDir)) { New-Item -ItemType Directory -Path $OutputDir | Out-Null }
    Write-Host "Running container to create ISO (output -> $OutputDir)"
    $absOut = (Get-Item $OutputDir).FullName
    # Use quotes around the volume mapping to avoid invalid reference format
    docker run --rm --privileged -v "${absOut}:/output" $ImageName
    return $LASTEXITCODE
}

function Invoke-Compose {
    if (-not (Test-Path $OutputDir)) { New-Item -ItemType Directory -Path $OutputDir | Out-Null }
    docker-compose up --build
    return $LASTEXITCODE
}

function Invoke-Clean {
    Write-Host 'Removing output and temporary files...'
    if (Test-Path $OutputDir) { Remove-Item -Recurse -Force $OutputDir }
    Get-ChildItem -Path $ScriptDir -Filter '*.iso' -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue
    # leave Docker image removal to user
    return 0
}

switch ($Action.ToLower()) {
    'validate' { exit (Invoke-Validate) }
    'build'    { exit (Invoke-Build) }
    'run'      { exit (Invoke-Run) }
    'compose'  { exit (Invoke-Compose) }
    'clean'    { exit (Invoke-Clean) }
    'help' {
        Write-Host 'Usage: .\run.ps1 <action>'
        Write-Host 'Actions: validate, build, run, compose, clean, help'
        exit 0
    }
    default {
        Write-Error "Unknown action: $Action"
        exit 2
    }
}
