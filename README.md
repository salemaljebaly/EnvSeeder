# GitHub Secrets Uploader

A powerful bash script with automated setup to bulk upload environment variables from a `.env` file to GitHub Actions secrets.

## Features

- 🚀 **Automated Setup**: One-command installation of all dependencies
- 🔄 **Automatic Detection**: Auto-detects `.env` files and git repository
- 🛡️ **Secure**: Masks secret values in output logs
- ✅ **Validation**: Validates secret names according to GitHub requirements
- 🔁 **Retry Logic**: Automatically retries failed uploads
- 🎯 **Environment Support**: Supports both repository and environment-specific secrets
- 📊 **Progress Tracking**: Shows detailed progress and summary
- 🔧 **Cross-Platform**: Supports macOS, Linux, and Windows

## Quick Start

### Option 1: Automated Setup (Recommended)

1. **Run the setup script** (installs all dependencies automatically):
   ```bash
   ./setup.sh
   ```

2. **Upload your secrets**:
   ```bash
   ./gh-secrets-upload.sh
   ```

### Option 2: Manual Setup

1. **Install GitHub CLI** (if not already installed):
   ```bash
   # macOS
   brew install gh
   
   # Ubuntu/Debian
   curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
   sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
   echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
   sudo apt update && sudo apt install gh
   ```

2. **Authenticate with GitHub**:
   ```bash
   gh auth login
   ```

3. **Make script executable**:
   ```bash
   chmod +x gh-secrets-upload.sh
   ```

## Usage

```bash
./gh-secrets-upload.sh [envfile] [owner/repo] [environment]
```

### Arguments

- `envfile` (optional): Path to your `.env` file. If not provided, script will auto-detect in this order:
  - `.env.prod`
  - `.env.production` 
  - `.env.local`
  - `.env`

- `owner/repo` (optional): GitHub repository in format `owner/repository`. If not provided, script will auto-detect from git remote.

- `environment` (optional): Target environment name for environment-specific secrets. If not provided, secrets will be set at repository level.

### Examples

```bash
# Basic usage - auto-detect everything
./gh-secrets-upload.sh

# Use specific .env file
./gh-secrets-upload.sh .env.production

# Specify different repository
./gh-secrets-upload.sh .env.prod myorg/myapp

# Upload to specific environment
./gh-secrets-upload.sh .env.prod myorg/myapp staging
```

## Setup Script Features

The `setup.sh` script provides:

- **Dependency Detection**: Automatically checks for required tools
- **Cross-Platform Installation**: Supports multiple operating systems and package managers
- **GitHub CLI Installation**: Installs GitHub CLI using the appropriate method for your system
- **Authentication Check**: Verifies GitHub CLI authentication status
- **Permission Setup**: Makes scripts executable automatically

### Supported Platforms

- **macOS**: Uses Homebrew
- **Linux**: 
  - Debian/Ubuntu (apt)
  - RHEL/CentOS/Fedora (dnf/yum)
  - Arch Linux (pacman)
- **Windows**: Uses winget or Chocolatey

## .env File Format

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

- Variable names will be converted to uppercase
- Variable names must match pattern `[A-Z0-9_]+`
- Values can be quoted with single or double quotes
- Comments (lines starting with `#`) are ignored
- Empty lines are ignored
- Variables starting with `GITHUB_` are automatically skipped (GitHub restriction)

## Security Features

- **Value Masking**: Secret values are masked in output (e.g., `my****et`)
- **No Logging**: Secret values are never written to logs or files
- **Memory Cleanup**: Variables are unset after processing
- **Validation**: Only valid secret names are processed

## Error Handling

- **Automatic Setup**: If dependencies are missing, the main script will automatically run setup
- **Automatic Retry**: Failed uploads are automatically retried once
- **Detailed Errors**: Error messages include helpful debugging information
- **Validation**: Invalid secret names are skipped with warnings
- **Prerequisites Check**: Verifies GitHub CLI installation and authentication

## Example Output

```
ℹ️  Auto-detected .env file: .env.production
ℹ️  Auto-detected repository: myorg/myapp
ℹ️  Setting repository-level secrets

✅ Added DATABASE_URL (value: po****ql)
✅ Added API_KEY (value: ab****56)
⚠️  Skipping GITHUB_TOKEN - secret names cannot start with 'GITHUB_' (GitHub restriction)
✅ Added STRIPE_KEY (value: sk****_test)

ℹ️  === SUMMARY ===
Total secrets processed: 3
Successfully added: 3
Failed: 0
```

## Troubleshooting

### "Dependencies missing"
The script will automatically run `setup.sh` if dependencies are missing. If setup fails:
```bash
./setup.sh
```

### "GitHub CLI is not authenticated"
```bash
gh auth login
# Follow the prompts to authenticate
```

### "Token may not have sufficient 'repo' scope"
```bash
gh auth refresh -s repo
```

### "No .env file found"
Ensure you have one of these files in your current directory:
- `.env.prod`
- `.env.production`
- `.env.local` 
- `.env`

Or specify the path explicitly:
```bash
./gh-secrets-upload.sh path/to/your/.env
```

### "No git repository detected"
Ensure you're in a git repository with a GitHub remote, or specify the repository:
```bash
./gh-secrets-upload.sh .env myorg/myrepo
```

## Files

- `gh-secrets-upload.sh`: Main script for uploading secrets
- `setup.sh`: Automated dependency installation script
- `.env.example`: Example environment file
- `README.md`: This documentation
- `LICENSE`: MIT license file

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.