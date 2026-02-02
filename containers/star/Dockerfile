# =============================================================================
# Dockerfile: STAR Aligner (Using Biocontainer)
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
