# =============================================================================
# Multi-Stage Dockerfile: STAR Aligner
# =============================================================================
#
# PURPOSE:
# This Dockerfile builds a container for the STAR RNA-seq aligner using a
# multi-stage build pattern. This is a best practice for creating optimized,
# secure, and small container images.
#
# WHAT IS A MULTI-STAGE BUILD?
# A multi-stage build uses multiple FROM instructions. Each FROM instruction
# starts a new build stage. You can selectively copy artifacts from one stage
# to another, leaving behind everything you don't want in the final image.
#
# WHY USE MULTI-STAGE BUILDS?
# 1. Smaller Image Size: The final image only contains the compiled binary
#    and its runtime dependencies, not the build tools (compilers, source
#    code, etc.). This reduces storage costs and network transfer time.
# 2. Improved Security: A smaller attack surface because build tools are not
#    present in the final image.
# 3. Better Caching: Docker can cache individual stages, speeding up builds.
#
# INTERVIEW TIP:
# Explaining the benefits of multi-stage builds demonstrates a deep
# understanding of containerization best practices and security.
#
# =============================================================================

# -----------------------------------------------------------------------------
# STAGE 1: BUILDER
# -----------------------------------------------------------------------------
# PURPOSE: This stage downloads the STAR source code and compiles it.
# It contains all the build-time dependencies (g++, make, etc.) that are
# NOT needed in the final image.
# -----------------------------------------------------------------------------
FROM ubuntu:22.04 AS builder

# --- Metadata ---
LABEL stage="builder"

# --- Environment ---
ENV DEBIAN_FRONTEND=noninteractive
ENV STAR_VERSION=2.7.10a

# --- Build Dependencies ---
# Install the tools needed to compile STAR
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        wget \
        ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# --- Compile STAR ---
# Download, compile, and create the STAR binary
WORKDIR /build

RUN wget https://github.com/alexdobin/STAR/archive/refs/tags/${STAR_VERSION}.tar.gz && \
    tar -xzf ${STAR_VERSION}.tar.gz && \
    cd STAR-${STAR_VERSION}/source && \
    make STAR

# -----------------------------------------------------------------------------
# STAGE 2: FINAL IMAGE
# -----------------------------------------------------------------------------
# PURPOSE: This is the final, optimized image. It copies the compiled STAR
# binary from the builder stage and installs only the runtime dependencies.
# -----------------------------------------------------------------------------
FROM ubuntu:22.04

# --- Metadata ---
LABEL maintainer="devops-team@alphonse.com"
LABEL description="Optimized STAR aligner for RNA-Seq pipelines"
LABEL version="2.7.10a"

# --- Environment ---
ENV DEBIAN_FRONTEND=noninteractive

# --- Runtime Dependencies ---
# Install only what's needed to run STAR (zlib for gzipped files)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        zlib1g && \
    rm -rf /var/lib/apt/lists/*

# --- Copy Artifacts from Builder Stage ---
# This is the key step in a multi-stage build. We copy the compiled binary
# from the 'builder' stage into our final image.
COPY --from=builder /build/STAR-2.7.10a/source/STAR /usr/local/bin/STAR

# --- Create Non-Root User ---
# Security best practice: run containers as a non-root user
RUN useradd --create-home --shell /bin/bash biouser
USER biouser
WORKDIR /home/biouser

# --- Health Check ---
# Verifies that the STAR binary is executable and works
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
  CMD STAR --version || exit 1

# --- Default Command ---
# What to run when the container starts without arguments
ENTRYPOINT ["STAR"]
CMD ["--help"]
