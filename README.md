# GitHub Actions Secrets Uploader

A simple, fully automated Bash script that bulk-uploads environment variables from a `.env` file as GitHub Actions repository secrets using the GitHub CLI.

## Features

- 🚀 **Fully Automated** - Zero prompts, smart auto-detection
- 🔐 Secure handling of sensitive data with value masking in logs
- 🔄 Automatic retry mechanism for failed uploads
- 🌍 Support for environment-specific secrets
- ✅ Comprehensive validation and error handling
- 📊 Progress tracking and detailed summary reporting

## Prerequisites

1. **GitHub CLI (gh)** - Version 2.0 or higher
   ```bash
   # Install via Homebrew (macOS)
   brew install gh
   
   # Install via apt (Ubuntu/Debian)
   sudo apt install gh
   
   # Install via yum (RHEL/CentOS)
   sudo yum install gh
   ```

2. **Authentication** - Must be logged in with repo scope
   ```bash
   gh auth login
   # or refresh with repo scope
   gh auth refresh -s repo
   ```

3. **POSIX shell** - Works on macOS and Linux (bash, zsh, etc.)

## Quick Start

1. Download and run:
   ```bash
   curl -O https://raw.githubusercontent.com/your-repo/gh-secrets-uploader/main/gh-secrets-upload.sh
   chmod +x gh-secrets-upload.sh
   ./gh-secrets-upload.sh
   ```

2. Or clone the repository:
   ```bash
   git clone https://github.com/your-repo/gh-secrets-uploader.git
   cd gh-secrets-uploader
   ./gh-secrets-upload.sh
   ```

## Usage

### Super Simple - Just Run It!

The script automatically detects everything:

```bash
./gh-secrets-upload.sh
```

**That's it!** The script will:
- Auto-find your .env file (tries `.env.prod`, `.env.production`, `.env.local`, `.env`)
- Auto-detect your GitHub repository from git remote
- Upload all secrets immediately

### Manual Override (Optional)

You can specify arguments if needed:

```bash
./gh-secrets-upload.sh [envfile] [owner/repo] [environment]
```

### Examples

```bash
# Fully automated (recommended)
./gh-secrets-upload.sh

# Use specific .env file
./gh-secrets-upload.sh .env.staging

# Specify .env and repository
./gh-secrets-upload.sh .env.prod myorg/myapp

# Include environment name
./gh-secrets-upload.sh .env.prod myorg/myapp production
```

## .env File Format

The script supports standard `.env` file format:

```bash
# Comments are ignored
API_KEY=your-secret-api-key
DATABASE_URL="postgresql://user:pass@host:5432/db"
DEBUG=true
WEBHOOK_SECRET='your-webhook-secret'

# Empty lines are ignored

FEATURE_FLAG=enabled
```

### Rules

- Lines starting with `#` are treated as comments
- Empty lines are ignored
- Variable names are automatically converted to uppercase
- Values can be quoted with single or double quotes
- Variable names must match pattern `[A-Z0-9_]+` (enforced by GitHub)

## Security Features

- **Value Masking**: Secret values are masked in all output (shows first 2 and last 2 characters)
- **Memory Cleanup**: Sensitive data is cleared from memory after processing
- **No Logging**: Secret values are never written to logs or stdout
- **Validation**: Ensures GitHub CLI has proper authentication and permissions

## Output Example

```
ℹ️  Processing .env file: .env.prod
ℹ️  Target repository: myorg/myapp
ℹ️  Setting repository-level secrets

✅ Added API_KEY (value: ap****ey)
✅ Added DATABASE_URL (value: po****32)
⚠️  Retrying WEBHOOK_SECRET...
✅ Added WEBHOOK_SECRET (value: wh****et) [retry]
❌ Failed to add INVALID-NAME (value: so****ng)

ℹ️  === SUMMARY ===
Total secrets processed: 4
Successfully added: 3
Failed: 1
```

## Error Handling

The script handles various error conditions:

- **Missing GitHub CLI**: Prompts to install `gh`
- **Authentication Issues**: Guides through `gh auth login`
- **Invalid Repository**: Validates repository exists and is accessible
- **File Access**: Checks if .env file exists and is readable
- **Invalid Secret Names**: Validates against GitHub's naming requirements
- **Upload Failures**: Retries once, then reports failure

## Environment-Specific Secrets

GitHub Actions supports environment-specific secrets for deployment environments:

```bash
# Upload to 'production' environment
./gh-secrets-upload.sh -f .env.prod -r myorg/myapp -e production

# Upload to 'staging' environment  
./gh-secrets-upload.sh -f .env.staging -r myorg/myapp -e staging
```

Environment secrets take precedence over repository secrets in GitHub Actions workflows.

## Troubleshooting

### Permission Errors

```bash
# Re-authenticate with repo scope
gh auth refresh -s repo

# Check current authentication status
gh auth status
```

### Invalid Secret Names

GitHub requires secret names to match `[A-Z0-9_]+`:
- ✅ `API_KEY`, `DATABASE_URL`, `FEATURE_FLAG_1`
- ❌ `api-key`, `database.url`, `feature-flag`

### Large .env Files

The script processes files line by line, so memory usage is minimal even for large files.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

MIT License - see LICENSE file for details

## Support

- Report issues: [GitHub Issues](https://github.com/your-repo/gh-secrets-uploader/issues)
- Documentation: [GitHub Discussions](https://github.com/your-repo/gh-secrets-uploader/discussions)