#!/bin/bash

# Liquibase Database Script Validation Script
# This script validates Liquibase changelog files for syntax, structure, and best practices
# Simulates AWS Aurora Postgres validation using LocalStack

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
LOG_FILE="$PROJECT_ROOT/validation.log"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1" | tee -a "$LOG_FILE"
}

error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR:${NC} $1" | tee -a "$LOG_FILE"
}

warn() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARNING:${NC} $1" | tee -a "$LOG_FILE"
}

info() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')] INFO:${NC} $1" | tee -a "$LOG_FILE"
}

# Validation counters
TOTAL_CHECKS=0
PASSED_CHECKS=0
FAILED_CHECKS=0
WARNING_CHECKS=0

# Increment counters
increment_total() { ((TOTAL_CHECKS++)); }
increment_passed() { ((PASSED_CHECKS++)); }
increment_failed() { ((FAILED_CHECKS++)); }
increment_warning() { ((WARNING_CHECKS++)); }

# Check XML syntax
validate_xml_syntax() {
    local changelog_file="$1"
    local changelog_name="$(basename "$changelog_file")"
    
    log "Validating XML syntax for: $changelog_name"
    increment_total
    
    # Check if xmllint is available
    if ! command -v xmllint &> /dev/null; then
        warn "xmllint not available, skipping XML syntax validation"
        increment_warning
        return 0
    fi
    
    # Validate XML syntax
    if xmllint --noout "$changelog_file" 2>/dev/null; then
        log "✓ XML syntax validation passed for: $changelog_name"
        increment_passed
    else
        error "✗ XML syntax validation failed for: $changelog_name"
        increment_failed
        return 1
    fi
}

# Check Liquibase schema validation
validate_liquibase_schema() {
    local changelog_file="$1"
    local changelog_name="$(basename "$changelog_file")"
    
    log "Validating Liquibase schema for: $changelog_name"
    increment_total
    
    # Check if Liquibase is available
    if ! command -v liquibase &> /dev/null; then
        warn "Liquibase not available, skipping schema validation"
        increment_warning
        return 0
    fi
    
    # Validate against Liquibase schema
    if liquibase --changeLogFile="$changelog_file" validate 2>/dev/null; then
        log "✓ Liquibase schema validation passed for: $changelog_name"
        increment_passed
    else
        error "✗ Liquibase schema validation failed for: $changelog_name"
        increment_failed
        return 1
    fi
}

# Check changeset naming conventions
validate_changeset_naming() {
    local changelog_file="$1"
    local changelog_name="$(basename "$changelog_file")"
    
    log "Validating changeset naming for: $changelog_name"
    increment_total
    
    local issues=0
    
    # Check for proper changeset IDs
    if grep -q 'id="[0-9]\+\.[0-9]\+-[0-9]\+"' "$changelog_file"; then
        log "✓ Changeset ID format validation passed for: $changelog_name"
        increment_passed
    else
        error "✗ Changeset ID format validation failed for: $changelog_name (should be version-number format)"
        increment_failed
        ((issues++))
    fi
    
    # Check for author attribute
    if grep -q 'author="[^"]*"' "$changelog_file"; then
        log "✓ Author attribute validation passed for: $changelog_name"
        increment_passed
    else
        error "✗ Author attribute validation failed for: $changelog_name (missing author)"
        increment_failed
        ((issues++))
    fi
    
    return $issues
}

# Check for best practices
validate_best_practices() {
    local changelog_file="$1"
    local changelog_name="$(basename "$changelog_file")"
    
    log "Validating best practices for: $changelog_name"
    increment_total
    
    local issues=0
    
    # Check for comments in changesets
    if grep -q '<comment>' "$changelog_file"; then
        log "✓ Changeset comments found in: $changelog_name"
        increment_passed
    else
        warn "⚠ Missing changeset comments in: $changelog_name"
        increment_warning
        ((issues++))
    fi
    
    # Check for rollback statements
    if grep -q '<rollback>' "$changelog_file"; then
        log "✓ Rollback statements found in: $changelog_name"
        increment_passed
    else
        warn "⚠ Missing rollback statements in: $changelog_name"
        increment_warning
        ((issues++))
    fi
    
    # Check for constraints in CREATE TABLE
    if grep -q '<createTable>' "$changelog_file" && grep -q '<constraints' "$changelog_file"; then
        log "✓ Table constraints found in: $changelog_name"
        increment_passed
    else
        warn "⚠ Missing table constraints in: $changelog_name"
        increment_warning
        ((issues++))
    fi
    
    return $issues
}

