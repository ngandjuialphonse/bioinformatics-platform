# =============================================================================
# Dockerfile: FastQC (Using Biocontainer)
# =============================================================================

FROM quay.io/biocontainers/fastqc:0.12.1--hdfd78af_0

LABEL maintainer="devops-team@alphonse.com"
LABEL description="FastQC for NGS quality control (biocontainer)"
LABEL version="0.12.1"

# Biocontainer already includes FastQC with all dependencies
# Run as root for compatibility with workflow engines
USER root
WORKDIR /data
