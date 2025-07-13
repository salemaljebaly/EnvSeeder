#!/bin/bash

# GitHub Secrets Uploader - Setup Script
# This script automatically checks for and installs required dependencies

set -euo pipefail

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Detect operating system
detect_os() {
    case "$(uname -s)" in
        Darwin*)    echo "macos" ;;
        Linux*)     echo "linux" ;;
        CYGWIN*)    echo "windows" ;;
        MINGW*)     echo "windows" ;;
        *)          echo "unknown" ;;
    esac
}

# Install GitHub CLI
install_gh_cli() {
    local os
    os=$(detect_os)
    
    log_info "Installing GitHub CLI for $os..."
    
    case "$os" in
        "macos")
            if command_exists brew; then
                brew install gh
            else
                log_error "Homebrew not found. Please install Homebrew first or install GitHub CLI manually."
                log_info "Visit: https://cli.github.com/manual/installation"
                return 1
            fi
            ;;
        "linux")
            # Try different package managers
            if command_exists apt-get; then
                # Debian/Ubuntu
                curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
                sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
                echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
                sudo apt update
                sudo apt install gh
            elif command_exists yum; then
                # RHEL/CentOS/Fedora
                sudo dnf install 'dnf-command(config-manager)'
                sudo dnf config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo
                sudo dnf install gh
            elif command_exists pacman; then
                # Arch Linux
                sudo pacman -S github-cli
            else
                log_error "No supported package manager found. Please install GitHub CLI manually."
                log_info "Visit: https://cli.github.com/manual/installation"
                return 1
            fi
            ;;
        "windows")
            if command_exists winget; then
                winget install --id GitHub.cli
            elif command_exists choco; then
                choco install gh
            else
                log_error "No supported package manager found (winget/chocolatey). Please install GitHub CLI manually."
                log_info "Visit: https://cli.github.com/manual/installation"
                return 1
            fi
            ;;
        *)
            log_error "Unsupported operating system: $os"
            log_info "Please install GitHub CLI manually: https://cli.github.com/manual/installation"
            return 1
            ;;
    esac
    
    log_success "GitHub CLI installed successfully!"
}

# Check GitHub CLI authentication
check_gh_auth() {
    if ! gh auth status >/dev/null 2>&1; then
        log_warn "GitHub CLI is not authenticated."
        log_info "Please run: gh auth login"
        return 1
    fi
    log_success "GitHub CLI is authenticated"
}

# Check prerequisites
check_prerequisites() {
    local missing_deps=()
    
    log_info "Checking prerequisites..."
    
    # Check for git
    if ! command_exists git; then
        missing_deps+=("git")
    fi
    
    # Check for GitHub CLI
    if ! command_exists gh; then
        log_warn "GitHub CLI not found. Will attempt to install..."
        if ! install_gh_cli; then
            missing_deps+=("gh")
        fi
    else
        log_success "GitHub CLI found"
        if ! check_gh_auth; then
            log_info "Run 'gh auth login' to authenticate with GitHub"
        fi
    fi
    
    # Check for basic tools
    for tool in curl grep sed; do
        if ! command_exists "$tool"; then
            missing_deps+=("$tool")
        fi
    done
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        log_error "Missing required dependencies: ${missing_deps[*]}"
        log_info "Please install the missing dependencies and run this script again."
        return 1
    fi
    
    log_success "All prerequisites are satisfied!"
}

# Make main script executable
setup_main_script() {
    local script_path="./gh-secrets-upload.sh"
    
    if [ -f "$script_path" ]; then
        chmod +x "$script_path"
        log_success "Made $script_path executable"
    else
        log_error "Main script not found: $script_path"
        return 1
    fi
}

# Main setup function
main() {
    log_info "GitHub Secrets Uploader - Setup Script"
    log_info "======================================"
    
    # Check prerequisites and install if needed
    if ! check_prerequisites; then
        exit 1
    fi
    
    # Setup main script
    if ! setup_main_script; then
        exit 1
    fi
    
    log_success "Setup completed successfully!"
    log_info ""
    log_info "You can now use the GitHub Secrets Uploader:"
    log_info "  ./gh-secrets-upload.sh [options]"
    log_info ""
    log_info "For help: ./gh-secrets-upload.sh --help"
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi