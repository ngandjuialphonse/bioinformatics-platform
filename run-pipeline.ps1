#!/usr/bin/env pwsh
# Run Nextflow Pipeline via WSL
# ==============================
# This script makes it easy to run Nextflow through WSL on Windows

$ProjectDir = Split-Path -Parent $PSScriptRoot
$WorkflowDir = Join-Path $ProjectDir "workflows"

# Convert Windows path to WSL path
$WslProjectDir = $ProjectDir -replace '\\', '/' -replace 'C:', '/mnt/c'
$WslWorkflowDir = Join-Path $WslProjectDir "workflows" -replace '\\', '/'

Write-Host "`n=== Running Nextflow Pipeline via WSL ===" -ForegroundColor Cyan
Write-Host "Project: $ProjectDir" -ForegroundColor Yellow
Write-Host "WSL Path: $WslWorkflowDir`n" -ForegroundColor Yellow

# Run Nextflow in WSL
wsl bash -c "cd '$WslWorkflowDir' && nextflow run main.nf -profile test,docker $args"

Write-Host "`n=== Complete! ===" -ForegroundColor Green
