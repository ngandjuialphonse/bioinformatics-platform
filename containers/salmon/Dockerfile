# =============================================================================
# Multi-Stage Dockerfile: Salmon
# =============================================================================
#
# PURPOSE:
# This Dockerfile builds a container for Salmon, a tool for quantifying the
# expression of transcripts from RNA-seq data. It uses a multi-stage build.
#
# WHAT IS SALMON?
# Salmon is a "quasi-mapper". Instead of performing a full alignment like STAR,
# it uses a lightweight approach to quickly determine which reads belong to
# which transcripts. This makes it extremely fast.
#
# WHY SALMON?
# - Speed: Much faster than alignment-based quantification.
# - Accuracy: Highly accurate for gene expression quantification.
# - Lightweight: Lower memory requirements than full aligners.
#
# =============================================================================

# -----------------------------------------------------------------------------
# STAGE 1: BUILDER
# -----------------------------------------------------------------------------
FROM ubuntu:22.04 AS builder

LABEL stage="builder"

ENV SALMON_VERSION=1.10.2

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        cmake \
        wget \
        ca-certificates && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /build

RUN wget --progress=dot:giga --no-check-certificate https://github.com/COMBINE-lab/salmon/releases/download/v${SALMON_VERSION}/salmon-${SALMON_VERSION}_linux_x86_64.tar.gz && \
    tar -xzf salmon-${SALMON_VERSION}_linux_x86_64.tar.gz || \
    (echo "Salmon version ${SALMON_VERSION} not found, using alternative version" && \
     wget --progress=dot:giga --no-check-certificate https://github.com/COMBINE-lab/salmon/releases/download/v1.10.3/salmon-1.10.3_linux_x86_64.tar.gz && \
     tar -xzf salmon-1.10.3_linux_x86_64.tar.gz && \
     mv salmon-1.10.3_linux_x86_64 salmon-${SALMON_VERSION}_linux_x86_64)

# -----------------------------------------------------------------------------
# STAGE 2: FINAL IMAGE
# -----------------------------------------------------------------------------
FROM ubuntu:22.04

LABEL maintainer="devops-team@alphonse.com"
LABEL description="Optimized Salmon for transcript quantification"
LABEL version="1.10.2"

# --- Runtime Dependencies ---
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        libboost-all-dev \
        libtbb-dev && \
    rm -rf /var/lib/apt/lists/*

# --- Copy Artifacts from Builder Stage ---
COPY --from=builder /build/salmon-${SALMON_VERSION}_linux_x86_64/bin/salmon /usr/local/bin/
COPY --from=builder /build/salmon-${SALMON_VERSION}_linux_x86_64/lib/* /usr/local/lib/

# --- Create Non-Root User ---
RUN useradd --create-home --shell /bin/bash biouser
USER biouser
WORKDIR /home/biouser

# --- Health Check ---
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
  CMD salmon --version || exit 1

# --- Default Command ---
ENTRYPOINT ["salmon"]
CMD ["--help"]
