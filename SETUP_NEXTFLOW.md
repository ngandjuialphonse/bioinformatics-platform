# Nextflow Setup Guide

## Prerequisites

Nextflow requires Java 11 or later to run.

## Installation Steps

### **Recommended: Using WSL (Windows Subsystem for Linux)**

This is the easiest and most reliable method for Windows users:

```powershell
# 1. Open PowerShell and install Java and Nextflow in WSL
wsl bash -c "sudo apt-get update && sudo apt-get install -y openjdk-17-jre-headless curl"
wsl bash -c "curl -s https://get.nextflow.io | bash && sudo mv nextflow /usr/local/bin/"

# 2. Verify installation
wsl nextflow -version
```

**That's it!** Skip to "Running the Pipeline" section below.

---

### Alternative: Native Installation (Linux/Mac or Git Bash)

#### Option A: Using curl (in Git Bash or Linux)
```bash
curl -s https://get.nextflow.io | bash
sudo mv nextflow /usr/local/bin/
```

#### Option B: Manual Download
1. Install Java from: https://adoptium.net/
2. Download from: https://github.com/nextflow-io/nextflow/releases/latest
3. Add to your PATH

#### Option C: Using Docker (No installation needed)
```powershell
# Run Nextflow in a container
.\run-nextflow-docker.ps1
```

## Running the Pipeline

### **Quick Start (Windows with WSL):**

```powershell
# Simply run the helper script
.\run-pipeline.ps1

# Or run directly via WSL
wsl bash -c "cd '/mnt/c/Users/YOUR_USERNAME/path/to/bioinformatics-platform/workflows' && nextflow run main.nf -profile test,docker"
```

### **Standard Usage:**

```bash
# Test with small dataset (RECOMMENDED FOR FIRST RUN)
cd workflows
nextflow run main.nf -profile test,docker

# Or with your own data
nextflow run main.nf -profile docker \
  --reads "/path/to/fastq/*_R{1,2}.fastq.gz" \
  --genome "/path/to/reference/genome.fa" \
  --gtf "/path/to/reference/genes.gtf"
```

**Important:** The `-profile test,docker` is required to use the bundled test data. Without it, you must provide `--reads`, `--genome`, and `--gtf` parameters.

## Test Data

Test data has been set up in:
- `test_data/reads/test_R1.fastq`
- `test_data/reads/test_R2.fastq`
- `test_data/reference/genome.fa`
- `test_data/reference/genes.gtf`

## Troubleshooting

### "nextflow: command not found"
- Make sure Java is installed: `java -version`
- Make sure Nextflow is in your PATH
- Try running with full path: `./nextflow run main.nf`

### Docker issues
- Make sure Docker Desktop is running
- Check Docker is accessible: `docker ps`
