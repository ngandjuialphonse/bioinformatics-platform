# Run Nextflow in Docker Container
# ==================================
# This script runs Nextflow without installing it locally

$workflowDir = "$PSScriptRoot\workflows"
$projectDir = $PSScriptRoot

Write-Host "`n=== Running Nextflow in Docker ===" -ForegroundColor Cyan
Write-Host "Project: $projectDir`n" -ForegroundColor Yellow

# Run Nextflow in a container
docker run --rm `
    -v ${projectDir}:/workspace `
    -v /var/run/docker.sock:/var/run/docker.sock `
    -w /workspace/workflows `
    nextflow/nextflow:25.10.3 `
    nextflow run main.nf -profile test,docker

Write-Host "`n=== Complete! ===" -ForegroundColor Green
