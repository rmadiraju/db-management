#!/bin/bash

# Liquibase Database Deployment Script
# This script deploys database changes using Liquibase
# Simulates AWS Aurora Postgres deployment using LocalStack

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
LIQUIBASE_CONFIG="$PROJECT_ROOT/liquibase.properties"
LOG_FILE="$PROJECT_ROOT/deployment.log"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1" | tee -a "$LOG_FILE"
}

error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR:${NC} $1" | tee -a "$LOG_FILE"
    exit 1
}

warn() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARNING:${NC} $1" | tee -a "$LOG_FILE"
}

# Check prerequisites
check_prerequisites() {
    log "Checking prerequisites..."
    
    # Check if Liquibase is installed
    if ! command -v liquibase &> /dev/null; then
        error "Liquibase is not installed. Please install Liquibase first."
    fi
    
    # Check if PostgreSQL is running (LocalStack simulation)
    if ! pg_isready -h localhost -p 5432 &> /dev/null; then
        error "PostgreSQL is not running on localhost:5432. Please start LocalStack PostgreSQL."
    fi
    
    # Check if database exists
    if ! psql -h localhost -p 5432 -U postgres -d aurora_postgres_db -c "SELECT 1;" &> /dev/null; then
        error "Database 'aurora_postgres_db' does not exist. Please create it first."
    fi
    
    log "Prerequisites check passed."
}

# Validate changelog files
validate_changelog() {
    log "Validating changelog files..."
    
    # Check main changelog file
    if [ ! -f "$PROJECT_ROOT/scripts/db-changelog.xml" ]; then
        error "Main changelog file not found: scripts/db-changelog.xml"
    fi
    
    # Validate XML syntax
    if ! xmllint --noout "$PROJECT_ROOT/scripts/db-changelog.xml" 2>/dev/null; then
        error "XML syntax error in main changelog file"
    fi
    
    # Validate version-specific changelog files
    for changelog in "$PROJECT_ROOT/scripts/versions"/*/changelog-*.xml; do
        if [ -f "$changelog" ]; then
            log "Validating changelog: $(basename "$changelog")"
            if ! xmllint --noout "$changelog" 2>/dev/null; then
                error "XML syntax error in changelog: $(basename "$changelog")"
            fi
        fi
    done
    
    log "Changelog validation passed."
}

# Backup database
backup_database() {
    log "Creating database backup..."
    BACKUP_FILE="$PROJECT_ROOT/backup_$(date +%Y%m%d_%H%M%S).sql"
    
    if pg_dump -h localhost -p 5432 -U postgres aurora_postgres_db > "$BACKUP_FILE"; then
        log "Database backup created: $BACKUP_FILE"
    else
        error "Failed to create database backup"
    fi
}

# Deploy changes
deploy_changes() {
    log "Deploying database changes..."
    
    cd "$PROJECT_ROOT"
    
    # Run Liquibase update
    if liquibase --defaults-file="$LIQUIBASE_CONFIG" update; then
        log "Database changes deployed successfully."
    else
        error "Database deployment failed."
    fi
}

# Verify deployment
verify_deployment() {
    log "Verifying deployment..."
    
    # Check if all tables exist
    TABLES=("users" "products" "orders" "order_items")
    for table in "${TABLES[@]}"; do
        if psql -h localhost -p 5432 -U postgres -d aurora_postgres_db -c "SELECT 1 FROM $table LIMIT 1;" &> /dev/null; then
            log "Table '$table' exists and is accessible."
        else
            error "Table '$table' does not exist or is not accessible."
        fi
    done
    
    # Check Liquibase status
    log "Liquibase status:"
    liquibase --defaults-file="$LIQUIBASE_CONFIG" status
    
    log "Deployment verification completed."
}

# Main execution
main() {
    log "Starting Liquibase database deployment..."
    
    check_prerequisites
    validate_changelog
    backup_database
    deploy_changes
    verify_deployment
    
    log "Database deployment completed successfully!"
}

# Run main function
main "$@"