# Check for security issues
validate_security() {
    local changelog_file="$1"
    local changelog_name="$(basename "$changelog_file")"
    
    log "Validating security for: $changelog_name"
    increment_total
    
    local issues=0
    
    # Check for hardcoded passwords in SQL
    if grep -qi "password.*=.*['\"].*['\"]" "$changelog_file"; then
        error "✗ Hardcoded password detected in: $changelog_name"
        increment_failed
        ((issues++))
    else
        log "✓ No hardcoded passwords in: $changelog_name"
        increment_passed
    fi
    
    # Check for DROP statements
    if grep -qi "<drop" "$changelog_file"; then
        warn "⚠ DROP statement detected in: $changelog_name (review for safety)"
        increment_warning
        ((issues++))
    fi
    
    # Check for GRANT statements
    if grep -qi "GRANT " "$changelog_file"; then
        warn "⚠ GRANT statement detected in: $changelog_name (review permissions)"
        increment_warning
        ((issues++))
    fi
    
    return $issues
}

# Validate individual changelog file
validate_changelog() {
    local changelog_file="$1"
    
    if [ ! -f "$changelog_file" ]; then
        error "Changelog file not found: $changelog_file"
        return 1
    fi
    
    info "Starting validation for: $(basename "$changelog_file")"
    
    local total_issues=0
    
    validate_xml_syntax "$changelog_file" || ((total_issues++))
    validate_liquibase_schema "$changelog_file" || ((total_issues++))
    validate_changeset_naming "$changelog_file" || ((total_issues++))
    validate_best_practices "$changelog_file" || ((total_issues++))
    validate_security "$changelog_file" || ((total_issues++))
    
    if [ $total_issues -eq 0 ]; then
        log "✓ All validations passed for: $(basename "$changelog_file")"
    else
        warn "⚠ $total_issues validation issues found in: $(basename "$changelog_file")"
    fi
    
    return $total_issues
}

# Validate all changelog files
validate_all_changelogs() {
    log "Validating all Liquibase changelog files"
    
    local failed_changelogs=0
    
    # Validate main changelog
    validate_changelog "$PROJECT_ROOT/scripts/db-changelog.xml" || ((failed_changelogs++))
    
    # Validate version-specific changelogs
    for changelog in "$PROJECT_ROOT/scripts/versions"/*/changelog-*.xml; do
        if [ -f "$changelog" ]; then
            validate_changelog "$changelog" || ((failed_changelogs++))
        fi
    done
    
    # Validate DML changelogs
    for changelog in "$PROJECT_ROOT/scripts/dml"/*.xml; do
        if [ -f "$changelog" ]; then
            validate_changelog "$changelog" || ((failed_changelogs++))
        fi
    done
    
    if [ $failed_changelogs -eq 0 ]; then
        log "✓ All changelog files passed validation"
    else
        error "✗ $failed_changelogs changelog files failed validation"
    fi
    
    return $failed_changelogs
}

# Print validation summary
print_summary() {
    log "Validation Summary:"
    log "Total checks: $TOTAL_CHECKS"
    log "Passed: $PASSED_CHECKS"
    log "Failed: $FAILED_CHECKS"
    log "Warnings: $WARNING_CHECKS"
    
    if [ $FAILED_CHECKS -eq 0 ]; then
        log "✓ All validations completed successfully!"
        return 0
    else
        error "✗ Validation completed with $FAILED_CHECKS failures"
        return 1
    fi
}

# Main execution
main() {
    log "Starting Liquibase changelog validation..."
    
    # Check prerequisites
    if ! command -v psql &> /dev/null; then
        error "PostgreSQL client (psql) is not installed"
        exit 1
    fi
    
    if ! pg_isready -h localhost -p 5432 &> /dev/null; then
        error "PostgreSQL is not running on localhost:5432"
        exit 1
    fi
    
    # Validate all changelogs
    validate_all_changelogs
    
    # Print summary
    print_summary
}

# Run main function
main "$@"
