# =============================================================================
# Dockerfile: Salmon (Using Biocontainer)
# =============================================================================
#
# PURPOSE:
# This Dockerfile uses a pre-built Salmon container from Biocontainers,
# which is more reliable than building from source.
#
# WHAT IS SALMON?
# Salmon is a "quasi-mapper" for quantifying transcript expression from RNA-seq.
# It's much faster than alignment-based methods.
#
# WHY USE BIOCONTAINERS?
# - Pre-built and tested by the bioinformatics community
# - Consistent versions across different environments
# - Faster builds (no compilation needed)
# - Regular security updates
#
# =============================================================================

FROM quay.io/biocontainers/salmon:1.10.3--h8b2e3c8_1

LABEL maintainer="devops-team@alphonse.com"
LABEL description="Salmon for transcript quantification (biocontainer)"
LABEL version="1.10.3"

# Biocontainer already includes salmon and all dependencies
# Run as root for compatibility with workflow engines
USER root
WORKDIR /data

# --- Health Check ---
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
  CMD salmon --version || exit 1

# --- Default Command ---
ENTRYPOINT ["salmon"]
CMD ["--help"]
