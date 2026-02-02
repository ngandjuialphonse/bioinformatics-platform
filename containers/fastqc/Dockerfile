# =============================================================================
# Multi-Stage Dockerfile: FastQC
# =============================================================================
#
# PURPOSE:
# This Dockerfile builds a container for FastQC, a quality control tool for
# high-throughput sequencing data. It uses a multi-stage build to create a
# minimal, secure final image.
#
# WHY THIS IS DIFFERENT:
# FastQC is a Java application, so our build process involves downloading the
# application and setting up a Java Runtime Environment (JRE).
#
# =============================================================================

# -----------------------------------------------------------------------------
# STAGE 1: DOWNLOADER
# -----------------------------------------------------------------------------
# PURPOSE: This stage downloads the FastQC application zip file.
# -----------------------------------------------------------------------------
FROM ubuntu:22.04 AS downloader

LABEL stage="downloader"

ENV FASTQC_VERSION=0.12.1

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        wget \
        unzip \
        ca-certificates && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

RUN wget --progress=dot:giga https://www.bioinformatics.babraham.ac.uk/projects/fastqc/fastqc_v${FASTQC_VERSION}.zip && \
    unzip fastqc_v${FASTQC_VERSION}.zip

# -----------------------------------------------------------------------------
# STAGE 2: FINAL IMAGE
# -----------------------------------------------------------------------------
# PURPOSE: This is the final image. It installs a minimal Java runtime and
# copies the FastQC application from the downloader stage.
# -----------------------------------------------------------------------------
FROM eclipse-temurin:17-jre-jammy

LABEL maintainer="devops-team@alphonse.com"
LABEL description="Optimized FastQC for NGS quality control"
LABEL version="0.12.1"

# --- Copy FastQC from Downloader Stage ---
COPY --from=downloader /app/FastQC /opt/FastQC

# --- Set up Environment ---
ENV PATH /opt/FastQC:$PATH

# --- Create Non-Root User ---
RUN useradd --create-home --shell /bin/bash biouser
USER biouser
WORKDIR /home/biouser

# --- Health Check ---
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
  CMD fastqc --version || exit 1

# --- Default Command ---
ENTRYPOINT ["fastqc"]
CMD ["--help"]
