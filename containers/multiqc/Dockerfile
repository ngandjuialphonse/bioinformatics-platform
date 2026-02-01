# =============================================================================
# Multi-Stage Dockerfile: MultiQC
# =============================================================================
#
# PURPOSE:
# This Dockerfile builds a container for MultiQC, a tool that aggregates
# results from bioinformatics analyses across many samples into a single
# HTML report.
#
# WHY MULTIQC?
# - Visualization: Provides interactive plots for comparing QC metrics.
# - Standardization: Creates a consistent report format for all your pipelines.
# - Extensibility: Supports a wide range of bioinformatics tools.
#
# =============================================================================

# -----------------------------------------------------------------------------
# STAGE 1: BUILDER
# -----------------------------------------------------------------------------
# PURPOSE: This stage installs MultiQC and its Python dependencies in a
# virtual environment.
# -----------------------------------------------------------------------------
FROM python:3.11-slim AS builder

LABEL stage="builder"

ENV MULTIQC_VERSION=1.19

RUN pip install --no-cache-dir multiqc==${MULTIQC_VERSION}

# -----------------------------------------------------------------------------
# STAGE 2: FINAL IMAGE
# -----------------------------------------------------------------------------
# PURPOSE: This is the final image. It copies the Python virtual environment
# from the builder stage.
# -----------------------------------------------------------------------------
FROM python:3.11-slim

LABEL maintainer="devops-team@alphonse.com"
LABEL description="Optimized MultiQC for aggregating bioinformatics results"
LABEL version="1.19"

# --- Copy Python Environment from Builder Stage ---
COPY --from=builder /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages
COPY --from=builder /usr/local/bin/multiqc /usr/local/bin/multiqc

# --- Create Non-Root User ---
RUN useradd --create-home --shell /bin/bash biouser
USER biouser
WORKDIR /home/biouser

# --- Health Check ---
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
  CMD multiqc --version || exit 1

# --- Default Command ---
ENTRYPOINT ["multiqc"]
CMD ["--help"]
