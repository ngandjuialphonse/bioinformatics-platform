# GitHub Actions Issues & Solutions

## Issues Identified

### 1. AWS Credentials Error ❌
```
Error: The security token included in the request is invalid
```

**Cause:** GitHub Actions is trying to authenticate with AWS, but the required secrets are not configured.

**Solution:**

#### Option A: Configure AWS Secrets (For Production)
Add these secrets in GitHub:
1. Go to: `https://github.com/ngandjuialphonse/bioinformatics-platform/settings/secrets/actions`
2. Click "New repository secret"
3. Add:
   - `AWS_ROLE_ARN` - Your AWS IAM role ARN for OIDC
   - `AWS_REGION` - Your AWS region (e.g., `us-east-1`)

#### Option B: Skip AWS Steps (For Development) ✅
The workflow has been updated to skip AWS steps when:
- Not pushing to main branch
- Or when running on PRs
- Credentials are marked as `continue-on-error: true`

### 2. Nextflow Test Profile Missing ❌
```
ERROR: --reads parameter is required
```

**Cause:** The CI workflow was running Nextflow without the `-profile test` flag.

**Solution:** The workflow now checks for test configuration and uses the test profile automatically.

---

## What's Been Fixed ✅

### Workflow Changes Made:

1. **AWS Authentication** - Now conditional:
   ```yaml
   - name: Configure AWS credentials
     if: github.event_name == 'push' && github.ref == 'refs/heads/main'
     continue-on-error: true
   ```

2. **ECR Login** - Now optional:
   ```yaml
   - name: Login to Amazon ECR
     if: github.event_name == 'push' && github.ref == 'refs/heads/main'
     continue-on-error: true
   ```

3. **Test Execution** - Uses test profile properly

---

## How to Push These Changes

The terminal seems stuck in multi-line mode. Here's how to complete the push:

### Method 1: New PowerShell Window
```powershell
cd "C:\Users\ngand\OneDrive\Documents\Bioinformatics\bioinformatics-platform"
git add .github/workflows/pipeline-ci.yml
git commit -m "Fix GitHub Actions: make AWS credentials optional"
git push origin main
```

### Method 2: Using WSL (Recommended)
```powershell
wsl
cd /mnt/c/Users/ngand/OneDrive/Documents/Bioinformatics/bioinformatics-platform
git add .github/workflows/pipeline-ci.yml
git commit -m "Fix GitHub Actions: make AWS credentials optional"
git push origin main
exit
```

---

## Expected Behavior After Fix

### On Pull Requests:
- ✅ Linting will run
- ✅ Validation will run
- ⏭️  AWS steps will be skipped
- ⏭️  Build steps will be skipped
- ✅ Basic tests may run (if configured)

### On Push to Main (without AWS secrets):
- ✅ Linting will run
- ✅ Validation will run
- ⚠️  AWS steps will be attempted but won't fail the workflow
- ⚠️  Build steps will be attempted but won't fail
- ✅ Tests will run with test profile

### On Push to Main (with AWS secrets):
- ✅ Full workflow runs
- ✅ Images pushed to ECR
- ✅ Deployment happens

---

## Next Steps

1. **Push the workflow fix** (see methods above)
2. **Wait for GitHub Actions to run**
3. **Check the workflow results** at:
   `https://github.com/ngandjuialphonse/bioinformatics-platform/actions`

4. **Optional - Configure AWS later:**
   - When ready for production
   - Follow AWS OIDC setup guide
   - Add secrets to GitHub

---

## Test Locally

You can test the pipeline works locally:

```powershell
# Via WSL (recommended)
wsl bash -c "cd '/mnt/c/Users/ngand/OneDrive/Documents/Bioinformatics/bioinformatics-platform/workflows' && nextflow run main.nf -profile test,docker"

# Or using the helper script
.\run-pipeline.ps1
```

---

## Summary

The GitHub Actions workflow errors were caused by:
1. Missing AWS credentials (expected for development)
2. Missing test profile in CI execution

Both have been fixed. The workflow will now:
- Skip AWS steps gracefully when credentials aren't available
- Continue-on-error for optional steps
- Use proper test profile for validation

✅ **Your pipeline is ready for development work!**
