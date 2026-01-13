#!/bin/bash
# ─────────────────────────────────────────────────────────────────────────────
# Bicep Module Publisher
# ─────────────────────────────────────────────────────────────────────────────
# Publishes Bicep modules to Azure Container Registry based on versions.json
# Skips modules where the version tag already exists (idempotent re-runs)
#
# Usage: ./scripts/publish-modules.sh
#
# Environment Variables:
#   ACR_NAME       - Azure Container Registry name (required)
#   FORCE_PUBLISH  - Set to 'true' to publish even if tag exists (optional)
# ─────────────────────────────────────────────────────────────────────────────

set -e

# Configuration
VERSIONS_FILE="modules/versions.json"
MODULES_DIR="modules"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
TOTAL=0
PUBLISHED=0
SKIPPED=0
FAILED=0

# ─────────────────────────────────────────────────────────────────────────────
# Functions
# ─────────────────────────────────────────────────────────────────────────────

log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

log_header() {
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}📦 $1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# Check if a tag exists in ACR
# Returns 0 if exists, 1 if not
check_tag_exists() {
    local repository=$1
    local tag=$2
    
    # Query ACR for existing tags
    EXISTING_TAGS=$(az acr repository show-tags \
        --name "$ACR_NAME" \
        --repository "$repository" \
        --output tsv 2>/dev/null || echo "")
    
    if echo "$EXISTING_TAGS" | grep -q "^${tag}$"; then
        return 0  # Tag exists
    else
        return 1  # Tag does not exist
    fi
}

# Publish a single module to ACR
publish_module() {
    local module_path=$1
    local version=$2
    
    # Construct paths
    local bicep_file="${MODULES_DIR}/${module_path}/main.bicep"
    local repository="bicep/modules/${module_path,,}"  # lowercase
    local target="br:${ACR_NAME}.azurecr.io/${repository}:${version}"
    
    log_header "$module_path (v$version)"
    
    # Validate bicep file exists
    if [ ! -f "$bicep_file" ]; then
        log_error "Bicep file not found: $bicep_file"
        FAILED=$((FAILED + 1))
        return 1
    fi
    
    log_info "Source: $bicep_file"
    log_info "Target: $target"
    
    # Check if tag already exists (unless force publish)
    if [ "$FORCE_PUBLISH" != "true" ]; then
        log_info "Checking if tag exists in ACR..."
        
        if check_tag_exists "$repository" "$version"; then
            log_warning "Tag '$version' already exists in repository '$repository' - SKIPPING"
            log_warning "Set FORCE_PUBLISH=true to override"
            SKIPPED=$((SKIPPED + 1))
            return 0
        else
            log_info "Tag does not exist, proceeding with publish..."
        fi
    else
        log_warning "Force publish enabled - skipping tag existence check"
    fi
    
    # Publish the module
    log_info "Publishing module..."
    
    if az bicep publish \
        --file "$bicep_file" \
        --target "$target" \
        --force 2>&1; then
        log_success "Successfully published: $target"
        PUBLISHED=$((PUBLISHED + 1))
        return 0
    else
        log_error "Failed to publish: $target"
        FAILED=$((FAILED + 1))
        return 1
    fi
}

# ─────────────────────────────────────────────────────────────────────────────
# Main Script
# ─────────────────────────────────────────────────────────────────────────────

echo ""
echo "╔══════════════════════════════════════════════════════════════════════╗"
echo "║           Bicep Module Publisher - Azure Container Registry          ║"
echo "╚══════════════════════════════════════════════════════════════════════╝"
echo ""

# Validate environment
if [ -z "$ACR_NAME" ]; then
    log_error "ACR_NAME environment variable is not set"
    exit 1
fi

log_info "ACR Name: $ACR_NAME"
log_info "Force Publish: ${FORCE_PUBLISH:-false}"

# Validate versions.json exists
if [ ! -f "$VERSIONS_FILE" ]; then
    log_error "Versions file not found: $VERSIONS_FILE"
    exit 1
fi

log_info "Versions file: $VERSIONS_FILE"

# Parse versions.json and iterate over modules
# Extract module paths (keys) excluding _comment
MODULE_KEYS=$(jq -r 'keys[] | select(. != "_comment")' "$VERSIONS_FILE")

if [ -z "$MODULE_KEYS" ]; then
    log_warning "No modules found in versions.json"
    exit 0
fi

# Process each module
while IFS= read -r module_path; do
    TOTAL=$((TOTAL + 1))
    
    # Get version for this module
    VERSION=$(jq -r --arg key "$module_path" '.[$key].version' "$VERSIONS_FILE")
    
    if [ -z "$VERSION" ] || [ "$VERSION" = "null" ]; then
        log_error "No version found for module: $module_path"
        FAILED=$((FAILED + 1))
        continue
    fi
    
    # Publish the module
    publish_module "$module_path" "$VERSION" || true
    
done <<< "$MODULE_KEYS"

# ─────────────────────────────────────────────────────────────────────────────
# Summary
# ─────────────────────────────────────────────────────────────────────────────

echo ""
echo "╔══════════════════════════════════════════════════════════════════════╗"
echo "║                           Publish Summary                            ║"
echo "╚══════════════════════════════════════════════════════════════════════╝"
echo ""
echo "  Total modules:  $TOTAL"
echo "  ✅ Published:   $PUBLISHED"
echo "  ⚠️  Skipped:     $SKIPPED (version already exists)"
echo "  ❌ Failed:      $FAILED"
echo ""

# Exit with error if any failures
if [ $FAILED -gt 0 ]; then
    log_error "Some modules failed to publish"
    exit 1
fi

if [ $PUBLISHED -gt 0 ]; then
    log_success "All new modules published successfully!"
elif [ $SKIPPED -eq $TOTAL ]; then
    log_info "All modules already published - nothing to do"
fi

exit 0
