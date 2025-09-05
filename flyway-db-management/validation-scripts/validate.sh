#!/bin/bash

# Database Script Validation Script
# This script validates SQL scripts for syntax, naming conventions, and best practices
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

# Check SQL syntax
validate_syntax() {
    local script_file="$1"
    local script_name="$(basename "$script_file")"
    
    log "Validating syntax for: $script_name"
    increment_total
    
    # Check if PostgreSQL can parse the script
    if psql -h localhost -p 5432 -U postgres -d aurora_postgres_db --dry-run -f "$script_file" &> /dev/null; then
        log "✓ Syntax validation passed for: $script_name"
        increment_passed
    else
        error "✗ Syntax validation failed for: $script_name"
        increment_failed
        return 1
    fi
}

# Check naming conventions
validate_naming_conventions() {
    local script_file="$1"
    local script_name="$(basename "$script_file")"
    
    log "Validating naming conventions for: $script_name"
    increment_total
    
    local issues=0
    
    # Check Flyway naming convention (V{version}__{description}.sql)
    if [[ "$script_name" =~ ^V[0-9]+\.[0-9]+__.*\.sql$ ]]; then
        log "✓ Flyway naming convention passed for: $script_name"
        increment_passed
    else
        error "✗ Flyway naming convention failed for: $script_name (should be V{version}__{description}.sql)"
        increment_failed
        ((issues++))
    fi
    
    # Check for reserved keywords in table/column names
    local reserved_keywords=("order" "user" "group" "select" "from" "where" "table" "database")
    for keyword in "${reserved_keywords[@]}"; do
        if grep -qi "CREATE TABLE.*$keyword" "$script_file"; then
            warn "⚠ Potential reserved keyword usage in: $script_name (keyword: $keyword)"
            increment_warning
        fi
    done
    
    return $issues
}

# Check for best practices
validate_best_practices() {
    local script_file="$1"
    local script_name="$(basename "$script_file")"
    
    log "Validating best practices for: $script_name"
    increment_total
    
    local issues=0
    
    # Check for IF NOT EXISTS in CREATE TABLE
    if grep -q "CREATE TABLE" "$script_file" && ! grep -q "IF NOT EXISTS" "$script_file"; then
        warn "⚠ Missing 'IF NOT EXISTS' in CREATE TABLE statement: $script_name"
        increment_warning
        ((issues++))
    fi
    
    # Check for primary keys
    if grep -q "CREATE TABLE" "$script_file" && ! grep -q "PRIMARY KEY" "$script_file"; then
        error "✗ Missing PRIMARY KEY in CREATE TABLE statement: $script_name"
        increment_failed
        ((issues++))
    else
        log "✓ PRIMARY KEY found in: $script_name"
        increment_passed
    fi
    
    # Check for timestamps
    if grep -q "CREATE TABLE" "$script_file" && ! grep -q "created_at\|updated_at" "$script_file"; then
        warn "⚠ Missing timestamp columns (created_at/updated_at) in: $script_name"
        increment_warning
        ((issues++))
    fi
    
    # Check for comments
    if grep -q "CREATE TABLE" "$script_file" && ! grep -q "COMMENT ON" "$script_file"; then
        warn "⚠ Missing table/column comments in: $script_name"
        increment_warning
        ((issues++))
    fi
    
    return $issues
}

# Check for security issues
validate_security() {
    local script_file="$1"
    local script_name="$(basename "$script_file")"
    
    log "Validating security for: $script_name"
    increment_total
    
    local issues=0
    
    # Check for hardcoded passwords
    if grep -qi "password.*=.*['\"].*['\"]" "$script_file"; then
        error "✗ Hardcoded password detected in: $script_name"
        increment_failed
        ((issues++))
    else
        log "✓ No hardcoded passwords in: $script_name"
        increment_passed
    fi
    
    # Check for DROP statements
    if grep -qi "DROP " "$script_file"; then
        warn "⚠ DROP statement detected in: $script_name (review for safety)"
        increment_warning
        ((issues++))
    fi
    
    # Check for GRANT statements
    if grep -qi "GRANT " "$script_file"; then
        warn "⚠ GRANT statement detected in: $script_name (review permissions)"
        increment_warning
        ((issues++))
    fi
    
    return $issues
}

# Validate individual script
validate_script() {
    local script_file="$1"
    
    if [ ! -f "$script_file" ]; then
        error "Script file not found: $script_file"
        return 1
    fi
    
    info "Starting validation for: $(basename "$script_file")"
    
    local total_issues=0
    
    validate_syntax "$script_file" || ((total_issues++))
    validate_naming_conventions "$script_file" || ((total_issues++))
    validate_best_practices "$script_file" || ((total_issues++))
    validate_security "$script_file" || ((total_issues++))
    
    if [ $total_issues -eq 0 ]; then
        log "✓ All validations passed for: $(basename "$script_file")"
    else
        warn "⚠ $total_issues validation issues found in: $(basename "$script_file")"
    fi
    
    return $total_issues
}

# Validate all scripts in directory
validate_directory() {
    local directory="$1"
    local script_type="$2"
    
    log "Validating all $script_type scripts in: $directory"
    
    local failed_scripts=0
    
    for script in "$directory"/*.sql; do
        if [ -f "$script" ]; then
            validate_script "$script" || ((failed_scripts++))
        fi
    done
    
    if [ $failed_scripts -eq 0 ]; then
        log "✓ All $script_type scripts passed validation"
    else
        error "✗ $failed_scripts $script_type scripts failed validation"
    fi
    
    return $failed_scripts
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
    log "Starting database script validation..."
    
    # Check prerequisites
    if ! command -v psql &> /dev/null; then
        error "PostgreSQL client (psql) is not installed"
        exit 1
    fi
    
    if ! pg_isready -h localhost -p 5432 &> /dev/null; then
        error "PostgreSQL is not running on localhost:5432"
        exit 1
    fi
    
    # Validate DDL scripts
    validate_directory "$PROJECT_ROOT/scripts/ddl" "DDL"
    
    # Validate DML scripts
    validate_directory "$PROJECT_ROOT/scripts/dml" "DML"
    
    # Print summary
    print_summary
}

# Run main function
main "$@"
