# =============================================================================
# Dockerfile: FastQC (Using Biocontainer)
# =============================================================================
#
# PURPOSE:
# This Dockerfile uses a pre-built FastQC container from Biocontainers.
# FastQC is a Java/Perl application for quality control of sequencing data.
#
# WHY USE BIOCONTAINERS?
# - Pre-built and tested by the bioinformatics community
# - All dependencies (Java, Perl) included
# - Consistent versions across different environments
# - Regular security updates
# - Avoids Perl module installation issues
#
# =============================================================================

FROM quay.io/biocontainers/fastqc:0.12.1--hdfd78af_0

LABEL maintainer="devops-team@alphonse.com"
LABEL description="FastQC for NGS quality control (biocontainer)"
LABEL version="0.12.1"

# Biocontainer already includes FastQC with all dependencies
# Run as root for compatibility with workflow engines
USER root
WORKDIR /data
