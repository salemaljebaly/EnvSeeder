#!/bin/bash

# GitHub Secrets Uploader - Universal Installer
# Usage: curl -fsSL https://raw.githubusercontent.com/salemaljebaly/EnvSeeder/main/install.sh | bash

set -euo pipefail

# Color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# GitHub repository details
REPO_OWNER="salemaljebaly"
REPO_NAME="EnvSeeder"
BRANCH="feat/improve-script-automation"
BASE_URL="https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/${BRANCH}"

# Installation directory
INSTALL_DIR="${1:-$(pwd)}"

install_envseeder() {
    log_info "Installing GitHub Secrets Uploader to: $INSTALL_DIR"
    
    # Create directory if it doesn't exist
    mkdir -p "$INSTALL_DIR"
    cd "$INSTALL_DIR"
    
    # Download setup script
    log_info "Downloading setup script..."
    if curl -fsSL "${BASE_URL}/setup.sh" -o setup.sh; then
        chmod +x setup.sh
        log_success "Setup script downloaded"
    else
        log_error "Failed to download setup script"
        exit 1
    fi
    
    # Download main script
    log_info "Downloading main script..."
    if curl -fsSL "${BASE_URL}/gh-secrets-upload.sh" -o gh-secrets-upload.sh; then
        chmod +x gh-secrets-upload.sh
        log_success "Main script downloaded"
    else
        log_error "Failed to download main script"
        exit 1
    fi
    
    # Download example env file
    log_info "Downloading example .env file..."
    if curl -fsSL "${BASE_URL}/.env.example" -o .env.example 2>/dev/null; then
        log_success "Example .env file downloaded"
    else
        log_warn "Could not download .env.example (optional)"
    fi
    
    # Run setup
    log_info "Running automated setup..."
    if ./setup.sh; then
        log_success "Setup completed successfully!"
    else
        log_warn "Setup encountered issues, but scripts are installed"
    fi
    
    # Show usage
    echo
    log_success "GitHub Secrets Uploader installed successfully!"
    echo
    echo "Usage:"
    echo "  ./gh-secrets-upload.sh                    # Auto-detect .env and repo"
    echo "  ./gh-secrets-upload.sh .env.prod          # Use specific .env file"
    echo "  ./gh-secrets-upload.sh .env owner/repo    # Specify repo"
    echo
    echo "Help:"
    echo "  ./gh-secrets-upload.sh --help"
    echo
}

# Main execution
main() {
    log_info "GitHub Secrets Uploader Universal Installer"
    log_info "==========================================="
    
    # Check if we're in a git repository
    if git rev-parse --git-dir >/dev/null 2>&1; then
        log_info "Git repository detected"
    else
        log_warn "Not in a git repository - you'll need to specify repo manually"
    fi
    
    install_envseeder "$@"
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi