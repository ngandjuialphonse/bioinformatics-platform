# =============================================================================
# Dockerfile: STAR Aligner (Using Biocontainer)
# =============================================================================
#
# PURPOSE:
# This Dockerfile uses a pre-built STAR container from Biocontainers.
#
# WHAT IS STAR?
# STAR (Spliced Transcripts Alignment to a Reference) is an ultrafast RNA-seq
# aligner that can handle splice junctions. It's the gold standard for RNA-seq
# alignment.
#
# WHY USE BIOCONTAINERS?
# - Pre-built and tested by the bioinformatics community
# - Consistent versions across different environments  
# - Faster builds (no compilation needed)
# - Regular security updates
# - Avoids complex build dependencies (xxd, g++, make, etc.)
#
# INTERVIEW TIP:
# Using community-maintained biocontainers demonstrates:
# - Understanding of reproducibility in bioinformatics
# - Pragmatic approach to DevOps (don't reinvent the wheel)
# - Knowledge of bioinformatics ecosystem
#
# =============================================================================

FROM quay.io/biocontainers/star:2.7.11b--h43eeafb_1

LABEL maintainer="devops-team@alphonse.com"
LABEL description="STAR aligner for RNA-Seq pipelines (biocontainer)"
LABEL version="2.7.11b"

# Biocontainer already includes STAR and all dependencies
# Run as root for compatibility with workflow engines
USER root
WORKDIR /data

# --- Health Check ---
# Verifies that the STAR binary is executable and works
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
  CMD STAR --version || exit 1

# --- Default Command ---
# What to run when the container starts without arguments
ENTRYPOINT ["STAR"]
CMD ["--help"]
