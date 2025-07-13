#!/bin/bash
set -euo pipefail

# GitHub Actions Secret Bulk Uploader - Simplified & Automated
# Usage: ./gh-secrets-upload.sh [envfile] [owner/repo] [environment]

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Progress tracking
TOTAL_SECRETS=0
SUCCESS_COUNT=0
FAIL_COUNT=0

# Helper functions
log_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
log_success() { echo -e "${GREEN}✅ $1${NC}"; }
log_warn() { echo -e "${YELLOW}⚠️  $1${NC}"; }
log_error() { echo -e "${RED}❌ $1${NC}"; }

# Mask secret values in output
mask_value() {
    local value="$1"
    if [ ${#value} -le 4 ]; then
        echo "****"
    else
        echo "${value:0:2}$(printf '*%.0s' $(seq 1 $((${#value} - 4))))${value: -2}"
    fi
}

# Validate GitHub secret name
validate_secret_name() {
    local name="$1"
    if ! echo "$name" | grep -qE '^[A-Z0-9_]+$'; then
        return 1
    fi
    return 0
}

# Check prerequisites
check_prerequisites() {
    if ! command -v gh >/dev/null 2>&1; then
        log_error "GitHub CLI (gh) is not installed. Please install it first."
        exit 1
    fi

    if ! gh auth status >/dev/null 2>&1; then
        log_error "GitHub CLI is not authenticated. Please run 'gh auth login' first."
        exit 1
    fi

    # Check if authenticated user has repo scope
    local scopes
    scopes=$(gh auth status 2>&1 | grep -o 'Token scopes:.*' | cut -d: -f2- || echo "")
    if [[ "$scopes" != *"repo"* ]] && [[ "$scopes" != *"public_repo"* ]]; then
        log_warn "GitHub token may not have sufficient 'repo' scope for setting secrets."
        log_info "If you encounter permission errors, re-authenticate with: gh auth refresh -s repo"
    fi
}

# Get current git repository
get_current_repo() {
    if git remote get-url origin >/dev/null 2>&1; then
        git remote get-url origin | sed -E 's|.*github\.com[/:]([^/]+/[^/]+)(\.git)?.*|\1|'
    else
        echo ""
    fi
}

# Find .env file automatically
find_env_file() {
    # Priority order: .env.prod, .env.production, .env.local, .env
    for file in ".env.prod" ".env.production" ".env.local" ".env"; do
        if [ -f "$file" ] && [ -r "$file" ]; then
            echo "$file"
            return 0
        fi
    done
    return 1
}

# Show usage
show_usage() {
    echo "Usage: $0 [envfile] [owner/repo] [environment]"
    echo "Examples:"
    echo "  $0                          # Auto-detect .env and repo"
    echo "  $0 .env.prod                # Use specific .env file"
    echo "  $0 .env.prod myorg/myapp    # Specify .env and repo"
    echo "  $0 .env.prod myorg/myapp staging  # Include environment"
    exit 0
}

# Set GitHub secret with retry
set_secret() {
    local key="$1"
    local value="$2"
    local repo="$3"
    local environment="$4"
    local masked_value
    masked_value=$(mask_value "$value")

    local cmd="gh secret set '$key' -b'$value' --repo '$repo'"
    if [ -n "$environment" ]; then
        cmd="$cmd --env '$environment'"
    fi

    # First attempt
    if eval "$cmd" >/dev/null 2>&1; then
        log_success "Added $key (value: $masked_value)"
        return 0
    fi

    # Retry once
    log_warn "Retrying $key..."
    if eval "$cmd" >/dev/null 2>&1; then
        log_success "Added $key (value: $masked_value) [retry]"
        return 0
    fi

    log_error "Failed to add $key (value: $masked_value)"
    return 1
}

# Process .env file
process_env_file() {
    local env_file="$1"
    local repo="$2"
    local environment="$3"

    log_info "Processing .env file: $env_file"
    log_info "Target repository: $repo"
    if [ -n "$environment" ]; then
        log_info "Environment: $environment"
    else
        log_info "Setting repository-level secrets"
    fi
    echo

    # Read and process each line
    while IFS= read -r line || [ -n "$line" ]; do
        # Skip empty lines and comments
        [ -z "$line" ] && continue
        [[ "$line" =~ ^[[:space:]]*# ]] && continue
        [[ "$line" =~ ^[[:space:]]*$ ]] && continue

        # Parse KEY=VALUE
        if [[ "$line" =~ ^[[:space:]]*([A-Za-z_][A-Za-z0-9_]*)=(.*)$ ]]; then
            local key="${BASH_REMATCH[1]}"
            local value="${BASH_REMATCH[2]}"
            
            # Convert key to uppercase for GitHub Actions
            key=$(echo "$key" | tr '[:lower:]' '[:upper:]')
            
            # Validate secret name
            if ! validate_secret_name "$key"; then
                log_error "Invalid secret name: $key (must match [A-Z0-9_]+)"
                ((FAIL_COUNT++))
                continue
            fi

            # Remove surrounding quotes if present
            if [[ "$value" =~ ^\"(.*)\"$ ]] || [[ "$value" =~ ^\'(.*)\'$ ]]; then
                value="${BASH_REMATCH[1]}"
            fi

            ((TOTAL_SECRETS++))
            
            if set_secret "$key" "$value" "$repo" "$environment"; then
                ((SUCCESS_COUNT++))
            else
                ((FAIL_COUNT++))
            fi
        else
            log_warn "Skipping invalid line: $line"
        fi
    done < "$env_file"

    # Clear sensitive data from memory
    unset line key value
}

# Print final summary
print_summary() {
    echo
    log_info "=== SUMMARY ==="
    echo "Total secrets processed: $TOTAL_SECRETS"
    echo "Successfully added: $SUCCESS_COUNT"
    echo "Failed: $FAIL_COUNT"
    
    if [ $FAIL_COUNT -gt 0 ]; then
        exit 1
    fi
}

# Main execution
main() {
    check_prerequisites

    # Handle help
    if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
        show_usage
    fi

    # Auto-detect or use provided arguments
    local env_file="${1:-}"
    local repo="${2:-}"
    local environment="${3:-}"

    # Auto-detect .env file if not provided
    if [ -z "$env_file" ]; then
        if env_file=$(find_env_file); then
            log_info "Auto-detected .env file: $env_file"
        else
            log_error "No .env file found. Tried: .env.prod, .env.production, .env.local, .env"
            exit 1
        fi
    fi

    # Validate .env file
    if [ ! -f "$env_file" ] || [ ! -r "$env_file" ]; then
        log_error "Invalid or unreadable .env file: $env_file"
        exit 1
    fi

    # Auto-detect repository if not provided
    if [ -z "$repo" ]; then
        if repo=$(get_current_repo); then
            log_info "Auto-detected repository: $repo"
        else
            log_error "No git repository detected. Please specify owner/repo as second argument."
            exit 1
        fi
    fi

    process_env_file "$env_file" "$repo" "$environment"
    print_summary
}

# Execute main function with all arguments
main "$@"