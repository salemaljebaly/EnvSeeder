# GitHub Secrets Uploader

A powerful bash script with automated setup to bulk upload environment variables from a `.env` file to GitHub Actions secrets.

## 🎯 What This Tool Does

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────────┐
│   Your .env     │───▶│  Your Script     │───▶│  GitHub Actions     │
│   (Local File)  │    │  (Local Tool)    │    │  Secrets (Cloud)    │
└─────────────────┘    └──────────────────┘    └─────────────────────┘
```

- **Input**: Local `.env` file with your secrets
- **Process**: Script uploads via GitHub CLI  
- **Output**: Secrets available in GitHub Actions workflows

## 🚀 Quick Start

### Recommended Install (Most Reliable)
```bash
# Download both scripts
curl -O https://raw.githubusercontent.com/salemaljebaly/EnvSeeder/feat/improve-script-automation/setup.sh
curl -O https://raw.githubusercontent.com/salemaljebaly/EnvSeeder/feat/improve-script-automation/gh-secrets-upload.sh

# Make executable and run setup
chmod +x *.sh
./setup.sh
```

### Alternative: Git Clone and Copy
```bash
git clone https://github.com/salemaljebaly/EnvSeeder.git
cp EnvSeeder/gh-secrets-upload.sh EnvSeeder/setup.sh .
rm -rf EnvSeeder
chmod +x *.sh && ./setup.sh
```

### If You Cloned This Repository
```bash
./setup.sh  # Run once to install dependencies
./gh-secrets-upload.sh  # Upload your secrets
```

## Features

- 🚀 **One Command Setup**: Installs all dependencies automatically
- 🔄 **Smart Detection**: Auto-detects `.env` files and git repository
- 🛡️ **Secure**: Masks secret values in output logs
- ✅ **Validation**: Validates secret names according to GitHub requirements
- 🔁 **Retry Logic**: Automatically retries failed uploads
- 🎯 **Environment Support**: Repository and environment-specific secrets
- ⏭️ **Skip Existing Secrets**: Option to skip secrets that already exist
- 🔄 **Sync Mode**: Delete GitHub secrets that are not present in .env file
- 📊 **Progress Tracking**: Detailed progress and summary reporting
- 🔧 **Cross-Platform**: macOS, Linux, and Windows support

## 📋 Usage Examples

### Basic Usage (Auto-detect everything)
```bash
./gh-secrets-upload.sh
```

### Skip existing secrets
```bash
./gh-secrets-upload.sh --skip-existing
```

### Sync secrets (delete secrets not in .env file)
```bash
./gh-secrets-upload.sh --sync
```

### Specific .env file
```bash
./gh-secrets-upload.sh .env.production
```

### Skip existing with specific file
```bash
./gh-secrets-upload.sh --skip-existing .env.production
```

### Sync with specific file
```bash
./gh-secrets-upload.sh --sync .env.production
```

### Different repository
```bash
./gh-secrets-upload.sh .env.prod owner/repository
```

### Environment-specific secrets
```bash
./gh-secrets-upload.sh .env.staging owner/repo staging
```

## 🔄 Common Workflows

### Development Workflow
```bash
# 1. Create your .env file with secrets
echo "API_KEY=your-secret-key" > .env.prod

# 2. Upload to GitHub
./gh-secrets-upload.sh .env.prod

# 3. Your GitHub Actions can now use ${{ secrets.API_KEY }}
```

### Multiple Environments
```bash
# Upload different environments
./gh-secrets-upload.sh .env.development owner/repo development
./gh-secrets-upload.sh .env.staging owner/repo staging  
./gh-secrets-upload.sh .env.production owner/repo production
```

### Incremental Updates
```bash
# Initial upload of all secrets
./gh-secrets-upload.sh .env.production

# Later, add new secrets without overwriting existing ones
./gh-secrets-upload.sh --skip-existing .env.production
```

### Team Setup
```bash
# Each team member runs once
curl -fsSL https://raw.githubusercontent.com/salemaljebaly/EnvSeeder/feat/improve-script-automation/install.sh | bash

# Then anyone can upload secrets
./gh-secrets-upload.sh .env.production
```

## 📦 Integration with Existing Projects

### Node.js (package.json)
```json
{
  "scripts": {
    "secrets:install": "curl -fsSL https://raw.githubusercontent.com/salemaljebaly/EnvSeeder/feat/improve-script-automation/install.sh | bash",
    "secrets:upload": "./gh-secrets-upload.sh",
    "secrets:prod": "./gh-secrets-upload.sh .env.production"
  }
}
```

```bash
npm run secrets:install  # One-time setup
npm run secrets:prod     # Upload production secrets
```

### Any Project (Makefile)
```makefile
install-secrets:
	curl -fsSL https://raw.githubusercontent.com/salemaljebaly/EnvSeeder/feat/improve-script-automation/install.sh | bash

upload-secrets:
	./gh-secrets-upload.sh

upload-prod:
	./gh-secrets-upload.sh .env.production
```

```bash
make install-secrets  # One-time setup
make upload-prod      # Upload production secrets
```

## 🔧 .env File Format

Your `.env` file should contain key-value pairs:

```bash
# Database configuration
DB_HOST=localhost
DB_PORT=5432
DB_PASSWORD="my-secret-password"

# API keys
API_KEY=abc123def456
STRIPE_SECRET_KEY='sk_test_...'

# Comments and empty lines are ignored
# COMMENTED_OUT_VAR=value
```

### Rules
- Variable names converted to uppercase automatically
- Must match pattern `[A-Z0-9_]+`
- Values can be quoted with single or double quotes
- Comments (lines starting with `#`) are ignored
- Variables starting with `GITHUB_` are automatically skipped

## 🛡️ Security Features

- **Value Masking**: Secret values masked in output (e.g., `my****et`)
- **No Logging**: Secret values never written to logs or files
- **Memory Cleanup**: Variables unset after processing
- **Validation**: Only valid secret names processed
- **GitHub CLI Auth**: Uses official GitHub authentication

## ⚡ Quick Commands Reference

```bash
# Install (run once per project)
curl -fsSL https://raw.githubusercontent.com/salemaljebaly/EnvSeeder/feat/improve-script-automation/install.sh | bash

# Basic upload
./gh-secrets-upload.sh

# Skip existing secrets
./gh-secrets-upload.sh --skip-existing

# Sync secrets (delete missing from .env)
./gh-secrets-upload.sh --sync

# Help
./gh-secrets-upload.sh --help

# Check what secrets will be uploaded
cat .env.production | grep -E '^[A-Z0-9_]+=' | cut -d'=' -f1
```

## 🎯 Key Benefits

- ✅ **Simple**: Just 2 files to download
- ✅ **Fast**: One command to install, one command to upload
- ✅ **Secure**: Never stores or transmits secrets unnecessarily  
- ✅ **Universal**: Works with any project, any language
- ✅ **Local**: No external dependencies or cloud services needed

## 🚨 Important Notes

1. **This is a LOCAL tool** - runs on your machine or CI server
2. **Not a GitHub Action** - GitHub Actions would access the uploaded secrets
3. **One-time setup** - Install once per project/machine
4. **Secure by design** - Uses official GitHub CLI authentication

## 🆘 Troubleshooting

### First time setup
```bash
gh auth login  # Authenticate with GitHub
```

### Permission issues
```bash
gh auth refresh -s repo  # Ensure repo permissions
```

### Script not found
```bash
chmod +x gh-secrets-upload.sh  # Make executable
```

### "No .env file found"
Ensure you have one of these files in your current directory:
- `.env.prod`, `.env.production`, `.env.local`, `.env`

Or specify the path explicitly:
```bash
./gh-secrets-upload.sh path/to/your/.env
```

## Files

- `gh-secrets-upload.sh`: Main script for uploading secrets
- `setup.sh`: Automated dependency installation script
- `install.sh`: Universal installer for other projects
- `.env.example`: Example environment file

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.