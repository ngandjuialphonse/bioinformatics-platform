#!/bin/bash
# Run Nextflow in Docker Container
# ==================================
# This script runs Nextflow without installing it locally

WORKFLOW_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/workflows" && pwd)"
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo ""
echo "=== Running Nextflow in Docker ==="
echo "Project: $PROJECT_DIR"
echo ""

# Run Nextflow in a container
docker run --rm \
    -v "$PROJECT_DIR:/workspace" \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -w /workspace/workflows \
    nextflow/nextflow:25.10.3 \
    nextflow run main.nf -profile test,docker

echo ""
echo "=== Complete! ==="
