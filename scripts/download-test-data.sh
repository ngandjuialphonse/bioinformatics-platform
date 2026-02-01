#!/bin/bash
# =============================================================================
# Test Data Download Script
# =============================================================================
#
# PURPOSE:
# This script downloads the minimal test dataset required to run the nf-test
# suite. In a real-world scenario, this data would come from a public
# repository (like SRA) or an internal data store.
#
# WHY A SCRIPT?
# - Automation: Makes setting up the test environment repeatable
# - Versioning: The script is version-controlled with the code
# - CI/CD Integration: The GitHub Actions workflow calls this script
#
# =============================================================================

set -e

# --- Configuration ---
TEST_DATA_DIR="test_data"
READS_DIR="${TEST_DATA_DIR}/reads"
REF_DIR="${TEST_DATA_DIR}/reference"
VALIDATION_DIR="${TEST_DATA_DIR}/validation"
EDGE_CASE_DIR="${TEST_DATA_DIR}/edge_cases"

# --- Create Directories ---
echo "[INFO] Creating test data directories..."
mkdir -p "${READS_DIR}"
mkdir -p "${REF_DIR}/star_index"
mkdir -p "${VALIDATION_DIR}"
mkdir -p "${EDGE_CASE_DIR}"

# --- Generate Dummy FASTQ Files ---
echo "[INFO] Generating dummy FASTQ files..."

# R1 reads
cat << EOF > "${READS_DIR}/test_R1.fastq"
@SEQ_ID_1
NGCATGCATGCATGCATGCATGCATGCATGCATGCATGCAT
+
!"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHI
@SEQ_ID_2
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
+
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
EOF

# R2 reads
cat << EOF > "${READS_DIR}/test_R2.fastq"
@SEQ_ID_1
TACGTACGTACGTACGTACGTACGTACGTACGTACGTAC
+
!"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHI
@SEQ_ID_2
TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT
+
TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT
EOF

# Compress FASTQ files
gzip -f "${READS_DIR}/test_R1.fastq"
gzip -f "${READS_DIR}/test_R2.fastq"

# --- Generate Dummy Reference Files ---
echo "[INFO] Generating dummy reference genome and GTF..."

# Dummy genome.fa
cat << EOF > "${REF_DIR}/genome.fa"
>chr1
NGCATGCATGCATGCATGCATGCATGCATGCATGCATGCATAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
>chr2
TACGTACGTACGTACGTACGTACGTACGTACGTACGTAC
EOF

# Dummy genes.gtf
cat << EOF > "${REF_DIR}/genes.gtf"
chr1\tHAVANA\texon\t1\t50\t.\t+\t.\tgene_id "gene1"; transcript_id "transcript1";
chr1\tHAVANA\texon\t60\t100\t.\t+\t.\tgene_id "gene2"; transcript_id "transcript2";
EOF

# --- Generate Dummy STAR Index ---
echo "[INFO] Generating dummy STAR index files..."
touch "${REF_DIR}/star_index/SA"
touch "${REF_DIR}/star_index/genomeParameters.txt"

# --- Generate Dummy Samplesheets ---
echo "[INFO] Generating dummy samplesheets..."

# samplesheet.csv
cat << EOF > "${TEST_DATA_DIR}/samplesheet.csv"
sample,fastq_1,fastq_2
sample1,${READS_DIR}/test_R1.fastq.gz,${READS_DIR}/test_R2.fastq.gz
sample2,${READS_DIR}/test_R1.fastq.gz,${READS_DIR}/test_R2.fastq.gz
EOF

# validation/samplesheet.csv
cat << EOF > "${VALIDATION_DIR}/samplesheet.csv"
sample,fastq_1,fastq_2
valid_sample,${READS_DIR}/test_R1.fastq.gz,${READS_DIR}/test_R2.fastq.gz
EOF

# validation/de_samplesheet.csv
cat << EOF > "${VALIDATION_DIR}/de_samplesheet.csv"
sample,fastq_1,fastq_2,condition
sample_A1,${READS_DIR}/test_R1.fastq.gz,${READS_DIR}/test_R2.fastq.gz,A
sample_A2,${READS_DIR}/test_R1.fastq.gz,${READS_DIR}/test_R2.fastq.gz,A
sample_B1,${READS_DIR}/test_R1.fastq.gz,${READS_DIR}/test_R2.fastq.gz,B
sample_B2,${READS_DIR}/test_R1.fastq.gz,${READS_DIR}/test_R2.fastq.gz,B
EOF

# edge_cases/low_coverage_samplesheet.csv
cat << EOF > "${EDGE_CASE_DIR}/low_coverage_samplesheet.csv"
sample,fastq_1,fastq_2
low_cov_sample,${READS_DIR}/test_R1.fastq.gz,${READS_DIR}/test_R2.fastq.gz
EOF

# --- Generate Dummy Validation Files ---
echo "[INFO] Generating dummy validation files..."

# expected_counts.tsv
cat << EOF > "${VALIDATION_DIR}/expected_counts.tsv"
gene\tvalid_sample
gene1\t100.0
gene2\t200.0
EOF

# known_de_genes.txt
cat << EOF > "${VALIDATION_DIR}/known_de_genes.txt"
gene1
EOF

# --- Generate Dummy Invalid File ---
echo "[INFO] Generating dummy invalid file..."
mkdir -p "${TEST_DATA_DIR}/invalid"
echo "This is not a FASTQ file" > "${TEST_DATA_DIR}/invalid/not_a_fastq.txt"

echo "[SUCCESS] Test data generated successfully in ${TEST_DATA_DIR}/"
